function [EF_mean, TFRs, EF_count, Fs, timeVec,EF_output]=inverse_get_EF_fif(inputname,Trigger,Chans,TimeInt,freqVec,Width,TimeExtr,varargin) 
% function inverse_get_EF_fif(INPUTNAME,TRIGGER,CHANS,TIMEINT,FREQVEC,WIDTH,TIMEEXTR) 
%
% Calculate the time-frequency representation of a Neuromag fif-file with 
% respect to the TRIGGER. A wavelet method is used.  
% The files are saved in Matlab format.  
%
% INPUTNAME  : A rawdata fiffile. Include directory is necessary. 
% TRIGGER    : Trigger for used for averaging
% CHANS      : Channels for which to calculated plf (numbered 1 to 306) 
% TIMEINT    : Timeinterval (sec) for which to calculate ER,
%              with respect to the TRIGGER e.g [-0.1 0.5]
% FREQVEC    : Frequency vector over which to calc (Hz)., e.g. 20:2:60;
% WIDTH      : Width of Morlet wavelet (>= 5 ) e.g. 7.
% TIMEEXTR   : (OPTIONAL) Timeinterval for when to extract
%              from raw data (sec) e.g.  [0 60]
%
%------------------------------------------------------------------------
% Ole Jensen, Brain Resarch Unit, Low Temperature Laboratory,
% Helsinki University of Technology, 02015 HUT, Finland,
% Report bugs to ojensen@neuro.hut.fi
%------------------------------------------------------------------------
%    Copyright (C) 2000 by Ole Jensen 
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You can find a copy of the GNU General Public License
%    along with this package (4DToolbox); closf not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% steve stufflebeam @ feb. 2002
%
% fa-hsuan lin @ june 2002
%------------------------------------------------------------------------
% The file InitParam.txt contains a set of parameters which have to 
% be defined prior to the analysis. In this file the variables for EOG 
% threshold, SSP etc are defined. 
%------------------------------------------------------------------------

InitParam=readInitParam('InitParam.txt');

iop=[];
iop_output='raw';
bad_channel=[];
mode='raw';

phase_chanref=[];
phase_chans=[];
phase_dipoleref=[];


flag_meg=1;
flag_eeg=0;


EF_count=0;
EF_mean=[];
X_mean=[];
TFRs=[];

X_orig=[];
X_trans=[];
TFR_orig=[];
TFR_trans=[];

rowMEG=[1:306];		%default 306 channel MEG
rowEEG=[307:370];	%default 64 channel EEG

Fs=[];
timeVec=0;
vararginout={};

tPre_stim=[];

ref=[];
ref_chan=[];
ref_dec_dip=[];
ref_dec_dip_norm=[];
ref_dec_dip_hemi=[];

inverse_mode='mne';

A_reg=[];
A_reg_rank=[];
A_reg_u=[];
A=[];

x_mne_orientation=[];
mce_weight=[];
X_mne=[];
W_mne=[];
flag_estimate_orientation=1;
flag_display=0;
flag_collapse_A_reg=1;


flag_filter_raw=0;
filter_raw_B=1;
filter_raw_A=1;


flag_cov_full=0;
cov_full_half_length=0; %in terms of decimated samples

flag_decimate=0;
decimate_factor=[];

estimate_time=[];

nperdip=3;
ssp_rank=[];
time_zero=[];

flag_auto_reject=1;
flag_finalize=1;

subtract_evoked_response_data=[];
subtract_evoked_response_timeVec=[];

if(nargin>7)
    for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
        
        switch lower(option)
        case 'iop'
            iop=option_value;
        case 'iop_output'
            iop_output=option_value;
        case 'bad_channel'
            bad_channel=option_value;
        case 'phase_chanref'
            phase_chanref=option_value;
        case 'phase_dipoleref'
            phase_dipoleref=option_value;
        case 'phase_chans'
            phase_chans=option_value;
        case 'mode'
            mode=option_value;
        case 'flag_meg'
            flag_meg=option_value;
        case 'flag_eeg'
            flag_eeg=option_value;
        case 'rowmeg'
            rowMEG=option_value;
        case 'roweeg'
            rowEEG=option_value;
        case 'ef_mean'
            EF_mean=option_value;
        case 'fs'
            Fs=option_value;
        case 'tpre_stim'
            tPre_stim=option_value;
	case 'estimate_time'
	    estimate_time=option_value;
        case 'ref'
            ref=option_value;
        case 'ref_chan'
            ref_chan=option_value;
        case 'ref_dec_dip'
            ref_dec_dip=option_value;
        case 'ref_dec_dip_norm'
            ref_dec_dip_norm=option_value;
        case 'ref_dec_dip_hemi'
            ref_dec_dip_hemi=option_value;
        case 'inverse_mode'
            inverse_mode=option_value;
        case 'a_reg'
            A_reg=option_value;
        case 'a_reg_rank'
            A_reg_rank=option_value;
        case 'a_reg_u'
            A_reg_u=option_value;
        case 'a'
            A=option_value;
        case 'x_mne_orientation'
            x_mne_orientation=option_value;
        case 'mce_weight'
            mce_weight=option_value;
        case 'x_mne'
            X_mne=option_value;
        case 'w_mne'
            W_mne=option_value;
        case 'flag_estimate_orientation'
            flag_estimate_orientation=option_value;           
        case 'flag_display'
            flag_display=option_value;
        case 'flag_collapse_a_reg'
            flag_collapse_A_reg=option_value;
	case 'flag_filter_raw'
		flag_filter_raw=option_value;
	case 'filter_raw_a'
		filter_raw_A=option_value;
	case 'filter_raw_b'
		filter_raw_B=option_value;
	case 'flag_cov_full'
		flag_cov_full=option_value;
	case 'cov_full_half_length'
		cov_full_half_length=option_value;
	case 'flag_decimate'
		flag_decimate=option_value;
	case 'decimate_factor'
		decimate_factor=option_value;
	case 'flag_auto_reject'
		flag_auto_reject=option_value;
	case 'flag_finalize'
		flag_finalize=option_value;
	case 'nperdip'
		nperdip=option_value;
	case 'ssp_rank'
		ssp_rank=option_value;
	case 'subtract_evoked_response_data'
		subtract_evoked_response_data=option_value;
	case 'subtract_evoked_response_timevec'
		subtract_evoked_response_timeVec=option_value;
	case 'time_zero'
		time_zero=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('exit!\n');
            return;
        end;
    end;
