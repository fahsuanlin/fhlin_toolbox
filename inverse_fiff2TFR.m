function fiff2TFR(inputname,outputname,Trigger,Chans,TimeInt,freqVec,Width,TimeExtr,varargin) 
% function fiff2TFR(INPUTNAME,OUTPUTNAME,TRIGGER,CHANS,TIMEINT,FREQVEC,WIDTH,TIMEEXTR) 
%
% Calculate the time-frequency representation of a Neuromag fif-file with 
% respect to the TRIGGER. A wavelet method is used.  
% The files are saved in Matlab format.  
%
% INPUTNAME  : A rawdata fiffile. Include directory is necessary. 
% OUTPUTNAME : outputname.
% TRIGGER    : Trigger for used for averaging
% CHANS      : Channels for which to calculated plf (numbered 1 to 306) 
% TIMEINT    : Timeinterval (sec) for which to calculate ER,
%              with respect to the TRIGGER e.g [-0.1 0.5]
% FREQVEC    : Frequency vector over which to calc., e.g. 20:2:60;
% WIDTH      : Width of Morlet wavelet (>= 5 ) e.g. 7.
% TIMEEXTR   : (OPTIONAL) Timeinterval for when to extract
%              from raw data (sec) e.g.  [0 60]
%
%------------------------------------------------------------------------
% Ole Jensen, Brain Resarch Unit, Low Temperature Laboratory,
% Helsinki University of Technology, 02015 HUT, Finland,
% Report bugs to ojensen@neuro.hut.fi
%------------------------------------------------------------------------

%    Copyright (C) 2000 by Ole Jensen 
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You can find a copy of the GNU General Public License
%    along with this package (4DToolbox); if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%------------------------------------------------------------------------
% The file InitParam.txt contains a set of parameters which have to 
% be defined prior to the analysis. In this file the variables for EOG 
% threshold, SSP etc are defined. 
%------------------------------------------------------------------------

tPre=[];
output_format='power';
flag_stat=0;

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch lower(option)

	case 'output_format'
		output_format=option_value;
	case 'tPre'
		tPre=option_value;
	case 'flag_stat'
		flag_stat=option_value;
	otherwise
		fprintf('unknown option [%s]!', option);
		fprintf('exit!\n');
		return;
	end;
end;


InitParam=readInitParam('InitParam.txt');




%------------------------------------------------------------------------
%  Initialize variables/open fiff file
%------------------------------------------------------------------------

tPre = -TimeInt(1);
tPost = TimeInt(2);    

if exist('TimeExtr')
    tStart = TimeExtr(1);
    tStop  = TimeExtr(2);
else 
    tStart = 0;
    tStop = Inf;
end



[Fs,rowMEG,rowEOG,rowTRIG,rowEEG,rowMISC,rowEMB,STbc,ST] = fiffSetup(inputname);
if isempty(ST)
    if InitParam.applySSP
        fprintf('No SSP transformation available - SSP turned off\n');
        InitParam.applySSP = 0;
    end
 else
    if InitParam.applySSP
        fprintf('SSP applied\n');
    else
        fprintf('SSP transformation available, but SSP is NOT applied\n');
    end
end

ChNames = channames(inputname) ;


tCurrent = tStart; 
TrigThres = 2; 
rawdata('any',inputname);                    

colPre    = floor(Fs*tPre);
colPost   = floor(Fs*tPost);  
colDelay  = floor(Fs*InitParam.stimDelay);

Trials = 0;   
EOGrej = 0;
Frej = 0;
DFDTrej = 0;

t = rawdata('goto',tStart);
[B,status]=rawdata('next');
while strcmp(status,'skip')
   [B,status]=rawdata('next');
end

BPre  = zeros(size(B,1),colPre);  
BPost = zeros(size(B,1),colPost); 
colB = size(B,2); 
colTRACE = colB+colPre+colPost;
TRACE = zeros(size(B,1),colTRACE); 
TFR   = zeros(length(freqVec),colPre+colPost,length(Chans)); 

%------------------------------------------------------------------------
% Read chunks of fif file and calculate the ERP
%------------------------------------------------------------------------


