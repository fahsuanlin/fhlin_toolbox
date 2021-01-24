function [tableau,basicptr,cost] = pivottableau(intableau,inbasicptr,varargin)
% 
% Perform pivoting on an augmented tableau until 
% there are no negative entries on the last row
%
% function [tableau,basicptr] = pivottableau(intableau,inbasicptr)
%
% intableau = input tableau tableau,
% inbasicptr = a list of the basic variables, such as [1 3 4]
%
% tableau = pivoted tableau 
% basicptr = new list of basic variables

% Copyright 1999 by Todd K. Moon


flag_display=1;
cost=[];

mode='opt';
n_var=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
    case 'flag_display'
        flag_display=option_value;
    case 'mode'
        mode=option_value;
    case 'n_var'
        n_var=option_value;
    otherwise
        fprintf('unknown option [%s]',option);
        fprintf('error!\n');
        return;
    end;
end;
        
tableau = intableau; basicptr = inbasicptr;
[mp1,np1] = size(tableau);
n = np1-1;  m = mp1-1;


[rmin,q] = min(tableau(end,1:n));
count=0;
cont=1;

if(strcmp(mode,'init'))
else
    n_var=0;
end;

%while(((rmin < 0)&cont)&(max(basicptr)>n_var))
while((rmin < 0)&(max(basicptr)>n_var))
  p = 0;
  minratio = realmax;
  for i=1:m
    if(tableau(i,q) > 0)
      r = tableau(i,np1)/tableau(i,q);
      if(r < minratio)
        minratio = r;
        p = i;
      end
    end
  end
  if(p == 0)
    error('unbounded solution');
  end
  % update which are the basic variables in the list

  oldb = basicptr(p); basicptr(p) = q;
  
  % perform the pivot
  tableau(p,:) = tableau(p,:) / tableau(p,q);
  for i=1:mp1
    if(i ~= p)
      tableau(i,:) = tableau(i,:) - tableau(p,:) .* tableau(i,q);
    end
  end
  [rmin,q] = min(tableau(end,1:n));
  
  
  if(flag_display==2)
      fprintf('simplex [%d]...r_min=[%e] cost=[%e] max(basic_ptr)=[%d] min(basit_ptr=[%d]',count,rmin,tableau(end,end),max(basicptr),min(basicptr));
  end;

  count=count+1;
  cost(count)=tableau(end,end).*(-1);
  if(count>1) 
        if(flag_display==2)
            fprintf(' diff=[%e]\n',cost(count)-cost(count-1)); 
        end;
        if(abs(cost(count)-cost(count-1))<1e-10) cont=0;  end; 
  else
        if(flag_display==2)
            fprintf('\n');
        end;
  end;
end
