for i=1:500
imagesc(abs(navs(:,:,i)));title(['Acq Number is ' int2str(i)]);
pause;
end;

for i=1:9
imagesc(abs(navs(:,:,i,1)));title(['Slice Number is ' int2str(i)]);
pause;
end;
for i=1:9
plot(abs(navs(1,:,i,1)));hold on;plot(abs(navs(2,:,i,1)),'r');plot(abs(navs(3,:,i,1)),'g');
pause;
end
   

