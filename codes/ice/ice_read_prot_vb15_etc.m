function [MrProt]=ice_read_prot_vb15_etc(file_prot,varargin)
%   ice_read_prot_vb15_etc       reading protocol for VB15 only
%
%   [MrProt, sParam]=ice_read_prot_vb15_etc(file_prot)
%
%   file_prot: file name of the protocol ASCII file
%   MrPort: output protocol structure
%
%   fhlin@jan. 16 2008
%

MrProt=[];

for i=1:length(varargin)/2
    option=lower(varargin{i*2-1});
    option_value=varargin{i*2};
    
    switch(option)
        case 'mrprot'
            MrProt=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;


%% initialization
MrProt.lADCDuration=0;          %// ADC duration (us) used for regridding
MrProt.lRampTime=0;             %// Ramp Time for x gradient (us) for regridding
MrProt.lFlatTime=0;             %// Flat Time for x gradient (us) for regridding
MrProt.lRampMode=0;             %// 0 = trapezoid, 1 = sinusoid


MrProt_file = fopen(file_prot,'r');


sLine=0;
sLine=fgets(MrProt_file);
count=0;

while (sLine>-1)
    sLine=fgets(MrProt_file);

    eq=findstr(sLine,'ParamDouble."ADCDuration"');
    if(~isempty(eq))
        tmp=strread(sLine,'%s'); if(length(tmp)>=5) MrProt.lADCDuration= str2num(tmp{5}); end;
    end;
    
    eq=findstr(sLine,'ParamLong."RampupTime"');
    if(~isempty(eq))
        tmp=strread(sLine,'%s'); if(length(tmp)>=3) MrProt.lRampTime= str2num(tmp{3}); end;
    end;
    
    eq=findstr(sLine,'ParamLong."NRepMeas"');
    if(~isempty(eq))
        tmp=strread(sLine,'%s'); if(length(tmp)>=3) MrProt.lTimePoints= str2num(tmp{3}); end;
    end;

    eq=findstr(sLine,'ParamLong."NAveMeas"');
    if(~isempty(eq))
        tmp=strread(sLine,'%s'); if(length(tmp)>=3) MrProt.lRepetitions= str2num(tmp{3}); end;
    end;

    eq=findstr(sLine,'ParamLong."FlattopTime"');
    if(~isempty(eq))
        tmp=strread(sLine,'%s'); if(length(tmp)>=3) MrProt.lFlatTime= str2num(tmp{3}); end;
    end;

    eq=findstr(sLine,'sCoilSelectMeas.aRxCoilSelectData[0].asList.__attribute__.size');
    if(~isempty(eq))
        tmp=strread(sLine,'%s');
        if(length(tmp)>=3) MrProt.lNumberOfChannels= str2num(tmp{3}); end;
    end;

    
    eq=findstr(sLine,'aFFT_SCALE');
    if(~isempty(eq))
        if(~isempty(findstr(sLine,'lRxChannel')))
            MrProt.lNumberOfChannels= MrProt.lNumberOfChannels+1;
        end;
    end;
    
end;
fclose(MrProt_file);


if(abs(MrProt.lRampTime*MrProt.lADCDuration*MrProt.lFlatTime)<eps)
    MrProt.flag_regrid=0;
else
    MrProt.flag_regrid=1;
end;

return;
