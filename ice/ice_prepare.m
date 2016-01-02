function [ice_obj]=ice_prepare(MrProt,varargin)
global ice_m_data;
global ice_m_data_burst;
global ice_obj;

nx=[];
ny=[];
nz=[];
for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
	switch(lower(option))
            case 'nx'
                nx=option_value;
            case 'ny'
                ny=option_value;
            case 'nz'
                nz=option_value;
   	end;
end;

ice_obj.flag_init = 1;			%we use this flag for later on data archiving to indicate the first time point measurement.
ice_obj.MrProt    = MrProt;

if(isempty(nx))
	ice_obj.m_NxRaw   = MrProt.lBaseResolution;
else
	ice_obj.m_NxRaw   = nx;
end;

if(isempty(ny))
	ice_obj.m_NyRaw   = MrProt.lPhaseEncodingLines;
else
	ice_obj.m_NyRaw	  = ny;
end;	

if(~MrProt.acq_3D)
    fprintf('2D sequence...\n');
    if(isempty(nz))
	    ice_obj.m_Nz      = MrProt.lSlices;
    else
	    ice_obj.m_Nz      = nz;
    end;
    ice_obj.flag_3D   = 0;
else
    fprintf('3D sequence...\n');
    if(isempty(nz))
	    ice_obj.m_Nz      = MrProt.lPartitions;
    else
   	    ice_obj.m_Nz      = nz;
    end;
    ice_obj.flag_3D   = 1;
end;
%if(isempty(ice_obj.m_NChan))
	ice_obj.m_NChan   = MrProt.lNumberOfChannels;
    %end;

if(isempty(nx))
	ice_obj.m_NxImage = MrProt.lBaseResolution;
else
	ice_obj.m_NxImage = nx;
end;

if(isempty(ny))
	ice_obj.m_NyImage = MrProt.lPhaseEncodingLines;
	ice_obj.m_NyFT    = MrProt.lPhaseEncodingLines;
else
	ice_obj.m_NyImage = ny;
	ice_obj.m_NyFT    = ny;
end;



%this is for partial Fourier phase encoding
if(isfield(MrProt,'lNoOfFourierLines'))
	ice_obj.m_PEshift =MrProt.lPhaseEncodingLines -MrProt.lNoOfFourierLines;
else
	ice_obj.m_PEshift = 0;
end;

%this is for partial Fourier phase encoding
if(isfield(MrProt,'lNoOfFourierLines'))
        ice_obj.m_PAshift =MrProt.lPartitions -MrProt.lNoOfFourierPartitions;
else
        ice_obj.m_PAshift = 0;
end;


if(isfield(MrProt,'lContrasts'))
	ice_obj.m_NContrast=MrProt.lContrasts;
else
	ice_obj.m_NContrast=1;
end;

%ice_obj.flag_regrid = MrProt.flag_regrid;


%initialize memory for PEPSI data
if(ice_obj.flag_pepsi)
    fprintf('PEPSI data initialization\n');
    fprintf('\tspectrum length = [%d]\n',MrProt.pepsi_spectrum_length);
    fprintf('\tfreq. encoding = [%d]\n',MrProt.pepsi_freq);
    fprintf('\tphase encoding 1= [%d]\n',ice_obj.m_NyImage);
    fprintf('\tphase encoding 2= [%d]\n',ice_obj.m_Nz);	
    fprintf('\tchannel = [%d]\n',ice_obj.m_NChan);
    ice_obj.m_NxImage=MrProt.pepsi_freq;
    ice_obj.m_NxRaw=MrProt.pepsi_freq;
    if(ice_obj.flag_3D)
	fprintf('3D PEPSI...\n');
	ice_m_data= zeros(MrProt.pepsi_freq, MrProt.pepsi_spectrum_length, ice_obj.m_NyImage, ice_obj.m_Nz, ice_obj.m_NChan);
    else
    	fprintf('2D PEPSI...\n');
	ice_m_data= zeros(MrProt.pepsi_freq, MrProt.pepsi_spectrum_length, ice_obj.m_NyImage, ice_obj.m_NChan);
    end;

elseif(ice_obj.flag_svs)
    %initialize memory for SVS data
    fprintf('SVS data initialization\n');
    fprintf('\tspectrum length = [%d]\n',MrProt.svs_vector_size);
    fprintf('\tchannel = [%d]\n',ice_obj.m_NChan);
    fprintf('\trepetition = [%d]\n',MrProt.lRepetitions+1);
    ice_m_data= zeros(MrProt.svs_vector_size, ice_obj.m_NChan, MrProt.lRepetitions+1);
elseif(ice_obj.flag_epi)
    %initialize memory for imaging data
    fprintf('EPI data initialization\n');
    fprintf('\tfreq. encoding = [%d]\n',ice_obj.m_NxImage);
    fprintf('\tphase encoding = [%d]\n',ice_obj.m_NyImage);
    fprintf('\tslice = [%d]\n',ice_obj.m_Nz);
    fprintf('\tchannel = [%d]\n',ice_obj.m_NChan);
    ice_m_data= zeros(ice_obj.m_NxImage, ice_obj.m_NyImage, ice_obj.m_Nz, ice_obj.m_NChan, ice_obj.m_NContrast);
    ice_obj.nav_image=zeros(ice_obj.m_NxImage, ice_obj.m_NyImage, ice_obj.m_Nz, ice_obj.m_NChan);

    ice_obj.disable_phasecor_data=0; 	%this flag is to enable only the first set of phase correction data. fhlin@dec 30, 2006

    if(ice_obj.flag_output_burst)
	if(ice_obj.m_NContrast>1)
		ice_m_data_burst=zeros(ice_obj.m_NxImage, ice_obj.m_NyImage, ice_obj.m_Nz, ice_obj.m_NChan, ice_obj.m_NContrast, ice_obj.n_measurement);
	else
		ice_m_data_burst=zeros(ice_obj.m_NxImage, ice_obj.m_NyImage, ice_obj.m_Nz, ice_obj.m_NChan, ice_obj.n_measurement);
	end;

	ice_obj.output_burst_count=1;
    end;
