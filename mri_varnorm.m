function y=mri_varnorm(d)

%zero-mean
m=mean2(d);
d=d-m;

%unit-variance
s=std2(d);
d=d./s;

%scaling back
y=d+m;

return;
