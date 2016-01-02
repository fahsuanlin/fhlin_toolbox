function [MrProt, sParam]=ice_read_prot(file_prot)
%   ice_read_prot       reading protocol ASCII file
%
%   [MrProt, sParam]=ice_read_prot(file_prot)
%   
%   file_prot: file name of the protocol ASCII file
%   MrPort: output protocol structure
%   sParam: output protocol variable list
%
%   fhlin@jan. 1 2005
%

MrProt=[];

%% initialization
  MrProt.lBaseResolution=0;       %// # of phase-encode steps in x
  MrProt.lPhaseEncodingLines=0;   %// # of phase-encode steps in y
  MrProt.lSegments=0;             %// # of segments
  MrProt.lNyPerSeg=0;             %// # of y lines per segment (lPhaseEncodingLines/lNyPerSeg)
  MrProt.lFIDNav=0;               %// # of FID navigator lines per excitation
  MrProt.lSlices=0;               %// # of slices
  MrProt.lPartitions=0;           %// # of partitions
  MrProt.lTimePoints=0;           %// # of time points (derived from repetitions)
  MrProt.lDummyScans=0;           %// # of dummy scans
  MrProt.lScanTimeSec=0;          %// scan time for one shot (sec)
  MrProt.lTotalScanTimeSec=0;     %// total scan time (sec)
  MrProt.lFlyBack=0;              %// number of times lines are retraced (1 or 2)
  MrProt.lNumberOfChannels=0;     %// # of receiver channels
  MrProt.lADCDuration=0;          %// ADC duration (us) used for regridding
  MrProt.lRampTime=0;             %// Ramp Time for x gradient (us) for regridding
  MrProt.lFlatTime=0;             %// Flat Time for x gradient (us) for regridding
  MrProt.lRampMode=0;             %// 0 = trapezoid, 1 = sinusoid
  MrProt.lTE=0;                   %// echo time
  MrProt.lTR=0;                   %// repetition time
  MrProt.swap_PE=0;               %// logical that is true for L->R (swap phase-encode)
  MrProt.fScaleFT=0;              %// Scale factor for FT for conversion to short integers
  MrProt.FileBshortOut='';        %// Output file for images.
  MrProt.BshortFileName='';       %// Output file for images.
      
  MrProt.acq_3D=0;                %// flag between 2D or 3D sequence
      
      
MrProt_file = fopen(file_prot,'r');


lRepetitions = 0;
MrProt.lSegments = 1;
MrProt.lNumberOfChannels = 0;
MrProt.swap_PE = 0;
MrProt.lFlyBack = 1;
MrProt.lRampMode = 0;  %// trapezoidal = default
MrProt.lFIDNav = 0;

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
        sParam{count}=sParameter;
       
        %//
        %// Pick the values of important parameters.
        %//
        
        lNumber = 1;
        if ( strcmp(sParameter,'sKSpace.lBaseResolution') )
            MrProt.lBaseResolution = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sKSpace.lPhaseEncodingLines') )
            MrProt.lPhaseEncodingLines = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'iNoOfFourierLines') )
            MrProt.lNoOfFourierLines = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'iNoOfFourierPartitions') )
            MrProt.lNoOfFourierPartitions = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sFastImaging.lSegments') )
            MrProt.lSegments = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sSliceArray.lSize') )
            MrProt.lSlices = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sKSpace.lPartitions') )
            MrProt.lPartitions = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'lRepetitions') )
            MrProt.lRepetitions = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'lContrasts') )
            MrProt.lContrasts = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'lScanTimeSec') )
            MrProt.lScanTimeSec = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'lTotalScanTimeSec') )
            MrProt.lTotalScanTimeSec = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'alTE[0]') )
            MrProt.lTE = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'alTR[0]') )
            MrProt.lTR = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sWiPMemBlock.alFree[4]') )
            MrProt.lDummyScans = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sWiPMemBlock.alFree[14]') )
            MrProt.lADCDuration = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sWiPMemBlock.alFree[15]') )
            MrProt.lRampTime = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sWiPMemBlock.alFree[16]') )
            MrProt.lFlatTime = sscanf(psRemainder,'%d');
        elseif ( strcmp(sParameter,'sWiPMemBlock.alFree[17]') )
            MrProt.lFIDNav = sscanf(psRemainder,'%d');
            if ( MrProt.lFIDNav ~= 1 )
                MrProt.lFIDNav = 0;
            else
                MrProt.lFIDNav = 2;
            end;
        elseif ( strcmp(sParameter,'sRXSPEC.aFFT_SCALE[0].flFactor') )
            MrProt.fScaleFT = sscanf(psRemainder,'%f');
            MrProt.lNumberOfChannels=MrProt.lNumberOfChannels+1;
            MrProt.fScaleFT = MrProt.fScaleFT/4;
        elseif ( ~isempty(findstr(sParameter,'aflRegridADCDuration')))
            psRemainder=psRemainder(2:end); %// step one space to get past '[' character
            if(psRemainder(1)=='[') psRemainder=psRemainder(2:end); end;
            MrProt.lADCDuration = sscanf(psRemainder,'%d');
            MrProt.lADCDuration=MrProt.lADCDuration(1);
        elseif ( ~isempty(findstr(sParameter,'alRegridRampupTime')))
            psRemainder=psRemainder(2:end); %// step one space to get past '[' character
            if(psRemainder(1)=='[') psRemainder=psRemainder(2:end); end;
            MrProt.lRampTime = sscanf(psRemainder,'%d');
            MrProt.lRampTime=MrProt.lRampTime(1);
        elseif ( ~isempty(findstr(sParameter,'alRegridFlattopTime')))
            psRemainder=psRemainder(2:end); %// step one space to get past '[' character
            if(psRemainder(1)=='[') psRemainder=psRemainder(2:end); end;
            MrProt.lFlatTime = sscanf(psRemainder,'%d');
            MrProt.lFlatTime=MrProt.lFlatTime(1);
        elseif (~isempty(findstr(sParameter,'MRAcquisitionType')))
            if(~isempty(findstr(psRemainder,'3D')))
                MrProt.acq_3D = 1;
            end;
        elseif ( strcmp(sParameter,'sSliceArray.asSlice[0].dInPlaneRot') )
            MrProt.swap_PE = 1;
        elseif ( ~isempty(findstr(sParameter,'sRXSPEC.aFFT_SCALE')))
            MrProt.lNumberOfChannels=MrProt.lNumberOfChannels+1;
        elseif ( ~isempty(findstr(sParameter,'sSpecPara.lFinalMatrixSizeRead')))
            MrProt.pepsi_spectrum_length= sscanf(psRemainder,'%d');
        elseif ( ~isempty(findstr(sParameter,'sSpecPara.lVectorSize')))
            MrProt.pepsi_freq= sscanf(psRemainder,'%d');
            MrProt.svs_vector_size= sscanf(psRemainder,'%d');           
	end;
        
    end;
end;
fclose(MrProt_file);


MrProt.lNumberOfChannels=MrProt.lNumberOfChannels./3;

MrProt.lTimePoints = lRepetitions+1;
MrProt.lNyPerSeg   = MrProt.lPhaseEncodingLines / MrProt.lSegments;

if(abs(MrProt.lRampTime*MrProt.lADCDuration*MrProt.lFlatTime)<eps)
	MrProt.flag_regrid=0;
else
	MrProt.flag_regrid=1;
end;

return;
