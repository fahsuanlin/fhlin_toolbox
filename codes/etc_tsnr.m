function [tsnr]=etc_tsnr(varargin)

file_nii={};

stc=[];

img=[];

TR=2.0; %second

exclude_time=[];
%exclude_time=[];

confound_polynomial_order=2;

%output_stem='tsnr_epi_60deg';

nx=[];
ny=[];
nz=[];

flag_display=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case 'stc'
            stc=option_value;
        case 'img'
            img=option_value;
        case 'file_nii'
            file_nii=option_value;
        case 'tr'
            TR=option_value;
        case 'exclude_time'
            exclude_time=option_value;
        case 'confound_polynomial_order'
            confound_polynomial_order=2;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;
%------------------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% construct contrast matrix using legendres to model the effects
%
if(isempty(stc))
    if(isempty(img))
        if(flag_display)
            fprintf('loading data...\n');
        end;
        stc=[];
        exclude_time_all=[];
        for f_idx=1:length(file_nii)
            d=load_untouch_nii(file_nii{f_idx});
            sz=size(d.img);

            stc=reshape(double(d.img),[prod(sz(1:end-1)),sz(end)]);
            timepoints(f_idx)=size(stc,2);
            %stc(:,exclude_time)=[];

            ss=sz(1:end-1);
            ny=ss(1);
            nx=ss(2);
            nz=ss(3);

            if(~isempty(exclude_time))
                exclude_time_all=cat(1,exclude_time_all,exclude_time(:)+(timepoints(f_idx)).*(f_idx-1));
            end;


        end;
    else
        f_idx=1;

        sz=size(img);
        stc=reshape(img,[prod(sz(1:end-1)),sz(end)]);
        timepoints(f_idx)=size(stc,2);
        %stc(:,exclude_time)=[];

        ss=sz(1:end-1);
        ny=ss(1);
        nx=ss(2);
        nz=ss(3);


        exclude_time_all=[];
        if(~isempty(exclude_time))
            exclude_time_all=cat(1,exclude_time_all,exclude_time(:)+(timepoints(f_idx)).*(f_idx-1));
        end;

    end;
else
    f_idx=1;
    timepoints(1)=size(stc,2);
    exclude_time_all=[];
    if(~isempty(exclude_time))
        exclude_time_all=exclude_time(:);
    end;
end;

if(isempty(stc))
    fprintf('no data!\n');
    return;
end;

stc(:,exclude_time_all)=[];
stc=stc';

idx=find(isnan(stc(:)));
stc(idx)=randn(size(idx)).*eps;

idx=find(abs(stc(:))<eps);
stc(idx)=randn(size(idx)).*eps;

cumsum_timepoints=cumsum(timepoints);
cumsum_timepoints=cat(1,0,cumsum_timepoints(:));

if(flag_display)
    fprintf('adding confounds into a contrast matrix...\n');
end;
n_confound=1;
confound=[];
beta_dc=[];
confound_period=[60, 132, 180]; %second
confound_period=[];


contrast_count=0;

for run_idx=1:f_idx
    for j=0:confound_polynomial_order
        contrast_count=contrast_count+1;
        
        if(j==0) beta_dc=cat(1,beta_dc,contrast_count); end;
        
        confound(1+cumsum_timepoints(run_idx):cumsum_timepoints(run_idx+1),n_confound)=([0:1/((timepoints(run_idx))-1):1].^(j))';
        n_confound=n_confound+1;
    end;
    timeVec=[0:TR:TR*(timepoints-1)];
    for j=1:length(confound_period)
        contrast_count=contrast_count+1;
        contrast_count=contrast_count+1;
        
        confound(1+cumsum_timepoints(run_idx):cumsum_timepoints(run_idx+1),n_confound)=cos(2.*pi./confound_period(j).*timeVec)';
        n_confound=n_confound+1;
        confound(1+cumsum_timepoints(run_idx):cumsum_timepoints(run_idx+1),n_confound)=sin(2.*pi./confound_period(j).*timeVec)';
        n_confound=n_confound+1;
    end;
end;

%remove time points
confound(exclude_time_all,:)=[];

% %global mean
% confound(:,end+1)=mean(stc,2);
% n_confound=n_confound+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%remove confound
beta=inv(confound'*confound)*confound'*stc;
res=stc-confound*inv(confound'*confound)*confound'*stc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

avg_idx=[1:confound_polynomial_order+1:size(confound,2)];
avg=mean(beta(avg_idx,:),1);

tsnr=avg./std(res,0,1);
rr=std(res,0,1);


%mask=zeros(size(avg));
%mask(find(avg>mean(avg)/7))=1;
%idx=find(mask);
%idx=setdiff(idx,find(rr(:)<1e-10));

%fprintf('tsnr=%2.0f +/- %2.0f\n',mean(tsnr(idx)),std(tsnr(idx)));

if(~isempty(nx))
    tsnr=reshape(tsnr,[ny nx nz]);
end;

%fprintf('\tarchiving results...\n');
%save(sprintf('%s.mat',output_stem),'tsnr');
return;
