function [adc_data, mdh] = read_mdh_adc_VA21(fid)
% Read the (complex) data off the ADC and the Mdh (Siemens Numaris 4
% Measurement Data Header)
%
% [adc_data, mdh] = read_mdh_adc(fid)

% (MukundB, Tue Dec 4, 2001)
% Revised for VA21 (AvdK, Tue Dec 12, 2002)

% First, read the mdh (measurement data header)
mdh.DMAlength = fread(fid, 1, 'ulong');
if feof(fid)
    adc_data = [];
    return
end
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
	    'MDH_LASTSCANINCONCAT', ...   %  9
	    'Ten', ...                    % 10
	    'MDH_RAWDATACORRECTION', ...  % 11
	    'MDH_LASTSCANINMEAS', ...     % 12
	    'MDH_SCANSCALEFACTOR', ...    % 13
	    'MDH_2NDHADAMARPULSE', ...    % 14
	    'MDH_REFPHASESTABSCAN', ...   % 15
	    'MDH_PHASESTABSCAN', ...      % 16
	    'MDH_D3FFT', ...              % 17
	    'MDH_SIGNREV', ...            % 18
	    'MDH_PHASEFFT', ...           % 19
	    'MDH_SWAPPED', ...            % 20
	    'MDH_POSTSHAREDLINE', ...     % 21
	    'MDH_PHASCOR', ...            % 22
	    'MDH_PATREFSCAN', ...         % 23
	    'MDH_PATREFANDIMASCAN', ...   % 24
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

bitMask2 = fread(fid, 1, 'ulong'); % Last 32 bits of 64 bit EvalInfoMask (what's in here?)
mdh.EvalInfoMask2 = bitMask2;

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
mdh.LoopCounter.Ida = fread(fid, 1, 'ushort');
mdh.LoopCounter.Idb = fread(fid, 1, 'ushort');
mdh.LoopCounter.Idc = fread(fid, 1, 'ushort');
mdh.LoopCounter.Idd = fread(fid, 1, 'ushort');
mdh.LoopCounter.Ide = fread(fid, 1, 'ushort');

mdh.CutOffData.Pre = fread(fid, 1, 'ushort');
mdh.CutOffData.Post = fread(fid, 1, 'ushort');

mdh.KSpaceCentreColumn = fread(fid, 1, 'ushort');
mdh.Dummy = fread(fid, 1, 'ushort');
mdh.ReadOutOffcentre = fread(fid, 1, 'float');
mdh.TimeSinceLastRF = fread(fid, 1, 'ulong');
mdh.KSpaceCentreLineNo = fread(fid, 1, 'ushort');
mdh.KSpaceCentrePartitionNo = fread(fid, 1, 'ushort');

mdh.IceProgramPara = fread(fid, 4, 'ushort');
mdh.FreePara = fread(fid, 4, 'ushort');

mdh.SD.SlicePosVec.Sag = fread(fid, 1, 'float');
mdh.SD.SlicePosVec.Cor = fread(fid, 1, 'float');
mdh.SD.SlicePosVec.Tra = fread(fid, 1, 'float');
mdh.SD.Quaternion = fread(fid, 4, 'float');

mdh.ChannelId = fread(fid, 1, 'ulong');

% Last, read the adc_data
adc_data = fread(fid, 2*mdh.SamplesInScan, 'float');
adc_data = reshape(adc_data, 2, mdh.SamplesInScan);
adc_data = complex(adc_data(1,:), adc_data(2,:));

