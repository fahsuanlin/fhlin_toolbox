function [ps,ct]=inverse_psct(A,W,ndec)


fprintf('calculating resolution matrix....\n');
R=W*A;


fprintf('calculating cross-talk/point-spread....\n');
if(size(R,1)==size(R,2))
	if(size(R,1)==ndec)
		fprintf('1 dipole per location\n');
		
		ps=abs(R).^2./repmat(abs(diag(R)).^2,[1,size(R,2)]);
		ct=ps;
		
	else
		fprintf('3 dipole per location\n');
		
		R=abs(R).^2;
		R=blkproc(R,[3,3],'sum(sum(x))');
		
	
		ps=abs(R).^2./repmat(abs(diag(R)).^2,[1,size(R,2)]);
		ct=ps;
	end;
end;		
				
