function fmri_svcor(cor,CorDir)

%restore the permute di
cor = permute(cor, [3 2 1]);


d = dir(CorDir);
if(isempty(d))
   fprintf('Directory %s does not exist!\n',CorDir);
   %creating IMG root directory
   fprintf('Creating directory [%s] now!\n',CorDir);
   status=mkdir(CorDir);
end;

slices=[1:size(cor,2)];
nslices = length(slices);
%cor = zeros(256,nslices,256);

Endian = 0;
precision = 'uint8';
Nv = 256*256;

fprintf(1,'Saving corronals to [%s]. Total [%d] slices ... \n',...
        CorDir,nslices);

for s = 1:nslices

  n = slices(s);

  corfile = sprintf('%s/COR-%03d',CorDir,n);
  
  
  %%%% Open the corfile %%%%%
  if(Endian == 0) fid=fopen(corfile,'w','b'); % Big-Endian
  else            fid=fopen(corfile,'w','l'); % Little-Endian
  end
  if(fid == -1)
    fprintf('Could not open %s for saving.\n',corfile); 
  end

  %%% Save the file in corfile %%%
  %cor(:,s,:) = reshape(z, [256 256])'; %' transpose for row major
  %z = fwrite(fid,Nv,precision);
  
  cc=fwrite(fid,squeeze(cor(:,s,:))',precision);
  fclose(fid); 
  
  

end
fprintf(1,'Done \n');
