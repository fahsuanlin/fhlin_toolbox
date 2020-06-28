function wavelet_add_daub53()
dd=pwd;
%cd('e:/user/fhlin/toolbox/fhlin_toolbox');
fprintf('using Daub53 filter banks\n');
%!del wavelets.*

Rf = [1 2 1]./4;
Df = [-1     2     6     2    -1]./10;
save daub53 Rf Df
wavemngr('del', 'Biorthogonal')
wavemngr('add', 'Biorthogonal', 'daub', 2, '53', 'daub53.mat')
cd(dd);