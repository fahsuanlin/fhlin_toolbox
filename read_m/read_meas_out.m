function [kvol, navs] = read_meas_out(varargin)
% (Painfully slow) reader for "meas.out" files (Siemens Num4 raw data)
% [kvol, navs] = read_meas_out    (assumes "meas.out" in current dir)
% [kvol, navs] = read_meas_out('my_meas.out') 
%
% Note 1: the only navigators this handles are the standard ones used
% in the Siemens EPI sequences: i.e. for each slice, a navigator is
% acquired by reading the center k-space line 3 times, and the mdh
% head is marked with an MDH_PHASECOR.
%
% Dimensions:
% ---------
% 1 -- Column (in k-space)
% 2 -- Phase encode line (row in k-space)
% 3 -- Partition (slice in 3-D k-space) or Slice
% 4 -- Repetition (i.e. the only change is time)
% 5 -- Echo 

% (MukundB, Tue Dec 18, 2001)

more off

numNavs = 3;

DISPLAY = 1;
if nargin >=2
  DISPLAY = varargin{2};
end

if nargin >= 1
  fname = varargin{1};
else
  files = dir;
  MEASOUT_FOUND = 0;
  for ff = 1:length(files)
    if strcmp(files(ff).name, 'meas.out')
      MEASOUT_FOUND = 1;
    end
  end
  if MEASOUT_FOUND == 0
    fprintf('There is no meas.out in the current directory\n');
    error('Exiting ...');
  end
  fname = 'meas.out';
end

fid = fopen(fname, 'r', 'l');

% data starts 32 bytes from the file beginning for pineapple
meas_out_start_offset = fread(fid, 1, 'long'); 
fseek(fid, meas_out_start_offset, 'bof'); 

% Initialize for loop 1
ccMax = 1;
rrMax = 1;
psMax = 1;
ttMax = 1;
ecMax = 1;
CONT = 1;

% Start loop 1
if DISPLAY
  tic
end
while CONT == 1
  
  [adc_data, mdh] = read_mdh_adc(fid);

  if (mdh.EvalInfoMask(1)) % i.e. MDH_ACQEND
    
    CONT = 0;
    
  else

    ccMax = mdh.SamplesInScan;
    
    rr = mdh.LoopCounter.Line + 1;
    ps = max(mdh.LoopCounter.Partition + 1, ...
	     mdh.LoopCounter.Slice + 1);
    tt = mdh.LoopCounter.Repetition + 1;
    ec = mdh.LoopCounter.Echo + 1;

    if DISPLAY
      fprintf('%d %d %d %d %d\n', ...
	      rr, ccMax, ps, tt, ec);
    end
    
    if rr > rrMax
      rrMax = rr;
    end
    if ps > psMax
      psMax = ps;
    end
    if tt > ttMax
      ttMax = tt;
    end
    if ec > ecMax
      ecMax = ec;
    end

  end
  
end
if DISPLAY
  toc
  [rrMax ccMax psMax ttMax ecMax]
  fprintf('Paused: Hit any key\n');
  pause
end

% Initialize for loop 2
kvol = zeros(rrMax, ccMax, psMax, ttMax, ecMax);
navs = zeros(numNavs, ccMax, psMax, ttMax, ecMax);
numADCs = rrMax*psMax*ttMax*ecMax;
PERC = 10;
counter = 1;
navcounter = 1;
fseek(fid, meas_out_start_offset, 'bof'); 
CONT = 1;

% Start loop 2
if DISPLAY
  tic
end
while CONT == 1
  
  [adc_data, mdh] = read_mdh_adc(fid);
    
  if mdh.EvalInfoMask(1) % i.e. MDH_ACQEND
    
    CONT = 0;
    
  else

    rr = mdh.LoopCounter.Line + 1;
    
    ps = max(mdh.LoopCounter.Partition + 1, ...
	     mdh.LoopCounter.Slice + 1);
    
    tt = mdh.LoopCounter.Repetition + 1;
    ec = mdh.LoopCounter.Echo + 1;

    if mdh.EvalInfoMask(22) % i.e. MDH_PHASECOR
      
      navs(navcounter, :, ps, tt, ec) = adc_data;
      navcounter = navcounter + 1;
      if navcounter > 3
	navcounter = 1;
      end
      
    else
      
      kvol(rr, :, ps, tt, ec) = adc_data;

      if DISPLAY
	if 100*counter/numADCs > PERC;
	  fprintf('%d%% done\n', PERC);
	  PERC = PERC + 10;
	end
      end
      
      counter = counter + 1;
      
    end
    
  end
  
end
if DISPLAY
  toc
end

fclose(fid);

more on