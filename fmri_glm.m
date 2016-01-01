function [dat]=glm()
%general linear model for attention fMRI study
%

%--------------------------------------------------------------
%model description
%--------------------------------------------------------------
%y=b0*X0+b1*x1+b2*x2+b3*x3+b4*x1*x3+b5*x1*x2
%X1: condition
%X1=0-->off
%X1=1-->on
%
%X2,X3: attention encoding
%X2=0, X3=0--> LEFT
%X2=1, X3=0--> attending left
%X2=1, X3=1--> attending right
%
%passive-off: X0=1, X1=0, X2=0, X3=0
%passive-on : X0=1, X1=1, X2=0, X3=0
%left-off   : X0=1, X1=0, X2=1, X3=0
%left-on    : X0=1, X1=1, X2=1, X3=0
%right-off  : X0=1, X1=0, X2=1, X3=1
%right-on   : X0=1, X1=1, X2=1, X3=1


%passive-off: X0=1, X1=0, X2=0, X3=0, X4=0, X5=0
%passive-on : X0=1, X1=1, X2=0, X3=0, X4=0, X5=0
%left-off   : X0=1, X1=0, X2=1, X3=0, X4=0, X5=0
%left-on    : X0=1, X1=1, X2=1, X3=0, X4=1, X5=0
%right-off  : X0=1, X1=0, X2=1, X3=1, X4=0, X5=0
%right-on   : X0=1, X1=1, X2=1, X3=1, X4=1, X5=1

% passive-(on<->off)  	x1=0
% left-(on<->off)     	x1+x4=0
% right-(on<->off)    	x1+x4+x5=0
% on-(passive<->left)  	x2+x4=0 
% on-(passive<->right) 	x2+x3+x4+x5=0
% on-(left<->right)    	x3+x5=0

%--------------------------------------------------------------
%environment parameters
%--------------------------------------------------------------
PASSIVEFILE={
'c:\user\fhlin\attention\941003dk\passive\sh_passive009.bshort',
};
LEFTFILE={
'c:\user\fhlin\attention\941003dk\left\sh_left009.bshort',
};
RIGHTFILE={
'c:\user\fhlin\attention\941003dk\right\sh_right009.bshort',
};
PASSIVEPARAFILE='c:\user\fhlin\test\para.para';
LEFTPARAFILE   ='c:\user\fhlin\test\para.para';
RIGHTPARAFILE  ='c:\user\fhlin\test\para.para';

%--------------------------------------------------------------
%experiment parameters
%--------------------------------------------------------------
TIMEPOINTS=64;   	%time points of each run
SLICES=1;		%anatomical slices
DIM_Y=64;
DIM_X=64;
GLMPARAMETERS=6; 	% # of GLM parameters
PASSIVE_OFF=[1,0,0,0];
PASSIVE_ON =[1,1,0,0];
LEFT_OFF   =[1,0,1,0];
LEFT_ON    =[1,1,1,0];
RIGHT_OFF  =[1,0,1,1];
RIGHT_ON   =[1,1,1,1];

PASSIVE_ONOFF	=[0,1,0,0,0,0];
LEFT_ONOFF	=[0,1,0,0,1,0];
RIGHT_ONOFF	=[0,1,0,0,1,1];
ON_PASSIVELEFT	=[0,0,1,0,1,0];
ON_PASSIVERIGHT	=[0,0,1,0,1,1];
ON_LEFTRIGHT	=[0,0,0,1,0,1];

%--------------------------------------------------------------



%--------------------------------------------------------------
%initialization
%--------------------------------------------------------------
dirnow=pwd;
close all;

