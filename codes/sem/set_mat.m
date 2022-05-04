function [SEM, x0] = set_mat(Data, Free, SEM);


offset = find(diff(Free(3,:)')');
offset = [0 offset];
FreeAll= Free(1,:);
Freex0 = Free(4,:);

x0     = [];

for k = 1:size(Data,2)
	
	useit   = Data(k).useit;
	U       = Data(k).U;
	B       = Data(k).B;
	FreeAll = Free(1,:);
	
	%Set up matrices for free parameters
	%------------------------------------
	ConX = zeros(length(useit));
	ConZ = zeros(length(useit));

	
	%Insert free parameters
	%----------------------
	ul = size(U,2);
	bl = size(B,2);

	if ~isempty(U)
	 Usource = U(1,:);
	 Udest   = U(2,:);
	else
	 Usource = []; Udest = [];
	end

	if ~isempty(B)
	 Bsource = B(1,:);
	 Bdest   = B(2,:);
	else
	 Bsource = [];Bdest = [];
	end

	U = (Usource-1) * size(ConX,1) + Udest;
	ConX(U) = FreeAll(offset(k)+1:offset(k)+ul);

	B = (Bsource-1) * size(ConZ,1) + Bdest;
	ConZ(B) = FreeAll(offset(k)+ul+1:offset(k)+ul+bl);

	
	%Make Z matrices symmetric
	%-------------------------
	D    = diag(diag(ConZ));
	ConZ = ConZ	+ ConZ'- D;



	SEM(k).ConX = ConX;
	SEM(k).ConZ = ConZ;


end % for k

x0 = zeros(1,max(FreeAll));

for j = 1:max(FreeAll)
 x0(j) = mean(Freex0(find(FreeAll==j)));
end
%T 