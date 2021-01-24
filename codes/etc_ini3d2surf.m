function flag=etc_ini3d2surf(data,varargin)

flag=0;
fstem='';
file_mgh_template='';
file_register='';
timeVec='';

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};
	switch lower(option)
	case 'fstem'
		fstem=option_value;
	case 'file_mgh_template'
		file_mgh_template=option_value;
	case 'file_register'
		file_register=option_value;
	case 'timevec'
		timeVec=option_value;
	end;
end;


if(isempty(file_mgh_template))
	error('No MGH template file define!\n');
	return;
end;
if(isempty(fstem))
	fstem='ini3d2surf';
end;
if(isempty(timeVec))
	timeVec=[0:1:size(data,4)-1];
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saving reconstructed data into MGH format for surface/movie rendering

brain = MRIread(file_mgh_template);
brain.vol=data;
brain.nframes=size(data,4);
fn_brain=sprintf('%s.mgh',fstem);
MRIwrite(brain,fn_brain);
%do this outside matlab....
%make sure freesurfer environment, register file, and subjects directory are all set.
fn_brain_lh=sprintf('%s-lh.mgh',fstem);
fn_brain_rh=sprintf('%s-rh.mgh',fstem);

cmd=sprintf('!mri_vol2surf --src ./%s --srcreg %s --hemi lh --noreshape --out ./%s',fn_brain,file_register,fn_brain_lh);
eval(cmd);

cmd=sprintf('!mri_vol2surf --src ./%s --srcreg %s --hemi rh --noreshape --out ./%s',fn_brain,file_register,fn_brain_rh);
eval(cmd);

eval(sprintf('!rm %s',fn_brain));

brain_lh = MRIread(fn_brain_lh);
stc=squeeze(brain_lh.vol);
if(length(timeVec)>1)
	fn_brain_lh_stc=sprintf('%s-lh.stc',fstem);
	inverse_write_stc(stc,[0:brain_lh.nvoxels-1],timeVec(1).*1e3,mean(diff(timeVec)).*1e3,fn_brain_lh_stc);
else
        fn_brain_lh_stc=sprintf('%s-lh.stc',fstem);
        inverse_write_stc(stc(:),[0:brain_lh.nvoxels-1],0,1e3,fn_brain_lh_stc);
        %fn_brain_lh_w=sprintf('%s-lh.w',fstem);
        %inverse_write_wfile(fn_brain_lh_w,stc(:),[0:brain_lh.nvoxels-1]);
end;
eval(sprintf('!rm %s',fn_brain_lh));

brain_rh = MRIread(fn_brain_rh);
stc=squeeze(brain_rh.vol);
if(length(timeVec)>1)
	fn_brain_rh_stc=sprintf('%s-rh.stc',fstem);
	inverse_write_stc(stc,[0:brain_rh.nvoxels-1],timeVec(1).*1e3,mean(diff(timeVec)).*1e3,fn_brain_rh_stc);
else
        fn_brain_rh_stc=sprintf('%s-rh.stc',fstem);
        inverse_write_stc(stc(:),[0:brain_rh.nvoxels-1],0,1e3,fn_brain_rh_stc);
        %fn_brain_rh_w=sprintf('%s-rh.w',fstem);
        %inverse_write_wfile(fn_brain_rh_w,stc(:),[0:brain_rh.nvoxels-1]);
end;
eval(sprintf('!rm %s',fn_brain_rh));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('DONE!\n');

