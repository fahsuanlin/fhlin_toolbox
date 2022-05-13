classdef siemens_data_obj < handle
% class to hold raw data from siemens MRI scanners (currently VB and VD
% software versions are supported and tested).
%
%
% Philipp Ehses (philipp.ehses@tuebingen.mpg.de), Aug/19/2011
%

    properties(GetAccess='public', SetAccess='protected')
        
        arg  % arguments
        data % array holding the raw data (can be huge!)
        
        
        % properties:
        
        dataType
        dataSize
        
        NCol
        NCha
        NLin
        NPar
        NAve
        NSli
        NPhs
        NEco
        NMeas
        NSet
        NSeg
        NIda
        NIdb
        NIdc
        NIdd
        NIde
        NCnt
           
        cNCnt
        % test:
        cLin
        cPar
        cSet
        
        % some dims may be averaged directly to save memory during readout
        NAveAlloc
        NMeasAlloc
        NSegAlloc        
        
        minLin
        maxLin
        minPar
        maxPar
        
        centerCol
        centerLine
        centerPart
    end
    
    properties(Dependent = true, SetAccess = private)
        sqzData     % pseudo variable holding the squeezed raw data
    end
    
    properties(GetAccess='protected', SetAccess='protected')
    end
      
    methods(Access = public)
        % Constructor:
        function obj = siemens_data_obj(arg,dataType)
            % test
            obj.cLin       = [];
            obj.cPar       = [];
            obj.cSet       = [];
        
            obj.data       = [];
            obj.NCol       = 1;
            obj.NCha       = 1;
            obj.NLin       = 1;
            obj.NPar       = 1;
            obj.NAve       = 1;
            obj.NSli       = 1;
            obj.NPhs       = 1;
            obj.NEco       = 1;
            obj.NMeas      = 1;
            obj.NSet       = 1;
            obj.NSeg       = 1;
            obj.NIda       = 1;
            obj.NIdb       = 1;
            obj.NIdc       = 1;
            obj.NIdd       = 1;
            obj.NIde       = 1;
            obj.NAveAlloc  = 1;
            obj.NMeasAlloc = 1;
            obj.NSegAlloc  = 1;
            obj.centerCol  = 0;
            obj.centerLine = 0;
            obj.centerPart = 0;
            obj.NCnt       = 0;
            obj.cNCnt      = 0;
            obj.minLin     = inf;
            obj.maxLin     = 1;
            obj.minPar     = inf;
            obj.maxPar     = 1;
            
            if ~exist('dataType','var')
                obj.dataType = 'image';
            else
                obj.dataType = lower(dataType);
            end
            
            if ~exist('arg','var')
                obj.arg = [];
            else
                obj.arg = arg;
            end
            
        end
        
        
        function obj = checkMDH(obj,mdh)
        
            obj.NCol       = mdh.ushSamplesInScan;
            obj.NCha       = mdh.ushUsedChannels;
            obj.NLin       = max(obj.NLin,   mdh.sLC(1)+1);
            obj.NPar       = max(obj.NPar,   mdh.sLC(4)+1);
            obj.NAve       = max(obj.NAve,   mdh.sLC(2)+1);
            obj.NSli       = max(obj.NSli,   mdh.sLC(3)+1);
            obj.NPhs       = max(obj.NPhs,   mdh.sLC(6)+1);
            obj.NEco       = max(obj.NEco,   mdh.sLC(5)+1);
            obj.NMeas      = max(obj.NMeas,  mdh.sLC(7)+1);
            obj.NSet       = max(obj.NSet,   mdh.sLC(8)+1);
            obj.NSeg       = max(obj.NSeg,   mdh.sLC(9)+1);
            obj.NIda       = max(obj.NIda,   mdh.sLC(10)+1);
            obj.NIdb       = max(obj.NIdb,   mdh.sLC(11)+1);
            obj.NIdc       = max(obj.NIdc,   mdh.sLC(12)+1);
            obj.NIdd       = max(obj.NIdd,   mdh.sLC(13)+1);
            obj.NIde       = max(obj.NIde,   mdh.sLC(14)+1);
        
            obj.minLin     = min(obj.minLin, mdh.sLC(1)+1);
            obj.minPar     = min(obj.minPar, mdh.sLC(4)+1);
            obj.maxLin     = max(obj.maxLin, mdh.sLC(1)+1);
            obj.maxPar     = max(obj.maxPar, mdh.sLC(4)+1);
            
            obj.NCnt       = obj.NCnt + 1;
            
            obj.centerCol  = mdh.ushKSpaceCentreColumn      + 1;
            obj.centerLine = mdh.ushKSpaceCentreLineNo      + 1;
            obj.centerPart = mdh.ushKSpaceCentrePartitionNo + 1;
            
        end
        
        
        function allocateMemory(obj)
            
            % NCnt needs to be at least 1
            obj.NCnt       = max(obj.NCnt,1);
            
            obj.NAveAlloc  = obj.NAve;
            obj.NMeasAlloc = obj.NMeas;
            obj.NSegAlloc  = obj.NSeg;
                
            if strcmpi(obj.dataType,'image')
                if obj.arg.avg
                    obj.NAveAlloc  = 1;
                end
                if obj.arg.avgmeas
                    obj.NMeasAlloc = 1;
                end
                if obj.arg.ignSeg
                    obj.NSegAlloc  = 1;
                end
                
                obj.dataSize = [obj.NCol obj.NCha obj.NLin obj.NPar obj.NAveAlloc obj.NSli obj.NPhs obj.NEco obj.NMeasAlloc obj.NSet obj.NSegAlloc obj.NIda obj.NIdb obj.NIdc obj.NIdd obj.NIde];
            
            elseif strcmpi(obj.dataType,'refscan') || strcmpi(obj.dataType,'phasecor') || strcmpi(obj.dataType,'refscan_phasecor')
                obj.dataSize = [obj.NCol obj.NCha max(1,obj.maxLin-obj.minLin+1) max(1,obj.maxPar-obj.minPar+1) obj.NAveAlloc obj.NSli obj.NPhs obj.NEco obj.NMeasAlloc obj.NSet obj.NSegAlloc obj.NIda obj.NIdb obj.NIdc obj.NIdd obj.NIde];
            else
                obj.dataSize = [obj.NCol obj.NCha obj.NCnt];
            end
            
            allocSize = [obj.dataSize(1)*obj.dataSize(2) prod(obj.dataSize(3:end))];
            
            try
                obj.data  = zeros(allocSize,'single');
                % matlab has issues with complex arrays:
                % if first value in array has imaginary part everything is fine - 
                % otherwise filling an array in arbitrary order becomes painfully slow
                % (ImaData = complex(ImaData) alone doesn't help)
                obj.data(1) = 1e-31 * 1i;
            catch exception
                disp('*** Error allocating memory for image only scan - aborting');
                keyboard
                throw(exception);
            end 
        
            obj.cNCnt = 0;
        end
        
        
        function addData(obj,raw,mdh)
            obj.cNCnt  = obj.cNCnt   + 1;
            cLin       = mdh.sLC(1)  + 1;         %%% current line
            cPar       = mdh.sLC(4)  + 1;         %%% current partition  
            cAve       = mdh.sLC(2)  + 1;         %%% current scan ('average')
            cSli       = mdh.sLC(3)  + 1;         %%% current slice
            cPhs       = mdh.sLC(6)  + 1;         %%% current phase cycling step
            cEco       = mdh.sLC(5)  + 1;         %%% current echo no (untested)
            cMeas      = mdh.sLC(7)  + 1;         %%% current measurement no
            cSet       = mdh.sLC(8)  + 1;         %%% current set no
            cSeg       = mdh.sLC(9)  + 1;         %%% current segment for future use
            cIda       = mdh.sLC(10) + 1;         %%% ICE dim a
            cIdb       = mdh.sLC(11) + 1;         %%% ICE dim b
            cIdc       = mdh.sLC(12) + 1;         %%% ICE dim c
            cIdd       = mdh.sLC(13) + 1;         %%% ICE dim d
            cIde       = mdh.sLC(14) + 1;         %%% ICE dim e
            
            obj.cLin   = cat(1,obj.cLin,cLin);
            obj.cPar   = cat(1,obj.cPar,cPar);
            obj.cSet   = cat(1,obj.cSet,cSet);
            
            cAve       = min(cAve , obj.NAveAlloc);
            cMeas      = min(cMeas, obj.NMeasAlloc);
            cSeg       = min(cSeg , obj.NSegAlloc);
            
            if strcmpi(obj.dataType,'image')
                cIndex     = 1 +  (cLin-1 + obj.NLin * ( cPar-1 + obj.NPar * (cAve-1 + obj.NAveAlloc * ...
                    (cSli-1 + obj.NSli * (cPhs-1 + obj.NPhs * (cEco-1 + obj.NEco * (cMeas-1 + obj.NMeasAlloc * ...
                    (cSet-1 + obj.NSet * (cSeg-1 + obj.NSegAlloc * (cIda-1 + obj.NIda * (cIdb-1 + obj.NIdb *...
                    (cIdc-1 + obj.NIdc * (cIdd-1 + obj.NIdd * (obj.NIde-1) + cIde-1)))))))))))));

                obj.data(:,cIndex) = obj.data(:,cIndex) + raw(:);

            elseif strcmpi(obj.dataType,'refscan') || strcmpi(obj.dataType,'phasecor') || strcmpi(obj.dataType,'refscan_phasecor')
                cLinRef = cLin-obj.minLin;
                cLinPar = cPar-obj.minPar;
                NLinRef = max(1,obj.maxLin-obj.minLin+1);
                NParRef = max(1,obj.maxPar-obj.minPar+1);
                cIndex     = 1 +  (cLinRef + NLinRef * ( cLinPar + NParRef * (cAve-1 + obj.NAveAlloc * ...
                    (cSli-1 + obj.NSli * (cPhs-1 + obj.NPhs * (cEco-1 + obj.NEco * (cMeas-1 + obj.NMeasAlloc * ...
                    (cSet-1 + obj.NSet * (cSeg-1 + obj.NSegAlloc * (cIda-1 + obj.NIda * (cIdb-1 + obj.NIdb *...
                    (cIdc-1 + obj.NIdc * (cIdd-1 + obj.NIdd * (obj.NIde-1) + cIde-1)))))))))))));
                
                obj.data(:,cIndex) = obj.data(:,cIndex) + raw(:);
            else
                obj.data(:,obj.cNCnt) = raw(:);  
            end
        end
        
        
        function decorrNoise(obj,noise)
            % performs noise decorrelation
            % noise has to be 2 dim matrix with coils first
            
            if ndims(obj.data)~=2
                disp('error: decorrelation function assumes not yet ordered data, i.e. size(data) == [NCol*NCha NCnt])');
                disp('Skipping noise decorrelation');
                return;
            end
            
            if numel(obj.data) <= 1
                % object empty (e.g. no phasecor/refscan/etc. data
                % available)
                return;
            end
                
            noise = noise(:,:);
            
            R = noise*noise';
            R = R./mean(abs(diag(R)));
   
            R(eye(obj.NCha)==1) = abs(diag(R));

            % Cholezky decomposition
            L = chol(R,'lower');

            % we need to bring coils in front:
            Ntmp     = prod(size(obj.data)) / ( obj.NCol*obj.NCha );
            obj.data = reshape(obj.data,[obj.NCol obj.NCha Ntmp]);
            obj.data = permute(obj.data,[2 1 3]);
            
%             obj.data = L\obj.data(:,:);
            % slower but more memory efficient:
            for k=1:obj.NCnt
                obj.data(:,:,k) = L\obj.data(:,:,k);
            end
            
            % reorder:
            obj.data = reshape(obj.data,[obj.NCha obj.NCol Ntmp]);
            obj.data = permute(obj.data,[2 1 3]);
            obj.data = obj.data(:,:);
            
        end
            
        function performPCA(obj)
            % transforms data to PCA domain in coil dim (e.g. useful for a 
            % simple compression of the data set)

            if numel(obj.data) <= 1
                % object empty (e.g. no phasecor/refscan/etc. data
                % available)
                return;
            end
            
            % we need to bring coils in front:
            obj.data = reshape(obj.data,[obj.NCol obj.NCha obj.NCnt]);            
            obj.data = permute(obj.data,[2 1 3]);
            
            if obj.NCnt > 4000
                % need to be more memory efficient in this case
                % lazy method: just pick some lines by random
                pick       = randperm(obj.NCnt);
                covariance = obj.data(:,:,pick(1:4000));
                covariance = covariance(:,:)*covariance(:,:)';
                clear pick;
            else
                covariance = obj.data(:,:)*obj.data(:,:)';
            end
            
            % Singular Value decomposition
            [U,S,V] = svd(covariance);
            
            % transform to PCA domain
            for k=1:obj.NCnt
                obj.data(:,:,k) = V'*obj.data(:,:,k);
            end
                        
            % reorder:
            obj.data = reshape(obj.data,[obj.NCha obj.NCol obj.NCnt]);
            obj.data = permute(obj.data,[2 1 3]);
            obj.data = obj.data(:,:);
        end
                
        function orderData(obj)
            
            obj.data = reshape(obj.data,obj.dataSize);
            
            if numel(obj.data) == 1
                obj.data     = [];
                obj.dataSize = [0 0];
            end
            
        end
        
        
        function [img cmap] = fft_reco(obj,coilCombineMode,donorm)
            
            cmap = [];
                       
            if ~exist('coilCombineMode','var')
                coilCombineMode = 'none';
            end
            
            if ~exist('donorm','var')
                donorm = 0;
            end
            
            % need to make sure that imSize has at least 5 entries:
            imSize = [1 1 1 1 1];
            imSize(1:ndims(obj.data)) = size(obj.data);
            
            if or(strcmpi(coilCombineMode,'sos'),strcmpi(coilCombineMode,'adapt'))
                imSize(2) = 1; % coils are combined
            end
            
            % Oversampled FoV is cropped:
            imSize(1) = obj.NCol/2;
            cutOS = 1 + obj.NCol/2 + ((-obj.NCol/4) : (obj.NCol/4-1));
             
            % read,lines,part,coils,rest
            imSize = [imSize(1) imSize(3) imSize(4) imSize(2) imSize(5:end)];
            img    = zeros(imSize,'single');
            
            % now reduce all last dims:
            img = img(:,:,:,:,:);
            
            % we need to temporarily change order of data:
            obj.data = permute(obj.data,[1 3 4 2 5:size(obj.data)]);
            
            tmp = zeros([obj.NCol obj.NLin obj.NPar obj.NCha]);
%             if strcmpi(coilCombineMode,'adapt')
%                 for c=1:obj.NCha
%                     tmp(:,:,:,c) = ifftshift(ifftn(ifftshift(mean(obj.data(:,:,:,c,:),5))));
%                 end
%                 [~,cmap,wfull] = openadapt(permute(tmp(cutOS,:,:,:),[4 1 2 3]));
%             end 
            
            for f=1:size(img,5)                
                
                for c=1:obj.NCha
                    tmp(:,:,:,c) = ifftshift(ifftn(ifftshift(obj.data(:,:,:,c,f))));
                end
                
                if strcmpi(coilCombineMode,'sos')
                    img(:,:,:,1,f) = sqrt(sum(abs(tmp(cutOS,:,:,:)).^2,4));
%                 elseif strcmpi(coilCombineMode,'adapt')
%                     img(:,:,:,1,f) = squeeze(sum(wfull.*permute(tmp(cutOS,:,:,:),[4 1 2 3]))); %Combine coil signals. 
                else
                    img(:,:,:,:,f) = tmp(cutOS,:,:,:);
                end
                
            end
            
%             if strcmpi(coilCombineMode,'adapt') && donorm % optional normalization
%                 disp('normalize');
%                 img = bsxfun(@times,img,squeeze(sum(abs(cmap))).^2);
%             end
                
            % reorder obj.data
            obj.data = permute(obj.data,[1 4 2 3 5:size(obj.data)]);
            
            img = reshape(img,imSize);
        end
        
    end
    
    
    methods

        % get-methods:  When user demands variables that were not yet
        %               calculated, calculate and return them.

        function data = get.sqzData(obj)
            data = squeeze(obj.data);
        end
    end
    
end
