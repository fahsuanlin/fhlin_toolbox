function [C,count,cov_count, C_f, noise_power]=inverse_get_C_fif(filename,mode_str,varargin)
% inverse_get_C_fif		Calculate the (noise) covariance given a FIF file
%
% [C, total_trial, skip_trial]=inverse_get_C_fif(filename, [mode]);
% filename: the file name and path of a FIF file
% mode: either "null" (default) or "evoke"
%	if it is "null", all time points in each trial is used to calculated the covariance
%	if it is "evoke", the program will search the first onset of all triggers and use only pre-stimuli interval as covariance data substrate
% 	if it is "avg", the program will load the averaged fif file
%		
% C: calculated output covariance matrix
% total_trial: the number of total trials in the FIF file
% cov_trial: the number of trials used for covariance matrix
% fhlin@mar. 13, 2002

mode=1; % empty room type; all measurement are used to get the covariance matrix

evoke_trig='';

C=[];
tPre=[];
tPost=[];

flag_eeg=0;
flag_meg=1;

freq=[];
width=[];

C_f=[];

noise_power=[];
ncov=[];
uu=[];
vv=[];

t_After=[];

% check if it is LINUX to use 4D-toolbox to read FIF file
if(ispc)
    fprintf('NO 4D-toolbox available on PC\n');
    fprintf('Fail to get covariance matrix');
    return;
end;

switch(lower(mode_str))
	case {'null','raw'}
        mode=1;
		case 'evoke'
        mode=2;
		evoke_trig=varargin{1};
		tPre=varargin{2};
	case 'avg'
        mode=3;
	otherwise
        fprintf('unknown type for the noise covariance calculation!\n');
        return;
end;



if(nargin>4)
    for i=1:(nargin-4)/2
        option=lower(varargin{2+i*2-1});
        option_value=varargin{2+i*2};
        
        switch(lower(option))
        case 'flag_eeg'
            flag_eeg=option_value;
        case 'flag_meg'
            flag_meg=option_value;
	case 'freq'
		freq=option_value;
	case 'width'
		width=option_value;
	case 'c'
		ncov=option_value;
		[uu,vv]=eig(ncov);
        case 't_after'
            t_After=option_value;
        case 't_pre'
            tPre=abs(option_value);
        case 't_post'
            tPost=abs(option_value);
        otherwise
            fprintf('unknown option [%s]\n',option);
            fprintf('exit!\n');
        end;
    end;
end;


if(mode==1|mode==2)
	[Fs,rowMEG,rowEOG,rowTRIG,rowEEG,rowMISC,rowEMB,STbc,ST] = fiffSetup(filename);
end;

if(mode==1)
    fprintf('Treating the FIF file as raw data!\n');
end;

if(mode==2)
    fprintf('Treating the FIF file as evoked data!\n');
    fprintf('search triggers at row %s\n',mat2str(rowTRIG));
    fprintf('Only pre-stimulus interval is used for noise covariance estimation!\n');
end;

if(mode==3)
    fprintf('Treating the FIF file as an averaged evoked data!\n');
    fprintf('Only pre-stimulus interval is used for noise covariance estimation!\n');
end;

