function ice_master(varargin)
%test

%setting up defaults
file_prot='meas.asc';   %default protocol file name
file_raw='meas.out';    %defualt rawdata file name

flag_VA21=1;
flag_VA15=0;
flag_VB13=0;
flag_VB15=0;
flag_VD11=0;

idea_ver='VA21';

flag_debug=0;
flag_debug_file=0;

output_stem='meas';
flag_scan_mdh_only=0;
flag_output_reim=1;
flag_output_maph=0;
flag_output_burst=0;
n_measurement=1;

flag_phase_cor=1;
flag_phase_cor_mgh=1;
flag_phase_cor_jbm=0;

flag_phase_cor_algorithm_jbm=1;
flag_phase_cor_algorithm_lsq=0;
flag_rev_even_odd=0;

flag_shimming_cor=0;

flag_phase_cor_offset=0;
flag_archive_nav_jbm=0;

nav_data_fraction=[];
nav_phase_offset_override=[];
nav_phase_slope_override=[];

flag_archive_segments=0;

flag_epi=1;
flag_sege=0;
flag_pepsi=0;
flag_svs=0;
flag_ini3d=0;
flag_phase_cor_ini=0;
flag_3d=[];

flag_autocrop=0;

flag_regrid=1;

slice_order='interleave';		%slice order can be "interleave" or "sequential".

n_channel=[];
array_index=[];

nx=[];
ny=[];
nz=[];

max_avg=inf;

clear global ice_obj;

if(nargin==0)
    file_prot='meas.asc';
    file_raw='meas.out';
    file_stem='meas';
    fprintf('using [meas.asc] and [meas.out] as input files.\n');
else
    for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
        
        switch(lower(option))
            case 'file_prot'
                file_prot=option_value;
                fprintf('protocol file = [%s]\n',file_prot);
            case 'file_raw'
                file_raw=option_value;
                fprintf('raw data file = [%s]\n',file_raw);
            case 'output_stem'
                output_stem=option_value;
                fprintf('output file stem = [%s]\n',file_raw);
            case 'flag_output_reim'
                flag_output_reim=option_value;
                fprintf('output as [real/imag] images\n');
            case 'flag_output_maph'
                flag_output_maph=option_value;
                fprintf('output as [mag/phas] images\n');
            case 'flag_debug'
                flag_debug=option_value;
                if(flag_debug)
                    fprintf('debug ON! flag_debug = [%d]\n',flag_debug);
                else
                    fprintf('debug OFF!\n');
                end;
            case 'flag_debug_file'
                flag_debug_file=option_value;
                if(flag_debug_file)
                    fprintf('debug to ON! flag_debug_file = [%d]\n',flag_debug_file);
                else
                    fprintf('debug to file OFF!\n');
                end;
            case 'flag_scan_mdh_only'
                flag_debug=option_value;
                if(flag_scan_mdh_only)
                    fprintf('Scanning MDH in [%s[ without reading raw data!\n',file_raw);
                else
                    fprintf('Scanning MDH and reading reaw data! [%s]\n',file_raw);
                end;
            case 'flag_phase_cor'
                flag_phase_cor=option_value;
                if(flag_phase_cor)
                    fprintf('EPI phase correction enabled!\n');
                end;
            case 'flag_phase_cor_mgh'
                flag_phase_cor_mgh=option_value;
                if(flag_phase_cor_mgh)
                    flag_phase_cor_jbm=0;
                end;
                if(flag_phase_cor_mgh)
                    fprintf('Estimate EPI phase correction using 3-scan at the center of k-space!\n');
                end;
            case 'flag_phase_cor_jbm'
                flag_phase_cor_jbm=option_value;
                if(flag_phase_cor_jbm)
                    flag_phase_cor_mgh=0;
                end;
                if(flag_phase_cor_jbm)
                    fprintf('Estimate EPI phase correction using whole image!\n');
                end;
            case 'flag_phase_cor_algorithm_jbm'
                flag_phase_cor_algorithm_jbm=option_value;
                if(flag_phase_cor_algorithm_jbm)
                    flag_phase_cor_algorithm_lsq=0;
                end;
            case 'flag_phase_cor_algorithm_lsq'
                flag_phase_cor_algorithm_lsq=option_value;
                if(flag_phase_cor_algorithm_lsq)
                    flag_phase_cor_algorithm_jbm=0;
                end;
            case 'flag_phase_cor_ini'
                flag_phase_cor_ini=option_value;
            case 'flag_rev_even_odd'
                flag_rev_even_odd=option_value;
            case 'flag_phase_cor_offset'
                flag_phase_cor_offset=option_value;
            case 'flag_shimming_cor'
                flag_shimming_cor=option_value;
            case 'nav_data_fraction'
                nav_data_fraction=option_value;
            case 'nav_phase_offset_override'
                nav_phase_offset_override=option_value;
            case 'nav_phase_slope_override'
                nav_phase_slope_override=option_value;
            case 'flag_regrid'
                flag_regrid=option_value;
                if(flag_regrid)
                    fprintf('Regridding on read-out enabled!\n');
                else
                    fprintf('Regridding on read-out disabled!\n');
                end;
            case 'flag_archive_nav_jbm'
                flag_archive_nav_jbm=option_value;
            case 'flag_archive_segments'
                flag_archive_segments=option_value;
            case 'flag_epi'
                flag_epi=option_value;
                flag_sege=0;
                flag_svs=0;
                flag_pepsi=0;
                flag_ini3d=0;
                fprintf('reading EPI data!\n');
            case 'flag_sege'
                flag_epi=0;
                flag_sege=option_value;
                flag_svs=0;
                flag_pepsi=0;
                flag_ini3d=0;
                fprintf('reading SE/GE data!\n');
            case 'flag_pepsi'
                flag_pepsi=option_value;
                flag_epi=0;
                flag_sege=0;
                flag_svs=0;
                flag_ini3d=0;
                fprintf('reading PEPSI data!\n');
            case 'flag_ini3d'
                flag_ini3d=option_value;
                flag_epi=0;
                flag_sege=0;
                flag_svs=0;
                flag_pepsi=0;
            case 'n_channel'
                n_channel=option_value;
            case 'array_index'
                array_index=option_value;
            case 'flag_svs'
                flag_svs=option_value;
                flag_epi=0;
                flag_pepsi=0;
                flag_ini3d=0;
                fprintf('reading SVS data!\n');
            case 'flag_autocrop'
                flag_autocrop=option_value;
            case 'max_avg'
                max_avg=option_value;
            case 'flag_output_burst'
                flag_output_burst=option_value;
            case 'n_measurement'
                n_measurement=option_value;
            case 'slice_order'
                slice_order=option_value;
            case 'nx'
                nx=option_value;
            case 'ny'
                ny=option_value;
            case 'nz'
                nz=option_value;
            case 'flag_3d'
                flag_3d=option_value;
            case 'flag_vb13'
                flag_VB13=option_value;
                raw_file_specified=0;
                for i=1:length(varargin)/2
                    if(~isempty(findstr(varargin{i*2-1},'file_raw')))
                        raw_file_specified=1;
                    end;
                end;
                if(~raw_file_specified)
                    file_raw='meas.dat';
                end;
            case 'flag_vb15'
                flag_VB15=option_value;
                raw_file_specified=0;
                for i=1:length(varargin)/2
                    if(~isempty(findstr(varargin{i*2-1},'file_raw')))
                        raw_file_specified=1;
                    end;
                end;
                if(~raw_file_specified)
                    file_raw='meas.dat';
                end;
            case 'flag_vd11'
                flag_VD11=option_value;
                raw_file_specified=0;
                for i=1:length(varargin)/2
                    if(~isempty(findstr(varargin{i*2-1},'file_raw')))
                        raw_file_specified=1;
                    end;
                end;
                if(~raw_file_specified)
                    file_raw='meas.dat';
                end;
            case 'flag_va21'
                flag_VA21=option_value;
            case 'flag_va15'
                flag_VA15=option_value;
            otherwise
                fprintf('unknown option [%s]. Error!\n\n',option);
                return;
        end;
    end;
