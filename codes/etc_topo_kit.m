function h=etc_topo_kit(data,varargin)
%
% etc_topo_kit    render MEG topology for KIT MEG
%
% h=etc_topo_kit(data,[option1, option_value1,...]);
%
% data: 2D data matrix (sensor x time points);
% options
%   'hdr': header from MEG measurement
%   'timeVec': a vector of time stamps
%   'label': a string cell of channel labels
%
% fhlin@apr 11 2019
%

subject='fsaverage';
timeVec=[];
hdr=[];
label={};

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch(lower(option))
        case 'hdr'
            hdr=option_value;
        case 'timevec'
            timeVec=option_value;
        case 'label'
            label=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;

if(isempty(hdr)) %default channel positions for KIT 157 gradiometer system
    fprintf('no header provided. using a default tempalte (for KIT 157 gradiometers) for sensor arrangement...\n');
    
    hdr.grad.chanpos=[12.1393    2.4261    3.9180
        11.2534    4.5875    3.9017
        9.9771    6.6317    3.8770
        11.2261    2.3521    5.9462
        10.3459    4.4500    5.9659
        10.0990    2.0751    8.0106
        
        7.8708    6.0270    7.8741
        6.0564    7.4683    7.7124
        2.7861    7.2657    9.1153
        7.0423    4.5065    9.4157
        5.0735    6.2450    9.3780
        6.8184    0.8483   10.7795
        4.1037    4.8895   10.5816
        1.9812    5.7534   10.3112
        4.4527    0.8025   11.4866
        3.1878    2.9286   11.5356
        -1.2839    8.8465    7.5458
        -3.7022    9.0206    8.0424
        -5.7465    7.4850    7.8093
        -8.9755    4.1740    7.8923
        -6.5267    1.6986   10.5966
        -0.2306    7.5062    9.1543
        -3.1172    7.5223    9.6605
        -7.2721    3.9810    9.5921
        -4.0695    1.8816   11.5635
        -0.8755    5.5283   10.5902
        -8.5231   -0.3781    9.3098
        -5.1058    3.9557   10.5721
        -1.9597    3.5724   11.4079
        -4.7611   -0.4477   11.6069
        -1.1036    1.5475   12.1762
        1.4189    1.4657   12.0722
        7.9820    9.5572   -5.6369
        5.9377   10.5625   -5.3872
        6.0323   10.4674   -2.7766
        3.8898   10.9723   -0.1616
        8.2428    9.3761   -2.9203
        3.6522   11.1706   -2.8511
        8.3850    9.0467   -0.3808
        6.2143   10.2157   -0.0699
        1.3748   11.2488   -0.2544
        8.6367    8.8001    2.1618
        6.3318    9.9832    2.1694
        4.0813   10.8225    2.1358
        5.9754    9.5706    4.0437
        1.2428   10.6221    4.0778
        7.2177    8.2673    5.9302
        2.5848    9.7921    5.9555
        -1.6717   11.1652   -5.4353
        -3.9426   10.9544   -5.5746
        -6.0627   10.1173   -5.5158
        -8.0694    8.9433   -5.8215
        -1.6656   11.3093   -2.9438
        -3.9435   10.9290   -2.8274
        -8.0688    8.9435   -3.2531
        -1.2868   11.6949   -0.2474
        -5.9001   10.2159   -0.3169
        -1.1630   11.0184    2.1476
        -3.4179   10.8247    2.1620
        -5.7622   10.0997    2.1690
        -3.8886   10.1803    4.0053
        -8.1386    8.0006    4.0397
        -0.0920    9.9201    5.9115
        -7.1158    7.8590    6.0556
        10.2089   -6.8840    3.5989
        11.4312   -4.7538    3.8752
        12.1863   -2.5343    3.8075
        12.4328   -0.1336    3.8326
        9.5134   -4.8741    7.9190
        11.1418   -2.6878    6.0188
        3.9440   -9.1198    7.1523
        7.8864   -6.7196    7.3982
        9.8947   -2.6676    7.8188
        5.6161   -6.9022    8.8802
        8.3898   -2.7832    9.2819
        1.9857   -6.6439    9.9855
        4.1507   -5.7195   10.2630
        6.7142   -1.8385   10.7152
        2.9871   -3.7886   11.3243
        4.4923   -1.6293   11.3740
        -9.9539   -0.1720    7.5373
        -10.2516   -2.6822    7.9459
        -9.0370   -4.7775    7.5822
        -5.8373   -8.1423    7.3630
        -1.2623   -9.4602    7.1436
        -7.2555   -5.2284    9.4773
        -2.7939   -7.9338    8.8358
        0.2191   -8.2857    8.6056
        -6.4027   -2.8417   10.4668
        -5.1176   -4.7095   10.2762
        -0.6676   -6.7673    9.9610
        -3.9756   -2.8719   11.2346
        -2.1525   -4.4897   11.2429
        -2.3494   -0.4660   12.0286
        -1.1498   -2.3026   11.9140
        1.3482   -2.3751   11.9177
        1.5877  -11.5633   -5.9580
        3.9824  -11.3384   -5.9273
        6.2921  -10.5911   -5.8809
        8.1943   -9.5862   -5.7501
        4.1029  -11.3000   -3.2854
        8.4371   -9.4837   -2.9693
        1.7570  -11.5485   -0.5185
        6.5683  -10.5026   -0.5311
        8.5650   -9.2135   -0.6972
        1.8510  -11.4629    1.6874
        4.2193  -11.1355    1.6463
        8.6828   -9.1069    1.4747
        5.0351   -9.8459    5.4710
        6.2611  -10.0593    3.6401
        2.8007  -10.3711    5.4580
        7.5223   -8.9621    5.5404
        -7.8233   -9.4670   -5.9786
        -5.8135  -10.6432   -5.8083
        -3.5822  -11.2899   -5.9015
        -1.2019  -11.5147   -5.8675
        -7.8131   -9.4954   -3.0620
        -3.4485  -11.3503   -3.2774
        -1.0975  -11.5509   -3.2812
        -7.7431   -9.5543   -0.5352
        -5.6863  -10.6315   -0.4360
        -5.5035  -10.6578    1.9616
        -3.3064  -11.2707    1.8023
        -0.8109  -11.5324    1.7586
        -8.2022   -8.9706    3.7635
        -3.6946  -10.8043    3.7461
        -4.9470   -9.7659    5.6099
        0.2031  -10.5439    5.4577
        -9.8497    7.3320   -5.9566
        -12.2251    3.1530   -6.1089
        -12.6901    0.8676   -6.1162
        -11.3481    5.3061   -3.3344
        -12.7338    0.7685   -3.3310
        -9.8664    7.3445   -0.8677
        -11.1970    5.4930   -0.6497
        -12.1969    3.1981   -0.6731
        -9.7554    7.2567    1.8507
        -12.1399    3.1963    1.8749
        -12.6278    0.8483    1.7493
        -11.2369    4.3077    4.0153
        -12.2534   -0.2911    3.7705
        -9.9378    6.3727    4.0667
        -11.1283    2.1523    6.0877
        -11.4400   -0.3075    5.9157
        -12.0662   -3.8891   -6.2374
        -9.6938   -7.9453   -6.1418
        -12.6501   -1.6433   -3.4009
        -11.1469   -6.0353   -3.6396
        -12.1303   -3.9195   -0.6587
        -11.0875   -6.0544   -0.7804
        -9.4989   -8.0379   -1.1069
        -12.5676   -1.5234    1.8070
        -12.0544   -3.8721    1.7089
        -9.5809   -7.9244    1.5495
        -11.2387   -5.0134    3.5727
        -11.1656   -2.7498    5.8058
        -8.9019   -7.0241    5.7156];
    
