function [y_out,kernel, kernel_inv]=etc_regridn(x_in,y_in,x_out,varargin)
%
%
%Ref. O'Sullivan: IEEE Trans. Med. Imag. (1985) Vol:MI-4, p 200-207)
%
%


%parameters for kernel
w=4;
b=5.44;
b=8;
% w=3;
% b=3.51;
kernel=[];
kernel_inv=[];
flag_inv=0;

flag_pr=0;
flag_spiral=0;


for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'w'
            w=option_value;
        case 'b'
            b=option_value;
        case 'kernel' %the kernel for forward the regridding operation
            kernel=option_value;
        case 'kernel_inv' %the kernel for roll-off
            kernel_inv=option_value;
        case 'flag_inv'
            flag_inv=option_value;
        case 'flag_pr'
            flag_pr=option_value;
        case 'flag_spiral'
            flag_spiral=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


if(isempty(kernel)|isempty(kernel_inv))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %density calculation: JBM approach
%     x=repmat(transpose(x_in),[1 1 size(x_in,1)]);
%     x=x-permute(repmat(transpose(x_in),[1 1 size(x_in,1)]),[1 3 2]);
%     x=squeeze(sqrt(sum(x.^2,1)));
%     x(find(abs(x)>w))=nan;
    
    ReferencePts = x_in; 
    %%% Build the k-d Tree once from the reference datapoints.
    [tmp, tmp, TreeRoot] = kdtree( ReferencePts, []);
    %%% and find all the points in the k-d tree that are within 'w'
    %%% units (D-dimensional Euclidean, 2-norm, distance) from the target
    %%% points
    %x=ones(size(x_in,1),size(x_in,1)).*nan;
    x=sparse([],[],[],size(x_in,1),size(x_in,1),0);
    for i=1:size(x_in,1)
        if(mod(i,100)==0) fprintf('[%2.2f%%]...\r',i./size(x_in,1)*100); end;        
        if(flag_pr) %density calculation for projection acquisition
           rr=norm(x_in(i,:));
           d_r=1;
           d_theta=pi/sqrt(size(x_in,1));
           kernel.delta_x(i)=rr*d_r*d_theta;
       elseif(flag_spiral) %density calculation for spiral acquisition
           
       else
            [ PtsInNeighborhood, Dist,idx ] = kdrangequery( TreeRoot, x_in(i,:), w*4 );
        
             kernel.delta_x(i)=min(setdiff(Dist,0));
        
             Delta_x=Dist.^2;
             Delta_x(find(Dist>w*w))=0;
             %kernel.delta_x(i)=sqrt(mean(Delta_x(find(Delta_x))));
             kernel.delta_x(i)=w;
        end;
    end;
%    kernel.delta_x=1./transpose(sum(x,2));

    %%% Free the k-D Tree from memory.
    kdtree([],[],TreeRoot);

    %density preparation
%     tmp=b.*sqrt(1-(2.*x./w).^2);
%     Delta_x=1./w.*besseli(0,tmp);
%     idx=find((2.*x./w<-1)|(2.*x./w>1));
%     Delta_x(idx)=0;
%     Delta_x(isnan(Delta_x(:)))=0;
%     kernel.delta_x=1./transpose(sum(Delta_x,2));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %distance between input and output data grid
%     x=repmat(transpose(x_in),[1 1 size(x_out,1)]);
%     x=x-permute(repmat(transpose(x_out),[1 1 size(x_in,1)]),[1 3 2]);
%     x=transpose(squeeze(sqrt(sum(x.^2,1))));
%     x(find(abs(x)>w))=nan;
    
    ReferencePts = x_in; 
    %%% Build the k-d Tree once from the reference datapoints.
    [tmp, tmp, TreeRoot] = kdtree( ReferencePts, []);
    %%% and find all the points in the k-d tree that are within 'w'
    %%% units (D-dimensional Euclidean, 2-norm, distance) from the target
    %%% points
    %x=ones(size(x_out,1),size(x_in,1)).*nan;
    x=sparse([],[],[],size(x_out,1),size(x_in,1),0);
    for i=1:size(x_out,1)
        if(mod(i,100)==0) fprintf('[%2.2f%%]...\r',i./size(x_out,1)*100); end;
        [ PtsInNeighborhood, Dist,idx ] = kdrangequery( TreeRoot, x_out(i,:), w );
        x(i,idx)=Dist;
        
        Delta_x=1./w.*besseli(0,b.*sqrt(1-(2.*Dist./w).^2));
        jdx=find((2.*Dist./w<-1)|(2.*Dist./w>1));
        Delta_x(jdx)=0;
        x(i,idx)=Delta_x;
    end;
    kernel.weights=x;
    %%% Free the k-D Tree from memory.
    kdtree([],[],TreeRoot);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %kernel preparation
%     tmp=b.*sqrt(1-(2.*x./w).^2);
%     Kernel=1./w.*besseli(0,tmp);
%     idx=find((2.*x./w<-1)|(2.*x./w>1));
%     Kernel(idx)=0;
%     Kernel(isnan(Kernel(:)))=0;
%     kernel.weights=Kernel;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %inverse kernel preparation -- roll-off kernel
    arg=sqrt(sum(abs(x_out).^2,2));
    mx=max(arg,[],1);
    x=arg./mx./sqrt(size(x_out,2));
    
    %x=sqrt(sum(abs(x_out).^2,2));
    arg=sqrt(pi.^2.*w.^2.*x.^2-b.^2);
    %Kernel=sin(arg)./arg.*b./sinh(b);
    Kernel=sin(arg)./arg;
    
    %Kernel(find(Kernel(:)<0.05))=0.05;
    
    
    kernel_inv.weights=Kernel;
    
    kernel_inv.delta_x=Kernel;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;

%output as convolution
if(~flag_inv) %regridding
    %y_out=sum(repmat(transpose(y_in(:)),[size(x_out,1),1]).*kernel.weights.*repmat(kernel.delta_x,[size(x_out,1),1]),2);
    %y_out=sum(repmat(transpose(y_in(:)).*kernel.delta_x,[size(x_out,1),1]).*kernel.weights,2); 
    tmp=transpose(y_in(:)).*kernel.delta_x;
    for i=1:size(kernel.weights,1)
        idx=find(kernel.weights(i,:));
        if(~isempty(idx))
            %y_out(i)=tmp(idx)*transpose(kernel.weights(i,idx))./sum(kernel.weights(i,idx).*kernel.delta_x(idx));
            y_out(i)=tmp(idx)*transpose(kernel.weights(i,idx));
        else
            y_out(i)=0;
        end;
    end;
    scale=sqrt(sum(abs(y_in(:).^2))./sum(abs(y_out(:).^2)));
    y_out=y_out.*scale;
else  %roll-off
    %y_out=y_in(:).*conj(kernel_inv.delta_x(:))./abs(kernel_inv.delta_x(:)).^2;
    y_out=y_in(:)./kernel_inv.delta_x(:);
    scale=sqrt(sum(abs(y_in(:).^2))./sum(abs(y_out(:).^2)));
    y_out=y_out.*scale;
end;

return;
