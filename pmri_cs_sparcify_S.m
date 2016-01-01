function y=pmri_cs_forward_S(x)

dwtmode('per');

y=wavedec(x,4,'db4');

return;