PASSIVEOFF=[PASSIVE_OFF,PASSIVE_OFF(2)*PASSIVE_OFF(3),PASSIVE_OFF(2)*PASSIVE_OFF(4)];
PASSIVEON =[PASSIVE_ON,PASSIVE_ON(2)*PASSIVE_ON(3),PASSIVE_ON(2)*PASSIVE_ON(4)];
LEFTOFF=[LEFT_OFF,LEFT_OFF(2)*LEFT_OFF(3),LEFT_OFF(2)*LEFT_OFF(4)];
LEFTON =[LEFT_ON,LEFT_ON(2)*LEFT_ON(3),LEFT_ON(2)*LEFT_ON(4)];
RIGHTOFF=[RIGHT_OFF,RIGHT_OFF(2)*RIGHT_OFF(3),RIGHT_OFF(2)*RIGHT_OFF(4)];
RIGHTON =[RIGHT_ON,RIGHT_ON(2)*RIGHT_ON(3),RIGHT_ON(2)*RIGHT_ON(4)];

%----------------------------------------------------------------------
%generate design matrix
%----------------------------------------------------------------------


str=sprintf('generating design matrix\n');
disp(str);
	
%passive part (design matrix)
passivepara=fmri_ldpara(PASSIVEPARAFILE);
for j=1: TIMEPOINTS
	if passivepara(j)==1
		x_passive(j,:)=PASSIVEON;
	end;
	if passivepara(j)==-1
		x_passive(j,:)=PASSIVEOFF;
	end;	
end;
	
%left-attended part (design matrix)
leftpara=fmri_ldpara(LEFTPARAFILE);
for j=1: TIMEPOINTS
	if leftpara(j)==1
		x_left(j,:)=LEFTON;
	end;
	if leftpara(j)==-1
		x_left(j,:)=LEFTOFF;
	end;
end;
	
%right-attended part (design matrix)
rightpara=fmri_ldpara(RIGHTPARAFILE);
for j=1: TIMEPOINTS
	if rightpara(j)==1
		x_right(j,:)=RIGHTON;
	end;
	if rightpara(j)==-1
		x_right(j,:)=RIGHTOFF;
	end;
end;
design=[x_passive;x_left;x_right];
imagesc(design);


colormap(gray(256));
imagesc(design);
title('design matrix');
pause

%----------------------------------------------------------------------
%read raw data
%----------------------------------------------------------------------
str=sprintf('reading raw data...');
disp(str);

%passive part
fp=char(PASSIVEFILE);
fl=char(LEFTFILE);
fr=char(RIGHTFILE);


dat_passive=zeros(SLICES,DIM_Y,DIM_X,TIMEPOINTS);
dat_left=zeros(SLICES,DIM_Y,DIM_X,TIMEPOINTS);
dat_right=zeros(SLICES,DIM_Y,DIM_X,TIMEPOINTS);	
datamatin=zeros(3*TIMEPOINTS,SLICES*DIM_X*DIM_Y);
[fs,dummy]=size(fr);

for i=1:SLICES
	%generate the file name
	str=sprintf('reading slice [%d]...',i);
	disp(str);
	
	%dat_passive(i,:,:,:)=fmri_ldbfile(fp(i,:));
	str=sprintf('reading [%s]...',fp(fs-i+1,:));
	disp(str);
	datamatin(1:TIMEPOINTS,(i-1)*DIM_X*DIM_Y+1:i*DIM_X*DIM_Y)=reshape(fmri_ldbfile(fp(fs-i+1,:)),[DIM_X*DIM_Y,TIMEPOINTS])';
	
	%dat_left(i,:,:,:)=fmri_ldbfile(fl(i,:));
	str=sprintf('reading [%s]...',fl(fs-i+1,:));
	disp(str);
	datamatin(TIMEPOINTS+1:2*TIMEPOINTS,(i-1)*DIM_X*DIM_Y+1:i*DIM_X*DIM_Y)=reshape(fmri_ldbfile(fl(fs-i+1,:)),[DIM_X*DIM_Y,TIMEPOINTS])';
	
	%dat_right(i,:,:,:)=fmri_ldbfile(fr(i,:));
	str=sprintf('reading [%s]...',fr(fs-i+1,:));
	disp(str);
	datamatin(2*TIMEPOINTS+1:3*TIMEPOINTS,(i-1)*DIM_X*DIM_Y+1:i*DIM_X*DIM_Y)=reshape(fmri_ldbfile(fr(fs-i+1,:)),[DIM_X*DIM_Y,TIMEPOINTS])';
end;


