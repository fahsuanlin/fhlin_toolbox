function pepsi_view(data,varargin)

global pepsi_figure;
global pepsi_data;
global pepsi_legend;
global pepsi_type;
global pepsi_bandwidth;
global pepsi_b0;
global pepsi_cf;


pepsi_type='abs';
pepsi_legend={};
pepsi_bandwidth=[];
pepsi_b0=[];
pepsi_cf=[];
pepsi_now_zoomin=1;

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};
	switch lower(option)
    case 'pepsi_b0'
            pepsi_b0=option_value;
    case 'pepsi_cf'
            pepsi_cf=option_value;
    case 'pepsi_bandwidth'
            pepsi_bandwidth=option_value;
	case 'pepsi_legend'
		pepsi_legend=option_value;
	case 'pepsi_type'
		pepsi_type=option_value;
	end;
end;



pepsi_figure=figure;

pepsi_data=data;

set(pepsi_figure,'KeyPressFcn','pepsi_view_handle(''kb'')');
set(pepsi_figure,'WindowButtonDownFcn','pepsi_view_handle(''bd'')');
set(pepsi_figure,'name','pepsi_figure');

pepsi_view_handle('init')
