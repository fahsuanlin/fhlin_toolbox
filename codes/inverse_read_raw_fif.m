function [data,timeVec,ch_names] = inverse_read_raw_fif(fname,from,to,varargin)
%
%   [ data, timeVec,ch_names ] = inverse_read_raw_fif(fname,from,to, [option1, option_value1,...]);
%
%   data        - The data read, compensated and projected, channel by
%                 channel
%   timeVec     - The time points of the samples, in seconds
%
%   ch_names	- The names of selected channels	
%
%
%   fname       - The name of the input fif file
%   from        - Starting sample
%   to          - Ending sample
%

flag_display=0;

hp=[]; %high-pass filter (Hz)

trigger_channel=[];

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch lower(option)
	case 'flag_display'
		flag_display=option_value;
	case 'hp'
		hp=option_value;
	case 'trigger_channel'
		trigger_channel=option_value;
	otherwise
		fprintf('unknown option [%s]. error!\n',option);
		return;
	end;
end;

if(isempty(trigger_channel)) trigger_channel='STI 014'; end;

raw = fiff_setup_read_raw(fname);

%
%   Set up pick list: MEG + STI 014 - bad channels
%
include{1} = trigger_channel;
want_meg   = true;
want_eeg   = false;
want_stim  = false;
%
picks = fiff_pick_types(raw.info,want_meg,want_eeg,want_stim,include,raw.info.bads);
%
%   Set up projection
%
if isempty(raw.info.projs)
    if(flag_display) fprintf('No projector specified for these data\n'); end;
    raw.proj = [];
else
    %
    %   Activate the projection items
    %
    for k = 1:length(raw.info.projs)
        raw.info.projs(k).active = true;
    end
    if(flag_display) fprintf(1,'%d projection items activated\n',length(raw.info.projs)); end;
    %
    %   Create the projector
    %
    [proj,nproj] = mne_make_projector_info(raw.info);
    if nproj == 0
        if(flag_display) fprintf('The projection vectors do not apply to these channels\n'); end;
        raw.proj = [];
    else
        if(flag_display) fprintf(1,'Created an SSP operator (subspace dimension = %d)\n',nproj); end;
        raw.proj = proj;
    end
end

%
%   Read a data segment
%   times output argument is optional
%

from0=from;
to0=to;
if(~isempty(hp))
	hp_length=round(1./hp*raw.info.sfreq);
	from=from-hp_length+1;	
	to=to;
end;


ch_names={};
for idx=1:length(picks)
	ch_names{idx}=raw.info.ch_names{picks(idx)};
end;

[ data, timeVec ] = fiff_read_raw_segment(raw,from,to,picks);

if(~isempty(hp))

	[ data0, timeVec ] = fiff_read_raw_segment(raw,from0,to0,picks);

	dataf=data-filter(ones(1,hp_length)/hp_length,1,data,[],2);
	
	data=dataf(:,hp_length:end);

	if(size(data,2)~=size(data0,2))
		if(flag_display) fprintf('not filtered due to data size problem...\n'); end;
		data=data0;
	end;
end;


if(flag_display) fprintf('Read %d samples.\n',size(data,2)); end;
%
%   Remember to close the file descriptor
%
fclose(raw.fid);
if(flag_display) fprintf('File closed.\n'); end;

return;
