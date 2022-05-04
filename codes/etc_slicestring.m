function etc_slicestring(sequence)

subjects={'ca','dj','hb','lp','ls','nd','rg','sr','ss','tw','uu','ws'};
tasks={'0.33l','1l','3l'};
func_path='c:/user/fhlin/motor/difference/bshort';
struct_path='c:/user/fhlin/motor/difference/bshort/struct';


fp=fopen('slicestring','w');
for t=1:length(tasks)
	for s=1:length(subjects)
		for i=1:length(sequence)

			str=sprintf('%s%s/%s.%s_%s.bshort%s,',char(39),func_path,char(subjects(s)),char(tasks(t)),num2str(sequence(i),'%03d'),char(39));
			fprintf(fp,'%s\n',str);
		end;
	end;
end;


fprintf(fp,'\n\n\n');

for i=1:length(sequence)
	str=sprintf('%s%s/struct_%s.bshort%s,',char(39),struct_path,num2str(sequence(i),'%03d'),char(39));
	fprintf(fp,'%s\n',str);
end;


fclose(fp);

disp('done! written to "slicestring" under current directory!');