end;

global ice_obj;
global ice_m_data;
clear ice_obj;
clear ice_m_data;

fprintf('reading protocol [%s]...\n',file_prot);
if(flag_VB13)
    file_in=fopen(file_raw,'r','ieee-le');
    tmp=fread( file_in,2,'int32');
    fprintf('VB13 :: data starts at [%d] bytes offset\n',tmp(1));
    fprintf('VB13 :: [%d] protocols included\n',tmp(2));
    for j=1:tmp(2)
        fname = [];
        fname_char = fread(file_in,1,'uchar');
        while(fname_char>0)
            fname=strvcat(fname,fname_char);
            fname_char = fread(file_in,1,'uchar');
        end;
        flength=fread(file_in,1,'int32');
        fprintf('VB13 :: \t#%d protocol : <%s> [%d] bytes...\n',j,fname, flength);
        fprot{j}.name=fname';
        fprot{j}.size=flength;
        fprot{j}.data=fread(file_in,flength,'uchar');
    end;
    
    for j=1:tmp(2)
        if(~isempty(findstr(lower(fprot{j}.name),'meas')))
            fp=fopen(sprintf('vb13_meas.asc.tmp'),'w');
            fprintf(fp,'%s',(fprot{j}.data));
            fclose(fp);
        end;
    end;
    fclose(file_in);
    
    MrProt=ice_read_prot('vb13_meas.asc.tmp');
elseif(flag_VB15)
    file_in=fopen(file_raw,'r','ieee-le');
    tmp=fread( file_in,2,'int32');
    fprintf('VB15 :: data starts at [%d] bytes offset\n',tmp(1));
    fprintf('VB15 :: [%d] protocols included\n',tmp(2));
    for j=1:tmp(2)
        fname = [];
        fname_char = fread(file_in,1,'uchar');
        while(fname_char>0)
            fname=strvcat(fname,fname_char);
            fname_char = fread(file_in,1,'uchar');
        end;
        flength=fread(file_in,1,'int32');
        fprintf('VB15 :: \t#%d protocol : <%s> [%d] bytes...\n',j,fname, flength);
        fprot{j}.name=fname';
        fprot{j}.size=flength;
        fprot{j}.data=fread(file_in,flength,'uchar');
    end;
    
    for j=1:tmp(2)
        fp=fopen(sprintf('vb15_meas_%02d.asc',j),'w');
        fprintf(fp,'%s',char(fprot{j}.data));
        fclose(fp);
        
    end;
    fclose(file_in);
    
    MrProt=ice_read_prot('vb15_meas_04.asc');
    MrProt=ice_read_prot_vb15_etc('vb15_meas_04.asc','MrProt',MrProt); %read number of channels; vb15
    MrProt=ice_read_prot_vb15_etc('vb15_meas_01.asc','MrProt',MrProt); %read regrid parameters; vb15
    if(flag_svs)
        MrProt=ice_read_prot_vb15_etc('vb15_meas_01.asc','MrProt',MrProt); %read n_average parameters; vb15
    end;
    