end;


if(~isempty(EF_mean))
    fprintf('Using provided trigger-averaged response!\n');
    EF_count=0;	%skipping the number of trial averaged
    
    for m=1:length(freqVec)
        fprintf('wavelet...');
        
        if((~flag_meg)&(flag_eeg)) 
            %TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowEEG(Chans),:),Fs,Width);
			TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean,Fs,Width);
        end;
        if((flag_meg)&(~flag_eeg)) 
            %TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowMEG(Chans),:),Fs,Width);
			TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean,Fs,Width);
        end;
        if((flag_meg)&(flag_eeg)) 
            %rowMEGEEG=[rowMEG; rowEEG];
            %TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowMEGEEG(Chans),:),Fs,Width);
			TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean,Fs,Width);
        end;
        
        tfr=squeeze(TFR(m,:,:));
        tfr(bad_channel,:)=[];
 
        %preparation of reference channel for phase synchronization
        % no phase synchronization for trigger averaged data!
        if((isempty(ref))&(~isempty(freqVec)))
            ref=cos([0:size(EF_mean,2)-1]./Fs.*2.*pi.*freqVec(1))+sqrt(-1.0).*sin([0:size(EF_mean,2)-1]./Fs.*2.*pi.*freqVec(1));
        end;
        rr=inverse_waveletcoef(freqVec(m),ref,Fs,Width)';
        
        %if(~isempty(iop));
            
            [tfr_trans,X_orig,X_trans]=get_wavelet(tfr,bad_channel,iop,iop_output,rr,'A_reg',A_reg,'A_reg_u',A_reg_u,'A_reg_rank',A_reg_rank,'x_mne_orientation',x_mne_orientation,'mce_weight',mce_weight,'X_mne',X_orig,'flag_estimate_orientation',flag_estimate_orientation,'flag_display',flag_display,'inverse_mode',inverse_mode,'flag_collapse_A_reg',flag_collapse_A_reg,'nperdip',nperdip);
            
        %end;
        
        TFRs=tfr;
        X_mean=X_trans;
    end;
    
    EF_output{1}=EF_mean;
    fprintf('output[1]: Evoked field.\n');
    
    EF_output{2}=[];
    fprintf('output[2]: variance of evoked field.\n');
    
    EF_output{3}=X_trans;
    fprintf('output[3]: averaged transformed dipole estimates in wavelet domain.\n');
    
    EF_output{4}=[];
    fprintf('output[4]: variance of transformed dipole estimates in wavelet domain.\n');
    
    EF_output{5}=tfr_trans;
    fprintf('output[5]: averaged transformed sensor data in wavelet domain.\n');
    
    EF_output{6}=[];
    fprintf('output[6]: variance of transformed sensor data in wavelet domain.\n');
    
    EF_output{7}=1;
    fprintf('output[7]: number of trials averaged.\n');
    
    return;
end;


%------------------------------------------------------------------------
%  Initialize variables/open fiff file
%------------------------------------------------------------------------
tPre = -TimeInt(1);
tPost = TimeInt(2);    

tStart=0;
tStop=inf;
if (exist('TimeExtr'))
    if(~isempty(TimeExtr))
        tStart = TimeExtr(1);
        tStop  = TimeExtr(2);
    end;
end

