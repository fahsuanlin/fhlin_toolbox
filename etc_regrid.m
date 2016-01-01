function[y_out,kernel, kernel_inv]=etc_regrid(x_in,y_in,x_out,varargin)
%
%
%Ref. O'Sullivan: IEEE Trans. Med. Imag. (1985) Vol:MI-4, p 200-207)
%
%


%parameters for kernel
%w=4;
%b=5.44;
w=3.5;
b=4.91;
kernel=[];
kernel_inv=[];
flag_inv=0;

for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'w'
            w=option_value;
        case 'b'
            b=option_value;
        case 'kernel'
            kernel=option_value;
        case 'kernel_inv'
            kernel_inv=option_value;
        case 'flag_inv'
            flag_inv=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%density calculation
% [x_s,idx]=sort(x_in);
% delta_x=diff(x_s);
% delta_x=[x_s(1) delta_x];
% delta_x(idx)=delta_x;

%density calculation: JBM approach
x=repmat(x_in(:)',[length(x_in),1]);
x=x-repmat(x_in(:),[1, length(x_in)]);
x(find(abs(x)>w))=nan;

%density preparation
tmp=b.*sqrt(1-(2.*x./w).^2);
delta_x=1./w.*besseli(0,tmp);
idx=find((2.*x./w<-1)|(2.*x./w>1));
delta_x(idx)=0;
delta_x(isnan(delta_x(:)))=0;
kernel.delta_x=1./sum(delta_x,2)';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%distance between input and output data grid
x=repmat(x_in(:)',[length(x_in),1]);
x=x-repmat(x_out(:),[1, length(x_in)]);
x(find(abs(x)>w))=nan;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%kernel preparation
tmp=b.*sqrt(1-(2.*x./w).^2);
Kernel=1./w.*besseli(0,tmp);
idx=find((2.*x./w<-1)|(2.*x./w>1));
Kernel(idx)=0;
Kernel(isnan(Kernel(:)))=0;
kernel.weights=Kernel;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%inverse kernel preparation
x=[0:length(x)-1]./length(x);
Kernel=sin(sqrt(pi.*2.*w.*2.*x.^2-b.^2))./sqrt(pi.*2.*w.*2.*x.^2-b.^2);
kernel_inv.weights=Kernel;

kernel_inv.delta_x=kernel.delta_x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%output as convolution
if(~flag_inv)
    y_out=sum(repmat(transpose(y_in(:)),[size(x_out,1),1]).*kernel.weights.*repmat(kernel.delta_x,[size(x_out,1),1]),2);
else
    %y_out=sum(repmat(y_in(:)',[size(x_out,1),1]).*kernel_inv.weights.*repmat(kernel_inv.delta_x,[size(x_out,1),1]),2);
    y_out=y_in(:).*conj(kernel_inv.delta_x(:))./abs(kernel_inv.delta_x(:)).^2;
end;

return;
