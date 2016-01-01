function wavelet_add_daub97()
dd=pwd;
%cd('e:/user/fhlin/toolbox/fhlin_toolbox');
fprintf('using Daub97 filter banks\n');
%!del wavelets.*

load daub97 h0 h1
Rf = qmf(h1);
Df = h0;
save daub97 Rf Df -append
wavemngr('del', 'Biorthogonal')
wavemngr('add', 'Biorthogonal', 'daub', 2, '97', 'daub97.mat')
cd(dd);