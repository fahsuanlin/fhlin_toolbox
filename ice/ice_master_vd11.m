function ice_master_vd11(varargin)

%setting up defaults
file_prot='meas.asc';   %default protocol file name
file_raw='meas.out';    %defualt rawdata file name

flag_VA21=0;
flag_VA15=0;
flag_VB13=0;
flag_VB15=0;
flag_VD11=1;

idea_ver='VA21';

flag_debug=0;
flag_debug_file=0;

output_stem='meas';
flag_scan_mdh_only=0;
flag_output_reim=1;
flag_output_maph=0;
flag_output_burst=0;
n_measurement=1;
flag_clear_after_saving=1;      %clear ice_m_data after saving into files


flag_phase_cor=1;
flag_phase_cor_mgh=1;
flag_phase_cor_jbm=0;

flag_phase_cor_algorithm_jbm=1;
flag_phase_cor_algorithm_lsq=0;

flag_shimming_cor=0;

flag_phase_cor_offset=0;
flag_archive_nav_jbm=0;

nav_data_fraction=[];
nav_phase_offset_override=[];
nav_phase_slope_override=[];

flag_archive_segments=0;

flag_epi=1;
flag_sege=0;
flag_ini3d=0;
flag_phase_cor_ini=0;
flag_3d=[];


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
                flag_sege==0;
                flag_ini3d=0;
                fprintf('reading EPI data!\n');
            case 'flag_sege'
                flag_epi=0;
                flag_sege=option_value;
                flag_ini3d=0;
                fprintf('reading SE/GE data!\n');
            case 'flag_ini3d'
                flag_ini3d=option_value;
                flag_epi=0;
                flag_sege=0;
            case 'flag_clear_after_saving'
                flag_clear_after_saving=option_value;
            case 'n_channel'
                n_channel=option_value;
            case 'array_index'
                array_index=option_value;
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
            otherwise
                fprintf('unknown option [%s]. Error!\n\n',option);
                return;
        end;
    end;
end;

clear global ice_obj;
clear global ice_m_data;
global ice_obj;
global ice_m_data;

fprintf('reading protocol [%s]...\n',file_prot);
if(flag_VD11)
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
end;



fprintf('reading raw data [%s]...\n',file_raw);
fp=fopen(file_raw);


%// Compute images only when raw data streaming is turned off.
%///////////////////////////////////////////////////////////////////////////
%////////////////////////// Call of Prepare Function ///////////////////////
%///////////////////////////////////////////////////////////////////////////
%// Do ICE preparation for image computations
ice_obj.flag_svs=0;
ice_obj.flag_pepsi=0;
ice_obj.flag_epi=flag_epi;
ice_obj.flag_sege=flag_sege;
ice_obj.flag_ini3d=flag_ini3d;
ice_obj.slice_order=slice_order;

ice_obj.flag_regrid=flag_regrid;

ice_obj.flag_archive_nav_jbm=flag_archive_nav_jbm;

ice_obj.flag_output_burst=flag_output_burst;
ice_obj.n_measurement=n_measurement;
ice_obj.flag_clear_after_saving=flag_clear_after_saving;

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

ice_obj.flag_shimming_cor=flag_shimming_cor;

ice_obj.nav_data_fraction=nav_data_fraction;

ice_obj.flag_archive_segments=flag_archive_segments;

ice_obj.max_avg=max_avg;

%load definitions...
ice_va21_def;

%///////////////////////////////////////////////////////////////////////////
%////////////////////// Begin reading the input file ///////////////////////
%///////////////////////////////////////////////////////////////////////////
%// Open the file for reading.
file_in=fopen(file_raw,'r');

if(ice_obj.flag_debug_file)
    ice_obj.fp_debug=fopen('ice_master_debug.txt','w');
end;



if(flag_VD11)
    fseek(file_in,0,'eof');
    fileSize = ftell(file_in);
    fseek(file_in,measOffset(1),'bof'); %multi-raid file header
    for j=1:n_measraw
        %hdrLength(j)  = fread(file_in,1,'uint32');
        fseek(file_in,hdrLength(j),'cof');    %measurement header
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
        data=reshape(data(1,:)+sqrt(-1).*data(2,:),[sMdh_scan.ushSamplesInScan+4 sMdh_scan.ushUsedChannels]);
        sFifo.FCData=data(5:end,:);
        
        
        %process data
        [ok]= ice_online(sMdh_scan, sFifo);
        
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


fprintf('DONE!\n\n');

return;

