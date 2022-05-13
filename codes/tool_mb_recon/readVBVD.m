function [image_obj noise_obj phasecor_obj refscan_obj refscanPC_obj RTfeedback_obj phasestab_obj] = readVBVD(filename,varargin)

%  Reads Siemens raw .dat file from VB/VD MRI raw data.
%
%  Requires siemens_data_obj.m
%
%
%  Philipp Ehses 11.02.07, original version
%  [..]
%  Philipp Ehses 22.03.11, port to VD11
%  Felix Breuer  31.03.11, added support for noise & ref scans, speed fixes
%  Philipp Ehses 19.08.11, complete reorganization of code, added
%                          siemens_data_obj class to improve readability
%
%
% Input:
%
% filename or simply measurement id, e.g. readVBVD(122) (if file is in same path)
% optional arguments (see below)
%
%
% Output:
%
% image_obj:       object for image scan
% noise_obj:       object for noise scan, if available
% phasecor_obj:    object for phase correction scan, if available
% refscan_obj:     object for reference scan, if available
% refscanPC_obj:   object for phase correction scan for reference data, if available
% RTfeedback_obj:  object for realtime feedback data, if available
% phasestab_obj:   object for phase stabilization scan, if available
%
%
% The raw data can be obtained by calling image_obj.data. Squeezed raw
% data can be obtained by calling image_obj.sqzData.
%
% Raw data is oversampled!
%
% Order of raw data:
%  1) Columns
%  2) Channels/Coils
%  3) Lines
%  4) Partitions
%  5) Averages
%  6) Slices
%  7) (Cardiac-) Phases
%  8) Contrasts/Echoes
%  9) Measurements
% 10) Sets
% 11) Segments
% 12) Ida
% 13) Idb
% 14) Idc
% 15) Idd
% 16) Ide
%
%
% Optional parameters:
% 
% avg:         automatic average during read operation (preserves memory)
% avgmeas:     automatic average of measurements (preserves memory)
% undoOSr:     removes oversampling in read direction (preserves memory)
% imaScanOnly: only image scan will be read
% refScanOnly: only reference scan will be read (if available)
% refScanFull: 
% exclACS:     exclude autocalibration lines from ImaData
% ignSeg:      ignore segments


if ischar(filename) 
    % assume that complete path is given
    if  ~strcmpi(filename(end-3:end),'.dat');
        filename=[filename '.dat'];   %% adds filetype ending to file
    end
else 
    % filename not a string, so assume that it is the MeasID
    filename=ls(['meas_MID' num2str(filename) '_*.dat']);
    if isunix
        filename=filename(1:end-1); % crops line break
    end
end


