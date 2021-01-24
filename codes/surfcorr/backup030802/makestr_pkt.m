function str=makestr_pkt(L,signal_size,which_band,option)
%function str=makestr_pkt(L,signal_size,which_band,option)
% WHICH_BAND is a string consisting of '0' or '1' signifying which half of
% the corresponding dimensions is to be decomposed. 
%   e.g. '01' means [0 pi/2] for the 1st dim, and [pi/2 pi] for the 2nd dim.


% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001

if(option==0)
   if which_band(1)=='0'
      str=sprintf('sub_input=input(1:%d',signal_size(1)/(2^L));
   else
      str=sprintf('sub_input=input((%d+1):(2*%d)',signal_size(1)/(2^L),signal_size(1)/(2^L));
   end
   
   for i=2:length(signal_size)
      if which_band(i)=='0'
         %str=sprintf('sub_input=input(1:%d',signal_size(1)/(2^L));
         str=strcat(str,sprintf(',1:%d',signal_size(i)./(2.^L)));
      else
         %str=sprintf('sub_input=input(%end+1:2*%d',signal_size(1)/(2^L));
         str=strcat(str,sprintf(',(%d+1):(2*%d)',signal_size(i)./(2.^L), signal_size(i)./(2.^L)));
      end  
   end;
   
	str=strcat(str,');');
end;
if(option==1)
   if which_band(1)=='0'
      str=sprintf('(1:%d',signal_size(1)./(2.^L));
   else
      str=sprintf('((%d+1):(2*%d)',signal_size(1)./(2.^L),signal_size(1)./(2.^L));
   end
   
   for i=2:length(signal_size)
      if which_band(i)=='0'
         str=strcat(str,sprintf(',1:%d',signal_size(i)./(2.^L)));
      else
         str=strcat(str,sprintf(',(%d+1):(2*%d)',signal_size(i)./(2.^L),signal_size(i)./(2.^L)));
      end
	end;
   str=strcat(str,')'); 
   str=sprintf('input%s=sub_input;',str);
end;
return;
