function [sequence]=fmri_parabstp(paradigm)
%fmri_parabstp	generate a random bootstrpped index based on the paradigm file
%
%[sequence]=fmri_parabstp(paradigm)
%
%
%paradigm : the paradigm column vector
%
%written by fhlin@aug. 21, 1999
a1=fmri_paraperm(paradigm);
a2=fmri_paraperm(paradigm);

sequence=floor((fmri_paraperm(paradigm)+fmri_paraperm(paradigm))./2);