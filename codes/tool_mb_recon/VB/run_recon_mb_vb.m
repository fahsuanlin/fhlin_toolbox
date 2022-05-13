%recon_script
function run_recon_mb_vb(sub_path,save_path)
% cd(sub_path)
% 20160126
% ref_files=dir([sub_path,'raw/*MBSIREPI*ref*.dat']);
% acc_files=dir([sub_path,'raw/*MBSIREPI*acc*.dat']);
ref_files=dir([sub_path,'*ref*.dat']);
acc_files=dir([sub_path,'*acc*.dat']);
mkdir([save_path,'recon/']);
for i=1:length(acc_files)

%     [ ref,EPInew ] = MBrecon( [sub_path,'raw/',ref_files(i).name],[sub_path,'raw/',acc_files(i).name],0.0005 );
    [ ref,EPInew ] = MBrecon_vb( [sub_path,ref_files(i).name],[sub_path,acc_files(i).name],0.0001 );
     acc=abs(EPInew(:,:,:,1:end));
     save([save_path,'recon/mb_run_',num2str(i),'_ref.mat'],'ref','-v7.3');
     save([save_path,'recon/mb_run_',num2str(i),'.mat'],'acc','-v7.3');
    %save([sub_path,'run_',num2str(i),'.mat'],'ref','EPInew','-v7.3');
end
