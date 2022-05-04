% Generate points that fill space evenly but randomly, using 2d poisson disc
% Rhodri Cusack, Brain and Mind Institute, Western University, Canada, July 2013
% www.cusacklab.org  cusacklabcomputing.blogspot.ca rhodri@cusacklab.org
% 
% Algorithm with thanks from
% http://devmag.org.za/2009/05/03/poisson-disk-sampling/
%
% sz=[width, height] of space to be filled
% min_dist=min separation of points
% newpointscount= higher number gives higher quality (fewer gaps)
%
% Example useage:
% spoints=generate_poisson_2d([100 100 ],10,20);

function [samplepoints]=etc_poissondisc_nd(sz,min_dist,newpointscount)

cellsize=min_dist/sqrt(length(sz));
str='Grid=cell(';
for idx=1:length(sz)
    str=sprintf('%sceil(sz(%d)/cellsize)',str,idx);
    if(idx==length(sz))
        str=sprintf('%s);',str);
    else
        str=sprintf('%s,',str);
    end;
end;
eval(str);
%grid=cell(ceil(sz(1)/cellsize),ceil(sz(2)/cellsize));
proclist=[];
samplepoints=[];

% Random start
%firstpoint=ceil(sz.*rand(1,ndims(sz)));
firstpoint=ceil(sz.*rand(size(sz)));
firstpoint=sz./2;

% This will be a queue with points pulled randomly from it
proclist=[proclist; firstpoint];

% Output...
samplepoints=[samplepoints; firstpoint];

% Grid - see algorithm from devmag above
gridpoint=imageToGrid(firstpoint,cellsize);

Gridsiz=size(Grid);
Gridk = [1 cumprod(Gridsiz(1:end-1))];
ind = 1;
for i = 1:length(Gridsiz),
    v = gridpoint(i);
    ind = ind + (v-1)*Gridk(i);
end;
Grid{ind}=firstpoint;

%grid{gridpoint(1),gridpoint(2)}=firstpoint;

while ~isempty(proclist)
    randrow=ceil(rand(1)*size(proclist,1));
    point=proclist(randrow,:);
    proclist(randrow,:)=[];

    for i=1:newpointscount
        newpoint=generateRandomPointsAround(point, min_dist);
        if inRectangle(newpoint,sz) && ~inNeighbourhood(Grid, newpoint, min_dist,cellsize)
            proclist=[proclist; newpoint];
            samplepoints=[samplepoints; newpoint];
            gridpoint=imageToGrid(newpoint,cellsize);

            ind = 1;
            for i = 1:length(Gridsiz),
                v = gridpoint(i);
                ind = ind + (v-1)*Gridk(i);
            end;
            Grid{ind}=newpoint;
        end;
    end;
end;


figure(10);
if(size(samplepoints,2)==2) scatter(samplepoints(:,1),samplepoints(:,2)); end;


end

function [gpoint]=imageToGrid(point,cellsize)
gpoint=ceil(point/cellsize);
end

function [newpoint]=generateRandomPointsAround(point,min_dist)
%[x y z]=sph2cart(2*pi*rand(1),0,min_dist*(rand(1)+1));
n_dim=size(point,2);
R=min_dist*(rand+1); %the distance from given 'point'
p=rand(1,n_dim);
p=p./sum(p);
dR=sqrt(R.^2.*p);
sign_dR=2.*(rand(size(p))>0.5)-1;
dR=dR.*sign_dR;

%newpoint=point+[x y];
newpoint=point+dR;
end

% Is there another point already nearby. 
function [isin]=inNeighbourhood(Grid,point,min_dist,cellsize)
Gridsz=size(Grid);
n_dim=ndims(Grid);
% Where does this point belong in the grid
gridpoint=imageToGrid(point,cellsize);
% only check neighbours -2<delta<2 in each dim arount "gridpoint"
cmd=sprintf('[');
for dim_idx=1:n_dim
    cmd=sprintf('%so%d',cmd,dim_idx);
    if(dim_idx~=n_dim) cmd=sprintf('%s,',cmd); else cmd=sprintf('%s]=ndgrid(',cmd); end;
end;
for dim_idx=1:n_dim
    cmd=sprintf('%s-2:2',cmd);
    if(dim_idx~=n_dim) cmd=sprintf('%s,',cmd); else cmd=sprintf('%s);',cmd); end;
end;
eval(cmd);
%[ox oy]=meshgrid(-2:2,-2:2); 

c=repmat(gridpoint,[size(o1(:),1) 1]);
cmd=sprintf('c=c+[');
for dim_idx=1:n_dim
    cmd=sprintf('%so%d(:)',cmd,dim_idx);
    if(dim_idx~=n_dim) cmd=sprintf('%s,',cmd); else cmd=sprintf('%s];',cmd); end;
end;
eval(cmd);
%c=repmat(gridpoint,[size(ox(:),1) 1])+[ox(:) oy(:)];

% Reject any putative neighbours that are out of bounds?
cmd=sprintf('c(any(c<1,2)|');
for dim_idx=1:n_dim
    cmd=sprintf('%sc(:,%d)>Gridsz(%d)',cmd,dim_idx,dim_idx);
    if(dim_idx~=n_dim) cmd=sprintf('%s|',cmd); else cmd=sprintf('%s,:)=[];',cmd); end;
end;
eval(cmd);
%c(any(c<1,2) | c(:,1)>gridsz(1) | c(:,2)>gridsz(2),:)=[];


% Reject any putative neighbours without coordinates
cmd=sprintf('index=sub2ind(Gridsz,');
for dim_idx=1:n_dim
    cmd=sprintf('%sc(:,%d)',cmd,dim_idx);
    if(dim_idx~=n_dim) cmd=sprintf('%s,',cmd); else cmd=sprintf('%s);',cmd); end;
end;
eval(cmd);
c(isempty(cat(1,Grid{index})),:)=[];    
%c(isempty(cat(1,grid{sub2ind(gridsz,c(:,1),c(:,2))})),:)=[];

% Get points from grid neighbours 
cmd=sprintf('index=sub2ind(Gridsz,');
for dim_idx=1:n_dim
    cmd=sprintf('%sc(:,%d)',cmd,dim_idx);
    if(dim_idx~=n_dim) cmd=sprintf('%s,',cmd); else cmd=sprintf('%s);',cmd); end;
end;
eval(cmd);
neighbour_points=cat(1,Grid{index});
%neighbour_points=cat(1,grid{sub2ind(Gridsz,c(:,1),c(:,2))});


% Any closeby?
if ~isempty(neighbour_points)
    dists=sqrt(sum((neighbour_points-repmat(point,[size(neighbour_points,1) 1])).^2,2));
    isin=any(dists<min_dist);
else
    isin=false;
end;
end

% Is point in rectangle specified by sz?
function [isin]=inRectangle(point,sz)
isin=all(point>1) && all(point<=sz);
end


