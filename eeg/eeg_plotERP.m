function []=eeg_plotERP(timeVec,data,varargin)
% eeg_plotERP    Plot event-related potentials (ERP's)
%
% []=eeg_plotERP(electrodes,varargin)
%
% modified from plotEF.m in 4D toolbox
%
% fhlin@jan. 3 2016
%

flag_show_electrodes=1;
flag_show_electrode_name=1;

topoconfig=[];
alim=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'topoconfig'
            topoconfig=option_value;
        case 'flag_show_electrodes'
            flag_show_electrodes=option_value;
        case 'flag_show_electrode_name'
            flag_show_electrode_name=option_value;
        case 'alim'
            alim=option_value;
        otherwise
            fprintf('unknown option [%s].\n',option);
            fprintf('error!\n');
            return;
    end;
end;

if(isempty(topoconfig))
    load('eeg_topoconfig32.mat');
end;


cx=topoconfig.electrodes_pos(:,1);
cy=topoconfig.electrodes_pos(:,2);
cl=topoconfig.electrodes;

cx=fmri_scale(cx,40,-40);
cy=fmri_scale(cy,40,-40);

nanidx=find(isnan(topoconfig.electrodes_vertex));

data(nanidx,:)=nan;

if(isempty(alim))
    amin=min(data(:));
    amax=max(data(:));
else
    amin=min(alim);
    amax=max(alim);
end;

rowEEG = 1:length(cx);

nplts = length(rowEEG);


px = 0.05+0.95*(cx - min(cx))/(0.06 + max(cx) - min(cx));
py = 0.8*(cy  - min(cy))/(0.04 + max(cy) - min(cy));
py =  py + 0.03;
px = 0.8*px;
for pos=1:nplts
    fprintf('%d ',pos);
    
    if(~isnan(px(rowEEG(pos))))
        axes('position',[px(rowEEG(pos)) py(rowEEG(pos)) 0.08 0.08]);
        
        h=line([min(timeVec) max(timeVec)],[0 0]); hold on;
        set(h,'color','k');
        h=line([0 0], [amin amax]); hold on;
        set(h,'color','k');
        
        
        plot(timeVec,squeeze(data(pos,:,:)));
        
        if(flag_show_electrode_name)
            h=title(topoconfig.electrodes{pos});
        end;
        
        axis off;
        set(gca,'XLim',[min(timeVec) max(timeVec)]);
        set(gca,'YLim',[amin amax]);
        
    end;
end
fprintf('\n');


axes('position',[0.8 0.9 0.07 0.07 ])

h=line([min(timeVec) max(timeVec)],[0 0]); hold on;
set(h,'color','k');
h=line([0 0], [amin amax]); hold on;
set(h,'color','k');

set(gca,'XLim',[min(timeVec) max(timeVec)]);
if ~isnan(amin)
    set(gca,'YLim',[amin amax]);
end
set(gca,'color','none');
%axis off;
xlabel('Time (s)')
h=ylabel('\muV'); set(h,'interp','tex');


return;
