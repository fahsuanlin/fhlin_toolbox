function [outdata,correct_phase]=zerophase(indata,varargin)
% zero order phase correction
% input1 indata: spec, dimy, dimx
% input2 phase : dimy, dimx
% outdata  : spec, dimy, dimx
% (phase)  : dimy, dimx

[samplepoint,dimy,dimx,chan]=size(indata);
if(nargin>1)
    %applying phase correcting terms to input data
    correct_phase=varargin(1);
    outdata=indata.*correct_phase;
else
    %estimating phase correting terms from input data
    phase=zeros(dimy,dimx,chan);
    ang=exp(sqrt(-1).*angle(indata));
    if(chan==1)
        opt_ang=permute(angle(squeeze(sum(ang.*abs(indata).^2,1))),[4 1 2 3]);
    else
        opt_ang=angle(sum(ang.*abs(indata).^2,1));
    end;
    opt_ang=repmat(opt_ang,[samplepoint,1,1,1]);
    correct_phase=exp(sqrt(-1).*(-opt_ang));
    outdata=indata.*exp(sqrt(-1).*(-opt_ang));
end

return;