[Fs,rowMEG,rowEOG,rowTRIG,rowEEG,rowMISC,ST] = fiffSetup(inputname);
Fs_orig=Fs;
fprintf('Types of channels: MEG=%d EOG=%d TRIG=%d EEG=%d MISC=%d\n',length(rowMEG),length(rowEOG),length(rowTRIG),length(rowEEG),length(rowMISC));
if(strcmp(mode,'raw')|strcmp(mode,'evoke'))
    fprintf('un-averaged raw FIF file...\n');
    
    if isempty(ST)
        if InitParam.applySSP
            fprintf('No SSP transformation available - SSP turned off\n');
            InitParam.applySSP = 0;
        end
    else
        if InitParam.applySSP
            fprintf('SSP applied\n');
        else
            fprintf('SSP transformation available, but SSP is NOT applied\n');
        end
    end
    
    ChNames = channames(inputname);
    
    
    tCurrent = tStart; 
    TrigThres = 2; 
    rawdata('any',inputname);                    
    
    colPre    = floor(Fs*tPre);
    colPost   = floor(Fs*tPost);  
    
    Trials = 0;   
    EOGrej = 0;
    Frej = 0;
    DFDTrej = 0;
    
    t = rawdata('goto',tStart);
    [B,status]=rawdata('next');
    while strcmp(status,'skip')
        [B,status]=rawdata('next');
    end
    
    BPre  = zeros(size(B,1),colPre);  
    BPost = zeros(size(B,1),colPost); 
    colB = size(B,2); 
    colTRACE = colB+colPre+colPost;
    TRACE = zeros(size(B,1),colTRACE); 
	
else
    status='ok';
end;

%------------------------------------------------------------------------
% Read chunks of fif file and calculate the ERP
%------------------------------------------------------------------------


fprintf('Reading trial\n');


if(strcmp(iop_output,'phase'))
    if(isempty(phase_chans))
        if((~flag_meg)&(flag_eeg)) 
            phase_chans=rowEEG(Chans);
        end;
        if((flag_meg)&(~flag_eeg)) 
            phase_chans=rowMEG(Chans);
        end;
        if((flag_meg)&(flag_eeg)) 
            rowMEGEEG=[rowMEG; rowEEG];
            phase_chans=rowMEGEEG(Chans);
        end;
        
    end;
    %TFR=zeros(length(freqVec),length(phase_chans),colPre+colPost+2); 
else
    TFRs=[];
    tCurrent=0.0;
    tStop=Inf;
end;




