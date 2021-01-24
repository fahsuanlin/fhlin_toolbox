function cmap=etc_threshold_colorbar(h, clim,varargin)
% etc_threshold_color     modify the existing color bar and apply the
% current colorbar to the one with threshold values.
%
% cmap=etc_threshold_colorbar(h, clim, [option, option_value])
% h: the handle to the colorbar
% clim: a two-entry vector indicating the lower and upper bound of the new
% colorbar; 
% option:
%       'flag_apply': 0 or 1 (default value); the value to apply the new 
%       colormap to the handle 
%
% output:
% cmap: the new colormap;
%
% NOTE: "clim" is applied to both postive and negative values. For example,
% clim=[3 5] means that the values will be color-coded between [-5 -3] and
% [3 5]. All values between [-3 and 3] will be coor-coded by the middle
% value (0).
%
% fhlin@mar 12 2019
%

flag_apply=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'flag_apply' %apply the new colormap to the handle 
            flag_apply=option_value;
        otherwise
            fprintf('unknown option [%s].\nerror!\n',option);
            return;
    end;    
end;

hh=get(h,'parent');
cc=get(hh,'colormap'); %the original color map;

cmap=cc;

min(abs(clim));

output=interp1([-max(abs(clim)) max(abs(clim))],[1 size(cmap,1)],[-min(abs(clim)) min(abs(clim))],'linear');
clim_lower_neg=output(1);
clim_lower_pos=output(2);
clim_lower_neg=round(clim_lower_neg);
clim_lower_pos=round(clim_lower_pos);

cl=round(interp1([1 clim_lower_neg],[1 size(cc,1)/2],[1:clim_lower_neg]));
ch=round(interp1([clim_lower_pos size(cc,1)],[size(cc,1)/2 size(cc,1)],[clim_lower_pos:size(cc,1)]));
cc_idx=[cl(:); ones(size(cc,1)-length(cl)-length(ch),1).*size(cc,1)./2; ch(:)];

try
    cmap=cc(cc_idx,:);
    if(flag_apply)
        set(hh,'colormap',cmap);
    end;
catch ME
end;