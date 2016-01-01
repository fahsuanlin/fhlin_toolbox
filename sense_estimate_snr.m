function [snr]=sense_estimate_snr(im)

sz=size(im);

box=sz(1)/16;
noise0=im(1:box,1:box);
noise1=im(sz(1)-box+1:sz(1),1:box);
noise2=im(sz(1)-box+1:sz(1),sz(2)-box+1:sz(2));
noise3=im(1:box,sz(2)-box+1:sz(2));

noise=mean([mean2(noise0),mean2(noise1),mean2(noise2),mean2(noise3)]);

snr=nlfilter(im,[box box],'mean2')./noise;

return;







