function [TrigList,TrigListCount,Trig_output]=inverse_search_trigger_fif(filename,varargin)
% inverse_search_trigger_fif		Search triggers in a raw FIFF file
%
% [trigger_list,trigger_count]=inverse_search_trigger_fif(filename);
% filename: the file name and path of a FIF file
%
% trigger_list: 1-D vector of triggers in the FIF file
% trigger_count: 1-D vector of the number of triggers in the FIF file. Each entry corresponds to the "trigger_list" output.
%
% fhlin@eb. 10, 2004



TrigList=[];
TrigListCount=[];
mode=1;
flag_6bit=0;

% check if it is LINUX to use 4D-toolbox to read FIF file
if(ispc)
    fprintf('NO 4D-toolbox available on PC\n');
    fprintf('Fail to get covariance matrix');
    return;
end;

if(nargin>1)
    for i=1:(nargin-1)/2
        option=lower(varargin{i*2-1});
        option_value=varargin{i*2};
        
        switch(lower(option))
        case 'flag_eeg'
            flag_eeg=option_value;
        case 'flag_6bit'
        	flag_6bit=option_value;
        otherwise
            fprintf('unknown option [%s]\n',option);
            fprintf('exit!\n');
        end;
    end;
end;

Trig_output=[];

[Fs,rowMEG,rowEOG,rowTRIG,rowEEG,rowMISC,rowEMB,STbc,ST] = fiffSetup(filename);

if(flag_6bit)
	rowTRIG=rowTRIG(1:6);
end;

if(mode==1)
    %Opens the selected raw data file reading all channels
    rawdata('any',filename);

    done=0;
    count=1;

    sample_freq=rawdata('sf');		%Gets the sampling frequency
    samples=rawdata('samples');		%Gets number of samples
    [range,calibration]=rawdata('range');   %Gets the range and calibration
    
    skip_count=0;
    
    while(~done)
        fprintf('%d...',count);
        time(count)=rawdata('t');		%Gets current time	

        [buffer,status]=rawdata('next');	%Gets the next data buffer
        %Status can be 'ok', 'skip', 'eof', or 'error'
        if(strcmp(status,'ok'))	
           
             	%TrigList = findTrigger(buffer(rowTRIG),evoke_trig,TrigThres);
           
           	TrigThres=2;
           	B=buffer(rowTRIG,:);
		BB = zeros(size(B));
		
		Trig_output=cat(2,Trig_output,B);
		
		for k=1:size(B,1)
			BB(k,find(diff(B(k,:)) > TrigThres)) = 1;
		end 

		for j=1:size(B,2)
			sum = 0;
			for k=1:size(B,1)
				sum = sum + BB(k,j)*(2^(k-1)); 
			end
			TrigVal(j) = sum;
		end
	
		idxx=find(TrigVal>0);

	
		for pp=1:length(idxx)
			if(isempty(intersect(TrigList,TrigVal(idxx(pp)))))
				if(isempty(TrigList))
					TrigList=TrigVal(idxx(pp));
					TrigListCount=1;
				else
					TrigList=cat(1,TrigList,TrigVal(idxx(pp)));
					TrigListCount(length(TrigList))=1;
				end;
			else
				idx=find(TrigList==TrigVal(idxx(pp)));
				TrigListCount(idx)=TrigListCount(idx)+1;
			end;
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
end;
