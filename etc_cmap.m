function [ mm ] = etc_cmap( varargin )
%etc_cmap    generate a colormap with three segments; useful for plotting
% upper/lower triangular matrices with thresholded values
%
% [ mm ]= etc_cmap(option, option_value...);
% 1st segment: background color (default: white)
% 2nd segment: insignficant values color (default: gray [1 1 1].*0.5)
% 3rd segment: signficant values color (default: red <--> yellow from 'jet' colormap)
%
% options
%   v_bg: the value corresponding to the background color (default: -1).
%   v_insig: the value corresponding to the lower bonund of insiginficant
%   color, i.e., the upper bound of background color  (default: 0).
%   v_lower: the value corresponding to the lower bound of the signficant
%   color, i.e., the upper bound of insignficant color (default: 0.95).
%   v_upper: the value corresponding to the upper bound of the signficant
%   color (default: 1).
%  n_step_color: the number of color steps for signficant values (default: 10)
%
%  By using default settings, values in the following ranges will be rendered with the colors:
%  [-1 0]: white
%  [0 0.95]: gray
%  [0.95 1]: yellow <--> red 
%
%
% To use the colormap, try:
% > mm=etc_cmap('v_lower',v_lower, 'v_upper',v_upper,'v_bg',v_bg,'v_insig',v_insig);
% > imagesc(data); 
% > colormap(mm);
% > caxis([v_bg v_upper]);
% > c=colorbar;set(c,'ylim',[v_lower v_upper]);
%
%
% fhlin@apr 17 2015
%


% Defaults
%-1: white
% 0: gray
% lower: color bottom
% upper: color top
% n_step_color

v_upper=1;
v_lower=0.95;
v_insig=0;
v_bg=-1;
n_step_color=10;

color_insig=[1 1 1].*0.5;
cmap=jet(64);
color_sig=cmap(41:64,:);

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case 'v_upper'
            v_upper=option_value;
        case 'v_lower'
            v_lower=option_value;
        case 'v_insig'
            v_insig=option_value;
        case 'v_bg'
            v_bg=option_value;
        case 'n_step_color'
            n_step_color=option_value;
        case 'color_insig'
            color_insig=option_value;
        case 'color_sig'
            color_sig=option_value;
        otherwise
            fprintf('unknown option [%s].\n error!\n',option);
            return;
    end;
end;


step=(v_upper-v_lower)./(n_step_color);
n_step_white=ceil((v_insig-v_bg)/step);
n_step_gray=ceil((v_lower-v_insig)/step);

%prepare colormap
%figure(1)
%imagesc(jet)
cmap_crop=color_sig;
rr=([1:n_step_color]-1)/(n_step_color-1)*(size(cmap_crop,1)-1)+1;
ccmap=zeros(n_step_color,3);
ccmap(:,1)=interp1([1:size(cmap_crop,1)],cmap_crop(:,1),rr);
ccmap(:,2)=interp1([1:size(cmap_crop,1)],cmap_crop(:,2),rr);
ccmap(:,3)=interp1([1:size(cmap_crop,1)],cmap_crop(:,3),rr);


mm=zeros(n_step_white+n_step_gray+n_step_color,3);
mm(1:n_step_white,:)=1; %solid white
mm(n_step_white+1:n_step_white+n_step_gray,:)=repmat(color_insig,[n_step_gray,1]); %solod gray
mm(n_step_white+n_step_gray+1:end,:)=ccmap;



end

