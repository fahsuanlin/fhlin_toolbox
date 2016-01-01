function [EF, EF_var,timeVec,EF_count,Fs,EF_raw,noise_cov, data_cov]=inverse_average_fif(inputname,Trigger,Chans,TimeInt,TimeExtr,varargin) 
% function inverse_get_EF_fif(INPUTNAME,TRIGGER,CHANS,TIMEINT,TIMEEXTR) 
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
% fa-hsuan lin @ dec. 2004
%
%------------------------------------------------------------------------
% The file InitParam.txt contains a set of parameters which have to 
% be defined prior to the analysis. In this file the variables for EOG 
% threshold, SSP etc are defined. 
%------------------------------------------------------------------------

InitParam=readInitParam('InitParam.txt');

bad_channel=[];

flag_meg=1;
flag_eeg=0;


EF_count=0;
EF_mean=[];

rowMEG=[1:306];		%default 306 channel MEG
rowEEG=[307:370];	%default 64 channel EEG


tPre_stim=[];

W=[];
flag_display=0;
flag_mne_toolbox=0;
flag_filter_raw=0;
flag_cov_full=0;
cov_full_half_length=0; %in terms of decimated samples

flag_decimate=0;
decimate_factor=[];

estimate_time=[];

ssp_rank=[];
time_zero=[];

flag_auto_reject=1;
flag_finalize=1;
flag_detrend=0;

wave_freq=[];
wave_width=[];


EF_raw=[];
flag_EF_raw=0;
epochs=[];

noise_cov=[];
data_cov=[];

subtract_evoked_response_data=[];
subtract_evoked_response_timeVec=[];

if(nargin>5)
    for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
        
        switch lower(option)
        case 'bad_channel'
		bad_channel=option_value;
        case 'flag_meg'
		flag_meg=option_value;
        case 'flag_eeg'
		flag_eeg=option_value;
        case 'rowmeg'
		rowMEG=option_value;
        case 'roweeg'
		rowEEG=option_value;
        case 'tpre_stim'
		tPre_stim=option_value;
	case 'estimate_time'
		estimate_time=option_value;
        case 'ref'
		ref=option_value;
        case 'w'
		W=option_value;
        case 'flag_display'
		flag_display=option_value;
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
	case 'flag_detrend'
		flag_detrend=option_value;
	case 'flag_finalize'
		flag_finalize=option_value;
	case 'ssp_rank'
		ssp_rank=option_value;
	case 'subtract_evoked_response_data'
		subtract_evoked_response_data=option_value;
	case 'subtract_evoked_response_timevec'
		subtract_evoked_response_timeVec=option_value;
	case 'time_zero'
		time_zero=option_value;
	case 'wave_freq'
		wave_freq=option_value;
	case 'wave_width'
		wave_width=option_value;
	case 'flag_ef_raw'
		flag_EF_raw=option_value;
	case 'epochs'
		epochs=option_value;
	case 'flag_mne_toolbox'
		flag_mne_toolbox=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('exit!\n');
            return;
        end;
    end;
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

if(~flag_mne_toolbox)
	[Fs,rowMEG,rowEOG,rowTRIG,rowEEG,rowMISC,ST] = fiffSetup(inputname);
	Fs_orig=Fs;
	fprintf('Types of channels: MEG=%d EOG=%d TRIG=%d EEG=%d MISC=%d\n',length(rowMEG),length(rowEOG),length(rowTRIG),length(rowEEG),length(rowMISC));

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
	me='MNE:mne_ex_read_raw';
	keep_comp = false;
	in_samples = false;
	%
	%   Setup for reading the raw data
	%
	try
    		raw = fiff_setup_read_raw(inputname);
	catch
    		error(me,'%s',mne_omit_first_line(lasterr));
	end
	%
	%   Set up pick list: MEG + STI 014 - bad channels
	%
	include{1} = 'STI 014';
	want_meg   = true;
	want_eeg   = false;
	want_stim  = false;
	%
	picks = fiff_pick_types(raw.info,want_meg,want_eeg,want_stim,include,raw.info.bads);
	%
	%   Set up projection
	%
	if isempty(raw.info.projs)
		fprintf(1,'No projector specified for these data\n');
		raw.proj = [];
	else
		%
		%   Activate the projection items
		%
		for k = 1:length(raw.info.projs)
			raw.info.projs(k).active = true;
		end
		fprintf(1,'%d projection items activated\n',length(raw.info.projs));
		%
		%   Create the projector
		%
		[proj,nproj] = mne_make_projector_info(raw.info);
		if nproj == 0
			fprintf(1,'The projection vectors do not apply to these channels\n');
			raw.proj = [];
		else
			fprintf(1,'Created an SSP operator (subspace dimension = %d)\n',nproj);
			raw.proj = proj;
		end
	end
