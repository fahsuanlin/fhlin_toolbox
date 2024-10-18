function etc_rmmatvar(matfile, varname)
% Load in data as a structure, where every field corresponds to a variable
% Then remove the field corresponding to the variable
flag_display=1;

if(flag_display)
    fprintf('loading [%s]...\n',matfile);
end;
data=load(matfile);

if(isstring(varname))
    varname={varname};
end;

for v_idx=1:length(varname)
    try
        if(isfield(data,varname{v_idx}))
            fprintf('\tremoving [%s]...\n',varname{v_idx})
            data = rmfield(data, varname{v_idx});
        else
            fprintf('\t[%s] not existed in the MAT file...\n',varname{v_idx});
        end;
% Resave, '-struct' flag tells MATLAB to store the fields as distinct variables
    catch
    end;
end;
if(flag_display)
    fprintf('saving [%s]...\n',matfile);
end;
save(matfile, '-struct', 'data');
end