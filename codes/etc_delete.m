function h=etc_delete(h)

if(isempty(h))
    delete(h);
else
    if(ishandle(h))
%        if(exist(h))
            if(isvalid(h))
                delete(h);
            end;
            h=[];
%        end;
    else
        h=[];
    end;
end;

return;