if(mode==1)
    %Opens the selected raw data file reading all channels
    rawdata('any',filename);
    
    done=0;
    count=1;
    
    sample_freq=rawdata('sf');		%Gets the sampling frequency
    samples=rawdata('samples');		%Gets number of samples
    [range,calibration]=rawdata('range');   %Gets the range and calibration
    
    e_x2=[];
    m=[];
    
    skip_count=0;
    
    while(~done)
        fprintf('%d...',count);
        time(count)=rawdata('t');		%Gets current time	
        
        [buffer,status]=rawdata('next');	%Gets the next data buffer
        
        %Status can be 'ok', 'skip', 'eof', or 'error'
        if(strcmp(status,'ok'))	
            
            flag_skip=0;
            
            if((flag_meg)&(~flag_eeg)) 
                buffer=buffer(rowMEG,:);	%only MEG channels are calculated.
            end;
            if((~flag_eeg)&(flag_eeg))
                buffer=buffer(rowEEG,:);
            end;
            if((flag_eeg)&(flag_eeg))
                buffer=buffer([rowMEG; rowEEG],:);
            end;
            
            
            
            if(~flag_skip)
                
				if(~isempty(freq))
					buffer_f=(inverse_waveletcoef(freq,buffer,sample_freq,width)).';
				end;

                buffer=buffer';
                

				if(~isempty(ncov))
					buffer_mean_remove=buffer-repmat(mean(buffer,1),[size(buffer,1),1]);
					np=sqrt(inv(vv))*uu'*buffer_mean_remove';
					noise_power=cat(2,noise_power,reshape(np,[1,prod(size(np))]));
				end;	


                %update covariance parameters
                %cov_now=cov(buffer,1);
                
                mn_now=mean(buffer,1);
				e_x2_now=buffer'*buffer./size(buffer,1);

				if(~isempty(freq))
					mn_now_f=mean(buffer_f,1);
					e_x2_now_f=buffer_f'*buffer_f./size(buffer_f,1);
				end;
                
                %e_x2_now=cov_now+mn_now'*mn_now;
                
                if(isempty(m))
                    e_x2=e_x2_now;
                    m=mn_now;
					
					if(~isempty(freq))
	                    e_x2_f=e_x2_now_f;
						m_f=mn_now_f;
					end;
                else
                    e_x2=(e_x2.*(count-1)+e_x2_now)./count;
                    m=(m*(count-1)+mn_now)./count;

					if(~isempty(freq))
	                    e_x2_f=(e_x2_f.*(count-1)+e_x2_now_f)./count;
						m_f=(m_f*(count-1)+mn_now_f)./count;
					end;

                end;
                
                done=0;
            end;
            
            count=count+1;
            
        else
            done=1;
        end;
    end;
    fprintf('\n');
    fprintf('Total [%d] trials.\n',count);
    cov_count=count-skip_count;
    
    rawdata('close');		%Closes the raw data file
    
    fprintf('calculating covariance...\n');
    C=e_x2-m'*m;

	if(~isempty(freq))
		C_f=e_x2_f-m_f'*m_f;
	end;
    
