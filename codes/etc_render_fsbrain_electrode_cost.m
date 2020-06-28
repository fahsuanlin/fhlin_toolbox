function [cost, tmp_opt]=etc_render_fsbrain_electrode_cost(param,tmp, mri, tkrvox2ras,varargin)
%
% etc_render_fsbrain_electrode_cost  calculates the "cost" of electrode 
% contacts by pooling the MRI voxels corresponding to the location of each
% contact. 
%
% cost=etc_render_fsbrain_electrode_cost(param,coord, mri, tkrvox2ras)
%
% param: a 7-element vector describing the rotation and translation of
% *all* contacts for an electrode
%       param(1): azimuth rotation (degree)
%       param(2): vertical elevation (degree)
%       param(3): rotate angle rotation (degree)
%       param(4): translation up/down (mm)
%       param(6): translation left/right (mm)
%       param(6:8): reference coordinate for electrode rotation
% coord: a 3xN array of the coordinates of N contacts 
%
% cost: the cost of evaluation (sum of MRI voxel values)
%
% fhlin@apr. 8 2019
%

cost=inf;
tmp_opt=tmp;

flag_display=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;

% az=3; %degree;
% el=90; %degree
% rotate_angle=1; %degree
% translate_dist=3; % mm
% rotate_ref_coord=???
az=param(1);
el=param(2);
rotate_angle=param(3);
translate_dist0=param(4);
translate_dist1=param(5);
rotate_ref_coord=param(6:8);
%fprintf('%s\n',mat2str(param));

[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

theta=(rotate_angle).*pi/180;
R=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
%https://en.wikipedia.org/wiki/Rotation_matrix


%Rotation
tmp=tmp-repmat(rotate_ref_coord(:),[1 size(tmp,2)]);
tmp=R*tmp;
tmp=tmp+repmat(rotate_ref_coord(:),[1 size(tmp,2)]);

%Tramslation: up-down
tmp=tmp+repmat(uu(:).*translate_dist0,[1 size(tmp,2)]);

%Tramslation: left-right
tmp=tmp+repmat(rr(:).*translate_dist1,[1 size(tmp,2)]);

%get contact coordinates
D=1;
imm=[];
immv=[];

[zz,xx,yy]=size(mri);
mm=max([zz yy xx]);
cost=0;
for c_idx=1:size(tmp,2)
    surface_coord=tmp(:,c_idx);
    v=inv(tkrvox2ras)*[surface_coord(:); 1];
    click_vertex_vox=round(v(1:3))';
    
    
    %get MRI voxel values; the lower voxel intensity the better
    try
        img_cor0=squeeze(mri(:,:,round(click_vertex_vox(3))));
        img_cor1=squeeze(mri(:,:,round(click_vertex_vox(3))-1));
        img_cor2=squeeze(mri(:,:,round(click_vertex_vox(3))+1));
        img_cor_voxels0=img_cor0(click_vertex_vox(2)-D:click_vertex_vox(2)+D, click_vertex_vox(1)-D:click_vertex_vox(1)+D);
        img_cor_voxels1=img_cor1(click_vertex_vox(2)-D:click_vertex_vox(2)+D, click_vertex_vox(1)-D:click_vertex_vox(1)+D);
        img_cor_voxels2=img_cor2(click_vertex_vox(2)-D:click_vertex_vox(2)+D, click_vertex_vox(1)-D:click_vertex_vox(1)+D);
        
        img_sag0=squeeze(mri(:,round(click_vertex_vox(1)),:));
        img_sag1=squeeze(mri(:,round(click_vertex_vox(1))-1,:));
        img_sag2=squeeze(mri(:,round(click_vertex_vox(1))+1,:));
        img_sag_voxels0=img_sag0(click_vertex_vox(2)-D:click_vertex_vox(2)+D, click_vertex_vox(3)-D:click_vertex_vox(3)+D);
        img_sag_voxels1=img_sag1(click_vertex_vox(2)-D:click_vertex_vox(2)+D, click_vertex_vox(3)-D:click_vertex_vox(3)+D);
        img_sag_voxels2=img_sag2(click_vertex_vox(2)-D:click_vertex_vox(2)+D, click_vertex_vox(3)-D:click_vertex_vox(3)+D);
        
        img_ax0=rot90(squeeze(mri(round(click_vertex_vox(2)),:,:)));
        img_ax1=rot90(squeeze(mri(round(click_vertex_vox(2))-1,:,:)));
        img_ax2=rot90(squeeze(mri(round(click_vertex_vox(2))+1,:,:)));
        %img_ax=rot90(squeeze(mri(round(click_vertex_vox(2)),:,:)));
        img_ax_voxels0=img_ax0(click_vertex_vox(3)-D:click_vertex_vox(3)+D, mm-click_vertex_vox(1)-D:mm-click_vertex_vox(1)+D);
        img_ax_voxels1=img_ax1(click_vertex_vox(3)-D:click_vertex_vox(3)+D, mm-click_vertex_vox(1)-D:mm-click_vertex_vox(1)+D);
        img_ax_voxels2=img_ax2(click_vertex_vox(3)-D:click_vertex_vox(3)+D, mm-click_vertex_vox(1)-D:mm-click_vertex_vox(1)+D);
        
        %cost=sum(img_cor_voxels(:))+sum(img_sag_voxels(:))+sum(img_ax_voxels(:));
        cost0=sum(img_cor_voxels0(:).^2)+sum(img_sag_voxels0(:).^2)+sum(img_ax_voxels0(:).^2);
        cost1=sum(img_cor_voxels1(:).^2)+sum(img_sag_voxels1(:).^2)+sum(img_ax_voxels1(:).^2);
        cost2=sum(img_cor_voxels2(:).^2)+sum(img_sag_voxels2(:).^2)+sum(img_ax_voxels2(:).^2);
        cost=cost+cost0+cost1+cost2;
        cost=cost+cost0;
        if(flag_display)
            if(flag_display>1)
                fprintf('cost at contact [%d]=%d (cor, sag, ax)=(%d, %d, %d)\n',c_idx,cost, sum(img_cor_voxels0(:).^2), sum(img_sag_voxels0(:).^2), sum(img_ax_voxels0(:).^2)); %cost of each contact
            end;
            if(c_idx==0) %show images
                figure;
                subplot(1,3,1);
                imagesc(img_cor0); axis off image; colormap(gray); hold on;
                h=plot(click_vertex_vox(1),click_vertex_vox(2),'r.');
                
                subplot(1,3,2);
                imagesc(img_sag0); axis off image; colormap(gray); hold on;
                h=plot(click_vertex_vox(3),click_vertex_vox(2),'r.');
                
                subplot(1,3,3);
                imagesc(img_ax0); axis off image; colormap(gray); hold on;
                h=plot(click_vertex_vox(1),mm-click_vertex_vox(3),'r.');
                
            end;
%             fprintf('vvvvvvvvvvv contact %d vvvvvvvvv\n',c_idx);
%             img_cor_voxels0
%             img_sag_voxels0
%             img_ax_voxels0
%             fprintf('^^^^^^^^^^^^ contact %d ^^^^^^^^^^\n',c_idx);
            
        end;
    catch
        fprintf('something wrong in the cost...\n');
        cost=inf;
    end;
end;

if(flag_display)
end;

tmp_opt=tmp;

return;