%%%%% Parse varargin %%%%%

    % Definition of default parameters
    arg.avg             = 0;
    arg.avgmeas         = 0;                                   
    arg.ignSeg          = 1;
    % noise decorrelation of data (only works in case noise scans have been acquired)
    arg.noiseDecorr     = 0; 
    arg.performPCA      = 0;

    k=1;

    while k <= numel(varargin)
        
        if ~ischar(varargin{k})
            error('string expected');
        end
        
        switch lower(varargin{k})
            case 'avg'
                if numel(varargin) > k && ~ischar(varargin{k+1})
                    arg.avg = logical(varargin{k+1});
                    k = k+2;
                else
                    arg.avg = true;
                    k = k+1;
                end
            case 'avgmeas'
                if numel(varargin) > k && ~ischar(varargin{k+1})
                    arg.avgmeas = logical(varargin{k+1});
                    k = k+2;
                else
                    arg.avgmeas = true;
                    k = k+1;
                end
            case 'ignseg'
                if numel(varargin) > k && ~ischar(varargin{k+1})
                    arg.ignSeg = logical(varargin{k+1});
                    k = k+2;
                else
                    arg.ignSeg = true;
                    k = k+1;
                end
            case {'decor','decorr','decorrelation','noisedecor','noisedecorr','noisedecorrelation'}
                if numel(varargin) > k && ~ischar(varargin{k+1})
                    arg.noiseDecorr = logical(varargin{k+1});
                    k = k+2;
                else
                    arg.noiseDecorr = true;
                    k = k+1;
                end
            case {'pca','performpca'}
                if numel(varargin) > k && ~ischar(varargin{k+1})
                    arg.performPCA = logical(varargin{k+1});
                    k = k+2;
                else
                    arg.performPCA = true;
                    k = k+1;
            end
            otherwise
                error('Argument not recognized.');
                return;
        end
    end
    clear varargin
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    tic;
    fid = fopen(filename,'r','l','US-ASCII'); % US-ASCII necessary for UNIX based systems
    fseek(fid,0,'eof');
    fileSize = ftell(fid);
    
    % start of actual measurment data (sans header)
    fseek(fid,0,'bof');
    
    firstInt  = fread(fid,1,'uint32');
    secondInt = fread(fid,1,'uint32');
    
    % check software version (VB or VD?)
    if and(firstInt < 10000, secondInt<=64) 
        % this is a very lazy version check and work in progress; may sometimes fail
        version = 'vd';
        disp('Software version: VD (!?)');
        
        % number of different scans in file stored in 2nd int (wip, only 
        % one supported for now)
        NScans = secondInt;
        
        fseek(fid,16,'bof');
        % measOffset: points to beginning of header, usually at 10240 bytes
        measOffset = fread(fid,1,'uint64');
        measLength = fread(fid,1,'uint64');
        fseek(fid,measOffset,'bof');
        hdrLength  = fread(fid,1,'uint32');
        datStart   = measOffset + hdrLength;
    else
        % in VB versions, the first 4 bytes indicate the beginning of the
        % raw data part of the file
        version  = 'vb';
        disp('Software version: VB (!?)');
        datStart = firstInt;
        NScans   = 1; % VB does not support multiple scans in one file
    end
    
    
    % data will be read in two steps (two while loops):
    %   1) reading all MDHs to find maximum line no., partition no.,... for
    %      ima, ref,... scan
    %   2) reading the data
    
    %%% start at beginning of first line
    cPos = datStart;
    
    % declare data objects:
    image_obj      = siemens_data_obj(arg,'image');
    noise_obj      = siemens_data_obj(arg,'noise');
    phasecor_obj   = siemens_data_obj(arg,'phasecor');
    refscan_obj    = siemens_data_obj(arg,'refscan');
    refscanPC_obj  = siemens_data_obj(arg,'refscan_phasecor');
    RTfeedback_obj = siemens_data_obj(arg,'rtfeedback');
    phasestab_obj  = siemens_data_obj(arg,'phasestab');
    
    
    tic;
    mask.MDH_ACQEND = 0;
    fseek(fid,cPos,'bof');
    while ftell(fid)+128 < fileSize % fail-safe; in case we miss MDH_ACQEND
        
        switch version
            case 'vb'
                [mdh mask nBytes] = evalMDHvb(fid,cPos);
            case 'vd'
                [mdh mask nBytes] = evalMDHvd(fid,cPos);
            otherwise
                disp('error: only vb/vd software versions supported');                    
        end
        
        if mask.MDH_ACQEND
            break;
        end
        
        if (mask.MDH_IMASCAN)
            image_obj.checkMDH(mdh);