elseif(flag_VD11)
    tic;
    file_in = fopen(file_raw,'r','l','US-ASCII'); % US-ASCII necessary for UNIX based systems
    fseek(file_in,0,'eof');
    fileSize = ftell(file_in);
    
    % start of actual measurment data (scan header)
    fseek(file_in,0,'bof');
    
    meas_ID  = fread(file_in,1,'uint32');
    n_measraw = fread(file_in,1,'uint32');
    
    fprintf('VD:: [%d] raw file measurements\n',n_measraw);
    
    for j=1:n_measraw
        meas_ID(j)=fread(file_in,1,'uint32');
        file_ID(j)=fread(file_in,1,'uint32');
        measOffset(j) = fread(file_in,1,'uint64');
        measLength(j) = fread(file_in,1,'uint64');
        patientName(j) = fread(file_in,1,'uint64');
        protocolName(j) = fread(file_in,1,'uint64');
    end;
    
    
    fseek(file_in,measOffset(1),'bof');
    
    for j=1:n_measraw
        
        hdrLength(j)  = fread(file_in,1,'uint32');
        fprintf('measurement [%d] has a header of %d (bytes)\n',j, hdrLength(j));
        
        buffer=fread(file_in,hdrLength(j),'uchar');
        
        fp=fopen(sprintf('vd11_meas_%02d.asc',j),'w');
        
        fprintf(fp,'%c',char(buffer));
        fclose(fp);
        MrProt=ice_read_prot(sprintf('vd11_meas_%02d.asc',j));
        MrProt=ice_read_prot_vb15_etc(sprintf('vd11_meas_%02d.asc',j),'MrProt',MrProt); %read number of channels; vb15
    end;
    fclose(file_in);
else
    MrProt=ice_read_prot(file_prot);
end;



fprintf('reading raw data [%s]...\n',file_raw);
fp=fopen(file_raw);


%// Compute images only when raw data streaming is turned off.
%///////////////////////////////////////////////////////////////////////////
%////////////////////////// Call of Prepare Function ///////////////////////
%///////////////////////////////////////////////////////////////////////////
%// Do ICE preparation for image computations
global ice_obj;

ice_obj.flag_pepsi=flag_pepsi;
ice_obj.flag_svs=flag_svs;
ice_obj.flag_epi=flag_epi;
ice_obj.flag_sege=flag_sege;
ice_obj.flag_ini3d=flag_ini3d;
ice_obj.slice_order=slice_order;

ice_obj.flag_regrid=flag_regrid;

ice_obj.flag_archive_nav_jbm=flag_archive_nav_jbm;

ice_obj.flag_output_burst=flag_output_burst;
ice_obj.n_measurement=n_measurement;

if(~isempty(nav_phase_offset_override))
    fprintf('phase correction [offset] has been overriden!\n');
    ice_obj.nav_phase_offset_override=nav_phase_offset_override;
end;
if(~isempty(nav_phase_slope_override))
    fprintf('phase correction [slope] has been overriden!\n');
    ice_obj.nav_phase_slope_override=nav_phase_slope_override;
end;



if(~isempty(n_channel))
    ice_obj.m_NChan=n_channel;
else
    ice_obj.m_NChan=[];
end;
if(~isempty(flag_3d))
    fprintf('forced 3D flag = %d\n',flag_3d);
    MrProt.acq_3D=flag_3d;
end;

if(~isempty(n_channel))
    MrProt.lNumberOfChannels=n_channel;
end;

[ice_obj]= ice_prepare(MrProt);

if(ice_obj.flag_svs)
    ice_obj.svs_vector_size=MrProt.svs_vector_size;
end;

ice_obj.flag_debug=flag_debug;
ice_obj.flag_debug_file=flag_debug_file;
ice_obj.idea_ver=idea_ver;

ice_obj.output_stem=output_stem;
ice_obj.flag_output_reim=flag_output_reim;
ice_obj.flag_output_maph=flag_output_maph;

ice_obj.nav_count=0;
ice_obj.flag_phase_cor=flag_phase_cor;
ice_obj.flag_phase_cor_mgh=flag_phase_cor_mgh;
ice_obj.flag_phase_cor_jbm=flag_phase_cor_jbm;
ice_obj.flag_phase_cor_offset=flag_phase_cor_offset;
ice_obj.flag_phase_cor_algorithm_jbm=flag_phase_cor_algorithm_jbm;
ice_obj.flag_phase_cor_algorithm_lsq=flag_phase_cor_algorithm_lsq;
ice_obj.flag_phase_cor_ini=flag_phase_cor_ini;
ice_obj.flag_rev_even_odd=flag_rev_even_odd;

ice_obj.flag_shimming_cor=flag_shimming_cor;

ice_obj.nav_data_fraction=nav_data_fraction;

ice_obj.flag_archive_segments=flag_archive_segments;

ice_obj.max_avg=max_avg;

%// Open the output file for writing.
%// This will be available in IceFake_online (..., etc.) through the protocol (MrProt).
%fp_out=fopen(file_output,'w');

%//
%// Allocate complex floating point data for each ADC read.
%//
if(~flag_pepsi	)
    if(isempty(nx))
        lNxOverSamp     = 2 * MrProt.lBaseResolution;    %// Actual n
    else
        lNxOverSamp     = 2 * nx;
    end;