end;

if(isempty(timeVec))
    fprintf('no timeVec provided. creating a timeVec in sample...\n');
    timeVec=[1:size(data,2)]; %sample;
end;

if(isempty(label))
    fprintf('no channel label provided. creating channel labels...\n');
    for ch_idx=1:size(data,1)
        label{ch_idx}=sprintf('%03d',ch_idx);
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


meg_x=hdr.grad.chanpos(:,1);
meg_y=hdr.grad.chanpos(:,2);
meg_z=hdr.grad.chanpos(:,3);

mmax_z=max(meg_z);

avg_2d=[mean(meg_x) mean(meg_y)];
d_2d=[meg_x meg_y]-repmat(avg_2d,[length(meg_x) 1]);
d_2d=d_2d./repmat(sqrt(sum(abs(d_2d).^2,2)),[1 2]);

meg_x_2d=meg_x+abs(meg_z-mmax_z).*d_2d(:,1);
meg_y_2d=meg_y+abs(meg_z-mmax_z).*d_2d(:,2);
%figure; plot(meg_y_2d,meg_x_2d,'r.'); axis equal vis3d;

meg_x_2d_s=fmri_scale(meg_x_2d,0.9,0.1);
meg_y_2d_s=fmri_scale(meg_y_2d,0.9,0.1);



%plot via separate axes
fig_h=figure;
set(fig_h,'color','w');
%set(h,'ButtonDownFcn',{@etc_plotEF_kit_kb,2},'HitTest','off')
for h_idx=1:length(meg_x_2d)
    h_ax(h_idx) = axes('Position', [meg_y_2d_s(h_idx), meg_x_2d_s(h_idx), .04, .04]);
    
    set(h_ax(h_idx),'ButtonDownFcn',{@etc_plotEF_kit_kb,fig_h,h_idx,timeVec,data(h_idx,:),label{h_idx}},'HitTest','on')
    
    hold on;
    h=line([0 0],[-100 100]); set(h,'color',[1 1 1].*0.3); set(h,'HitTest','off');
    h=line([-200 1000],[0 0]); set(h,'color',[1 1 1].*0.3); set(h,'HitTest','off');
    
    h=plot(h_ax(h_idx),timeVec,data(h_idx,:)); set(h,'HitTest','off');
    
    %set(h_ax(h_idx),'color','none','xlim',[-200 1000],'ylim',[-200 200]);
    set(h_ax(h_idx),'color','none');
    
    h=title(label{h_idx}); set(h,'fontname','helvetica','fontsize',8); set(h,'HitTest','off');
    set(h_ax(h_idx),'xcolor','none','ycolor','none');
    
end;
linkaxes(h_ax,'x');


function etc_plotEF_kit_kb(source, eventdata, h,h_idx,timeVec,d,l)

hh=figure(h.Number+1);
hh_pos=get(hh,'pos');
h_pos=get(h,'pos');
set(hh,'pos',[h_pos(1)-hh_pos(3) h_pos(2) hh_pos(3) hh_pos(4)]);

plot(timeVec,d);

h=title(l); set(h,'fontname','helvetica','fontsize',16);

set(gca,'fontname','helvetica','fontsize',16);

return;


