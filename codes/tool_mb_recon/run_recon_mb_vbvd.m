%recon_script
function run_recon_mb_vbvd(sub_path,save_path)
% cd(sub_path)
% 20160126
% ref_files=dir([sub_path,'raw/*MBSIREPI*ref*.dat']);
% acc_files=dir([sub_path,'raw/*MBSIREPI*acc*.dat']);
ref_files=dir([sub_path,'*ref*.dat']);
acc_files=dir([sub_path,'*acc*.dat']);
mkdir([save_path,'recon/']);

version=checkVersion([sub_path,ref_files(1).name]);

if version=='vb'
    for i=1:length(acc_files)

        [ ref,EPInew ] = MBrecon_vb( [sub_path,ref_files(i).name],[sub_path,acc_files(i).name],0.0001 );
         acc=abs(EPInew(:,:,:,1:end));
         save([save_path,'recon/mb_run_',num2str(i),'_ref.mat'],'ref','-v7.3');
         save([save_path,'recon/mb_run_',num2str(i),'.mat'],'acc','-v7.3');

    end
elseif version=='vd'
    for i=1:length(acc_files)
    
%    [ ref,EPInew ] = MBrecon( [sub_path,'raw/',ref_files(i).name],[sub_path,'raw/',acc_files(i).name],0.0005  ); % default
     [ ref,EPInew ] = MBrecon( [sub_path,ref_files(i).name],[sub_path,acc_files(i).name],0.0005  ); % default
     acc=abs(EPInew(:,:,:,1:end));%dummy scan=60
     save([save_path,'recon/mb_run_',num2str(i),'_ref.mat'],'ref','-v7.3');
     save([save_path,'recon/mb_run_',num2str(i),'.mat'],'acc','-v7.3');

    end
end
