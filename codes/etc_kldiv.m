function [dist, n_P, n_Q, edge_P, edge_Q]=etc_kldiv(P,Q,varargin)
% 
% etc_kldiv calculates the distance between two distributions using
% Kullback-Leiber divergence 
%
% dist=etc_kldiv(P,Q,[option, option_value,...])
% 
% P: 1-D signal 
% Q: 1-D signal
%
% 'n_bin': number of bin for histogram (default: 20)
% 'bin_edge': 1-D vector for edges used in histogram binning
%
% dist: Kullback-Leibler divergence for the relative entropy from Q to P
% n_P: normalized probability distribution of P
% n_Q: normalized probability distribution of Q
% edge_P: edges for the calculation noramlized probabilties using histograms
% edge_Q: edges for the calculation noramlized probabilties using histograms
%
% fhlin@Jun 20, 2021
%

dist=0;

n_bin=[];
bin_edge=[];

n_P=[];
n_Q=[];
edge_P=[];
edge_Q=[];

flag_display=1;

for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch(lower(option))
        case 'n_p'
            n_P=option_value;
        case 'n_q'
            n_Q=option_value;
        case 'edge_p'
            edge_P=option_value;
        case 'edge_q'
            edge_Q=option_value;
        case 'n_bin'
            n_bin=option_value;
        case 'bin_edge'
            bin_edge=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'otherwise'
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


%histogram
if(~isempty(n_P)&&~isempty(n_Q)&&~isempty(edge_P)&&~isempty(edge_Q))
else
    if(isempty(bin_edge))
        if(isempty(n_bin))
            n_bin=20;
        end;
        [n_P,edge_P] = histcounts(P,n_bin, 'Normalization', 'probability');
        [n_Q,edge_Q] = histcounts(Q,n_bin, 'Normalization', 'probability');
    else
        [n_P,edge_P] = histcounts(P,bin_edge, 'Normalization', 'probability');
        [n_Q,edge_Q] = histcounts(Q,bin_edge, 'Normalization', 'probability');
    end;
end;

%find histogram zero entries
idx_exclude_q=[];
if(~isempty(find(n_Q<eps)))
    idx_exclude_q=find(n_Q<eps);
    if(flag_display)
        fprintf('probability of Q is ill-conditioned!\nentries with zero probability!\n');
    end;
end;

idx_exclude_p=[];
if(~isempty(find(n_P<eps)))
    idx_exclude_p=find(n_P<eps);
    if(flag_display)
        fprintf('probability of P is ill-conditioned!\nentries with zero probability!\n');
    end;
end;


if(flag_display)
    if(~isempty(P)&~isempty(Q))
    figure;
    [NP,BINP] = histc(P,edge_P);
    [NQ,BINQ] = histc(Q,edge_Q);
    bar(edge_P,[NP(:),NQ(:)],'histc');
    end;
end;

%KL divergence
idx_exclude=union(idx_exclude_p,idx_exclude_q);
if(~isempty(idx_exclude)) 
    n_P(idx_exclude)=[];
    n_Q(idx_exclude)=[];

    n_P=n_P./sum(n_P);
    n_Q=n_Q./sum(n_Q);
end;
dist=sum(log(n_P./n_Q).*n_P);

return;