str=sprintf('generating datamat...');
disp(str);
threshold=max(max(datamatin))/7;
[datamat coords]=makedata_raw(reshape(datamatin,[3*TIMEPOINTS DIM_X*DIM_Y*SLICES]),threshold); %making the datamat
show_datamat(coords,DIM_Y,DIM_X,SLICES); %show the datamat


pause;
%----------------------------------------------------------------------
%GLM modeling
%----------------------------------------------------------------------


sz=size(datamat);
b=zeros(GLMPARAMETERS,sz(2));


str=sprintf('GLM modeling...');
disp(str);

x=design;
prepair1=inv(x'*x)*x';
size(prepair1);
for col=1:size(datamat,2);
	y=reshape(datamat(:,col),3*TIMEPOINTS,1);
	%least square estimation
	b(:,col)=prepair1*y;
end;



str=sprintf('variance calculation...');
disp(str);

% calculate the variance
diff=zeros(3*TIMEPOINTS,sz(2));
b_var=zeros(sz(2),GLMPARAMETERS,GLMPARAMETERS);
variance=zeros(sz(2));
prepair2=inv(x'*x);

for col=1:sz(2)
	y=reshape(datamat(:,col),3*TIMEPOINTS,1);
	diff(:,col)=y-design*(b(:,col));
	variance(col)=var(diff(:,col));		%estimated variance
	b_var(col,:,:)=prepair2*variance(col); 	%variance of the b vector, a matrix
end;



%----------------------------------------------------------------------
%significance evaluation
%----------------------------------------------------------------------
contrast=zeros(1,GLMPARAMETERS);
contrast(1,:)=PASSIVE_ONOFF;
%contrast(2,:)=LEFT_ONOFF;
%contrast(3,:)=RIGHT_ONOFF;
%contrast(4,:)=ON_PASSIVELEFT;
%contrast(5,:)=ON_PASSIVERIGHT;
%contrast(6,:)=ON_LEFTRIGHT;

str=sprintf('contrast probability calculation...');
disp(str);

%contrasts=size(contrast);
t_value=zeros(size(contrast,1),sz(2));
p_value=zeros(size(contrast,1),sz(2));
for c=1:size(contrast,1)
	c_index=find(contrast(c,:));
	pair=fmri_c2(c_index);
	

	for col=1:sz(2)
		%get the T statistics
		num=contrast(c,:)*b(:,col);
		pairs=size(pair,1);
		den1=0;
		for i=1:pairs
			den1=den1+b_var(col,pair(i,1),pair(i,2));
		end;
		den1=den1*2;
		den2=0;
		for i=1:size(c_index,2)
			den2=den2+b_var(col,c_index(i),c_index(i));
		end;
		den=sqrt(den1+den2);
		t_value(c,col)=num/den;
		p_value(c,col)=2*tcdf(abs(t_value(c,col)),3*TIMEPOINTS-GLMPARAMETERS+1)-1;
	end;
end;

tfn='';
pfn='';
for c=1:SLICES
	str=sprintf('glm_slice%s_T.bfloat',num2str(c,'%.2d'));
	tfn=strvcat(tfn,str);
	str=sprintf('glm_slice%s_P.bfloat',num2str(c,'%.2d'));
	pfn=strvcat(pfn,str);
end;
tfn=cellstr(tfn);
pfn=cellstr(pfn);

cd(dirnow);
fmri_datamat2bfile(t_value,coords,DIM_X,DIM_Y,SLICES,size(contrast,1),tfn);
fmri_datamat2bfile(p_value,coords,DIM_X,DIM_Y,SLICES,size(contrast,1),pfn);

str=sprintf('save results...');
disp(str);
cd(dirnow);
save glm b b_var diff  p_value t_value datamatin datamat coords DIM_X DIM_Y SLICES;


pdata=fmri_ldbfile(char(pfn));
figure;
for i=1:size(contrast,1)
	maxx=max(p_value(i,:))
	minn=min(p_value(i,:))
	show_active(p_value(i,:),coords,1-p_value(i,:),0.05,DIM_Y,DIM_X,SLICES,3);
	colorbar;
end;

str=sprintf('done');
disp(str);
 
 
 