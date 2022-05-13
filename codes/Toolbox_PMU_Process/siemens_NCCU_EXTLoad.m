function EXT_Data = siemens_NCCU_EXTLoad(varargin)
% EXT_Data = siemens_NCCU_EXTLoad('EXT file name')
% EXT_Data = siemens_NCCU_EXTLoad('EXT file name',[Preview time interval])
% EXT_Data = siemens_NCCU_EXTLoad('EXT file name',[Preview time interval],Save Plot Mode)
% Default Preview time interval is [0, 25].
% Save Plot Mode = 0: No saving plots.
% Save Plot Mode = 1: Save plots as PNG file. (default)
% Save Plot Mode = 2: Save and show plots with system dectection of local
% peak value occurs.
% EXT_Data (EXT raw data) recorded by PMU in NCCU,
% PMU sampleing rate is 400HZ in NCCU. 
% Edit by Jacky Lu 20170720

%% Parameters setting
fname = varargin{1};
Reference_time_interval_begin = 0;
Reference_time_interval_end = 25;
Plot_Mode = 0;
if(strcmp(fname(end-2:end),'ext'))
else
    fprintf('Input Format is NOT EXT!!!\n')
end

if(length(varargin)==2)
    Reference_time_interval_begin = varargin{2}(1);
    Reference_time_interval_end = varargin{2}(2);
end

if(length(varargin)==3)
    if(isempty(varargin{2}))
    else
        Reference_time_interval_begin = varargin{2}(1);
        Reference_time_interval_end = varargin{2}(2);
    end
    Plot_Mode = varargin{3};
end

%% Load whole EXT file
fclose('all');
fid = fopen(fname);
EXT_File = textscan(fid,'%s');
fclose('all');

%% Identify and extract the recorded EXT datas
% The numerical value in EXT File 6002 means the start of a series of 
% information such as header files and recorded data.
% The value 5003 means the end of a series on the other hand.
% The recorded EXT datas are between the LAST set of 6002 and 5003. 
        EXT_Start = 5;
for l=1:length(EXT_File{1})
    if(strcmp(EXT_File{1}(l),'5003'))
        EXT_End = l-1;
    end
end

temp_EXT_Data = EXT_File{1}(EXT_Start:EXT_End);
temp_EXT_Data = str2double(temp_EXT_Data);
% Takes most (>90%) of time in converting strings to doubles 


% 5000 are system own evaluations, remove them.
tgr1 = 5000;

%Competetion start
if(Plot_Mode==2)
%     %TaiYu
    Marker_5000 = temp_EXT_Data==tgr1;
%     %YiTien
%     a=find(temp_EXT_Data==tgr1);
%     b=find(a~=-1);
%     ind=a-b;
end
temp_EXT_Data(temp_EXT_Data==tgr1) = [];
%Competetion end

% Another way to do this:
% temp_EXT_Data = temp_EXT_Data(find(temp_EXT_Data~=tgr1));
% Maybe slower... logical judgements usually faster. Not quite sure.

EXT_Data = zeros(2,length(temp_EXT_Data));

EXT_Data(1,:) = temp_EXT_Data(1:end);
EXT_Data(2,:) = 1/400:1/400:1/400*length(temp_EXT_Data);

if(Plot_Mode==2)
    Marker_5000 = Marker_5000(1:end);
end
%% Give a preview of recorded EXT data

% counter = 0;
% t = Reference_time_interval_begin+1/400:1/400:...
%     Reference_time_interval_end+1/400;
% 
%         tempChannel = EXT_Data(1,:);
%         counter = counter+1;
%         delta_value = tempChannel;
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
%             tempMarker_5000 = (Marker_5000*...
%                                 (max(delta_value)-min(delta_value))) + ...
%                                 min(delta_value);
%             hold on
%             plot(t,tempMarker_5000(Reference_time_interval_begin*400+1:...
%             Reference_time_interval_end*400+1))
%             hold off
%         end
%         
%         axis([Reference_time_interval_begin+1/400 ...
%             Reference_time_interval_end+1/400 ...
%             ymin ymax])
%         if(counter==1)
%             title(sprintf('Preview of recorded EXT data from t=%3.1f~%3.1f secs\n',...
%                 Reference_time_interval_begin,Reference_time_interval_end));
%         end
%         xlabel('Time after recording started (secs)')
% 
% 
% if(Plot_Mode~=0)
%     saveas(p,sprintf('%s_t=%3.1f~%3.1f.png',fname(1:end-4),...
%         Reference_time_interval_begin,Reference_time_interval_end));
% end

end