keyboard;
	%
	%   Read a data segment
	%   times output argument is optional
	%
	try
    		if in_samples
			[ data, times ] = fiff_read_raw_segment(raw,from,to,picks);
		else
			[ data, times ] = fiff_read_raw_segment_times(raw,from,to,picks);
		end
	catch
    		fclose(raw.fid);
		error(me,'%s',mne_omit_first_line(lasterr));
	end

	fclose(raw.fid);
	fprintf(1,'File closed.\n');
end;
%------------------------------------------------------------------------
% Read chunks of fif file and calculate the ERP
%------------------------------------------------------------------------


fprintf('Reading trial\n');

TFRs=[];
tCurrent=0.0;
tStop=Inf;

while strcmp(status,'ok') & tCurrent < tStop 
	Fs=Fs_orig;


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
                
                if(flag_detrend)
                    Ttmp = detrend(Ttmp','constant')';
                end;
                
                if(~isempty(ssp_rank))
                	[uu,ss,vv]=svds(Ttmp,ssp_rank);
                	Ttmp=Ttmp-uu*ss*vv';
                end;

                if(~isempty(time_zero))
                	idx=find(timeVec>min(time_zero)&timeVec<max(time_zero));
                	%Ttmp(:,idx)=0;
                	Ttmp(:,idx)=Ttmp(:,idx-length(idx));
                	
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
                        if(flag_detrend)
                            Ttmp(rowMEG(Chans),:) = detrend(Ttmp(rowMEG(Chans),:)')';
                        end;
                    end;
                    if((~flag_meg)&(flag_eeg)) 
                        if(flag_detrend)
                            Ttmp(rowEEG(Chans),:) = detrend(Ttmp(rowEEG(Chans),:)')';
                        end;
                    end;
                    if((flag_meg)&(flag_eeg)) 
                        rowMEGEEG=[rowMEG; rowEEG];
                        if(flag_detrend)
                            Ttmp(rowMEGEEG(Chans),:) = detrend(Ttmp(rowMEGEEG(Chans),:)')';
                        end;
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
                    
                    
                    if(~isempty(wave_freq)&~isempty(wave_width))
                    	fprintf('wavelet [%2.1f Hz] for [%d] cycle...',wave_freq,wave_width);
                    	Ttmp=inverse_waveletcoef(wave_freq,Ttmp,Fs,wave_width);
                    end;
               
             
	
               	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               	                   	    
               	    if(~isempty(W))
                    	EF_st=W*Ttmp;
                    else
                    	EF_st=Ttmp;
                    end;
                    
                    if(flag_EF_raw)
                    	if(EF_count==0&~isempty(epochs))
                    		EF_raw=zeros(size(EF_st,1),size(EF_st,2),epochs);
                    	end;
			EF_raw(:,:,EF_count+1)=EF_st;
                    end;
                    
               	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
		    if(EF_count==0)
			if(~flag_cov_full)
				EF=EF_st;
				EF2=abs(EF_st).^2;
			elseif(flag_cov_full==1)
				EF2=zeros(size(EF_st,1),size(EF_st,1),size(EF_st,2));
				for k=1:size(EF_st,2)
					cov_full_idx=mod([-cov_full_half_length:cov_full_half_length]+k-1,size(EF_st,2))+1;

					EF(:,k)=mean(EF_st(:,cov_full_idx),2);

					EF2(:,:,k)=EF_st(:,cov_full_idx)*EF_st(:,cov_full_idx)'./length(cov_full_idx);
				end;
			end;
		    else
			if(~flag_cov_full)
				EF=(EF.*EF_count+EF_st)./(EF_count+1);
				EF2=(EF2.*EF_count+abs(EF_st).^2)./(EF_count+1);
			else
				for k=1:size(EF,2)
					cov_full_idx=mod([-cov_full_half_length:cov_full_half_length]+k-1,size(EF,2))+1;
					EF(:,k)=(EF(:,k).*EF_count+mean(EF_st(:,cov_full_idx),2))./(EF_count+1);
		
					EF2(:,:,k)=(EF2(:,:,k).*EF_count+EF_st(:,cov_full_idx)*EF_st(:,cov_full_idx)'./length(cov_full_idx))./(EF_count+1);
				end;
			end;
                        
		    end;     
                    EF_count=EF_count+1;
                end
            end
            
        end
        
        [B,status]=rawdata('next');	
        while strcmp(status,'skip')
            [B,status]=rawdata('next');
        end
        
        tCurrent = rawdata('t');
        
end


if(~flag_cov_full)
	EF_var=EF2-EF.^2;
	
	%noise_cov=mean(EF2,2)-mean(EF,2)*mean(EF,2)';
	%data_cov=mean(EF2,2);
else
	EF_var=zeros(size(EF2));
	for k=1:size(EF,2)
		EF_var(:,:,k)=EF2(:,:,k)-EF(:,k)*EF(:,k)';
	end;
end;



EF_output{1}=EF;
fprintf('output[1]: Evoked field.\n');

EF_output{2}=EF_var;
fprintf('output[2]: variance of evoked field.\n');


return;

