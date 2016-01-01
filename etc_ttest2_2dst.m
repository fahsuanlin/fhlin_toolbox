function [t_stat, under]=etc_ttest2_2dst(st_block, param)

under=squeeze(mean(st_block,3));

idx0=find(param==0);
idx1=find(param==1);

st_block_0=st_block(:,:,idx0);
st_block_1=st_block(:,:,idx1);

for i=1:size(st_block,1)
    t_stat(i,:)=etc_ttest2(squeeze(st_block_1(i,:,:))',squeeze(st_block_0(i,:,:))');
end;
return;