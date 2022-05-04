function [output, varargout]=cir_wavedec_full(input,level,h0,h1)
% function [output, varargout]=cir_wavedec_full(input,level,h0,h1)
% Full dyadic wavelet decomposition.

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001
if level==0
	output=input;
	return;
end;

if level>1
   input = cir_wavedec(input,1,h0,h1);
   
   cmd='';
   for k=1:ndims(input)
      cmd = strcat(cmd, sprintf('for i%d=0:1,', k));
   end
   
   idx_str = sprintf('%s', '[1:end/2]+i1*end/2');
   for k=2:ndims(input)
       idx_str = strcat(idx_str, sprintf(', [1:end/2]+i%d*end/2', k));  
   end
   
   %idx_str
   
   tmp = sprintf('%s %s %s', 'eval(sprintf(''sub_input = input(%s);'', idx_str)); ',...
      'sub_input = cir_wavedec_full(sub_input, level-1, h0, h1);',...
      'eval(sprintf(''input(%s) = sub_input;'', idx_str));');
   
   cmd = strcat(cmd, tmp);
   
   for k=1:ndims(input)
      cmd = strcat(cmd, 'end; ');
   end
   
   %fprintf('%s',cmd);

   eval(cmd)
   output = input;
else
   output = cir_wavedec(input,1,h0,h1);
end