%             if image_obj.NCnt >= 54206
%                 breakPos = cPos;
%                 break;
%             end
        end
        
        if (mask.MDH_NOISEADJSCAN)
            noise_obj.checkMDH(mdh);
        end

        if and(mask.MDH_PHASCOR,~mask.MDH_PATREFSCAN)
            phasecor_obj.checkMDH(mdh);
        end
        
        if nargout > 3
            if (mask.MDH_PATREFSCAN || mask.MDH_PATREFANDIMASCAN)
                refscan_obj.checkMDH(mdh);
            end

            if and(mask.MDH_PATREFSCAN,mask.MDH_PHASCOR)
                refscanPC_obj.checkMDH(mdh);
            end
            
            if (mask.MDH_RTFEEDBACK || mask.MDH_HPFEEDBACK)
                RTfeedback_obj.checkMDH(mdh);
            end

            if (mask.MDH_PHASESTABSCAN || mask.MDH_REFPHASESTABSCAN)
                phasestab_obj.checkMDH(mdh);
            end
        end
        
        % jump to mdh of next scan
        cPos = cPos + nBytes;
        
    end % while         
    
    %%%% allocate memory
    image_obj.allocateMemory();
    noise_obj.allocateMemory();
    phasecor_obj.allocateMemory();        
    
    if nargout > 3
        refscan_obj.allocateMemory();
        refscanPC_obj.allocateMemory();
        RTfeedback_obj.allocateMemory();
        phasestab_obj.allocateMemory();
    end
    %%%% end allocate memory
    
    disp(['Searched through MDHs and allocated memory in ' num2str(toc) ' s.']);
   
    tic;
    
    %%% start at beginning of first line
    cPos            = datStart;
    mask.MDH_ACQEND = false;
    percentFinished = 0;
    
    fseek(fid,cPos,'bof');
    
    while ftell(fid)+128<fileSize % fail-safe; in case we miss MDH_ACQEND
        
        switch version
            case 'vb'
                [mdh mask nBytes cur_read] = evalMDHvb(fid,cPos);
            case 'vd'
                [mdh mask nBytes cur_read] = evalMDHvd(fid,cPos);
            otherwise
                disp('error: only vb/vd software versions supported');                    
        end
        
        if mask.MDH_ACQEND
            break;
        end

        % jump to next mdh (mdhs for coils 2..n are skipped)
        fseek(fid,cPos+cur_read.skip,'bof');
        a = fread(fid, cur_read.sz, 'float');

        temp    = reshape(single((a(1,:) + 1j.*a(2,:))), cur_read.shape);
        temp    = temp(cur_read.cut,:);
        
        if mask.MDH_REFLECT
            temp = temp(end:-1:1,:);
        end
            
        if mask.MDH_SIGNREV
            temp = -temp;
        end
        
        if (mask.MDH_IMASCAN)
            image_obj.addData(temp,mdh);
%             if cPos == breakPos
%                 break;
%             end
        end
        
        if (mask.MDH_NOISEADJSCAN)
            noise_obj.addData(temp,mdh);
        end

        if and(mask.MDH_PHASCOR,~mask.MDH_PATREFSCAN)
            phasecor_obj.addData(temp,mdh);
        end
        
        if nargout > 3
            if (mask.MDH_PATREFSCAN || mask.MDH_PATREFANDIMASCAN)
                refscan_obj.addData(temp,mdh);
            end
            
            if and(mask.MDH_PATREFSCAN,mask.MDH_PHASCOR)
                refscanPC_obj.addData(temp,mdh);
            end

            if (mask.MDH_RTFEEDBACK || mask.MDH_HPFEEDBACK)
                RTfeedback_obj.addData(temp,mdh);
            end

            if (mask.MDH_PHASESTABSCAN || mask.MDH_REFPHASESTABSCAN)
                phasestab_obj.addData(temp,mdh);
            end
        end
        
        % jump to mdh of next scan
        cPos = cPos + nBytes;
        
        if (cPos/fileSize*100 > percentFinished + 1)
            percentFinished = floor(cPos/fileSize*100);
            elapsed_time  = toc;
            time_left     = (fileSize/cPos-1) * elapsed_time;

            if ~exist('progress_str','var')
                prevLength = 0;
            else
                prevLength = numel(progress_str);
            end

            progress_str = sprintf('%3.0f %% read in %3.0f s, at %3.1f MB/s; estimated time left: %3.0f s \n',...
            percentFinished,elapsed_time, cPos/1024^2/elapsed_time,time_left);

            fprintf([repmat('\b',1,prevLength) '%s'],progress_str);
        end
        
    end % while
