function []=ice_calc_epi_phase_correction(sMdh)

global ice_obj;

if(~ice_obj.flag_3D)
    odd=ice_obj.nav{sMdh.sLC.ushSlice+1,2};         %from line "1"
    even=ice_obj.nav{sMdh.sLC.ushSlice+1,1};        %from line "0"
else
    %fprintf('[%d]\n',sMdh.sLC.ushPartition);
    odd=ice_obj.nav{mod(sMdh.sLC.ushPartition,2)+1,2};         %from line "1"
    even=ice_obj.nav{mod(sMdh.sLC.ushPartition,2)+1,1};        %from line "0"
end;


if(~isempty(even)&~isempty(odd))
    %use the biggest (1-fraction) proportion of the data to estimate phase
    %shift
    if(~isfield(ice_obj,'nav_data_fraction'))
        ice_obj.nav_data_fraction=0.3;
    else
        if(isempty(ice_obj.nav_data_fraction))
            ice_obj.nav_data_fraction=0.3;
        end;
    end;
    
    %weighted least square fitting
    if(ice_obj.flag_phase_cor_algorithm_lsq) %least-square
%         for i=1:size(even,2)
%             RR=abs(even(:,i).*odd(:,i));
%             Rs=sort(RR);
%             idx=find(RR>Rs(round(length(Rs)*(1-ice_obj.nav_data_fraction))));
%             R=diag(RR(idx));
%             RR=diag(RR);
%             
%             
%             phase=-unwrap(angle(odd(:,i)))+unwrap(angle(even(:,i)));
%             phase=phase(idx);
%             x=([0:size(even,1)-1]-size(even,1)/2+0.5)';
%             XX=[x, ones(size(x))];
%             X=XX(idx,:);
%             
%             phi(:,i)=inv(X'*pinv(R)*X)*X'*pinv(R)*phase;
%         end;
%         ice_obj.nav_phase_slope=phi(1,:)';
%         ice_obj.nav_phase_offset=phi(2,:)';
%         ice_obj.nav_phase_slope=median(phi(1,:)).*ones(size(even,2),1);
%         ice_obj.nav_phase_offset=angle(mean(exp(sqrt(-1).*phi(2,:)))).*ones(size(even,2),1);
%         phi_cor=repmat(x,[1, size(even,2)])*diag(ice_obj.nav_phase_slope)+ones(size(even,1),1)*ice_obj.nav_phase_offset';
        
        RR=abs(even(:).*odd(:));
        Rs=sort(RR);
        idx=find(RR>Rs(round(length(Rs)*(1-ice_obj.nav_data_fraction))));
        R=diag(RR(idx));
        
        phase=[];
        for ii=1:size(odd,2)
            %phase=cat(1,phase,-unwrap(angle(odd(:,ii)))+unwrap(angle(even(:,ii))));
            phase=cat(1,phase,unwrap(-angle(odd(:,ii))+angle(even(:,ii))));
        end;
        phase=unwrap(phase(idx));
        x=repmat(([0:size(even,1)-1]-size(even,1)/2+0.5)',[size(even,2),1]);
        XX=[x, ones(size(x))];
        X=XX(idx,:);

        phi=inv(X'*pinv(R)*X)*X'*pinv(R)*phase;

        ice_obj.nav_phase_slope=phi(1).*ones(size(even,2),1);
        ice_obj.nav_phase_offset=phi(2).*ones(size(even,2),1);
        
        phi_cor=repmat(([0:size(even,1)-1]-size(even,1)/2+0.5)'.*phi(1)+phi(2),[1,size(even,2)]);
        
        if(~ice_obj.flag_3D)
            ice_obj.nav_phase_cor{sMdh.sLC.ushSlice+1}=exp(sqrt(-1).*phi_cor);
        else
            %ice_obj.nav_phase_cor{mod(sMdh.sLC.ushPartition,2)+1}=exp(sqrt(-1).*phi_cor);
            ice_obj.nav_phase_cor{sMdh.sLC.ushPartition+1}=exp(sqrt(-1).*phi_cor);
        end;
        %ice_obj.nav_phase_offset=zeros(size(phi(2,:)'));
    end;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(ice_obj.flag_phase_cor_algorithm_jbm)    %jbm's algorithm
        %original JBM algorithm
        odd2=odd(1:end-1,:);
        odd1=odd(2:end,:);
        even2=even(1:end-1,:);
        even1=even(2:end,:);
        
        %odd_linear_angle=angle(diag(odd1'*odd2));
        %even_linear_angle=angle(diag(even1'*even2));
        odd_linear_angle=angle(sum(conj(odd1).*odd2,1))';
        even_linear_angle=angle(sum(conj(even1).*even2,1))';

        
%         y=imag(log(odd)-log(even));
%         xx=[1:size(y,1)]';
%         for ii=1:size(y,2)
%             R=diag(abs(even(:,ii)).*abs(odd(:,ii)));
%             ss(ii)=real(inv(xx'*inv(R)*xx)*xx'*inv(R)*y(:,ii));
%         end;
%         ice_obj.nav_phase_slope=ss';

        
        x=([0:size(even,1)-1]-size(even,1)/2+0.5)';
        
        %offset=angle(diag(even'*odd));
        offset=angle(sum(conj(even).*odd,1))';
        ice_obj.nav_phase_slope=(odd_linear_angle-even_linear_angle);
        if(~ice_obj.flag_phase_cor_offset)
            ice_obj.nav_phase_offset=zeros(size(offset));
        else
            ice_obj.nav_phase_offset=-offset;
        end;
        
        phi_cor=repmat(x,[1, size(even,2)])*diag(ice_obj.nav_phase_slope)+ones(size(even,1),1)*ice_obj.nav_phase_offset';
        
        if(~ice_obj.flag_3D)
            ice_obj.nav_phase_cor{sMdh.sLC.ushSlice+1}=exp(sqrt(-1).*phi_cor);
        else
            %ice_obj.nav_phase_cor{mod(sMdh.sLC.ushPartition,2)+1}=exp(sqrt(-1).*phi_cor);
            ice_obj.nav_phase_cor{sMdh.sLC.ushPartition+1}=exp(sqrt(-1).*phi_cor);
        end;
    end;
end;

% this is the previous implementation of JBM's phase correction
% odd2=odd(1:end-1,:);
% odd1=odd(2:end,:);
% even2=even(1:end-1,:);
% even1=even(2:end,:);
% odd_linear_angle=angle(diag(odd1'*odd2));
% even_linear_angle=angle(diag(even1'*even2));
%
% offset=angle(diag(even'*odd));
%
% ice_obj.nav_phase_slope=odd_linear_angle-even_linear_angle;
% ice_obj.nav_phase_offset=offset;
% ice_obj.nav_phase_offset=zeros(length(offset),1);
return;
