function x = mywextend(x, lenEXT, lf)
% extends the 1st dim
% x = mywextend(x, lenEXT, lf)
% x: signal to extend in the first dimension
% lenEXT: # pts to extend on both sides
% lf: filter length

lx = size(x,1);

%if rem(sx,2) , x(sx+1) = x(sx); sx = sx+1; end
if rem(lx,2),
    cmd = 'x(lx+1';
    for k=2:ndims(x)
        cmd = strcat(cmd, ',:');
    end
    cmd = strcat(cmd, ') = x(lx');
    for k=2:ndims(x)
        cmd = strcat(cmd, ',:');
    end
    cmd = strcat(cmd, ');');
    eval(cmd);
    lx = lx+1;
end


I = [lx-lenEXT+1:lx , 1:lx , 1:lenEXT];
if lx<lenEXT
    I = mod(I,lx);
    I(I==0) = lx;
end
%I
cmd = 'x = x(I';
for k=1:ndims(x)-1
    cmd = strcat(cmd, ',:');
end
cmd = strcat(cmd, ');');
eval(cmd);


% zero-padding of x so that we can use FILTER in myconvdown
siz_x = size(x);
siz_x(1) = lf-1;

x = cat(1,x, zeros(siz_x));
