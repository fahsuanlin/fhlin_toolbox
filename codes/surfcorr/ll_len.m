function y = ll_len(L,binstr)


if binstr(1) == '2'  % Highpass
    if(length(binstr)==1)
        y = L{1}(end)+L{2}(end);
        return;
    else
%        L{2}
%        binstr(2:end)
        y = L{1}{end} + ll_len(L{2}, binstr(2:end));
    end;
else
    if(length(binstr)==1)
        y = L{1}(end);
        return;
    else
        y = ll_len(L{1}, binstr(2:end));
    end;
end