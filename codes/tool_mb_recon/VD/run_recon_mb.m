%recon_script
function run_recon_mb(sub_path,save_path)
% cd(sub_path)
% 20160126
ref_files=dir([sub_path,'raw/*MBSIREPI*ref*.dat']);
acc_files=dir([sub_path,'raw/*MBSIREPI*acc*.dat']);
% ref_files=dir([sub_path,'*MBSIREPI*ref*.dat']);
% acc_files=dir([sub_path,'*MBSIREPI*acc*.dat']);
mkdir([save_path,'recon/']);
for i=1:length(acc_files)
    
    [ ref,EPInew ] = MBrecon( [sub_path,'raw/',ref_files(i).name],[sub_path,'raw/',acc_files(i).name],0.0005  ); % default
%     [ ref,EPInew ] = MBrecon( [sub_path,ref_files(i).name],[sub_path,acc_files(i).name],0.0005  );
%     [ ref,EPInew ] = MBrecon( [sub_path,'raw/',ref_files(i).name],[sub_path,'raw/',acc_files(i).name],0.05 ); % test1
%     [ ref,EPInew ] = MBrecon( [sub_path,'raw/',ref_files(i).name],[sub_path,'raw/',acc_files(i).name],0.000005 );% test2
%     [ ref,EPInew ] =MBrecon_slicegrappa( [sub_path,'raw/',ref_files(i).name],[sub_path,'raw/',acc_files(i).name]); %  slicegrappa
%     [ ref,EPInew ] =MBrecon_spslicegrappa( [sub_path,'raw/',ref_files(i).name],[sub_path,'raw/',acc_files(i).name]); % btter slicegrappa

     acc=abs(EPInew(:,:,:,61:end));
     save([save_path,'recon/mb_run_',num2str(i),'_ref.mat'],'ref','-v7.3');
     save([save_path,'recon/mb_run_',num2str(i),'.mat'],'acc','-v7.3');
    %save([sub_path,'run_',num2str(i),'.mat'],'ref','EPInew','-v7.3');
end
