function trans_data=etc_rigidbodytrans(data,trans)
% etc_rigidbodytrans    transform 3D points via a 12-parameter rigid body
% transformatoin matrix
%
% trans_data=etc_rigidbodytrans(data,trans)
%
% data: [nx3] n data points to be transformed
% trans: [4x4] transformation matrix
%
% trans_data: [nx3] n data points after transformation
%
% fhlin@aug. 3 2014
%

trans_data=[];

tmp=cat(1,data',ones(1,size(data',2)));
tmp_trans=trans*tmp;
trans_data=transpose(tmp_trans(1:3,:));

return;