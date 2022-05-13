function MrProt=ice_read_prot_mbsirepi_FOV(file_prot,MrProt)

%   Read SMS-SIR-EPI parameters
%   Yi-Cheng Hsu





sLine=0;
MrProt_file = fopen(file_prot,'r');
sLine=fgets(MrProt_file);

while (sLine>-1)
    sLine=fgets(MrProt_file);
    eq=findstr(sLine,'<ParamDouble."ReadFoV">  { <Precision> 16  ');
    if(~isempty(eq))
        tmp=strread(sLine,'%s'); MrProt.lReadFoV = str2num(tmp{5});
    end;
    eq=findstr(sLine,'<ParamDouble."PhaseFoV">  { <Precision> 16  ');
    if(~isempty(eq))
        tmp=strread(sLine,'%s'); MrProt.lPhaseFoV = str2num(tmp{5});
    end;
end





return;
