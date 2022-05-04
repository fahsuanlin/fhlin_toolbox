function [vertex,face]=etc_read_nv(file_nv)

flag_v=0;
flag_f=0;
n_v=0;
n_f=0;

fid = fopen(file_nv);
tline=fgetl(fid);
while ischar(tline)
    tline = fgetl(fid);
    if(tline(1)=='#')
        fprintf('skip!\n');
    else
        n_v=sscanf(tline,'%d');
        vertex=zeros(n_v,3);
        for idx=1:n_v
            tline = fgetl(fid);
            tmp=sscanf(tline,'%f%f%f');
            vertex(idx,:)=tmp';
        end;
        tline = fgetl(fid);
        n_f=sscanf(tline,'%d');
        vertex=zeros(n_f,3);
        for idx=1:n_f
            tline = fgetl(fid);
            tmp=sscanf(tline,'%d%d%d');
            face(idx,:)=tmp';
        end;
        tline=0;
    end;
end

fclose(fid);