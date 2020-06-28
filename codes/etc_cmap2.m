function [ mm ] = etc_cmap2( varargin )
%etc_cmap2    generate a colormap with three segments: two color scales at the lower and upper ends and one solid color in the middle
%
% [ mm ]= etc_cmap2(option, option_value...);
% 1st segment: signficant values color (default: blue <--> cyan from 'jet' colormap)
% 2nd segment: insignficant values color (default: gray [1 1 1].*0.5)
% 3rd segment: signficant values color (default: red <--> yellow from 'jet' colormap)
%
% options
%   v_lower: the extreme values (lower-/upper-bound values at the lower end) corresponding to the thresholded color (default: [-1 -0.95]).
%   v_upper: the extreme values (lower-/upper-bound values at the upper end) corresponding to the thresholded color (default: [0.95 1]).
%   d_v: the increment for signficant values (default: 0.05); 10 colors
%   will be generated for default v_lower and v_upper ranges.
%
%   Note: values falling between max(v_lower) and min(v_upper) will be
%   rendered using insignficiant value colors
%
%
%
%
% To use the colormap, try:
% > mm=etc_cmap2('v_lower',v_lower, 'v_upper',v_upper);
% > imagesc(data); 
% > colormap(mm);
% > caxis([min(v_lower) max(v_upper)]);
% > c=colorbar;set(c,'ylim',[[min(v_lower) max(v_upper)]);
%
%
% fhlin@apr 20 2015
%


v_upper=[1 0.95];
v_lower=[-0.95 -1];
d_v=0.05;


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case 'v_upper'
            v_upper=option_value;
        case 'v_lower'
            v_lower=option_value;
        case 'd_v'
            d_v=option_value;
        otherwise
            fprintf('unknown option [%s].\n error!\n',option);
            return;
    end;
end;

n_step_color_u=ceil(abs(diff(v_upper))/d_v);
n_step_color_l=ceil(abs(diff(v_lower))/d_v);


%prepare colormap
%figure(1)
%imagesc(jet)
cmap=jet(64); %upper colors
cmap_crop=cmap(41:64,:);
rr=([1:n_step_color_u]-1)/(n_step_color_u-1)*(size(cmap_crop,1)-1)+1;
ccmap_u=zeros(n_step_color_u,3);
ccmap_u(:,1)=interp1([1:size(cmap_crop,1)],cmap_crop(:,1),rr);
ccmap_u(:,2)=interp1([1:size(cmap_crop,1)],cmap_crop(:,2),rr);
ccmap_u(:,3)=interp1([1:size(cmap_crop,1)],cmap_crop(:,3),rr);


cmap=jet(64); %lower colors
cmap_crop=cmap(1:24,:);
rr=([1:n_step_color_l]-1)/(n_step_color_l-1)*(size(cmap_crop,1)-1)+1;
ccmap_l=zeros(n_step_color_l,3);
ccmap_l(:,1)=interp1([1:size(cmap_crop,1)],cmap_crop(:,1),rr);
ccmap_l(:,2)=interp1([1:size(cmap_crop,1)],cmap_crop(:,2),rr);
ccmap_l(:,3)=interp1([1:size(cmap_crop,1)],cmap_crop(:,3),rr);


n_step_middle=ceil((min(v_upper)-max(v_lower))/d_v);
mm=zeros(n_step_middle+n_step_color_l+n_step_color_u,3);
mm(1:n_step_color_l,:)=ccmap_l;
mm(n_step_color_l+n_step_middle+1:end,:)=ccmap_u;

ccmap_us=zeros(n_step_middle/2,3);
ccmap_us(:,1)=1;
ccmap_us(:,2)=1;
ccmap_us(:,3)=linspace(1,0,n_step_middle/2);
ccmap_us(:,3)=ccmap_us(:,3).^.10./max(ccmap_us(:,3));

ccmap_ls=zeros(n_step_middle/2,3);
ccmap_ls(:,1)=linspace(0,1,n_step_middle/2);
ccmap_ls(:,1)=ccmap_ls(:,1).^0.1./max(ccmap_ls(:,1));
ccmap_ls(:,2)=1;
ccmap_ls(:,3)=1;

ccmap_mm=cat(1,ccmap_ls,ccmap_us);

%mm(n_step_color_l+1:n_step_color_l+n_step_middle,:)=repmat([1 1 1].*0.5,[n_step_middle,1]); %solid gray
mm(n_step_color_l+1:n_step_color_l+n_step_middle,:)=ccmap_mm; %solid gray

return;

end