else
    lNxOverSamp	= 2 * ice_obj.m_NxImage;
end;


lLengthFifoData = lNxOverSamp * MrProt.lNumberOfChannels;

if(~ice_obj.flag_svs)
    sFifo.FCData    = zeros(lNxOverSamp,MrProt.lNumberOfChannels);
else
    sFifo.FCData    = zeros(ice_obj.svs_vector_size.*2,MrProt.lNumberOfChannels);
end;

%///////////////////////////////////////////////////////////////////////////
%////////////////////// Begin reading the input file ///////////////////////
%///////////////////////////////////////////////////////////////////////////
%// Open the file for reading.
file_in=fopen(file_raw,'r');

if(ice_obj.flag_debug_file)
    ice_obj.fp_debug=fopen('ice_master_debug.txt','w');
end;



if(flag_VB13|flag_VB15)
    jump=fread( file_in,8,'int32');
    fseek(file_in,jump(1),-1);
elseif(flag_VD11)
    fseek(file_in,0,'eof');
    fileSize = ftell(file_in);
    fseek(file_in,measOffset(1),'bof'); %multi-raid file header
    for j=1:n_measraw
        %hdrLength(j)  = fread(file_in,1,'uint32');
        fseek(file_in,hdrLength(j),'cof');    %measurement header
    end;
else
    %// There are 32 bytes on top (uninteresting, as far as I can tell).
    dummy = fread( file_in,8,'long');
    if ( length(dummy)~=8 )
        fprintf('\nError reading the top 32 bytes (error = %d).\n', length(dummy)*4);
        return;
    end;
end;


if (flag_debug>= 2 )
    for j=0:7
        fprintf('dummy[%d] = %d\n',j,dummy(j+1));
    end;
end;

if(flag_VA21)
    ice_va21_def;
end;
%//
%// Begin the loop of MDH, FIFO, MDH, FIFO, ...
%//
flag_cont=1;
fprintf('accessing raw data...\n');

sLC_max=zeros(1,9);


array_idx_buffer=[];

flag_VD11_init=1;

