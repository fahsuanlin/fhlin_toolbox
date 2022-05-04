function inverse_render_dec(brain_patch_file,dec_dipole,dec_idx,varargin)

if(nargin==3)
    dec_idx_value=ones(size(dec_idx));
else
    dec_idx_value=varargin{1};
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualization of brain mesh using Matlab functions
%
% load the brain patch for visualization
fprintf('loading brain patch...\n');
load(brain_patch_file,'face','vertex','curv','orig2patch_idx','patch2orig_idx','triangle');


if((max(dec_dipole)==1)&(min(dec_dipole)==0))
    fprintf('input dec_dipole are [0/1] indicators.\n');
    dec_dipole=find(dec_dipole)-1;
else
    fprintf('input dec_dipole are decimated dipole indices.\n');
    if(min(dec_dipole)==0)
        fprintf('0-based decimated dipole indices!\n');
    else
        fprintf('NOT 0-based decimated dipole indices!\n');
        fprintf('NO further process here!! Take cautions!!\n');
    end;
end;
    


fg_idx=orig2patch_idx(dec_dipole+1);
fg_v=vertex(fg_idx+1,:);

fg_data=zeros(size(fg_v,1),1);
fg_data(dec_idx)=dec_idx_value;

	
inverse_render_brain(vertex,face,...
        'fg_data',fg_data,...
        'fg_v',fg_v,...
        'threshold',[0.5 10],...
        'bg_data',curv,...
        'dec_dipole',dec_dipole,...
        'interpolation','off',...
        'triangle',triangle);

        
%control the display of axis label
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
set(gca,'zticklabel',[]);
% no grid; no axis
set(gca,'NextPlot','replace','Visible','off');
hold on;

plot3(VMc(j,1),VMc(j,2),VMc(j,3),'.','Color',[1 1 1],'markersize',5);
		
return;