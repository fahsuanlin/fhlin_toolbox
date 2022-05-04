function wavelet_add_daub75()
dd=pwd;
%cd('e:/user/fhlin/toolbox/fhlin_toolbox');
fprintf('using Daub75 filter banks\n');
%del wavelets.*

Rf = [1 3 3 1]./8;
Df = [3    -9    -7    45    45    -7    -9     3]./64;
save daub75 Rf Df
wavemngr('del', 'Biorthogonal')
wavemngr('add', 'Biorthogonal', 'daub', 2, '75', 'daub75.mat')
cd(dd);