while (flag_cont)
    if(flag_VD11)
        
        %check current position in the raw file
        if( ftell(file_in)+128<fileSize)
            flag_cont=1;
        else
            flag_cont=0;
            break;
        end;
        
        %read scan MDH
        sMdh_scan=ice_read_mdh_vd11(file_in);
        
        %initial check and adjustment
        if(flag_VD11_init)
            if(MrProt.lNumberOfChannels~=sMdh_scan.ushUsedChannels)
                fprintf('warning! MDH has different number of channels [%d] from what was found in the protocol [%d]!\n',sMdh_scan.ushUsedChannels,MrProt.lNumberOfChannels);
                fprintf('re-initializing space for raw data reading...\n');
                
                MrProt.m_NChan=sMdh_scan.ushUsedChannels;
                MrProt.lNumberOfChannels=sMdh_scan.ushUsedChannels;
                [ice_obj]= ice_prepare(MrProt);
                
            end;
            
            sFifo.lDimX =  ice_obj.m_NxRaw*2;
            sFifo.lDimXOp = ice_obj.m_NxRaw*2;
            sFifo.lDimC = sMdh_scan.ushUsedChannels;
            
            flag_VD11_init=0;
        end;
        
        
        %debug....
        if(ice_obj.flag_debug_file)
            fprintf(ice_obj.fp_debug,' =================== MDH %d =======================\n',sMdh_scan.ulScanCounter);
            fprintf(ice_obj.fp_debug,'# samples in scan   = %d\n',sMdh_scan.ushSamplesInScan);
            %if ( sMdh_scan.ushUsedChannels ~= 1 )
            %    fprintf(ice_obj.fp_debug,'# channels = %d, channel ID = %d\n',sMdh_scan.ushUsedChannels,sMdh_ch.ushChannelID);
            %end;
            %// Special flags:
            fprintf(ice_obj.fp_debug,'flags: ');
            
            if ( sMdh_scan.aulEvalInfoMask(1) & MDH_PHASCOR )           fprintf(ice_obj.fp_debug,'PhaseCor ');        end;
            if ( sMdh_scan.aulEvalInfoMask(1) & MDH_FIRSTSCANINSLICE )  fprintf(ice_obj.fp_debug,'FirstInSlice ');    end;
            if ( sMdh_scan.aulEvalInfoMask(1) & MDH_LASTSCANINSLICE )   fprintf(ice_obj.fp_debug,'LastInSlice ');     end;
            if ( sMdh_scan.aulEvalInfoMask(1) & MDH_REFLECT )           fprintf(ice_obj.fp_debug,'Reflect ');         end;
            if ( sMdh_scan.aulEvalInfoMask(1) & MDH_REFPHASESTABSCAN )  fprintf(ice_obj.fp_debug,'RefNav');           end;
            if ( sMdh_scan.aulEvalInfoMask(1) & MDH_PHASESTABSCAN )     fprintf(ice_obj.fp_debug,'Nav');              end;
            
            fprintf(ice_obj.fp_debug,'\n');
            %//	  printf(' --------------- LOOP COUNTERS -----------------\n');
            fprintf(ice_obj.fp_debug,'REP = %d, SLC = %d, SEG = %d, LIN = %d, \n',...
                sMdh_scan.sLC.ushRepetition,sMdh_scan.sLC.ushSlice,sMdh_scan.sLC.ushSeg,sMdh_scan.sLC.ushLine);
            fprintf(ice_obj.fp_debug,'ACQ = %d, PAR = %d, ECO = %d, PHS = %d, SET = %d,\n ',...
                sMdh_scan.sLC.ushAcquisition,sMdh_scan.sLC.ushPartition,sMdh_scan.sLC.ushEcho,sMdh_scan.sLC.ushPhase,sMdh_scan.sLC.ushSet);
            
        end;
        
        %check if it is the end of raw file
        if (bitand(sMdh_scan.aulEvalInfoMask(1), MDH_ACQEND) ) flag_cont=0; break; end;
        
        
        %read data
        data=fread(file_in, [2 sMdh_scan.ushUsedChannels*(sMdh_scan.ushSamplesInScan+4)],'float'); %read 32 more bytes to account for channel MDH
        data=reshape(data(1,:)+sqrt(-1).*data(2),[sMdh_scan.ushSamplesInScan+4 sMdh_scan.ushUsedChannels]);
        sFifo.FCData=data(5:end,:);
        
        %process data
        [ok]= ice_online(sMdh_scan, sFifo);
        
    else
        if(flag_VA21)
            sMdh=ice_read_mdh_va21(file_in);
        end;
        
        
        sLC_now=[sMdh.sLC.ushRepetition,sMdh.sLC.ushSlice,sMdh.sLC.ushSeg,sMdh.sLC.ushLine,sMdh.sLC.ushAcquisition,sMdh.sLC.ushPartition,sMdh.sLC.ushEcho,sMdh.sLC.ushPhase,sMdh.sLC.ushSet];
        sLC_max=max(cat(1,sLC_now,sLC_max),[],1);
        
        if (flag_debug)
            
            fprintf(' =================== MDH %d =======================\n',sMdh.ulScanCounter);
            fprintf('# samples in scan   = %d\n',sMdh.ushSamplesInScan);
            if ( sMdh.ushUsedChannels ~= 1 )
                fprintf('# channels = %d, channel ID = %d\n',sMdh.ushUsedChannels,sMdh.ulChannelId);
            end;
            %// Special flags:
            fprintf('flags: ');
            if(flag_VA15)
                if ( sMdh.ulEvalInfoMask & MDH_PHASCOR )               fprintf('PhaseCor ');        end;
                if ( sMdh.ulEvalInfoMask & MDH_FIRSTSCANINSLICE )      fprintf('FirstInSlice ');    end;
                if ( sMdh.ulEvalInfoMask & MDH_LASTSCANINSLICE )       fprintf('LastInSlice ');     end;
                if ( sMdh.ulEvalInfoMask & MDH_REFLECT )               fprintf('Reflect ');         end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_REFPHASESTABSCAN )  fprintf('RefNav');           end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_PHASESTABSCAN )     fprintf('Nav');              end;
            end;
            if(flag_VA21)
                if ( sMdh.aulEvalInfoMask(1) & MDH_PHASCOR )           fprintf('PhaseCor ');        end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_FIRSTSCANINSLICE )  fprintf('FirstInSlice ');    end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_LASTSCANINSLICE )   fprintf('LastInSlice ');     end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_REFLECT )           fprintf('Reflect ');         end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_REFPHASESTABSCAN )  fprintf('RefNav');           end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_PHASESTABSCAN )     fprintf('Nav');              end;
            end;
            fprintf('\n');
            %//	  printf(' --------------- LOOP COUNTERS -----------------\n');
            fprintf('REP = %d, SLC = %d, SEG = %d, LIN = %d\n',...
                sMdh.sLC.ushRepetition,sMdh.sLC.ushSlice,sMdh.sLC.ushSeg,sMdh.sLC.ushLine);
            fprintf('ACQ = %d, PAR = %d, ECO = %d, PHS = %d, SET = %d\n',...
                sMdh.sLC.ushAcquisition,sMdh.sLC.ushPartition,sMdh.sLC.ushEcho,sMdh.sLC.ushPhase,sMdh.sLC.ushSet);
            if(flag_VA15)
                fprintf('FRE = %d\n',sMdh.sLC.ushFree);
            end;
            if(flag_VA21)
                fprintf('FRE = %d %d %d %d %d\n',sMdh.sLC.ushIda,...
                    sMdh.sLC.ushIdb,sMdh.sLC.ushIdc,sMdh.sLC.ushIdd,sMdh.sLC.ushIde);
            end;
            
            if ( flag_debug >= 2 )
                fprintf('DMA length          = %d\n',sMdh.ulDMALength);
                fprintf('measurement user ID = %d\n',sMdh.lMeasUID);
                fprintf('time stamp          = %d\n',sMdh.ulTimeStamp);
                fprintf('PMU time stamp      = %d\n',sMdh.ulPMUTimeStamp);
                fprintf(' ----------------------------------------------\n');
                fprintf('filled zeros (pre)  = %d\n',sMdh.sCutOff.ushPre);
                fprintf('filled zeros (post) = %d\n',sMdh.sCutOff.ushPost);
                fprintf('center line of echo = %d\n',sMdh.ushKSpaceCentreColumn);
                fprintf('swapping variable   = %d\n',sMdh.ushDummy);
                fprintf('Readout offcenter   = %f\n',sMdh.fReadOutOffcentre);
                fprintf('time since last RF  = %d\n',sMdh.ulTimeSinceLastRF);
                fprintf('k-space center line = %d\n',sMdh.ushKSpaceCentreLineNo);
                fprintf('k-space center part = %d\n',sMdh.ushKSpaceCentrePartitionNo);
                fprintf('free parameter[1]   = %d\n',sMdh.aushFreePara(1));
                fprintf('free parameter[2]   = %d\n',sMdh.aushFreePara(2));
                fprintf('free parameter[3]   = %d\n',sMdh.aushFreePara(3));
                fprintf('free parameter[4]   = %d\n',sMdh.aushFreePara(4));
                fprintf('slice position      = %f %f %f\n',sMdh.sSD.sSlicePosVec.flSag,...
                    sMdh.sSD.sSlicePosVec.flCor,...
                    sMdh.sSD.sSlicePosVec.flTra);
                fprintf('slice rot. matrix   = %f %f %f %f\n',sMdh.sSD.aflQuaternion(1),...
                    sMdh.sSD.aflQuaternion(2),...
                    sMdh.sSD.aflQuaternion(3),...
                    sMdh.sSD.aflQuaternion(4));
                
            end;
        end;
        
        if(ice_obj.flag_debug_file&&(sum(array_idx_buffer)==0))
            fprintf(ice_obj.fp_debug,' =================== MDH %d =======================\n',sMdh.ulScanCounter);
            fprintf(ice_obj.fp_debug,'# samples in scan   = %d\n',sMdh.ushSamplesInScan);
            if ( sMdh.ushUsedChannels ~= 1 )
                fprintf(ice_obj.fp_debug,'# channels = %d, channel ID = %d\n',sMdh.ushUsedChannels,sMdh.ulChannelId);
            end;
            %// Special flags:
            fprintf(ice_obj.fp_debug,'flags: ');
            if(flag_VA15)
                if ( sMdh.ulEvalInfoMask & MDH_PHASCOR )               fprintf(ice_obj.fp_debug,'PhaseCor ');        end;
                if ( sMdh.ulEvalInfoMask & MDH_FIRSTSCANINSLICE )      fprintf(ice_obj.fp_debug,'FirstInSlice ');    end;
                if ( sMdh.ulEvalInfoMask & MDH_LASTSCANINSLICE )       fprintf(ice_obj.fp_debug,'LastInSlice ');     end;
                if ( sMdh.ulEvalInfoMask & MDH_REFLECT )               fprintf(ice_obj.fp_debug,'Reflect ');         end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_REFPHASESTABSCAN )  fprintf(ice_obj.fp_debug,'RefNav');           end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_PHASESTABSCAN )     fprintf(ice_obj.fp_debug,'Nav');              end;
            end;
            if(flag_VA21)
                if ( sMdh.aulEvalInfoMask(1) & MDH_PHASCOR )           fprintf(ice_obj.fp_debug,'PhaseCor ');        end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_FIRSTSCANINSLICE )  fprintf(ice_obj.fp_debug,'FirstInSlice ');    end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_LASTSCANINSLICE )   fprintf(ice_obj.fp_debug,'LastInSlice ');     end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_REFLECT )           fprintf(ice_obj.fp_debug,'Reflect ');         end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_REFPHASESTABSCAN )  fprintf(ice_obj.fp_debug,'RefNav');           end;
                if ( sMdh.aulEvalInfoMask(1) & MDH_PHASESTABSCAN )     fprintf(ice_obj.fp_debug,'Nav');              end;
            end;
            fprintf(ice_obj.fp_debug,'\n');
            %//	  printf(' --------------- LOOP COUNTERS -----------------\n');
            fprintf(ice_obj.fp_debug,'REP = %d, SLC = %d, SEG = %d, LIN = %d, ',...
                sMdh.sLC.ushRepetition,sMdh.sLC.ushSlice,sMdh.sLC.ushSeg,sMdh.sLC.ushLine);
            fprintf(ice_obj.fp_debug,'ACQ = %d, PAR = %d, ECO = %d, PHS = %d, SET = %d, ',...
                sMdh.sLC.ushAcquisition,sMdh.sLC.ushPartition,sMdh.sLC.ushEcho,sMdh.sLC.ushPhase,sMdh.sLC.ushSet);
            if(flag_VA15)
                fprintf(ice_obj.fp_debug,'FRE = %d\n',sMdh.sLC.ushFree);
            end;
            if(flag_VA21)
                fprintf(ice_obj.fp_debug,'FRE = %d %d %d %d %d\n',sMdh.sLC.ushIda,...
                    sMdh.sLC.ushIdb,sMdh.sLC.ushIdc,sMdh.sLC.ushIdd,sMdh.sLC.ushIde);
            end;
        end;
        
        %//
        %// An extra MDH at the end indicates the end of file.
        %//
        if(flag_VA15)
            if (bitand(sMdh.ulEvalInfoMask, MDH_ACQEND) ) flag_cont=0; break; end;
        end;
        
        if(flag_VA21)
            if (bitand(sMdh.aulEvalInfoMask(1), MDH_ACQEND) ) flag_cont=0; break; end;
        end;
        
        %  //
        %  // Error checking: the number of ADC samples should be lNxOverSamp (oversampling).
        %  //
        %if ( sMdh.ushSamplesInScan ~= lNxOverSamp )
        %    if(~ice_obj.flag_svs)
        %        fprintf(' ******** Consistency error in ADC %d *************\n',sMdh.ulScanCounter);
        %        fprintf(' ******** ADC samples (%d) ~= expected samples (%d)\n\n',...
        %            sMdh.ushSamplesInScan, lNxOverSamp);
        %    end;
        %end;
        
        %// Set the fifo length according to the data length in the 1st channel.
        if ( sMdh.ulChannelId >= 0 )
            sFifo.lDimX =  ice_obj.m_NxRaw*2;
            sFifo.lDimXOp = ice_obj.m_NxRaw*2;
            sFifo.lDimC = sMdh.ushUsedChannels;
        else
            %// Other channels should have the same FIFO length.
            if ( sMdh.ushSamplesInScan ~= sFifo.lDimX )
                fprintf('\nError~~ Different ADC lengths in different channels~\n');
                return;
            end;
        end;
        
        data=fread(file_in, (sMdh.ushSamplesInScan)*2,'float');
        
        %    if (length(data)~=sFifo.lDimX*2)
        %        fprintf('\nError reading data for ADC %d.\n',sMdh.ulScanCounter);
        %        break;
        %    end;
        
        if(flag_svs)
            cdata=zeros(sMdh.ushSamplesInScan,1);
            offset=1;
        else
            cdata=zeros(sFifo.lDimX,1);
            offset=sFifo.lDimX-sMdh.ushSamplesInScan+1;
        end;
        cdata(offset:end)=data(1:2:end)+data(2:2:end).*sqrt(-1);
        
        if(isempty(array_index))
            if(flag_VB13|flag_VB15)
                vb13_channeloffset=sMdh.ulChannelId;
                ice_obj.array_index=[vb13_channeloffset:vb13_channeloffset+sMdh.ushUsedChannels-1];
                array_index=ice_obj.array_index;
            else
                ice_obj.array_index=[0:sMdh.ushUsedChannels-1];
            end;
        else
            ice_obj.array_index=array_index;
        end;
        
        idx=find(ice_obj.array_index==sMdh.ulChannelId);
        if(isempty(idx))
            fprintf('cannot find specified channel number with channel ID [%d]!	\n',sMdh.ulChannelId);
            return;
        end;
        
        if(flag_autocrop)
            sFifo.FCData(:,idx)=transpose(cdata(1:size(sFifo.FCData)));
        else
            sFifo.FCData(:,idx)=transpose(cdata);
        end;
        if(flag_debug_file)
            if(isempty(array_idx_buffer))
                array_idx_buffer=zeros(1,length(ice_obj.array_index));
            end;
            array_idx_buffer(idx)=1;
            if(isempty(find(1-array_idx_buffer)))
                array_idx_buffer=zeros(size(array_idx_buffer));
            end;
        end;
        
        cont=(sMdh.ulChannelId==ice_obj.array_index(end))&(~flag_scan_mdh_only);
        
        
        %// Process data only after all channels have been read
        if (cont)
            %//
            %// Call the 'online' IceFake function when all channels have been read.
            %// Note that the structure of the raw data file (e.g., 'meas.out')
            %// separates channels with headers (sMdh), but all channels are 1st combined
            %// here in order to simulate the way it is done on the scanner, where
            %// one call of the online function has all the channel data.
            %//
            
            [ok]= ice_online( sMdh, sFifo);
            %         if ( ~ok )
            %             fprintf('\nError returned from IceFake_online.\n');
            %             return;
            %         end;
            
        end;
    end;
