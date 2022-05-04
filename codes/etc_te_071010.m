function [TE2to1, TE1to2, pval2to1, pval1to2, prob_joint1, prob_joint2, prob_joint_perm1, prob_joint_perm2, min_si1_idx, min_si2_idx]=etc_te(ROI, varargin)

TE2to1=[];
TE1to2=[];
pval2to1=[];
pval1to2=[];

edge_roi=[];
tree=[];
timeVec=[];

flag_display=1;
flag_self_information_latency=1;

n_repeat=1e3; %number of permutation in null distribution estimation
n_delay=[1]; %latency of time series 
n_bin=2;    %the number of bin in the histogram calculation

source_history=[];
target_future=[];

edge1=[];
edge2=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'n_repeat'
            n_repeat=option_value;
        case 'n_delay'
            n_delay=option_value;
        case 'n_bin'
            n_bin=option_value;
        case 'edge_roi'
            edge_roi=option_value;
        case 'timevec'
            timeVec=option_value;
        case 'edge1'
            edge1=option_value;
        case 'edge2'
            edge2=option_value;
        case 'treeroot'
            tree=option_value;
        case 'flag_self_information_latency'
            flag_self_information_latency=option_value;
        case 'source_history'
            source_history=option_value;
        case 'target_future'
            target_future=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;



%use self-information to reduce auto-correlation
if(flag_self_information_latency)
    if(flag_display)
        fprintf('estimating the latency for minimal self-information....\n');
    end;
    for i=1:min(100,floor(size(ROI,1)./2))    
        si_1(i)=etc_mi(ROI(i+1:end,1)',ROI(1:end-i,1)',n_bin);
        si_2(i)=etc_mi(ROI(i+1:end,2),ROI(1:end-i,2),n_bin);
    end;
    [min_si1, min_si1_idx]=min(si_1);
    [min_si2, min_si2_idx]=min(si_2);    
else
    min_si1_idx=1;
    min_si2_idx=1;
end;
%  min_si1_idx=10;
%  min_si2_idx=10;
    
if(flag_display)
    fprintf('min SI for time series 1 with lantecy [%d] samples...\n',min_si1_idx);
    fprintf('min SI for time series 2 with lantecy [%d] samples...\n',min_si2_idx);
end;

n_delay=[1:max([min_si1_idx min_si2_idx])];
n_delay=max([min_si1_idx min_si2_idx]);
%determine edges for histogram
if(isempty(edge1)|isempty(edge2))
    if(~isempty(timeVec))
        base_idx=find(timeVec<0);
        avg1=mean(ROI(base_idx,1));
        avg2=mean(ROI(base_idx,2));
        std1=std(ROI(base_idx,1));
        std2=std(ROI(base_idx,2));
        max1=max(ROI(:,1));
        max2=max(ROI(:,2));
        min1=min(ROI(:,1));
        min2=min(ROI(:,2));
        %histogram edges determined by max/min values
        edge1=[min1:(max1-min1)./(n_bin):max1];
        edge2=[min2:(max2-min2)./(n_bin):max2];
        %histogram edges determined by std.
        edge1=avg1+[-n_bin/2:1:n_bin/2]'.*std1;
        edge2=avg2+[-n_bin/2:1:n_bin/2]'.*std2;
    else
        edge1=[];
        edge2=[];
    end;
end;

target_future=length(target_future);