elseif(ice_obj.flag_ini3d)
    %3D InI acqusiitions
    fprintf('3D InI acquisitions\n');
    fprintf('\tchannel = [%d]\n',ice_obj.m_NChan);
    fprintf('\tmeasurements = [%d phase]x[%d partition] = %d\n',MrProt.lNoOfFourierLines, MrProt.lNoOfFourierPartitions, MrProt.lNoOfFourierLines*MrProt.lNoOfFourierPartitions);

    ice_m_data= zeros(ice_obj.m_NxImage*2, ice_obj.m_NChan, MrProt.lNoOfFourierLines*MrProt.lNoOfFourierPartitions);
    ice_obj.ini3d_counter=0;
    ice_obj.ini3d_total_pe=MrProt.lNoOfFourierLines*MrProt.lNoOfFourierPartitions;

    ice_obj.output_burst_count=1;
end;


%  // Find the number of expected ADC reads.  This will enable consistency checks.
lADC_Expected = MrProt.lSegments * ( MrProt.lNyPerSeg + 3 )* MrProt.lSlices * MrProt.lTimePoints;

ice_obj.lADC_Actual = 0;

ice_obj.lNumberVolumes =0;


%[ice_obj]=ice_init_attributes(MrProt, ice_obj);    
[ok,lTest,lNext]=ice_is_power_of_2(ice_obj.m_NyFT);

if ( ~ok) ice_obj.m_NyFT = lNext; end;

%// The mosaic image will satisfy
%// 1) each panel will be square   and satisfy # pixels = 2^n in x and y
%// 2) the # panels will be square (e.g., total panels =1,2,4,9,16,25,36,...)
%//
%// CHOOSE THE SIZE OF THE PANELS:
%//
%// Find the larger of the 2 image dimensions.
ice_obj.m_DimPanel = ice_obj.m_NxImage;
if (ice_obj.m_DimPanel < ice_obj.m_NyImage) ice_obj.m_DimPanel = ice_obj.m_NyImage; end;
%// Increase this dimension (if necessary) to satisy 2^n.
lTest=1;
while (lTest < ice_obj.m_DimPanel)
    lTest=lTest*2;            
end;
ice_obj.m_DimPanel = lTest;

%//
%// CHOOSE THE NUMBER OF PANELS
%//
lTest = 1;
while (lTest*lTest < ice_obj.m_Nz ) 
    lTest=lTest+1;
end;
ice_obj.m_1dPanels = lTest;


%  // Initialize the regridding algorithm.
if(ice_obj.flag_regrid)
	ice_obj.trapezoid = ice_trapezoid_init(MrProt.lRampTime,...     %// time for one ramp of trapezoid
    		MrProt.lFlatTime,...                 %// flat time of trapezoid
    		MrProt.lADCDuration,...              %// ADC duration
    		2*ice_obj.m_NxRaw,...                        %// # x points to resample
    		MrProt.lRampMode);                   %// sinusiodal ramps? (logical variable)
end;

% %// Write the xds header file.
% [fpath,fstem,fext]=fileparts(MrProt.FileBshortOut);
% fn=sprintf('%s/%s.hdr',fpath,fstem);
% fp=fopen(fn,'w');
% fprintf( fp, '%d %d %d %d \n',...
%     ice_obj.m_1dPanels * ice_obj.m_DimPanel,...     %// Y
%     ice_obj.m_1dPanels * ice_obj.m_DimPanel,...     %// X
%     MrProt.lTimePoints,...          %// time
%     1);
% 
% fclose(fp);

%//
%// Output expectations.
if(~ice_obj.flag_3D)
    fprintf('Raw data:   (x, y, z, t)  = (%d, %d, %d, %d) with %d channels\n',...
        ice_obj.m_NxRaw, ice_obj.m_NyRaw, ice_obj.m_Nz, MrProt.lTimePoints,ice_obj.m_NChan);
    fprintf('Image data: (x, y, z, t)  = (%d, %d, %d, %d)\n',...
        ice_obj.m_NxImage, ice_obj.m_NyImage, ice_obj.m_Nz, MrProt.lTimePoints);
else
    fprintf('Raw data:   (x, y, z, t)  = (%d, %d, %d, %d) with %d channels\n',...
        ice_obj.m_NxRaw, ice_obj.m_NyRaw, ice_obj.m_Nz, MrProt.lTimePoints,ice_obj.m_NChan);
    fprintf('Image data: (x, y, z, t)  = (%d, %d, %d, %d)\n',...
        ice_obj.m_NxImage, ice_obj.m_NyImage, ice_obj.m_Nz, MrProt.lTimePoints);
end;

return;
