function [ECG_Data trg_Data] = siemens_NCCU_ECGLoad(varargin)
% ECG_Data = siemens_NCCU_ECGLoad('ECG file name')
% ECG_Data = siemens_NCCU_ECGLoad('ECG file name',Reference Channel(1~4))
% ECG_Data = siemens_NCCU_ECGLoad('ECG file name',Reference Channel(1~4), ...
%                                  [Preview time interval])
% ECG_Data = siemens_NCCU_ECGLoad('ECG file name',Reference Channel(1~4), ...
%                                  [Preview time interval],Save Plot Mode)
% Default Reference Channel is 0. 
% Default Preview time interval is [0, 5].
% Save Plot Mode = 0: No saving plots.
% Save Plot Mode = 1: Save plots as PNG file. (default)
% Save Plot Mode = 2: Save and show plots with system dectection of local
% peak value occurs.
% ECG_Data including 4 channels of ECG raw data recorded by PMU in NCCU,
% export as a 4rows*(each channel's time series data) matrix.
% Also demonstrates the previews of ECG Signals comparing (minus) to
% the Reference Channel from t=0~5(default setting) secs.
% PMU sampleing rate is 400HZ in NCCU. 
% Edit by Jacky Lu 20170720
% global Marker_5000_6000
%% Parameters setting
fname = varargin{1};
Reference_Channel = 2;
Reference_time_interval_begin = 0;
Reference_time_interval_end = 5;
Plot_Mode = 0;
if(strcmp(fname(end-2:end),'ecg'))
else
    fprintf('Input Format is NOT ECG!!!\n')
end

if(length(varargin)==2)
    Reference_Channel = varargin{2};
end
if(length(Reference_Channel)~=1)
    fprintf('Invalid Reference Channel input!!!\n')
end

if(length(varargin)==3)
    if(isempty(varargin{2}))
    else
        Reference_Channel = varargin{2};
    end
    Reference_time_interval_begin = varargin{3}(1);
    Reference_time_interval_end = varargin{3}(2);
end

if(length(varargin)==4)
    if(isempty(varargin{2}))
    else
        Reference_Channel = varargin{2};
    end
    if(isempty(varargin{3}))
    else
        Reference_time_interval_begin = varargin{3}(1);
        Reference_time_interval_end = varargin{3}(2);
    end
    Plot_Mode = varargin{4};
end

%% Load whole ECG file
fclose('all');
fid = fopen(fname);
ECG_File = textscan(fid,'%s');
fclose('all');

%% Identify and extract the recorded ECG datas
% The numerical value in ECG File 6002 means the start of a series of 
% information such as header files and recorded data.
% The value 5003 means the end of a series on the other hand.
% The recorded ECG datas are between the LAST set of 6002 and 5003. 
for l=length(ECG_File{1}):-1:1
    if(strcmp(ECG_File{1}(l),'6002'))
        ECG_Start = l+1;
    end
end
for l=1:length(ECG_File{1})
    if(strcmp(ECG_File{1}(l),'5003'))
        ECG_End = l-1;
    end
end

temp_ECG_Data = ECG_File{1}(ECG_Start:ECG_End);
temp_ECG_Data = str2double(temp_ECG_Data);
% Takes most (>90%) of time in converting strings to doubles 


% 5000 and 6000 are system own evaluations, remove them.
tgr1 = 5000;
tgr2 = 6000;

% tic;
%Competetion start
% if(Plot_Mode==2)
%     %TaiYu
    tempMarker_5000 = temp_ECG_Data==tgr1;
    tempMarker_6000 = temp_ECG_Data==tgr2;
    tempMarker_5000_6000 = tempMarker_5000 + tempMarker_6000;
    Marker_5000_6000 = diff(tempMarker_5000_6000);
    Marker_5000_6000(end+1) = 0;
    Marker_5000_6000(Marker_5000_6000==-1)=[];
%     %YiTien
%     a=find(temp_ECG_Data==tgr1 | temp_ECG_Data==tgr2);
%     b=find(a~=-1);
%     ind=a-b;
% end

temp_ECG_Data(temp_ECG_Data==tgr1) = [];
temp_ECG_Data(temp_ECG_Data==tgr2) = [];
% Marker_5000_6000=zeros(1,size(temp_ECG_Data,2));
% Marker_5000_6000(ind)=1;
%Competetion end
% toc;

% Another way to do this:
% temp_ECG_Data = temp_ECG_Data(find(temp_ECG_Data~=tgr1));
% Maybe slower... logical judgements usually faster. Not quite sure.

ECG_Data = zeros(4,round(length(temp_ECG_Data)/4));
for l=1:4
    ECG_Data(l,:) = temp_ECG_Data(l:4:4*round(length(temp_ECG_Data)/4));
end
% if(Plot_Mode==2)
    Marker_5000_6000 = Marker_5000_6000(4:4:end);
% end

ind = find(Marker_5000_6000~=0);
trg_Data=zeros(2,size(ECG_Data,2));
trg_Data(1,ind(1:2:end))=1;
trg_Data(2,:) = 1/400:1/400:1/400*size(ECG_Data,2);

%% Give a preview of recorded ECG data

% Reference_Channel_Data = ECG_Data(Reference_Channel,:);
% counter = 0;
% t = Reference_time_interval_begin+1/400:1/400:...
%     Reference_time_interval_end+1/400;
% for l=1:4
%     if(l~=Reference_Channel)
%         tempChannel = ECG_Data(l,:);
%         counter = counter+1;
%         delta_value = tempChannel-Reference_Channel_Data;
%         p = subplot(3,1,counter);
%         plot(t,delta_value(Reference_time_interval_begin*400+1:...
%             Reference_time_interval_end*400+1))
% 
%         if(min(delta_value)>0)
%             ymin = min(delta_value)*0.95;
%             ymax = max(delta_value)*1.05;
%         else
%             ymin = min(delta_value)*1.05;
%             ymax = max(delta_value)*0.95;
%         end
%         
%         if(Plot_Mode==2)
%             tempMarker_5000_6000 = (Marker_5000_6000*...
%                                 (max(delta_value)-min(delta_value))) + ...
%                                 min(delta_value);
%             hold on
%             plot(t,tempMarker_5000_6000(Reference_time_interval_begin*400+1:...
%             Reference_time_interval_end*400+1))
%             hold off
%         end
%         
%         axis([Reference_time_interval_begin+1/400 ...
%             Reference_time_interval_end+1/400 ...
%             ymin ymax])
%         if(counter==1)
%             title(sprintf('Preview of recorded ECG data from t=%3.1f~%3.1f secs\nReference Channel = Channel %d',...
%                 Reference_time_interval_begin,Reference_time_interval_end,Reference_Channel));
%         end
%         xlabel('Time after recording started (secs)')
%     end
% end
% 
% if(Plot_Mode~=0)
%     saveas(p,sprintf('%s_t=%3.1f~%3.1f.png',fname(1:end-4),...
%         Reference_time_interval_begin,Reference_time_interval_end));
% end

end
