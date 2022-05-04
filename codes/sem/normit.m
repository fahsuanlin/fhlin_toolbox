function Y = normit(X);
% function Y = normit(X);
% normalise X to zero mean, std unity
% if columns of zeros untouched

Y = X - ones(size(X,1),1)*mean(X); %zero mean

stdY = std(Y);
stdY(find(stdY == 0)) = ones(size(find(stdY == 0)));

Y = Y ./ (ones(size(Y,1),1)*stdY); %std 1