% keyboard;
    %%% noise Decorrelation if requested
    if (arg.noiseDecorr && numel(noise_obj.data) > 1)
        disp('Decorrelating noise in coils based on provided noise data');
        noise = reshape(noise_obj.data,[noise_obj.NCol noise_obj.NCha noise_obj.NCnt]);
        % coils first
        noise = permute(noise,[2 1 3]);
        noise = noise(:,:);
        image_obj.decorrNoise(noise);
        phasecor_obj.decorrNoise(noise);
        if nargout > 3
            refscan_obj.decorrNoise(noise);
            refscanPC_obj.decorrNoise(noise);
            RTfeedback_obj.decorrNoise(noise);
            phasestab_obj.decorrNoise(noise);
        end
    end
    
    %%% PCA in coil dim if requested
    if (arg.performPCA)
        disp('Transforming coils to Principal Component domain');
        
        image_obj.performPCA();
        noise_obj.performPCA();
        phasecor_obj.performPCA();
        if nargout > 3
            refscan_obj.performPCA();
            refscanPC_obj.performPCA();
            RTfeedback_obj.performPCA();
            phasestab_obj.performPCA();
        end
        
    end
    
    
    %%% Final sorting of data: %%%
    image_obj.orderData();
    noise_obj.orderData();
    phasecor_obj.orderData();
    
    if nargout > 3
        refscan_obj.orderData();
        refscanPC_obj.orderData();
        RTfeedback_obj.orderData();
        phasestab_obj.orderData();
    end
%     keyboard;
end


function [mdh mask nBytes cur_read] = evalMDHvb(fid,cPos)

    % no difference between 'scan' and 'channel' header in VB
    szMDH = 128; % [bytes]

    % inlining of readMDH
    fseek(fid,cPos+20,'bof');
    mdh.aulEvalInfoMask            = fread(fid,  [1 2], 'uint32');
    dummy                          = fread(fid,      2, 'uint16');
    mdh.ushSamplesInScan           = dummy(1);
    mdh.ushUsedChannels            = dummy(2);
    mdh.sLC                        = fread(fid, [1 14], 'ushort');  
    fseek(fid,4,'cof');
    dummy                          = fread(fid,      8, 'uint16');
    mdh.ushKSpaceCentreColumn      = dummy(1);
    mdh.ushKSpaceCentreLineNo      = dummy(7);
    mdh.ushKSpaceCentrePartitionNo = dummy(8);

    % inlining of evalInfoMask
    mask.MDH_ACQEND             = min(bitand(mdh.aulEvalInfoMask(1), 2^0),1);
    mask.MDH_RTFEEDBACK         = min(bitand(mdh.aulEvalInfoMask(1), 2^1),1);
    mask.MDH_HPFEEDBACK         = min(bitand(mdh.aulEvalInfoMask(1), 2^2),1);
    mask.MDH_REFPHASESTABSCAN   = min(bitand(mdh.aulEvalInfoMask(1), 2^14),1);
    mask.MDH_PHASESTABSCAN      = min(bitand(mdh.aulEvalInfoMask(1), 2^15),1);
    mask.MDH_PHASCOR            = min(bitand(mdh.aulEvalInfoMask(1), 2^21),1);
    mask.MDH_PATREFSCAN         = min(bitand(mdh.aulEvalInfoMask(1), 2^22),1);
    mask.MDH_PATREFANDIMASCAN   = min(bitand(mdh.aulEvalInfoMask(1), 2^23),1);
    mask.MDH_REFLECT            = min(bitand(mdh.aulEvalInfoMask(1), 2^24),1);
    mask.MDH_RAWDATACORRECTION  = min(bitand(mdh.aulEvalInfoMask(1), 2^10),1);
    mask.MDH_SIGNREV            = min(bitand(mdh.aulEvalInfoMask(1), 2^17),1);
    mask.MDH_NOISEADJSCAN       = min(bitand(mdh.aulEvalInfoMask(1), 2^25),1);
    mask.MDH_IMASCAN            = 1;
    if (mask.MDH_ACQEND || mask.MDH_RTFEEDBACK || mask.MDH_HPFEEDBACK || mask.MDH_REFPHASESTABSCAN || mask.MDH_PHASESTABSCAN || mask.MDH_PHASCOR || mask.MDH_NOISEADJSCAN)
        mask.MDH_IMASCAN = 0; 
    end
    
    % pehses: fail-safe for my own buggy sequence:
    if and(mask.MDH_PATREFSCAN,~mask.MDH_PATREFANDIMASCAN)
        mask.MDH_IMASCAN = 0;
    end
    
    
    % size of current data set (2*4 because of complex + float)
    nBytes = mdh.ushUsedChannels * (szMDH + 2*4*mdh.ushSamplesInScan);

    % nothing to skip
    cur_read.skip = 0;
    
    % size for fread
    cur_read.sz   = [2 nBytes/(2*4)];
    
    % reshape size
    cur_read.shape = [mdh.ushSamplesInScan + szMDH/8, mdh.ushUsedChannels];
    
    % we need to cut MDHs from fread data
    cur_read.cut   = szMDH/8+1:mdh.ushSamplesInScan+szMDH/8;

