function Cor = etc_movcorr(Data1,Data2,k)
y = zscore(Data2);
n = size(y,1);

if (n<k)
    Cor = NaN(n,1);
else
    x = zscore(Data1);
    x2 = x.^2;
    y2 = y.^2;
    xy = x .* y;
    A=1;
    B = ones(1,k);
    Stdx = sqrt((filter(B,A,x2) - (filter(B,A,x).^2)*(1/k))/(k-1));
    Stdy = sqrt((filter(B,A,y2) - (filter(B,A,y).^2)*(1/k))/(k-1));
    Cor = (filter(B,A,xy) - filter(B,A,x).*filter(B,A,y)/k)./((k-1)*Stdx.*Stdy);
    Cor(1:(k-1)) = NaN;
end

