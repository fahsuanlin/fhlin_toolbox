function [fieldmap, mask]=etc_fieldmap(i1,i2,delta_te,varargin)
%
%   etc_fieldmap    calculate field maps based on 2-echo images
%
% fieldmap=etc_fieldmap(i1,i2,delta_te,....)
% 
% i1: image of echo 1 (complex value)
% i2: image of echo 2 (complex value)
% delta_te: delta TE between i1 and i2 (in ms)
%
% fieldmap: estimated field map (in Tesla)
%
% fhlin@sep. 29 2007
%

for i=1:length(varargin)/2
    option_varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case ''
        otherwise
            fprintf('no option [%s]...n', option);
            return;
    end;
end;

gamma=42.58; %MHz/T
fieldmap=angle(i1./i2)./2./pi./(delta_te*1e-3)./(gamma.*1e6);

mask=zeros(size(fieldmap));
avg=(abs(i1)+abs(i2))./2;
mask(find(avg(:)>mean(avg(:))./4))=1; 
mask=imfill(mask,'holes');



return;


