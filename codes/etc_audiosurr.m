function [syn]=etc_audiosurr(audioIn,fs,f0,f0_idx)

syn=[];
audioIn=audioIn(:);
f0_idx=f0_idx(:);


inte=[1; f0_idx(1:end-1)+round(diff(f0_idx)/2); length(audioIn)];
phi=0;
for idx=1:length(inte)-1
    s0=audioIn(inte(idx):inte(idx+1));
    s1=sin(2.*pi.*[0:(inte(idx+1)-inte(idx)-1)]./fs.*f0(idx)+phi);
    amp=sqrt(sum(s0.^2)./sum(s1.^2));
    syn(inte(idx):inte(idx+1)-1)=amp.*sin(2.*pi.*[0:(inte(idx+1)-inte(idx)-1)]./fs.*f0(idx)+phi);
    phi=2.*pi.*((inte(idx+1)-inte(idx)-1))./fs.*f0(idx)+phi; %phase continuity across segments
end;

return;