end
    

function [mdh mask nBytes cur_read] = evalMDHvd(fid,cPos)

    % we need to differentiate between 'scan header' and 'channel header'
    % since these are used in VD versions:
    szScanHeader    = 192; % [bytes]
    szChannelHeader = 32;  % [bytes]

    % inlining of readScanHeader
    fseek(fid,cPos+40,'bof');
    mdh.aulEvalInfoMask            = fread(fid,  [1 2], 'uint32');
    dummy                          = fread(fid,      2, 'uint16');
    mdh.ushSamplesInScan           = dummy(1);
    mdh.ushUsedChannels            = dummy(2);
    mdh.sLC                        = fread(fid, [1 14], 'ushort');  
    fseek(fid,4,'cof');
    dummy                          = fread(fid,      8, 'uint16');
    mdh.ushKSpaceCentreColumn      = dummy(1);
    mdh.ushKSpaceCentreLineNo      = dummy(7);
    mdh.ushKSpaceCentrePartitionNo = dummy(8);

    % inlining of evalInfoMask
    mask.MDH_ACQEND             = min(bitand(mdh.aulEvalInfoMask(1), 2^0),1);
    mask.MDH_RTFEEDBACK         = min(bitand(mdh.aulEvalInfoMask(1), 2^1),1);
    mask.MDH_HPFEEDBACK         = min(bitand(mdh.aulEvalInfoMask(1), 2^2),1);
    mask.MDH_REFPHASESTABSCAN   = min(bitand(mdh.aulEvalInfoMask(1), 2^14),1);
    mask.MDH_PHASESTABSCAN      = min(bitand(mdh.aulEvalInfoMask(1), 2^15),1);
    mask.MDH_PHASCOR            = min(bitand(mdh.aulEvalInfoMask(1), 2^21),1);
    mask.MDH_PATREFSCAN         = min(bitand(mdh.aulEvalInfoMask(1), 2^22),1);
    mask.MDH_PATREFANDIMASCAN   = min(bitand(mdh.aulEvalInfoMask(1), 2^23),1);
    mask.MDH_REFLECT            = min(bitand(mdh.aulEvalInfoMask(1), 2^24),1);
    mask.MDH_RAWDATACORRECTION  = min(bitand(mdh.aulEvalInfoMask(1), 2^10),1);
    mask.MDH_SIGNREV            = min(bitand(mdh.aulEvalInfoMask(1), 2^17),1);
    mask.MDH_NOISEADJSCAN       = min(bitand(mdh.aulEvalInfoMask(1), 2^25),1);
    mask.MDH_IMASCAN            = 1;
    if (mask.MDH_ACQEND || mask.MDH_RTFEEDBACK || mask.MDH_HPFEEDBACK || mask.MDH_REFPHASESTABSCAN || mask.MDH_PHASESTABSCAN || mask.MDH_PHASCOR || mask.MDH_NOISEADJSCAN)
        mask.MDH_IMASCAN = 0; 
    end
    
    nBytes = szScanHeader + mdh.ushUsedChannels * (szChannelHeader + 2*4*mdh.ushSamplesInScan);
    
    % skip line header
	cur_read.skip = szScanHeader;
    
    % size for fread
    cur_read.sz   = [2 (nBytes-szScanHeader)/8];
    
    % reshape size
    cur_read.shape = [mdh.ushSamplesInScan + szChannelHeader/8, mdh.ushUsedChannels];
    
    % we need to cut MDHs from fread data
    cur_read.cut   = szChannelHeader/8+1:mdh.ushSamplesInScan+szChannelHeader/8;
    
end
