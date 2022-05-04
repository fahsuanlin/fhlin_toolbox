function []=fmri_mont_head2slice(filter,subimage_width,subimage_height,mont_image_row,mont_image_col,skip,total_slice,prefix)
% fmri_mont_head2slice       to convert heads montaged  as 2D images into slices
%  
% fmri_mont_head2slice(filter,subimage_width,subimage_height,mont_image_row,mont_image_col,skip,total_slice,prefix);
%
% filter: the file name filter to include all files to be converted (must be bshort files).
% subimage_width: the width (in pixel) of each sub image in the montaged image
% subimage_height: the height (in pixel) of each sub image in the montaged image
% mont_image_row: number of sub images horizontally on the montaged image
% mont_image_col: number of sub images vertically on the montaged image
% skip: the number of subimage to skip when converting
% total_slice: the total number slice in conversion after skipping
% prefix: the prefix for the converted file
%
% written by fhlin@jan. 27,
   pwd

   filter=sprintf('bshort_*.bshort');

   d=dir(filter);
   filename=struct2cell(d);
   filename=filename(1,:);
   [a,b]=size(filename);
   fn=filename(1,1:b);
   for j=1:b
   	f(j,:)=fn(j);
   end;
   f=sort(f);
   
   	

subimage_width=64;
subimage_height=64;
mont_image_row=8;
mont_image_col=8;
skip=0;
total_slice=46;
prefix='ws.3r';
time=[1:120];


temp=zeros(64,64,1,46);

    
    %read bshort files in one folder
    for j=1:b
         fn1=char(f(j,:));

         str=sprintf('loading [%s]...',fn1);
         disp(str);

         data=fmri_ldbfile(fn1);


         for i=1:total_slice
             row=ceil((skip+i)/mont_image_row);
             col=mod((skip+i),mont_image_col);
             if(col==0) col=mont_image_col; end;

             row_start=(row-1)*subimage_height+1;
             row_end=(row)*subimage_height;

             col_start=(col-1)*subimage_width+1; 
             col_end=(col)*subimage_width;
       
             buffer=data(row_start:row_end,col_start:col_end);
             %temp(:,:,1,i)=buffer;
 
             fn=sprintf('%s_%s.bshort',prefix,num2str(total_slice-i,'%03d'));
             %str=sprintf('saving [%s]...',fn);
             %disp(str);
              
             fmri_svbfile(buffer,fn,'append');
            

        end;

end;



str='done!';
disp(str);



