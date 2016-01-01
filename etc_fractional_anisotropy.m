function fa=etc_fractional_anisotropy(lambda)

lm=mean(lambda);
fa=sqrt((lambda(1)-lm).^2+(lambda(2)-lm).^2+(lambda(3)-lm).^2)./sqrt(sum(lambda.*lambda)).*sqrt(3/2);
return;