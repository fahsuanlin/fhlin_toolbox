function ff=etc_plot_localk(localk,varargin)
% etc_plot_localk       plot local k-space
%
% h=etc_plot_localk(localk, [option, option_value],...);
%
% localk: a structure of local k-space data
%   kx: 2D array [n_k,n_p] of k_x coordinates; n_k: number of k-space
%   points, n_p: number of local k-space plot
%   ky: 2D array [n_k,n_p] of k_y coordinates; n_k: number of k-space
%   points, n_p: number of local k-space plot
%   pos_x: 2D array [n_p_freq, n_p_phase] about the x coordinates of the 
%   image to show local k space data; n_p_freq*n_p_phase=n_p
%   pos_y: 2D array [n_p_freq, n_p_phase] about the y coordinates of the 
%   image to show local k space data; n_p_freq*n_p_phase=n_p
%
%   For example, image voxel (pos_y(1),pos_x(1)) has local k-space data
%   at kx(:,1) and ky(:,1)
%
% h: handle of the output figure
%
% fhlin@jan. 10 2011
%

k_color=[0 0 1];
k_box_color=[0 0 0];
k_bg_color=[1 1 1];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'k_color'
            k_color=option_value;
        case 'k_bg_color'
            k_bg_color=option_value;
        case 'k_box_color'
            k_box_color=option_value;
        otherwise
            fprintf('unknownn option [%s]...\nerror!\n',option);
            return;
    end;
end;

ff=figure; set(gcf,'color','w');

nx=size(localk.pos_x,2);
ny=size(localk.pos_x,1);
xlim=[-pi.*1 pi.*1].*2;
ylim=[-pi.*1 pi.*1].*2;

dx=1/nx;
dy=1/ny;
dx_shift=dx./20;
dy_shift=dy./20;

p_idx=1;
for y_idx=1:ny
    for x_idx=1:nx
        %subplot(ny,nx,p_idx,'align');
        subplot('position',[(x_idx-1)*dx+dx_shift 1-(y_idx)*dy+dy_shift dx dy]);
        h=plot(localk.kx(1:5:end,p_idx),localk.ky(1:5:end,p_idx),'.');
        set(h,'color',k_color); 
        hold on;
        set(h,'Markersize',2);    
        
        %plot a box indicating the resolution
        h=rectangle('pos',[-pi.*1,-pi.*1,2*pi,2*pi]); 
        if(isempty(k_box_color))
            k_box_color='k';
        end;
        set(h,'edgecolor',k_box_color);
        
        if(isempty(k_color))
            k_bg_color='k';
        end;
        set(gca,'color',k_bg_color);
        
        axis equal;
        
        set(gca,'xtick',[],'ytick',[],'xcolor',k_bg_color,'ycolor',k_bg_color);
        set(gca,'xlim',xlim,'ylim',ylim);
        p_idx=p_idx+1;
    end;
end;
set(gcf,'color',k_bg_color,'invert','off');

pp=get(gcf,'pos');
mm=max(pp(3),pp(4));
pp=[pp(1) pp(2) mm mm];

set(gcf,'pos',pp);
return;