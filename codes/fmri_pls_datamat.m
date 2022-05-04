function [datamat,coords,x,y]=fmri_pls_datamat(datafile,tasks,subjects,slices,threshold,flags)
%fmri_pls_datamat 	generate the datamat for the PLS analysis of functional data
%
%[datamat,coords,x,y]=fmri_pls_datamat(datafile,tasks,subjects,slices,threshold,flag)
%
%datafile: all bshort data files, must be arranged in tasks->subjects->slices
%tasks: number of tasks
%subjects: number of subjects
%slices: number of slices
%threshold: the threshold to disgard the unnecessary voxels; 0 using the default-1/7 of the maximail value
%flag: 1D control flag
%	flag(1)==1	linearly detrending
%	flag(2)==1	linearly scaling row by row (0~1)
%	flag(3)==1	linearly scaling col by col (0~1)
%	flag(4)==1	removing mean row by row
%	flag(5)==1	removing mean col by col
%	flag(6)==1	normalize slice of the same timepoint within subject across tasks
%	flag(7)==1	joint of voxels across slice included for datamat (default)
%	flag(7)==2	union of voxels across slice included for datamat
%
%written by fhlin@aug. 24, 1999

[files,dummy]=size(datafile);
fn=char(datafile);
clear datafile;


%
%reading data files
%
str=sprintf('reading raw data...');
disp(str);


%
%preparing for reading data files
%
allsize=zeros(subjects,3);
for i=1:subjects
   buffer=fmri_ldbfile(fn((i-1)*slices+1,:));
   [y,x,timepoints]=size(buffer);
   allsize(i,:)=[y,x,timepoints];
   str=sprintf('subject[%d] X=%d Y=%d Timepoints=%d',i,x,y,timepoints);
   disp(str);
end;
clear buffer;

maxsize=max(allsize,[],1);
timepoints=maxsize(3);
sumallsize=sum(allsize,1);
totaltime=sumallsize(3);
sz=[tasks,subjects,slices,maxsize];
%dat=zeros(sz);


%reading data files and putting into datamat
%datamatin=zeros(tasks*totaltime,y*x*slices);
datamatin=[];
if(size(fn,1)==tasks*subjects*slices)
	for i=1:tasks
		for j=1:subjects
   			for k=1:slices
        			%str=sprintf('tasks[%d] subject[%d] slice[%d]',i,j,k);
           			%disp(str);
   			        
  				index=(i-1)*subjects*slices+(j-1)*slices+k;
	
				str=sprintf('reading [%s]...([%s])',fn((i-1)*subjects*slices+(j-1)*slices+k,:),num2str(size(datamatin)));
				disp(str);
	
				%disp('reading');
  				buffer=reshape(fmri_ldbfile(fn((i-1)*subjects*slices+(j-1)*slices+k,:)),[x*y,allsize(j,3)])';
	  			%disp('reading DONE!');
         			
   				time_offset=0;
   				for tos=1:j-1
					time_offset=time_offset+allsize(tos,3);
     				end;
            
        			all_time=sum(allsize(:,3),1);
   				time_offset=time_offset+(i-1)*all_time;
         
	            		datamatin(time_offset+1:time_offset+allsize(j,3),(k-1)*x*y+1:k*x*y)=buffer;
        	    		datamatin=int16(datamatin);
           		end;
  		end;
   	end;
end;


str=sprintf('generating datamat...');
disp(str);

flags
if(length(flags)==6)
	datamat_switch=1;
else
	datamat_switch=flags(7);
end;

[datamat coords]=makedata_raw(reshape(datamatin,[tasks*totaltime y*x*slices]),threshold,datamat_switch); %making the datamat
show_datamat(coords,y,x,slices); %show the datamat

%
%detrending
%
if(flags(1)==1)
	disp('detrending within task....');
	for t=1:tasks
		datamat((t-1)*totaltime+1:t*totaltime,:)=detrend(datamat((t-1)*totaltime+1:t*totaltime,:));
	end;
end;


%
%linearly scale rows by rows
%
if(flags(2)==1)
	disp('linearly scaling row by row...');
	for i=1:size(datamat,1)
		datamat(i,:)=fmri_scale(datamat(i,:),1,0);
	end;
end;

%
%linearly scale cols by cols
%
if(flags(3)==1)
	disp('linearly scaling col by col...');
	for i=1:size(datamat,2)
		datamat(:,i)=fmri_scale(datamat(:,i),1,0);
	end;
end;

%
%removing mean rows by rows
%
if(flags(4)==1)
	disp('removing mean at each time point (row by row)...');
	datamat=datamat-mean(datamat,2)*ones(1,size(datamat,2));
end;


%
%remove the mean of the (task-subj)  col by col
%
if(flags(5)==1)
	disp('removing mean within task within subject (col by col)...');
	for i=1:tasks
		for j=1:subjects
			time_offset=0;
   		for tos=1:j-1
   				time_offset=time_offset+allsize(tos,3);
	   	end;
			all_time=sum(allsize(:,3),1);
   		time_offset=time_offset+(i-1)*all_time;
         
      	mm=mean(mean(datamatin(time_offset+1:time_offset+allsize(j,3),:)));
      	datamatin(time_offset+1:time_offset+allsize(j,3),:)=datamatin(time_offset+1:time_offset+allsize(j,3),:)-mm;
      end;
	end;
end;


%
%normalize based on time point (row by row) across tasks for the same subject
%

%before=datamat;
if(flags(6)==1)
	for i=1:subjects
		for j=1:allsize(i,3)
			clear t;
			for k=1:tasks
				t(k)=j+(k-1)*totaltime;
			end;
			d1=mean(datamat(t,:),2);
			d2=mean(d1);
			d3=d1-d2;
			vv(j)=var(d3);
			datamat(t,:)=datamat(t,:)-d3*ones(1,size(datamat,2));
		end;
	end;
end;

str=sprintf('generating datamat done!');
disp(str);
