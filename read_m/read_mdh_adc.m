function [adc_data, mdh] = read_mdh_adc(fid)
% Read the (complex) data off the ADC and the Mdh (Siemens Numaris 4
% Measurement Data Header)
%
% [adc_data, mdh] = read_mdh_adc(fid)

% (MukundB, Tue Dec 4, 2001)

% First, read the mdh (measurement data header)
mdh.DMAlength = fread(fid, 1, 'ulong');
mdh.MeasUID = fread(fid, 1, 'long');
mdh.ScanCounter = fread(fid, 1, 'ulong');

% time since 00:00 in 2.5 ms ticks
mdh.TimeStamp = fread(fid, 1, 'ulong');
mdh.TimeStamp = 2.5 * mdh.TimeStamp; % now in milliseconds

% time since last trigger in 2.5 ms ticks
mdh.PMUTimeStamp = fread(fid, 1, 'ulong');  
mdh.PMUTimeStamp = 2.5 * mdh.PMUTimeStamp; % now in milliseconds

% EVALINFOMASK
bitMask = fread(fid, 1, 'ulong');
evalInfo = {'MDH_ACQEND', ...             %  1
	    'MDH_RTFEEDBACK', ...         %  2
	    'MDH_HPFEEDBACK', ...         %  3
	    'MDH_ONLINE', ...             %  4
	    'MDH_OFFLINE', ...            %  5
	    'Six', ...                    %  6
	    'Seven', ...                  %  7
	    'Eight', ...                  %  8
	    'Nine', ...                   %  9
	    'Ten', ...                    % 10
	    'Eleven', ...                 % 11
	    'Twelve', ...                 % 12
	    'Thirteen', ...               % 13
	    'Fourteen', ...               % 14
	    'MDH_REFPHASESTABSCAN', ...   % 15
	    'MDH_PHASESTABSCAN', ...      % 16
	    'MDH_D3FFT', ...              % 17
	    'MDH_SIGNREV', ...            % 18
	    'MDH_PHASEFFT', ...           % 19
	    'MDH_SWAPPED', ...            % 20
	    'MDH_POSTSHAREDLINE', ...     % 21
	    'MDH_PHASCOR', ...            % 22
	    'MDH_ZEROLINE', ...           % 23
	    'MDH_ZEROPARTITION', ...      % 24
	    'MDH_REFLECT', ...            % 25
	    'MDH_NOISEADJSCAN', ...       % 26
	    'MDH_SHARENOW', ...           % 27
	    'MDH_LASTMEASUREDLINE', ...   % 28
	    'MDH_FIRSTSCANINSLICE', ...   % 29
	    'MDH_LASTSCANINSLICE', ...    % 30
	    'MDH_TREFFECTIVEBEGIN', ...   % 31
	    'MDH_TREFFECTIVEEND'};        % 32

mask = zeros(32,1);
for iii = 1:32
  mask(iii) = bitget(bitMask, iii);
end

mdh.EvalInfoMask = mask;
mdh.EvalInfoMaskChar = evalInfo(find(mask));
mdh.EvalInfoMaskChar = mdh.EvalInfoMaskChar(:);

mdh.SamplesInScan = fread(fid, 1, 'ushort');
mdh.UsedChannels = fread(fid, 1, 'ushort');

mdh.LoopCounter.Line = fread(fid, 1, 'ushort');
mdh.LoopCounter.Acquisition = fread(fid, 1, 'ushort');  
mdh.LoopCounter.Slice = fread(fid, 1, 'ushort');         
mdh.LoopCounter.Partition = fread(fid, 1, 'ushort');  
mdh.LoopCounter.Echo = fread(fid, 1, 'ushort');          
mdh.LoopCounter.Phase = fread(fid, 1, 'ushort');         
mdh.LoopCounter.Repetition = fread(fid, 1, 'ushort');  
mdh.LoopCounter.Set = fread(fid, 1, 'ushort');  
mdh.LoopCounter.Seg = fread(fid, 1, 'ushort');  
mdh.LoopCounter.Free = fread(fid, 1, 'ushort');  

mdh.CutOffData.Pre = fread(fid, 1, 'ushort');  
mdh.CutOffData.Post = fread(fid, 1, 'ushort');  

mdh.KSpaceCentreColumn = fread(fid, 1, 'ushort');

mdh.Dummy = fread(fid, 1, 'ushort');
mdh.ReadOutOffcentre = fread(fid, 1, 'float');
mdh.TimeSinceLastRF = fread(fid, 1, 'ulong');
mdh.KSpaceCentreLineNo = fread(fid, 1, 'ushort');
mdh.KSpaceCentrePartitionNo = fread(fid, 1, 'ushort');

mdh.FreePara = fread(fid, 14, 'ushort');

mdh.SD.SlicePosVec.Sag = fread(fid, 1, 'float');
mdh.SD.SlicePosVec.Cor = fread(fid, 1, 'float');
mdh.SD.SlicePosVec.Tra = fread(fid, 1, 'float');
mdh.SD.Quaternion = fread(fid, 4, 'float');

mdh.ChannelId = fread(fid, 1, 'ulong');

% Last, read the adc_data
adc_data = fread(fid, 2*mdh.SamplesInScan, 'float');
if(prod(size(adc_data))~=2*mdh.SamplesInScan)
	keyboard;
end;
adc_data = reshape(adc_data, 2, mdh.SamplesInScan); 
adc_data = complex(adc_data(1,:), adc_data(2,:));
