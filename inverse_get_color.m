function color=inverse_get_color(cmap,value,th_hi,th_lo)


th_lo_v=ones(size(value)).*th_lo;
th_hi_v=ones(size(value)).*th_hi;

idx=round((value-th_lo_v)./(th_hi-th_lo).*size(cmap,1));
idx(find(idx<1))=1;
idx(find(idx>size(cmap,1)))=size(cmap,1);

color=cmap(idx,:);

return;