fprintf('Reading trial\n');
while strcmp(status,'ok') & tCurrent < tStop
   B(rowMEG,:) = STbc * B(rowMEG,:);
   colB = size(B,2); 
   TRACE(:,1:colTRACE-colB)  = TRACE(:,colB+1:colTRACE);
   TRACE(:,colTRACE-colB+1:colTRACE)  = B;
   TrigList = colDelay + findTrigger(TRACE(rowTRIG,colPre+1:colPre+colB),Trigger,TrigThres);
   for k=1:length(TrigList)
       if colPre+TrigList(k)+colPost <= size(TRACE,2)  
           traceOK = 1;
           Ttmp = TRACE(:,TrigList(k):colPre+TrigList(k)+colPost-1);
           Ttmp = detrend(Ttmp','constant')';
           MEGtmp = Ttmp(rowMEG,:);
           if InitParam.applySSP
               MEGtmp = ST*MEGtmp;
           end
   

	   [tmpVal,dFmaxCh] = max(max(diff(abs(MEGtmp'))));
           DFDTmax = 1e13*tmpVal/(1/Fs);
	   
	   [tmpVal,FmaxCh] = max(max(abs(MEGtmp')));
	   Fmax = 2*1e13*tmpVal;
           Ttmp(rowMEG,:) = MEGtmp;   

           traceOK = 1;
           if DFDTmax > InitParam.DFDTreject 
               DFDTrej = DFDTrej + 1;
               fprintf('Reject:%s(dF) -',char(ChNames(dFmaxCh)));
               traceOK = 0;
           end

           if Fmax > InitParam.Freject 
               Frej = Frej + 1;
               fprintf('Reject:%s(F)-',char(ChNames(FmaxCh)));
               traceOK = 0;
           end

	   if ~isempty(rowEOG)
	       EOGtmp = TRACE(rowEOG,TrigList(k):colPre+TrigList(k)+colPost-1);
               for l=1:size(EOGtmp,1)
                   
		   EOGd = detrend(EOGtmp(l,:));
		   if 1e6*(max(EOGd) - min(EOGd)) > InitParam.EOGreject
                       EOGrej = EOGrej + 1;
                       fprintf('Reject:EOG-');
                       traceOK = 0;
		   
                   end
	       end
	   end
           if traceOK
               Ttmp(Chans,:) = detrend(Ttmp(Chans,:)')';
               for l=1:length(Chans)
                   for m=1:length(freqVec)
                       TFR(m,:,l) = energyvec(freqVec(m),Ttmp(Chans(l),:),Fs,Width,output_format) + TFR(m,:,l);
                   end
               end
               Trials = Trials + 1; 
               fprintf('%d-',Trials);
           end
       end
   end
   [B,status]=rawdata('next');
   while strcmp(status,'skip')
       [B,status]=rawdata('next');
   end
  
   tCurrent = rawdata('t');
   % rawdata('t')
end



%------------------------------------------------------------------------
% Save Matlab file
%------------------------------------------------------------------------


timeVec = (1:size(TFR,2))/Fs - tPre;
TFR = squeeze(TFR);
TFR = TFR/Trials;
save(strcat(outputname,'.mat'),'TFR','timeVec','freqVec','Trials','EOGrej','Chans','InitParam','Frej','DFDTrej');



rawdata('close');
%------------------------------------------------------------------------



function y = energyvec(f,s,Fs,width,output_format)
% function y = energyvec(f,s,Fs,width,output_format)
%
% Return a vector containing the energy as a
% function of time for frequency f. The energy
% is calculated using Morlet's wavelets.
% s : signal
% Fs: sampling frequency
% width : width of Morlet wavelet (>= 5 suggested).
% output_format : either 'power' or 'mag'
%

dt = 1/Fs;
sf = f/width;
st = 1/(2*pi*sf);

t=-3.5*st:dt:3.5*st;
m = morlet(f,t,width);

y = conv(s,m);

switch lower(output_format)
case 'power'
	y = (2*abs(y)/Fs).^2;
case 'mag'
	y = (2*abs(y)/Fs);
end;

y = y(ceil(length(m)/2):length(y)-floor(length(m)/2));

return;



function y = morlet(f,t,width)
% function y = morlet(f,t,width)
%
% Morlet's wavelet for frequency f and time t.
% The wavelet will be normalized so the total energy is 1.
% width defines the ``width'' of the wavelet.
% A value >= 5 is suggested.
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)
%
%
% Ole Jensen, August 1998

sf = f/width;
st = 1/(2*pi*sf);
A = 1/(st*sqrt(2*pi));
y = A*exp(-t.^2/(2*st^2)).*exp(i*2*pi*f.*t);


