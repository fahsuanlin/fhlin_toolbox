
level=2;
seg=4;

angle_level=2*pi/(2^level);
angle_div=2*pi/(2^level)/seg;
angle_start=angle_level-round(seg/2)*angle_div;

a=exp(-j*angle_start);
w=exp(-j*angle_div);
m=seg;

y=czt(raw,m,w,a);
