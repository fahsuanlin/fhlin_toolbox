function phi_opt=tempcorr_spec_core(data,varargin)

dT=[];

T2_init=0.1;   %20 ms T2
w0_init=0.0;     %0.0 Hz off resonance
T2_fix=0.1;   %20 ms T2
w0_fix=0.0;     %0.0 Hz off resonance

flag_free_real=1;
flag_free_imag=1;

flag_display=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
    case 'dt'
        dT=option_value;
    case 'w0_init'
        w0_init=option_value;
    case 't2_init'
        T2_init=option_value;
    case 't2_fix'
        T2_fix=option_value;
    case 'flag_free_real'
        flag_free_real=option_value;
    case 'flag_free_imag'
        flag_free_imag=option_value;
	case 'flag_display'
		flag_display=option_value;
    otherwise 
        fprintf('unknown option [%s]\n',option);
        fprintf('error!\n');
        return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display)
	fprintf('<<tempcorr_spec core>>\n');
end;

data=data(:);
D=zeros(length(data)+2,3);
D(3:end,3)=data;
D(2:end-1,2)=data;
D(1:end-2,1)=data;
D=D(3:end-2,:);
S_p=D'*D./size(D,1);

phi_init=[T2_init, w0_init];
phi_fix=[T2_fix, w0_fix];

%optimization procedure
options = optimset('MaxIter',1000);

phi_opt = fminsearch('tempcorr_spec_obj', phi_init, options, phi_fix, flag_free_real,flag_free_imag,S_p);

[f_init]=tempcorr_spec_obj(phi_init, phi_fix, flag_free_real,flag_free_imag,S_p)
[f]=tempcorr_spec_obj([0.05 2], phi_fix, flag_free_real,flag_free_imag,S_p)
[f_opt]=tempcorr_spec_obj(phi_opt, phi_fix, flag_free_real,flag_free_imag,S_p)

phi_init
phi_opt

T2_opt=phi_opt(1);
w0_opt=phi_opt(2);
dT=894.*1e-6; %894 us for 32x32 pepsi
timeVec=[0:length(data)-1].*dT;
Y=data(1).*exp(sqrt(-1).*w0_opt.*timeVec-timeVec./T2_opt);

plot(timeVec,real(Y),'b.',timeVec,imag(Y),'b:',timeVec,abs(Y),'b-'); hold on;
plot(timeVec,real(data),'r.',timeVec,imag(data),'r:',timeVec,abs(data),'r-');
keyboard;
if(flag_display)
	fprintf('<<tempcorr_spec core done!>>\n');
end;
return;
    

