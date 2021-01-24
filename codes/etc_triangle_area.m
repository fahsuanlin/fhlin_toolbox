function area=etc_triangle_area(vertices)
%	etc_triangle_area		calcualte the area of a triangle using Heron's formula
%
%   area=etc_triangle_area(vertices)
%
%	vertices: 3-by-3 matrix, each row contains the x, y and z or one vertex
%	area: calculated area
%
%	fhlin@june 25,2003
if(size(vertices)~=[3,3])
	fprintf('error! input matrix must be a 3-by-3 matrix!\n');
	return;
end;

a=norm(vertices(1,:)-vertices(2,:));
b=norm(vertices(2,:)-vertices(3,:));
c=norm(vertices(3,:)-vertices(1,:));
s=(a+b+c)./2;
area=sqrt((s-a)*(s-b)*(s-c)*s);

