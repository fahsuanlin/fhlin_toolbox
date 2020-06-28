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
iop_output='';
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
			TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowEEG(Chans),:),Fs,Width);
		end;
		if((flag_meg)&(~flag_eeg)) 
			TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowMEG(Chans),:),Fs,Width);
		end;
		if((flag_meg)&(flag_eeg)) 
			rowMEGEEG=[rowMEG; rowEEG];
			TFR(m,:,:) = inverse_waveletcoef(freqVec(m),EF_mean(rowMEGEEG(Chans),:),Fs,Width);
		end;

		tfr=squeeze(TFR(m,:,:));
		tfr(bad_channel,:)=[];

		%preparation of reference channel for phase synchronization
		% no phase synchronization for trigger averaged data!
		ref=[];
							                     
		if(~isempty(iop));
						
			[tfr,X]=get_wavelet(tfr,bad_channel,iop,iop_output,ref);
	
		end;

		TFRs=tfr;
		X_mean=X;
	end;

	varargout{1}=X_mean;
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
    TFR=zeros(length(freqVec),length(phase_chans),colPre+colPost); 
else
    TFRs=[];
	tCurrent=0.0;
	tStop=Inf;
end;




while strcmp(status,'ok') & tCurrent < tStop 
	if(strcmp(mode,'raw')|strcmp(mode,'evoke'))

		colB = size(B,2); 
		TRACE(:,1:colTRACE-colB)  = TRACE(:,colB+1:colTRACE);
		TRACE(:,colTRACE-colB+1:colTRACE)  = B;
		TrigList = findTrigger(TRACE(rowTRIG,colPre+1:colPre+colB),Trigger,TrigThres);

		for k=1:length(TrigList)
			if colPre+TrigList(k)+colPost <= size(TRACE,2)  

				traceOK = 1;
                if((flag_meg)&(~flag_eeg)) 
    				Ttmp = TRACE(rowMEG,TrigList(k):colPre+TrigList(k)+colPost-1);
                end;
                if((~flag_meg)&(flag_eeg)) 
    				Ttmp = TRACE(rowEEG,TrigList(k):colPre+TrigList(k)+colPost-1);
                end;
                if((flag_meg)&(flag_eeg)) 
    				Ttmp = TRACE([rowMEG; rowEEG],TrigList(k):colPre+TrigList(k)+colPost-1);
                end;
                
				Ttmp = detrend(Ttmp','constant')';

				if InitParam.applySSP
					Ttmp = ST*Ttmp;
				end

				[tmpVal,dFmaxCh] = max(max(diff(abs(Ttmp'))));
				DFDTmax = 1e13*tmpVal/(1/Fs);
	 	  
				[tmpVal,FmaxCh] = max(max(abs(Ttmp')));
				Fmax = 2*1e13*tmpVal;


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
                   
						EOGd = detrend(EOGtmp(l,:));
	
						if 1e6*(max(EOGd) - min(EOGd)) > InitParam.EOGreject
							EOGrej = EOGrej + 1;
							fprintf('Reject:EOG-\n');
							traceOK = 0;
			   
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
                    
					%calculating time vector
					timeVec=(1:size(Ttmp,2))/Fs-tPre;

					if(~isempty(tPre_stim))
						tPre_stim_idx=find((timeVec>-1.*abs(tPre_stim))&(timeVec<=0));
					else
						tPre_stim_idx=[];
					end;


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
							if(strcmp(iop_output,'phase'))
								if(isempty(phase_dipoleref))
									ref=cos([0:colPre+colPost-1]./Fs.*2.*pi.*freqVec(m))+sqrt(-1.0).*sin([0:colPre+colPost-1]./Fs.*2.*pi.*freqVec(m));
								else
									ref=X(phase_diopleref,:);
								end;
                                rr=inverse_waveletcoef(freqVec(m),ref,Fs,Width);
							else
								rr=[];
							end;

							[TFR_trans_st,X_orig_st,X_trans_st]=get_wavelet(TFR_orig_st,bad_channel,iop,iop_output,ref);

							%estimation of vairance from the pre-stimuli interval: signle-trial approach
							if(~isempty(tPre_stim))
								if(~isempty(X_orig_st)) X_baseline_orig_st=X_orig_st(:,tPre_stim_idx); else X_baseline_orig_st=[]; end;
								if(~isempty(X_trans_st)) X_baseline_trans_st=X_trans_st(:,tPre_stim_idx); else X_baseline_trans_st=[]; end;
								if(~isempty(TFR_orig_st)) TFR_baseline_orig_st=TFR_orig_st(:,tPre_stim_idx); else TFR_baseline_orig_st=[]; end;
								if(~isempty(TFR_trans_st)) TFR_baseline_trans_st=TFR_trans_st(:,tPre_stim_idx); else TFR_baseline_trans_st=[]; end;
								if(~isempty(EF_st)) EF_baseline_st=EF_st(:,tPre_stim_idx); else EF_baseline_st=[]; end;
							else
								X_baseline_orig_st=[];
								X_baseline_trans_st=[];
								TFR_baseline_orig_st=[];
								TFR_baseline_trans_st=[];
								EF_baseline_st=[];
							end;

							if(EF_count==0)
								X_orig=X_orig_st;
								X_trans=X_trans_st;
								X_baseline_orig=X_baseline_orig_st;
								X_baseline_orig2=X_baseline_orig_st.*conj(X_baseline_orig_st);
								X_baseline_trans=X_baseline_trans_st;
								X_baseline_trans2=X_baseline_trans_st.*conj(X_baseline_trans_st);
								EF=EF_st;
								EF2=EF_st.^2;
								EF_baseline=EF_baseline_st;
								EF_baseline2=EF_baseline_st.^2;
								TFRs = TFR_trans_st;
								TFR_orig=TFR_orig_st;
								TFR_trans=TFR_trans_st;
								TFR_baseline_orig=TFR_baseline_orig_st;
								TFR_baseline_orig2=TFR_baseline_orig_st.*conj(TFR_baseline_orig_st);
								TFR_baseline_trans=TFR_baseline_trans_st;
								TFR_baseline_trans2=TFR_baseline_trans_st.*conj(TFR_baseline_trans_st);
							else
								X_orig=(X_orig.*EF_count+X_orig_st)./(EF_count+1);
								X_trans=(X_trans.*EF_count+X_trans_st)./(EF_count+1);
								X_baseline_orig=(X_baseline_orig.*EF_count+X_baseline_orig_st)./(EF_count+1);
								X_baseline_orig2=(X_baseline_orig2.*EF_count+X_baseline_orig_st.*conj(X_baseline_orig_st))./(EF_count+1);
								X_baseline_trans=(X_baseline_trans.*EF_count+X_baseline_trans_st)./(EF_count+1);
								X_baseline_trans2=(X_baseline_trans2.*EF_count+X_baseline_trans_st.*conj(X_baseline_trans_st))./(EF_count+1);
								EF=(EF.*EF_count+EF_st)./(EF_count+1);
								EF2=(EF2.*EF_count+EF.^2)./(EF_count+1);
								EF_baseline=(EF_baseline.*EF_count+EF_baseline_st)./(EF_count+1);
								EF_baseline2=(EF_baseline2.*EF_count+EF_baseline_st.^2)./(EF_count+1);
								TFRs=(TFRs.*EF_count+TFR_trans_st)./(EF_count+1);
								TFR_orig=(TFR_orig.*EF_count+TFR_orig_st)./(EF_count+1);
								TFR_trans=(TFR_trans.*EF_count+TFR_trans_st)./(EF_count+1);
								TFR_baseline_orig=(TFR_baseline_orig.*EF_count+TFR_baseline_orig_st)./(EF_count+1);
								TFR_baseline_orig2=(TFR_baseline_orig2.*EF_count+TFR_baseline_orig_st.*conj(TFR_baseline_orig_st))./(EF_count+1);
  		  	                    TFR_baseline_trans=(TFR_baseline_trans.*EF_count+TFR_baseline_trans_st)./(EF_count+1);
								TFR_baseline_trans2=(TFR_baseline_trans2.*EF_count+TFR_baseline_trans_st.*conj(TFR_baseline_trans_st))./(EF_count+1);
                            end;
						end;
					end;

			
					EF_count=EF_count+1;
		  			Trials = Trials + 1; 
				end
			end

%fprintf('size(TFR_orig)=%s\n',mat2str(size(TFR_orig)));
%fprintf('size(TFR_trans)=%s\n',mat2str(size(TFR_trans)));

		end

		[B,status]=rawdata('next');	
		while strcmp(status,'skip')
 			[B,status]=rawdata('next');
		end
  
		tCurrent = rawdata('t');

	elseif(strcmp(mode,'avg'))
		fprintf('trigger (trigger [%d]) averaged FIF file...\n', Trigger);
		[EF_mean,Fs,tPre]=loadfif(inputname, Trigger-1);
		status='eof';
		EF_count=1;
		tPre=tPre.*-1;

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
						
				[TFR_trans,X_orig,X_trans]=get_wavelet(TFR_orig,bad_channel,iop,iop_output,ref);
			else
				TFR_trans=[];
				X_orig=[];
				X_trans=[];
			end;
		end;
		TFRs=TFR_trans;
	end;
end


X_baseline_orig_var=X_baseline_orig2-X_baseline_orig.*conj(X_baseline_orig);

X_baseline_trans_var=X_baseline_trans2-X_baseline_trans.*conj(X_baseline_trans);

EF_var=EF2-EF.^2;

EF_baseline_var=EF_baseline2-EF_baseline.^2;

TFR_baseline_orig_var=TFR_baseline_orig2-TFR_baseline_orig.*conj(TFR_baseline_orig);

TFR_baseline_trans_var=TFR_baseline_trans2-TFR_baseline_trans.*conj(TFR_baseline_trans);

%get the absolute value of a complex for phase/synchrony calculation;
if(strcmp('iop_output','phase'))
	X_trans=abs(X_trans);
    X_baseline_trans=abs(X_baseline_trans);
    TFR_trans=abs(TFR_trans);
    TFR_baseline_trans=abs(TFR_baseline_trans);
end;
	


EF_output{1}=EF;
fprintf('output[1]: Evoked field.\n');

EF_output{2}=EF_baseline;
fprintf('output[1]: baseline of the evoked field.\n');

EF_output{3}=EF_baseline_var;
fprintf('output[1]: baseline variance of the evoked field\n');

EF_output{4}=X_trans;
fprintf('output[4]: transformed averaged dipole estimates in wavelet domain.\n');

EF_output{5}=X_baseline_trans;
fprintf('output[5]: baseline mean of the transformed averaged dipole estimates in wavelet domain.\n');

EF_output{6}=X_baseline_trans_var;
fprintf('output[6]: baseline variance of the transformed averaged dipole estimates in wavelet domain.\n');

EF_output{7}=X_orig;
fprintf('output[7]: averaged dipole estimates in wavelet domain.\n');

EF_output{8}=X_baseline_orig;
fprintf('output[8]: baseline mean of the averaged dipole estimates in wavelet domain.\n');

EF_output{9}=X_baseline_orig_var;
fprintf('output[9]: baseline variance of the averaged dipole estimates in wavelet domain.\n');

EF_output{10}=TFR_trans;
fprintf('output[10]: Transformed sensor data in wavelet domain.\n');

EF_output{11}=TFR_baseline_trans;
fprintf('output[11]: baseline mean of the transformed sensor data in wavelet domain.\n');

EF_output{12}=TFR_baseline_trans_var;
fprintf('output[12]: baseline variance of the transformed sensor data in wavelet domain.\n');

EF_output{13}=TFR_orig;
fprintf('output[13]: Sensor data in wavelet domain.\n');

EF_output{14}=TFR_baseline_orig;
fprintf('output[14]: baseline mean of the sensor data in wavelet domain.\n');

EF_output{15}=TFR_baseline_orig_var;
fprintf('output[15]: baseline variance of the sensor data in wavelet domain.\n');


return;

%------------------------------------------------------------------------






function [tfr_trans,X_orig,X_trans]=get_wavelet(tfr,bad_channel,iop,iop_output,ref)


tfr_trans=[];
X_orig=[];
X_trans=[];

							
	fprintf('size(iop)=%s ',mat2str(size(iop)));
	fprintf('size(tfr)=%s ',mat2str(size(tfr)));
	
	if(~isempty(iop))
		tic;
		fprintf('inverse...');
		X_orig=iop*tfr;
		toc;
	else
		X_orig=[];
	end;

	switch(lower(iop_output))
	case 'power'
		fprintf('calculating power...\n');
		X_trans=abs(X_orig).^2;
		tfr_trans=abs(tfr).^2;
	
	case 'phase'
		fprintf('calculating phase...\n');

		%normalize the power
		X_trans=X_orig;
		l = find(abs(X_orig) == 0);
        X_orig(l)=1;
		X_trans = X_orig./abs(X_orig);
		X_trans(l) = 0;

		rr=ref;
		l = find(abs(ref) == 0);
        ref(l)=1;
		rr = ref./abs(ref);
		rr(l) = 0;

        %normalize the power
		tfr_trans=tfr;
		l = find(abs(tfr) == 0);
        tfr(l)=1;
		tfr_trans = tfr./abs(tfr);
		tfr_trans(l) = 0;

		X_trans = (X_trans.*repmat(rr,[size(X_trans,1),1]));
		tfr_trans = (tfr_trans.*repmat(rr,[size(tfr_trans,1),1]));

	case 'raw'
		fprintf('raw dipole estimate...\n');
		X_trans=X_orig;
		tfr_trans=tfr;
	end;



return;


