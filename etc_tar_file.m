function etc_tar_file(source_file,tar_file)
fprintf('analyzing [%s]...\n',source_file);
[fList,pList] = matlab.codetools.requiredFilesAndProducts(source_file);

fprintf('making [%s]...\n',tar_file);
for i=1:length(fList)
    %if(isempty(findstr(fList{i},'.mat')))
     if(strcmp(fList{i}(end-3:end),'.mat'))
        fprintf('ignore matlab data file [%s]...',fList{i});
     else
        fprintf('\t[%s]...\n',fList{i});
        cmd=sprintf('!tar -rhf %s %s',tar_file,fList{i});
        eval(cmd);
    end;
end;

return;