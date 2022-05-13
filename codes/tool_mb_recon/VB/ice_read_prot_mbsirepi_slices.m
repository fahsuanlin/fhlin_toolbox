function MrProt=ice_read_prot_mbsirepi_slices(file_prot,MrProt)

%   Read SMS-SIR-EPI parameters
%   Yi-Cheng Hsu
%


MrProt_file = fopen(file_prot,'r');


lRepetitions = 0;
MrProt.lSegments = 1;
MrProt.lNumberOfChannels = 0;
MrProt.swap_PE = 0;
MrProt.lFlyBack = 1;
MrProt.lRampMode = 0;  %// trapezoidal = default
MrProt.lFIDNav = 0;
MrProt.dCor=zeros(MrProt.lSlices,1);
MrProt.dTra=zeros(MrProt.lSlices,1);
MrProt.dSag=zeros(MrProt.lSlices,1);
sLine=0;
sLine=fgets(MrProt_file);
count=0;

while (sLine>-1)
    sLine=fgets(MrProt_file);
    eq=findstr(sLine,'=');
    if(~isempty(eq))
        sParameter=deblank(sLine(1:eq-1));
        psRemainder=sLine(eq+1:end);
        count=count+1;
        %//
        %// Pick the values of important parameters.
        %//
        

            for kk=0:MrProt.lSlices-1

                if ( ~isempty(findstr(sParameter,['sSliceArray.asSlice[' num2str(kk) '].sPosition.dCor'])))
                    MrProt.dCor(kk+1)= sscanf(psRemainder,'%f');
                end
     
                if ( ~isempty(findstr(sParameter,['sSliceArray.asSlice[' num2str(kk) '].sPosition.dTra'])))
                    MrProt.dTra(kk+1)= sscanf(psRemainder,'%f');
                end
                
                if ( ~isempty(findstr(sParameter,['sSliceArray.asSlice[' num2str(kk) '].sPosition.dSag'])))
                    MrProt.dTra(kk+1)= sscanf(psRemainder,'%f');
                end
            end
        
    end;
end;
fclose(MrProt_file);


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
