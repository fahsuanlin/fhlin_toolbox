function sm=fmri_datamat_smooth(roi_center,smooth_kernel,datamat,coords,sz)

fprintf('smoothing datamat at center of %s ....\n',mat2str(roi_center,2));

[roi_cubic_x,roi_cubic_y,roi_cubic_z]=size(smooth_kernel);

fprintf('calculating ROI%d index...\n',j);
k1=[round((1-roi_cubic_x)/2):round((1-roi_cubic_x)/2)+roi_cubic_x-1];
k2=[round((1-roi_cubic_y)/2):round((1-roi_cubic_y)/2)+roi_cubic_y-1];
k3=[round((1-roi_cubic_z)/2):round((1-roi_cubic_z)/2)+roi_cubic_z-1];

count=1;
for i=1:length(k1)
    for j=1:length(k2)
        for k=1:length(k3)
            coords_entries(count)=sub2ind([sz(2) sz(1) sz(3)], roi_center(2)+k1(i), roi_center(1)+k2(j), roi_center(3)+k3(k));
            count=count+1;
        end;
    end;
end;

[common, idx_roi,idx2]=intersect(coords, coords_entries);


sm=sum(datamat(:,idx_roi).*repmat(smooth_kernel(idx2),[size(datamat,1),1]),2);


return;
