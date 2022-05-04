function etc_distribute(dd)
%	etc_distribute		generate evenly distributed coordinates
%
%
for i=1:size(dd,3)
	tmp=abs(dd(:,:,i));
	[xx,yy]=meshgrid([1:size(tmp,2)],[1:size(tmp,1)]);
	yy=flipud(yy);
	cx(i)=tmp(:)'*xx(:)./sum(tmp(:));
	cy(i)=tmp(:)'*yy(:)./sum(tmp(:));
end;
cx=fmri_scale(cx,40,-40);
cy=fmri_scale(cy,40,-40);

boundary_radius=120;
n_boundary=180;
boundary_x=boundary_radius*cos([0:n_boundary-1]./n_boundary*2*pi);
boundary_y=boundary_radius*sin([0:n_boundary-1]./n_boundary*2*pi);


flag_cont=1;
count=1;
step=1;
while(flag_cont)
	C=cat(2,cx+sqrt(-1).*cy,boundary_x+sqrt(-1).*boundary_y);
	C=repmat(C,[length(cx),1]);
	CC=C-repmat(transpose(cx+sqrt(-1).*cy),[1,size(C,2)]);
	idx=find(abs(CC(:))>eps);
	CCF=zeros(size(CC));
	U=cat(2,ones(1,length(cx)),ones(1,length(boundary_x)).*10);
	U=repmat(U,[size(CCF,1),1]);
	CCF(idx)=1./(abs(CC(idx)).^0.1).*exp(sqrt(-1).*angle(CC(idx))).*U(idx);
	CCF=sum(CCF,2);
	
	cx=cx-real(CCF)'.*step;
	cy=cy-imag(CCF)'.*step;

	cx=fmri_scale(cx,40,-40);
	cy=fmri_scale(cy,40,-40);

	clf;
	for i=1:size(dd,3)
		text(cx(i),cy(i),sprintf('%d',i)); hold on;
		plot(cx(i),cy(i),'r.'); 
	end;
	for j=1:n_boundary
		plot(boundary_x(j),boundary_y(j),'b.'); 
	end;
	hold off;


	axis([-60 60 -60 60]);
	count=count+1;
	if(count>=100) flag_cont=0; end;
	pause(0.001);
end;


cx=fmri_scale(cx,30,-30);
cy=fmri_scale(cy,30,-30);

fp=fopen(sprintf('c%dmri.dat',size(dd,3)),'w');
for i=1:size(dd,3)
	fprintf(fp,'%d\t%f\t%f\t2\t1.5\t%3d\n',i,cx(i),cy(i),i);
end;
fclose(fp);
fprintf('[%s] generated.\n',sprintf('c%dmri.dat',size(dd,3)));

return;