end;

fprintf('\naccumulated MDH counter info:\n');
fprintf('REP = %d, SLC = %d, SEG = %d, LIN = %d\n',...
    sLC_max(1),sLC_max(2),sLC_max(3),sLC_max(4));
fprintf('ACQ = %d, PAR = %d, ECO = %d, PHS = %d, SET = %d\n',...
    sLC_max(5),sLC_max(6),sLC_max(7),sLC_max(8),sLC_max(9));

fclose(file_in);

if(ice_obj.flag_debug_file)
    fclose(ice_obj.fp_debug);
end;


if(ice_obj.flag_epi)
    if(ice_obj.flag_output_burst)
        global ice_m_data_burst;
        
        for s=1:ice_obj.m_Nz
            for ch=1:ice_obj.m_NChan
                if(ice_obj.flag_output_reim)
                    fn=sprintf('%s_slice%03d_chan%03d_re.bfloat',ice_obj.output_stem,s,ch);
                    fmri_svbfile_fhlin(real(ice_m_data_burst(:,:,s,ch,:)),fn);
                    fn=sprintf('%s_slice%03d_chan%03d_im.bfloat',ice_obj.output_stem,s,ch);
                    fmri_svbfile_fhlin(imag(ice_m_data_burst(:,:,s,ch,:)),fn);
                end;
                if(ice_obj.flag_output_maph)
                    fn=sprintf('%s_slice%03d_chan%03d_ma.bfloat',ice_obj.output_stem,s,ch);
                    fmri_svbfile_fhlin(abs(ice_m_data_burst(:,:,s,ch,:)),fn);
                    fn=sprintf('%s_slice%03d_chan%03d_ph.bfloat',ice_obj.output_stem,s,ch);
                    fmri_svbfile_fhlin(angle(ice_m_data_burst(:,:,s,ch,:)),fn);
                end;
                
            end;
        end;
        
    end;