for d_idx=1:length(n_delay)
%    [prob_joint1, TE2to1(d_idx)]=etc_mi_nd([ROI(n_delay(d_idx)+1:end,1) ROI(1:end-n_delay(d_idx),1) ROI(1:end-n_delay(d_idx),2)],n_bin,'edge_roi',edge_roi);
%    [prob_joint2, TE1to2(d_idx)]=etc_mi_nd([ROI(n_delay(d_idx)+1:end,2) ROI(1:end-n_delay(d_idx),2) ROI(1:end-n_delay(d_idx),1)],n_bin,'edge_roi',edge_roi);
    if(isempty(source_history))
        %[prob_joint1, TE2to1(d_idx),tr1]=etc_mi_nd([ROI(min_si1_idx+1:end,1) ROI(1:end-min_si1_idx,1) ROI(1:end-min_si1_idx,2)],n_bin,'edge_roi',edge_roi);
        %[prob_joint2, TE1to2(d_idx),tr2]=etc_mi_nd([ROI(min_si2_idx+1:end,2) ROI(1:end-min_si2_idx,2) ROI(1:end-min_si2_idx,1)],n_bin,'edge_roi',edge_roi);
        [prob_joint1, TE2to1(d_idx),tr1]=etc_mi_nd([ROI(min_si1_idx+1:end,1) ROI(1:end-min_si1_idx,1) ROI(1:end-min_si1_idx,2)],n_bin,'edge_roi',[edge1 edge1 edge2]);
        [prob_joint2, TE1to2(d_idx),tr2]=etc_mi_nd([ROI(min_si2_idx+1:end,2) ROI(1:end-min_si2_idx,2) ROI(1:end-min_si2_idx,1)],n_bin,'edge_roi',[edge2 edge2 edge1]);
    else
        ROI_a=[];
        ROI_b=[];
        for t=0:source_history
            for l=0:target_future
                ROI_a=cat(1,ROI_a,[ROI(min_si1_idx+1+t:end,1) ROI(t+1:end-min_si1_idx,1) ROI(1:end-min_si1_idx-t,2)]);
                ROI_b=cat(1,ROI_b,[ROI(min_si2_idx+1+t:end,2) ROI(t+1:end-min_si2_idx,2) ROI(1:end-min_si2_idx-t,1)]);
            end;
        end;
        %[prob_joint1, TE2to1(d_idx),tr1]=etc_mi_nd(ROI_a,n_bin,'edge_roi',edge_roi);
        %[prob_joint2, TE1to2(d_idx),tr2]=etc_mi_nd(ROI_b,n_bin,'edge_roi',edge_roi);
        [prob_joint1, TE2to1(d_idx),tr1]=etc_mi_nd(ROI_a,n_bin,'edge_roi',[edge1 edge1 edge2]);
        [prob_joint2, TE1to2(d_idx),tr2]=etc_mi_nd(ROI_b,n_bin,'edge_roi',[edge2 edge2 edge1]);
    end;
    
    
    for repeat_idx=1:n_repeat
        if(mod(repeat_idx,100)==0&flag_display)
            if(flag_display) fprintf('latency=[%d]\t%2.2f%%...\r',n_delay(d_idx),repeat_idx./n_repeat.*100); end;
            %fprintf('<<%2.2f%%>>...\r',repeat_idx./n_repeat.*100);
        end;
        %perm_idx=randperm(size(ROI,1));
        %L=ROI(perm_idx,1);
        %R=ROI(perm_idx,2);
        
        R=surr_ft_algotithm2(ROI(:,2));
        L=surr_ft_algotithm2(ROI(:,1));
        if(isempty(source_history))
            %AAFT
            %[prob_joint_perm1, TE2to1_perm(d_idx,repeat_idx)]=etc_mi_nd([ROI(min_si1_idx+1:end,1) ROI(1:end-min_si1_idx,1) R(1:end-min_si1_idx)],n_bin,'edge_roi',edge_roi);
            %[prob_joint_perm2, TE1to2_perm(d_idx,repeat_idx)]=etc_mi_nd([ROI(min_si2_idx+1:end,2) ROI(1:end-min_si2_idx,2) L(1:end-min_si2_idx)],n_bin,'edge_roi',edge_roi);
            [prob_joint_perm1, TE2to1_perm(d_idx,repeat_idx)]=etc_mi_nd([ROI(min_si1_idx+1:end,1) ROI(1:end-min_si1_idx,1) R(1:end-min_si1_idx)],n_bin,'edge_roi',[edge1 edge1 edge2]);
            [prob_joint_perm2, TE1to2_perm(d_idx,repeat_idx)]=etc_mi_nd([ROI(min_si2_idx+1:end,2) ROI(1:end-min_si2_idx,2) L(1:end-min_si2_idx)],n_bin,'edge_roi',[edge2 edge2 edge1]);
        else
            ROI_a=[];
            ROI_b=[];
            for t=0:source_history
                ROI_a=cat(1,ROI_a,[ROI(min_si1_idx+1+t:end,1) ROI(t+1:end-min_si1_idx,1) R(1:end-min_si1_idx-t)]);
                ROI_b=cat(1,ROI_b,[ROI(min_si2_idx+1+t:end,2) ROI(t+1:end-min_si2_idx,2) L(1:end-min_si2_idx-t)]);
            end;
            %[prob_joint_perm1, TE2to1_perm(d_idx,repeat_idx)]=etc_mi_nd(ROI_a,n_bin,'edge_roi',edge_roi);
            %[prob_joint_perm2, TE1to2_perm(d_idx,repeat_idx)]=etc_mi_nd(ROI_b,n_bin,'edge_roi',edge_roi);
            [prob_joint_perm1, TE2to1_perm(d_idx,repeat_idx)]=etc_mi_nd(ROI_a,n_bin,'edge_roi',[edge1 edge1 edge2]);
            [prob_joint_perm2, TE1to2_perm(d_idx,repeat_idx)]=etc_mi_nd(ROI_b,n_bin,'edge_roi',[edge2 edge2 edge1]);
        end;
    end;
    if(flag_display)
        fprintf('\n');
    end;
    
    if(n_repeat>1) 
        pval2to1(d_idx)=length(find(TE2to1_perm(d_idx,:)>=TE2to1(d_idx)))./length(TE2to1_perm(d_idx,:));
        pval1to2(d_idx)=length(find(TE1to2_perm(d_idx,:)>=TE1to2(d_idx)))./length(TE1to2_perm(d_idx,:));
    else
        pval2to1(d_idx)=nan;
        pval1to2(d_idx)=nan;
    end;
    %pval2to1=length(find(TE2to1_perm>TE2to1))./length(TE2to1_perm);
    %pval1to2=length(find(TE1to2_perm>TE1to2))./length(TE1to2_perm);
end;


if(flag_display)
    subplot(121);
    %plot(n_delay, [TE2to1; TE1to2]'); legend({'TE2->1','TE1->2'}); xlabel('delay (sample)'); ylabel('TE');
    if(n_repeat>1)
        plot(TE2to1_perm(d_idx,:),'ro'); hold on;
        plot([0 n_repeat],[TE2to1(d_idx) TE2to1(d_idx)],'r-');
        xlabel('permutation'); ylabel('TE');title('2->1');

        subplot(122);
        %plot(n_delay, [pval2to1;pval1to2]'); legend({'TE2->1','TE1->2'}); xlabel('delay (sample)'); ylabel('p-value');
        plot(TE1to2_perm(d_idx,:),'bo'); hold on;
        plot([0 n_repeat],[TE1to2(d_idx) TE1to2(d_idx)],'b-');
        xlabel('permutation'); ylabel('TE');title('1->2');
    end;

end;

return;