while strcmp(status,'ok') & tCurrent < tStop 
	Fs=Fs_orig;
    if(strcmp(mode,'raw')|strcmp(mode,'evoke'))

        colB = size(B,2); 
        TRACE(:,1:colTRACE-colB)  = TRACE(:,colB+1:colTRACE);
        TRACE(:,colTRACE-colB+1:colTRACE)  = B;
        TrigList = findTrigger(TRACE(rowTRIG,colPre+1:colPre+colB),Trigger,TrigThres);
        
        for k=1:length(TrigList)
            if colPre+TrigList(k)+colPost <= size(TRACE,2)  
                
                traceOK = 1;
                if((flag_meg)&(~flag_eeg)) 
                    Ttmp = TRACE(rowMEG,TrigList(k):colPre+TrigList(k)+colPost+1);
                end;
                if((~flag_meg)&(flag_eeg)) 
                    Ttmp = TRACE(rowEEG,TrigList(k):colPre+TrigList(k)+colPost+1);
                end;
                if((flag_meg)&(flag_eeg)) 
                    Ttmp = TRACE([rowMEG; rowEEG],TrigList(k):colPre+TrigList(k)+colPost+1);
                end;

                timeVec=[0:(size(Ttmp,2)-1)]./Fs+min(TimeInt);
                
                Ttmp = detrend(Ttmp','constant')';
                
                if(~isempty(ssp_rank))
                	[uu,ss,vv]=svds(Ttmp,ssp_rank);
                	Ttmp=Ttmp-uu*ss*vv';
                end;

                if(~isempty(time_zero))
                	idx=find(timeVec>min(time_zero)&timeVec<max(time_zero));
                	Ttmp(:,idx)=0;
                	
                	if(~isempty(subtract_evoked_response_data))
			    if(~isempty(subtract_evoked_response_timeVec))
				if((subtract_evoked_response_timeVec(1)==timeVec(1))&(subtract_evoked_response_timeVec(end)==timeVec(end)))
				    	subtract_evoked_response_data(:,idx)=0;
				end;	    	
			    end
			end;
                end;

                if InitParam.applySSP
                    Ttmp = ST*Ttmp;
                end
                
                good_channel=setdiff([1:size(Ttmp,1)],bad_channel);
		if(flag_auto_reject)
			[tmpVal,dFmaxCh] = max(max(diff(abs(Ttmp(good_channel,:)'))));
			DFDTmax = 1e13*tmpVal/(1/Fs);
		else
			DFDTmax=0.0;
		end;
                
                if(flag_auto_reject)
			[tmpVal,FmaxCh] = max(max(abs(Ttmp(good_channel,:)')));
			Fmax = 2*1e13*tmpVal;
		else
			Fmax=0.0;
		end;
                
                
                traceOK = 1;
                if DFDTmax > InitParam.DFDTreject 
                    DFDTrej = DFDTrej + 1;
                    fprintf('Reject:%s(dF) -\n',char(ChNames(dFmaxCh)));
                    traceOK = 0;
                end
                
                if Fmax > InitParam.Freject 
                    Frej = Frej + 1;
                    fprintf('Reject:%s(F)-\n',char(ChNames(FmaxCh)));
                    traceOK = 0;
                end
                
                if ~isempty(rowEOG)
                    EOGtmp = TRACE(rowEOG,TrigList(k):colPre+TrigList(k)+colPost-1);
			for l=1:size(EOGtmp,1)
				if(flag_auto_reject)
					EOGd = detrend(EOGtmp(l,:));
					if 1e6*(max(EOGd) - min(EOGd)) > InitParam.EOGreject
						EOGrej = EOGrej + 1;
						fprintf('Reject:EOG-\n');
						traceOK = 0;
					end
				end
			end
                end
                
                if traceOK
                    
                    fprintf('Trial [%d]..',EF_count);
                    
                    if(isempty(EF_mean))
                        if((flag_meg)&(~flag_eeg)) 
                            EF_mean=Ttmp(rowMEG(Chans),:);
                        end;
                        if((~flag_meg)&(flag_eeg)) 
                            EF_mean=Ttmp(rowEEG(Chans),:);
                        end;
                        if((flag_meg)&(flag_eeg)) 
                            rowMEGEEG=[rowMEG; rowEEG];
                            EF_mean=Ttmp(rowMEGEEG(Chans),:);
                        end;
                    else
                        if((flag_meg)&(~flag_eeg)) 
                            EF_mean=(EF_mean.*EF_count+Ttmp(rowMEG(Chans),:))./(EF_count+1);
                        end;
                        if((~flag_meg)&(flag_eeg)) 
                            EF_mean=(EF_mean.*EF_count+Ttmp(rowEEG(Chans),:))./(EF_count+1);
                        end;
                        if((flag_meg)&(flag_eeg)) 
                            rowMEGEEG=[rowMEG; rowEEG];
                            EF_mean=(EF_mean.*EF_count+Ttmp(rowMEGEEG(Chans),:))./(EF_count+1);
                        end;
                    end;
                    
                    if((flag_meg)&(~flag_eeg)) 
                        Ttmp(rowMEG(Chans),:) = detrend(Ttmp(rowMEG(Chans),:)')';
                    end;
                    if((~flag_meg)&(flag_eeg)) 
                        Ttmp(rowEEG(Chans),:) = detrend(Ttmp(rowEEG(Chans),:)')';
                    end;
                    if((flag_meg)&(flag_eeg)) 
                        rowMEGEEG=[rowMEG; rowEEG];
                        Ttmp(rowMEGEEG(Chans),:) = detrend(Ttmp(rowMEGEEG(Chans),:)')';
                    end;


		    if(flag_filter_raw)
			fprintf('fitlering raw epoch (only FIR filter)...\n');
			Ttmp=fft_conv2(Ttmp,filter_raw_B,'same');
		    end;

		    if(flag_decimate)
			fprintf('decimating by skipping [%d] samples...\n',decimate_factor);
			Ttmp=Ttmp(:,1:decimate_factor:end);
			Fs=Fs/decimate_factor;
			timeVec=timeVec(1:decimate_factor:end);
		    end;
                    
		    if(~isempty(estimate_time))
			for i=1:length(estimate_time)
			    [dummy,estimate_time_idx(i)]=min(abs(timeVec-estimate_time(i)));
			end;
		    else
			estimate_time_idx=[];
		    end;


		    if(~isempty(subtract_evoked_response_data))
			    if(~isempty(subtract_evoked_response_timeVec))
				if((subtract_evoked_response_timeVec(1)==timeVec(1))&(subtract_evoked_response_timeVec(end)==timeVec(end)))
					fprintf('subtracting evoked response....\n');
				    	Ttmp=Ttmp-subtract_evoked_response_data;
				else
					fprintf('no subtracting evoked response! timeVec mismatches!....\n');
				end;	    	
			    else
			    	if(size(Ttmp)==size(subtract_evoked_response_data))
				    	fprintf('subtracting evoked response....\n');
				    	Ttmp=Ttmp-subtract_evoked_response_data;
				end;			 
			    end
		    end;

		 
                    tPre_stim_idx=[1:length(timeVec)];
                    
               
                    
                    if(~isempty(freqVec))
                        for m=1:length(freqVec)
                            fprintf('wavelet...');
                            
                            if((~flag_meg)&(flag_eeg)) 
                                TFR(m,:,:) = inverse_waveletcoef(freqVec(m),Ttmp(rowEEG(Chans),:),Fs,Width);
                                EF_st=Ttmp(rowEEG(Chans),:);
                            end;
                            if((flag_meg)&(~flag_eeg)) 
                                TFR(m,:,:) = inverse_waveletcoef(freqVec(m),Ttmp(rowMEG(Chans),:),Fs,Width);
                                EF_st=Ttmp(rowMEG(Chans),:);
                            end;
                            if((flag_meg)&(flag_eeg)) 
                                rowMEGEEG=[rowMEG; rowEEG];
                                TFR(m,:,:) = inverse_waveletcoef(freqVec(m),Ttmp(rowMEGEEG(Chans),:),Fs,Width);
                                EF_st=Ttmp(rowMEGEEG(Chans),:);
                            end;
                            
                            
                            TFR_orig_st=squeeze(TFR(m,:,:));
                            TFR_orig_st(bad_channel,:)=[];
                            
                            EF_st(bad_channel,:)=[];
                            
                            %preparation of reference channel for phase synchronization
                            if(strcmp(iop_output,'phase')|strcmp(iop_output,'coh'))
                                if(isempty(ref))
                                    if(~isempty(ref_chan)) %reference from a channel on sensor space
                                        fprintf('[%d|%d] chan as reference...',ref_chan,size(TFR_orig_st,1));
                                        rref=TFR_orig_st(ref_chan,:);
                                    elseif(~isempty(ref_dec_dip))
                                        rref=[];
                                    else
                                        rref=cos([0:colPre+colPost+1]./Fs.*2.*pi.*freqVec(m))+sqrt(-1.0).*sin([0:colPre+colPost+1]./Fs.*2.*pi.*freqVec(m));
                                    end;
                                end;
                                if(~isempty(rref))
                                    rr=inverse_waveletcoef(freqVec(m),rref,Fs,Width)';
                                else
                                    rr=[];
                                end;
                            else
                                rr=[];
                            end;
                        end;
		     else
			fprintf('not frequency analysis...\n');
				if((~flag_meg)&(flag_eeg)) 
					TFR = Ttmp(rowEEG(Chans),:);
					EF_st=Ttmp(rowEEG(Chans),:);
				end;
				if((flag_meg)&(~flag_eeg)) 
					TFR = Ttmp(rowMEG(Chans),:);
					EF_st=Ttmp(rowMEG(Chans),:);
				end;
				if((flag_meg)&(flag_eeg)) 
					rowMEGEEG=[rowMEG; rowEEG];
					TFR = Ttmp(rowMEGEEG(Chans),:);
					EF_st=Ttmp(rowMEGEEG(Chans),:);
				end;
                            
                            
				TFR_orig_st=TFR;
				TFR_orig_st(bad_channel,:)=[];
                           
				EF_st(bad_channel,:)=[];

				rr=[];
                    end;
			
					[TFR_trans_st,X_orig_st,X_trans_st]=get_wavelet(TFR_orig_st,bad_channel,iop,iop_output,rr,'A_reg',A_reg,'A_reg_u',A_reg_u,'A_reg_rank',A_reg_rank,'x_mne_orientation',x_mne_orientation,'mce_weight',mce_weight,'X_mne',X_orig,'flag_estimate_orientation',flag_estimate_orientation,'flag_display',flag_display,'inverse_mode',inverse_mode,'flag_collapse_A_reg',flag_collapse_A_reg,'estimate_time_idx',estimate_time_idx,'nperdip',nperdip,'ref_dec_dip',ref_dec_dip,'fs',Fs,'width',Width,'freq',freqVec(m),'ref_dec_dip_norm',ref_dec_dip_norm,'ref_dec_dip_hemi',ref_dec_dip_hemi);

					if(EF_count==0)
						X_trans=X_trans_st;
						%X_trans2=X_trans_st.*conj(X_trans_st);
                                
						if(~flag_cov_full)
							EF=EF_st;
							EF2=EF_st.^2;
						elseif(flag_cov_full==1)
							EF2=zeros(size(EF_st,1),size(EF_st,1),size(EF_st,2));
							for k=1:size(EF_st,2)
								cov_full_idx=mod([-cov_full_half_length:cov_full_half_length]+k-1,size(EF_st,2))+1;

								EF(:,k)=mean(EF_st(:,cov_full_idx),2);

								EF2(:,:,k)=EF_st(:,cov_full_idx)*EF_st(:,cov_full_idx)'./length(cov_full_idx);
							end;
						elseif(flag_cov_full==2)
							epoch_odd=~epoch_odd;
							if(epoch_odd)
								EF_st_buffer=EF_st;
							else
								EF_st_diff=EF_st_buffer-EF_st;
							end;
							for k=1:size(EF_st,2)
								cov_full_idx=mod([-cov_full_half_length:cov_full_half_length]+k-1,size(EF_st,2))+1;

								EF(:,k)=mean(EF_st(:,cov_full_idx),2);

								EF2(:,:,k)=EF_st(:,cov_full_idx)*EF_st(:,cov_full_idx)'./length(cov_full_idx);
							end;

							EF2=zeros(size(EF_st,1),size(EF_st,1),size(EF_st,2));
							for k=1:size(EF_st,2)
								cov_full_idx=mod([-cov_full_half_length:cov_full_half_length]+k-1,size(EF_st,2))+1;

								EF(:,k)=mean(EF_st(:,cov_full_idx),2);

								EF2(:,:,k)=EF_st(:,cov_full_idx)*EF_st(:,cov_full_idx)'./length(cov_full_idx);
							end;
						end;
                                
						if(strcmp(iop_output,'raw'))
							TFR_trans=[];
							TFR_trans2=[];
						else
							if(~flag_cov_full)
								TFR_trans=TFR_trans_st;

								TFR_trans2=TFR_trans_st.*conj(TFR_trans_st);
							else
								TFR_trans2=zeros(size(TFR_trans_st,1),size(TFR_trans_st,1),size(TFR_trans_st,2));
								for k=1:size(TFR_trans,2)
									cov_full_idx=mod([-cov_full_half_length:cov_full_half_length]+k-1,size(TFR_trans,2))+1;

									TFR_trans(:,k)=mean(TFR_trans_st(:,cov_full_idx),2);

									TFR_trans2(:,:,k)=TFR_trans_st(:,cov_full_idx)*conj(TFR_trans_st(:,cov_full_idx))'./length(cov_full_idx);
								end;
							end;
						end;
					else
						X_trans=(X_trans.*EF_count+X_trans_st)./(EF_count+1);
						%X_trans2=(X_trans2.*EF_count+X_trans_st.*conj(X_trans_st))./(EF_count+1);
                                
						if(~flag_cov_full)
							EF=(EF.*EF_count+EF_st)./(EF_count+1);
							EF2=(EF2.*EF_count+EF_st.^2)./(EF_count+1);
						else
							for k=1:size(EF,2)
								cov_full_idx=mod([-cov_full_half_length:cov_full_half_length]+k-1,size(EF,2))+1;
								EF(:,k)=(EF(:,k).*EF_count+mean(EF_st(:,cov_full_idx),2))./(EF_count+1);
			
								EF2(:,:,k)=(EF2(:,:,k).*EF_count+EF_st(:,cov_full_idx)*EF_st(:,cov_full_idx)'./length(cov_full_idx))./(EF_count+1);

							end;
						end;
                            
						if(strcmp(iop_output,'raw'))
							TFR_trans=[];
							TFR_trans2=[];
						else
							if(~flag_cov_full)
	
								TFR_trans=(TFR_trans.*EF_count+TFR_trans_st)./(EF_count+1);

								TFR_trans2=(TFR_trans2.*EF_count+TFR_trans_st.*conj(TFR_trans_st))./(EF_count+1);

							else
								for k=1:size(TFR_trans,2)
									cov_full_idx=mod([-cov_full_half_length:cov_full_half_length]+k-1,size(TFR_trans,2))+1;

									TFR_trans(:,k)=(TFR_trans(:,k).*EF_count+mean(TFR_trans_st(:,cov_full_idx),2))./(EF_count+1);

									TFR_trans2(:,:,k)=(TFR_trans2(:,:,k).*EF_count+TFR_trans_st(:,cov_full_idx)*conj(TFR_trans_st(:,cov_full_idx))'./length(cov_full_idx))./(EF_count+1);
								end;
							end;
						end;
					end;     
                    EF_count=EF_count+1;
                    Trials = Trials + 1; 
                end
            end
            
        end
        
        [B,status]=rawdata('next');	
        while strcmp(status,'skip')
            [B,status]=rawdata('next');
        end
        
        tCurrent = rawdata('t');
        
    elseif(strcmp(mode,'avg'))
        fprintf('trigger (trigger [%d]) averaged FIF file...\n', Trigger);
        [EF_mean,Fs,tPre]=loadfif(inputname, Trigger-1);
        EF_mean(bad_channel,:)=[];
        status='eof';
        EF_count=1;
        tPre=tPre.*-1;
        

        %time vector for averaged data
        timeVec=(1:size(EF_mean,2))/Fs-tPre;

		if(~isempty(estimate_time))
			for i=1:length(estimate_time)
				[dummy,estimate_time_idx(i)]=min(abs(timeVec-estimate_time(i)));
			end;
			timeVec=timeVec(estimate_time_idx);
			EF_mean=EF_mean(:,estimate_time_idx);
		end;

        if(~isempty(tPre_stim))
            tPre_stim_idx=find((timeVec>-1.*abs(tPre_stim))&(timeVec<=0));
        else
            tPre_stim_idx=[];
        end;
        
        if(~isempty(freqVec))
            for m=1:length(freqVec)
                fprintf('wavelet...');
                
                if((~flag_meg)&(flag_eeg)) 
                    TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowEEG(Chans),:),Fs,Width);
                end;
                if((flag_meg)&(~flag_eeg)) 
                    TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowMEG(Chans),:),Fs,Width);
                end;
                if((flag_meg)&(flag_eeg)) 
                    rowMEGEEG=[rowMEG; rowEEG];
                    TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowMEGEEG(Chans),:),Fs,Width);
                end;
                
                TFR_orig=squeeze(TFR(m,:,:));
                TFR_orig(bad_channel,:)=[];
                
                %preparation of reference channel for phase synchronization
                % no phase synchronization for trigger averaged data!
                ref=[];
                
                if(~isempty(iop));
                    
                    [TFR_trans,X_orig,X_trans]=get_wavelet(TFR_orig,bad_channel,iop,iop_output,ref,'A_reg',A_reg,'A_reg_u',A_reg_u,'A_reg_rank',A_reg_rank,'x_mne_orientation',x_mne_orientation,'mce_weight',mce_weight,'X_mne',X_orig,'flag_estimate_orientation',flag_estimate_orientation,'flag_display',flag_display,'inverse_mode',inverse_mode,'flag_collapse_A_reg',flag_collapse_A_reg,'estimate_time_idx',estimate_time_idx,'nperdip',nperdip);
                    X_baseline_trans=X_trans(:,tPre_stim_idx);
                    X_baseline_trans2=X_trans(:,tPre_stim_idx).^2;
                else
                    TFR_trans=[];
                    X_orig=[];
                    X_orig_baseline=[];
                    X_orig_baseline2=[];
                    X_trans=[];
                    X_baseline_trans=[];
                    X_baseline_trans2=[];
                end;
            end;
            
            TFRs=TFR_trans;
        else
            EF=EF_mean;
            EF2=EF_mean.^2;
            EF_baseline=mean(EF_mean(:,tPre_stim_idx),2);
            EF_baseline2=EF_baseline.^2;
            
            
            if(~isempty(iop));
                [TFR_trans,X_orig,X_trans]=get_wavelet(EF_mean,bad_channel,iop,iop_output,[],'A_reg',A_reg,'A_reg_u',A_reg_u,'A_reg_rank',A_reg_rank,'x_mne_orientation',x_mne_orientation,'mce_weight',mce_weight,'X_mne',X_orig,'flag_estimate_orientation',flag_estimate_orientation,'flag_display',flag_display,'inverse_mode',inverse_mode,'flag_collapse_A_reg',flag_collapse_A_reg,'nperdip',nperdip);
                X_baseline_trans=X_trans(:,tPre_stim_idx);
                X_baseline_trans2=X_trans(:,tPre_stim_idx).^2;
            else
                TFR_trans=[];
                X_orig=[];
                X_orig_baseline=[];
                X_orig_baseline2=[];
                X_trans=[];
                X_baseline_trans=[];
                X_baseline_trans2=[];
            end;
        end;
        
        X_orig=[];
        X_orig_baseline=[];
        X_orig_baseline2=[];
        
        TFR_trans=EF_mean;
        TFR_baseline_trans=EF_mean(:,tPre_stim_idx);
        TFR_baseline_trans2=EF_mean(:,tPre_stim_idx).^2;
    end;
end


%X_trans_var=X_trans2-X_trans.*conj(X_trans);

if(~flag_cov_full)
	EF_var=EF2-EF.^2;
else
	EF_var=zeros(size(EF2));
	for k=1:size(EF,2)
		EF_var(:,:,k)=EF2(:,:,k)-EF(:,k)*EF(:,k)';
	end;
end;

if(strcmp(iop_output,'raw'))
	TFR_trans_var=[];
else
	if(~flag_cov_full)
		TFR_trans_var=TFR_trans2-TFR_trans.*conj(TFR_trans);
	else
		TFR_trans_var=zeros(size(TFR_trans2));
		for k=1:size(TFR_trans,2)
			TFR_trans_var(:,:,k)=TFR_trans2(:,:,k)-TFR(:,k)*TFR(:,k)';
		end;
	end;
end;

if(flag_finalize)
	%get the absolute value of a complex for phase/synchrony calculation;
	if(strcmp(iop_output,'phase'))
		X_trans=abs(X_trans);
		X_baseline_trans=[];
		TFR_trans=abs(TFR_trans);
		TFR_baseline_trans=[];
	end;

	if(strcmp(iop_output,'coh'))
		X_t=X_trans(1:(size(X_trans,1)-1)/2,:);
		X_b=X_trans((size(X_trans,1)-1)/2+1:end-1,:);
		X_r=X_trans(end,:);
		if(~isempty(ref_dec_dip))
			X_trans=abs(X_t).^2./abs(X_b)./repmat(abs(X_b(ref_dec_dip,:)),[size(X_t,1),1]);
		else
			X_trans=abs(X_t).^2./abs(X_b)./repmat(abs(X_r),[size(X_t,1),1]);
		end;

	%	TFR_t=TFR_trans(1:size(TFR_trans,1)/2,:);
	%	TFR_b=TFR_trans(size(TFR_trans,1)/2+1:end,:);
	%	TFR_trans=abs(TFR_t).^2./abs(TFR_b)./repmat(abs(TFR_b(ref_dec_dip,:)),[size(TFR_t,1),1]);
	end;
end;


EF_output{1}=EF;
fprintf('output[1]: Evoked field.\n');

EF_output{2}=EF_var;
fprintf('output[2]: variance of evoked field.\n');

EF_output{3}=X_trans;
fprintf('output[3]: averaged transformed dipole estimates in wavelet domain.\n');

%EF_output{4}=X_trans_var;
EF_output{4}=[];;
fprintf('output[4]: variance of transformed dipole estimates in wavelet domain.\n');

EF_output{5}=TFR_trans;
fprintf('output[5]: averaged transformed sensor data in wavelet domain.\n');

EF_output{6}=TFR_trans_var;
fprintf('output[6]: variance of transformed sensor data in wavelet domain.\n');

EF_output{7}=EF_count;
fprintf('output[7]: number of trials averaged.\n');

return;

%------------------------------------------------------------------------






function [tfr_trans,X_orig,X_trans]=get_wavelet(tfr,bad_channel,iop,iop_output,ref,varargin)


tfr_trans=[];
X_orig=[];
X_trans=[];

inverse_mode='mne';

A_reg=[];
A_reg_rank=[];
A=[];

x_mne_orientation=[];
mce_weight=[];
X_mne=[];
W_mne=[];
flag_estimate_orientation=1;
flag_display=0;
flag_collapse_A_reg=1;

estimate_time_idx=[];

ref_dec_dip=[];
freq=[];
width=[];
fs=[];

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

    switch lower(option)
    case 'inverse_mode'
        inverse_mode=option_value;
    case 'a_reg'
	A_reg=option_value;
    case 'a_reg_rank'
        A_reg_rank=option_value;
    case 'a_reg_u'
        A_reg_u=option_value;
    case 'a'
        A=option_value;
    case 'x_mne_orientation'
        x_mne_orientation=option_value;
    case 'mce_weight'
        mce_weight=option_value;
    case 'x_mne'
        X_mne=option_value;
    case 'w_mne'
        W_mne=option_value;
    case 'flag_estimate_orientation'
        flag_estimate_orientation=option_value;
    case 'flag_display'
        flag_display=option_value;
    case 'flag_collapse_a_reg'
        flag_collapse_A_reg=option_value;
    case 'estimate_time_idx'
	estimate_time_idx=option_value;
    case 'nperdip'
	nperdip=option_value;
    case 'ref_dec_dip'
        ref_dec_dip=option_value;
    case 'ref_dec_dip_norm'
        ref_dec_dip_norm=option_value;
    case 'ref_dec_dip_hemi'
        ref_dec_dip_hemi=option_value;
    case 'fs'
        fs=option_value;
    case 'width'
        width=option_value;
    case 'freq'
        freq=option_value;
    otherwise
	fprintf('unknown option [%s]\n',option);
	return;
    end;
end;

if(~isempty(estimate_time_idx))
	tfr=tfr(:,estimate_time_idx);
end;

fprintf('size(iop)=%s ',mat2str(size(iop)));
fprintf('size(tfr)=%s ',mat2str(size(tfr)));

if(~isempty(iop))
    tic;
    fprintf('inverse...');
    X_orig=iop*tfr;
    if(strcmp(inverse_mode,'mce'))
        if(isempty(x_mne_orientation))
            flag_estimate_orientation=1;
        else
            flag_estimate_orientation=0;
        end;
        
        X_orig=inverse_mce_core(tfr,'A_reg',A_reg,'A_reg_rank',A_reg_rank,'A_reg_u',A_reg_u,'x_mne_orientation',x_mne_orientation,'mce_weight',mce_weight,'X_mne',abs(X_orig),'flag_estimate_orientation',flag_estimate_orientation,'flag_display',flag_display,'flag_collapse_A_reg',flag_collapse_A_reg);
	else
		%if(nperdip==3&strcmp(iop_output,'phase'))
		%	%collapsing directional components for phase synchrony estimation
		%	fprintf('collapsing directional components...');
		%	X_orig=sqrt(squeeze(sum(reshape(X_orig,[3,size(X_orig,1)/3,size(X_orig,2)]).^2,1)));
		%end;
    end;
    if(isempty(ref)&~isempty(ref_dec_dip))
        fprintf('using dec diopole [%d] as reference (IOP gives [%d] dipoles)...',ref_dec_dip,size(X_orig,1));
        if(nperdip==3)
            ref=X_orig(3*(ref_dec_dip-1)+1:3*ref_dec_dip,:);
            %ang=acos(sum(real(ref).*imag(ref),1)./sqrt(sum(abs(real(ref)).^2,1))./sqrt(sum(abs(imag(ref)).^2,1)));
            power_ref=sum(abs(ref).^2,2);
            [dummy,idx]=max(power_ref);
            ref=ref(idx,:);
        elseif(nperdip==1)
            ref=X_orig(ref_dec_dip,:);
        end;
    end;
    
    xx=toc;
    fprintf('([%2.2f] sec).',xx);
else
    X_orig=[];
end;

switch(lower(iop_output))
case 'power'
	fprintf('calculating power...');
	X_trans=abs(X_orig).^2;
	tfr_trans=abs(tfr).^2;
    
case 'phase'
	fprintf('calculating phase...');

	fprintf('.');
	%normalize the power
	if(~isempty(X_orig))
		X_trans=zeros(size(X_orig));
		l = find(abs(X_orig) ~= 0); 
		X_trans(l)=X_orig(l)./abs(X_orig(l));
		l = find(abs(X_orig) == 0); 
		X_trans(l) =0;
	else
		X_trans=[];
	end;
    
	fprintf('.');
	%normalize the power
	rr=zeros(size(ref));
	l = find(abs(ref) ~= 0);
	rr(l) = ref(l)./abs(ref(l));

	fprintf('.');
	%normalize the power
	tfr_trans=zeros(size(tfr));
	l = find(abs(tfr) ~= 0);
	tfr_trans(l) = tfr(l)./abs(tfr(l));

	fprintf('.');
	if(~isempty(X_trans))
		X_trans = (X_trans.*repmat(conj(rr),[size(X_trans,1),1]));
 	else
		X_trans = [];
	end;	
	tfr_trans = (tfr_trans.*repmat(conj(rr),[size(tfr_trans,1),1]));
case 'coh'
	fprintf('calculatig wavelet coherence...');
	X_trans=X_orig.*repmat(conj(ref),[size(X_orig,1),1]);
	X_trans=cat(1,X_trans,X_orig.*conj(X_orig));
	X_trans=cat(1,X_trans,ref.*conj(ref));

	tfr_trans = tfr.*repmat(conj(ref),[size(tfr,1),1]);
	tfr_trans = cat(1,tfr_trans,tfr.*conj(tfr));
    
case 'wc'
	fprintf('calculating wavelet coefficients only...');
	X_trans=X_orig;
	tfr_trans=tfr;
case 'raw'
	fprintf('calculating wavelet coefficients only...');
	X_trans=X_orig;
	tfr_trans=tfr;end;
fprintf('\n');    
return;