elseif(mode==2)
    InitParam=readInitParam('InitParam.txt');
	ChNames = channames(filename) ;
    
    [Fs,rowMEG,rowEOG,rowTRIG,rowEEG,rowMISC,ST] = fiffSetup(filename);
    fprintf('Types of channels: MEG=%d EOG=%d TRIG=%d EEG=%d MISC=%d\n',length(rowMEG),length(rowEOG),length(rowTRIG),length(rowEEG),length(rowMISC));
    
	if(isempty(tPre))
	    tPre=0.1; %pre-stimuli 100 msec
	end;
    if(isempty(tPost))
        tPost=0.5; %post-stimuli 500 msec
    end;
    
    tStart=0;
    tStop=inf;
    
    tCurrent = tStart; 
    TrigThres = 2; 
    rawdata('any',filename);                    
    
    colPre    = floor(Fs*tPre);
    colPost   = floor(Fs*tPost);  
    
    Trials = 0;   
    EOGrej = 0;
    Frej = 0;
    DFDTrej = 0;
    
    t = rawdata('goto',0);
    [B,status]=rawdata('next');
    while strcmp(status,'skip')
        [B,status]=rawdata('next');
    end
    
    BPre  = zeros(size(B,1),colPre);  
    BPost = zeros(size(B,1),colPost); 
    colB = size(B,2); 
    colTRACE = colB+colPre+colPost;
    TRACE = zeros(size(B,1),colTRACE); 
    
    
    e_x2=[];
    m=[];
    
    fprintf('Reading trial\n');
    
    count=1;
    skip_count=0;
    
    while strcmp(status,'ok') & tCurrent < tStop
        colB = size(B,2); 
        TRACE(:,1:colTRACE-colB)  = TRACE(:,colB+1:colTRACE);
        TRACE(:,colTRACE-colB+1:colTRACE)  = B;
        TrigList = findTrigger(TRACE(rowTRIG,colPre+1:colPre+colB),evoke_trig,TrigThres);
        
	if(isempty(TrigList))
		fprintf('.');
	else
		fprintf('*');
	end;
	
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
                    fprintf('Reject:%s(dF) -',char(ChNames(dFmaxCh)));
                    traceOK = 0;
                end
                
                if Fmax > InitParam.Freject 
                    Frej = Frej + 1;
                    fprintf('Reject:%s(F)-',char(ChNames(FmaxCh)));
                    traceOK = 0;
                end
                
                if ~isempty(rowEOG)
                    EOGtmp = TRACE(rowEOG,TrigList(k):colPre+TrigList(k)+colPost-1);
                    for l=1:size(EOGtmp,1)
                        
                        EOGd = detrend(EOGtmp(l,:));
                        
                        if 1e6*(max(EOGd) - min(EOGd)) > InitParam.EOGreject
                            EOGrej = EOGrej + 1;
                            fprintf('Reject:EOG-');
                            traceOK = 0;
                            
                        end
                    end
                end
                
                if traceOK
                    if(isempty(t_After))
                    	fprintf('pre-stim covariance (%2.2f msec)\n',tPre.*1e3);
        				if(~isempty(freq))
    						buffer_f=(inverse_waveletcoef(freq,Ttmp,Fs,width)).';    						
    						buffer_f=buffer_f(1:colPre,:);
				    	end;
    
                        buffer=Ttmp(:,1:colPre)';
                    else
                       	fprintf('covariance between (%2.2f msec) and (%2.2f msec)\n',min(t_After).*1e3, max(t_After).*1e3);
                        t_after1=colPre+floor(min(t_After)*Fs);
                        t_after2=colPre+floor(max(t_After)*Fs);
                        
                        if(~isempty(freq))
    						buffer_f=(inverse_waveletcoef(freq,Ttmp,Fs,width)).';
                            buffer_f=buffer_f(t_after1:t_after2,:)';
				    	end;
                        
                        buffer=Ttmp(:,t_after1:t_after2)';
                    end;
 
					if(~isempty(ncov))
						buffer_mean_remove=buffer-repmat(mean(buffer,1),[size(buffer,1),1]);
						np=sqrt(inv(vv))*uu'*buffer_mean_remove';
						noise_power=cat(2,noise_power,reshape(np,[1,prod(size(np))]));
					end;	

                    
                    cov_now=cov(buffer,1);
                    mn_now=mean(buffer,1);
					e_x2_now=cov_now+mn_now'*mn_now;

					if(~isempty(freq))
                    	mn_now_f=mean(buffer_f,1);
						e_x2_now_f=buffer_f'*buffer_f./size(buffer_f,1);
					end;
                    
                    if(isempty(m))
                        e_x2=e_x2_now;
                        m=mn_now;

						if(~isempty(freq))
							e_x2_f=e_x2_now_f;
							m_f=mn_now_f;
						end;

                    else
                        e_x2=(e_x2.*(count-1)+e_x2_now)./count;
                        m=(m*(count-1)+mn_now)./count;

						if(~isempty(freq))
	 						e_x2_f=(e_x2_f.*(count-1)+e_x2_now_f)./count;
							m_f=(m_f*(count-1)+mn_now_f)./count;
						end;

                    end;
                    
                    fprintf('%d...',count);
                    count=count+1;
                else
                    fprintf('[skipped]...');
                    skip_count=skip_count+1;
                end
            end
        end
        
        [B,status]=rawdata('next');	
        while strcmp(status,'skip')
            [B,status]=rawdata('next');
        end
        
        tCurrent = rawdata('t');
    end;
    fprintf('\n');
    
    rawdata('close');		%Closes the raw data file
    
    fprintf('calculating covariance...\n');
    C=e_x2-m'*m;
    
	if(~isempty(freq))
		C_f=e_x2_f-m_f'*m_f;
	end;

    cov_count=count;
    count=count+skip_count;
    
elseif(mode==3)
    fprintf('Averaged evoked FIF file!\n');
    [data,sf,t0]=loadfif(filename,'any');
    fprintf('sampling frequency=%2.2 (Hz)\n', sf);
    fprintf('onset of stimulus=%3.3 (sec)\n',t0);
    fprintf('using pre-stimulus interval as noise covariance estimate...\n');
    
%    if((flag_meg)&(~flag_eeg)) 
%        data=data(rowMEG,:);
%    end;
%    if((~flag_meg)&(flag_eeg)) 
%        data=data(rowEEG,:);
%    end;
%    if((flag_meg)&(flag_eeg)) 
%        data=data([rowMEG; rowEEG],:);
%    end;

 	data=data(1:306,:);
   
    count=abs(round(t0*sf));
    cov_count=abs(round(t0*sf*0.8));
    fprintf('total [%d] samples in noise covariance estimate.\n',cov_count);
    C=cov(data(:,1:cov_count)');
end;