end;

if(ice_obj.flag_pepsi)
    fprintf('saving PEPSI data...\n');
    global ice_m_data;
    
    ice_m_data=fftshift(ifft(fftshift(ice_m_data,1),[],1),1);
    
    if(~ice_obj.flag_3D)
        PEPSI_EVEN=ice_m_data(:,1:2:end,:,:);
        PEPSI_EVEN=permute(PEPSI_EVEN,[2 3 1 4]);
        
        PEPSI_ODD=ice_m_data(:,2:2:end,:,:);
        PEPSI_ODD=permute(PEPSI_ODD,[2 3 1 4]);
        fprintf('[time,ky,kx] (ky: phase-encoding, kx: freq.-encoding)\n');
    else
        PEPSI_EVEN=ice_m_data(:,1:2:end,:,:,:);
        PEPSI_EVEN=permute(PEPSI_EVEN,[2 3 4 1 5]);
        
        PEPSI_ODD=ice_m_data(:,2:2:end,:,:,:);
        PEPSI_ODD=permute(PEPSI_ODD,[2 3 4 1 5]);
        fprintf('[time,ky, z, kx] (ky: phase-encoding, kz: phase-encoding, kx: freq.-encoding)\n');
    end;
    
    vv=str2num(version('-release'));
    if(vv<=13.0)
        for ch=1:size(PEPSI_EVEN,ndims(PEPSI_EVEN))
            if(ndims(PEPSI_EVEN)==4&&(~ice_obj.flag_3D))
                fn=sprintf('%s_even_ch%03d.mat',ice_obj.output_stem,ch);
                PEPSI_EVEN_CH=PEPSI_EVEN(:,:,:,ch);
                save(fn,'PEPSI_EVEN_CH');
                
                fn=sprintf('%s_odd_ch%03d.mat',ice_obj.output_stem,ch);
                PEPSI_ODD_CH=PEPSI_ODD(:,:,:,ch);
                save(fn,'PEPSI_ODD_CH');
            elseif(ndims(PEPSI_EVEN)==5&&(ice_obj.flag_3D))
                fn=sprintf('%s_even_ch%03d.mat',ice_obj.output_stem,ch);
                PEPSI_EVEN_CH=PEPSI_EVEN(:,:,:,:,ch);
                save(fn,'PEPSI_EVEN_CH');
                
                fn=sprintf('%s_odd_ch%03d.mat',ice_obj.output_stem,ch);
                PEPSI_ODD_CH=PEPSI_ODD(:,:,:,:,ch);
                save(fn,'PEPSI_ODD_CH');
            elseif(ndims(PEPSI_EVEN)==4&&(ice_obj.flag_3D))
                fn=sprintf('%s_even.mat',ice_obj.output_stem);
                PEPSI_EVEN_CH=PEPSI_EVEN;
                save(fn,'PEPSI_EVEN_CH');
                
                fn=sprintf('%s_odd.mat',ice_obj.output_stem);
                PEPSI_ODD_CH=PEPSI_ODD;
                save(fn,'PEPSI_ODD_CH');
                break;
            end;
        end;
    else
        for ch=1:size(PEPSI_EVEN,ndims(PEPSI_EVEN))
            if(ndims(PEPSI_EVEN)==4&&(~ice_obj.flag_3D))
                fn=sprintf('%s_even_ch%03d.mat',ice_obj.output_stem,ch);
                PEPSI_EVEN_CH=PEPSI_EVEN(:,:,:,ch);
                save(fn,'PEPSI_EVEN_CH','-v6');
                
                fn=sprintf('%s_odd_ch%03d.mat',ice_obj.output_stem,ch);
                PEPSI_ODD_CH=PEPSI_ODD(:,:,:,ch);
                save(fn,'PEPSI_ODD_CH','-v6');
            elseif(ndims(PEPSI_EVEN)==5&&(ice_obj.flag_3D))
                fn=sprintf('%s_even_ch%03d.mat',ice_obj.output_stem,ch);
                PEPSI_EVEN_CH=PEPSI_EVEN(:,:,:,:,ch);
                save(fn,'PEPSI_EVEN_CH','-v6');
                
                fn=sprintf('%s_odd_ch%03d.mat',ice_obj.output_stem,ch);
                PEPSI_ODD_CH=PEPSI_ODD(:,:,:,:,ch);
                save(fn,'PEPSI_ODD_CH','-v6');
            elseif(ndims(PEPSI_EVEN)==4&&(ice_obj.flag_3D))
                fn=sprintf('%s_even.mat',ice_obj.output_stem);
                PEPSI_EVEN_CH=PEPSI_EVEN;
                save(fn,'PEPSI_EVEN_CH','-v6');
                
                fn=sprintf('%s_odd.mat',ice_obj.output_stem);
                PEPSI_ODD_CH=PEPSI_ODD;
                save(fn,'PEPSI_ODD_CH','-v6');
                break;
            end;
        end;
    end;
elseif(ice_obj.flag_svs)
    fprintf('saving SVS data...\n');
    
    global ice_m_data;
    
    ice_m_data=fftshift(ifft(fftshift(ice_m_data,1),[],1),1);
    
    fprintf('[time,channel]\n');
    
    fn=sprintf('%s_svs.mat',ice_obj.output_stem);
    save(fn,'ice_m_data');
elseif(ice_obj.flag_ini3d)
    fprintf('saving 3D InI data...\n');
    
    global ice_m_data;
    
    for ch=1:size(ice_m_data,2)
        fn=sprintf('%s_chan%03d_re.bfloat',ice_obj.output_stem,ch);
        fmri_svbfile_fhlin(real(squeeze(ice_m_data(:,ch,:))),fn);
        
        fn=sprintf('%s_chan%03d_im.bfloat',ice_obj.output_stem,ch);
        fmri_svbfile_fhlin(imag(squeeze(ice_m_data(:,ch,:))),fn);
    end;
    
end;


fprintf('DONE!\n\n');

return;

