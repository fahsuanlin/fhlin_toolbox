function [kvol, navs, time_stamp,k_struct] = myread_meas_out(fname, varargin)
% (Painfully slow) reader for "meas.out" files (Siemens Num4 raw data)
% [kvol, navs] = read_meas_out(fname)
%
%	fname: meas.out file name/path
%	kvol: k-space data
%	navs: navigator data
%
% Note 1: the only navigators this handles are the standard ones used
% in the Siemens EPI sequences: i.e. for each slice, a navigator is
% acquired by reading the center k-space line 3 times, and the mdh
% head is marked with an MDH_PHASECOR.
%
% Dimensions:
% ---------
% 1 -- Column (in k-space)
% 2 -- Phase encode line (row in k-space)
% 3 -- Partition (slice in 3-D k-space) or Slice
% 4 -- Repetition (i.e. the only change is time)
% 5 -- Echo 
% 6 -- RF coil channel
%
% (MukundB, Tue Dec 18, 2001)
% (FhLin, Oct. 30, 2003; VA21 support)


%defaults
flag_fileio=0;
flag_dec_freq=0;
flag_scanonly=0;
k_struct=[];
kvol=[];
navs=[];
time_stamp=[];

partial_fourier_den=[];
partial_fourier_num=[];

numNavs = 3;
DISPLAY = 1;

flag_va21=1;

archive_time=[];

[dummy,fstem]=fileparts(fname);

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};
    
	switch lower(option)
	case 'flag_fileio'
		flag_fileio=option_value;
	case 'flag_display'
		DISPLAY=option_value;
	case 'flag_dec_freq'
		flag_dec_freq=option_value;
	case 'partial_fourier_den'
		partial_fourier_den=option_value;
	case 'partial_fourier_num'
		partial_fourier_num=option_value;
	case 'flag_va21'
		flag_va21=option_value;
	case 'flag_va16'
		flag_va21=~option_value;
	case 'archive_time'
		archive_time=option_value;
	case 'k_struct'
		k_struct=option_value;
	case 'flag_scanonly'
		flag_scanonly=option_value;
	otherwise
        fprintf('unknown option [%s]...\n',option);
        fprintf('exit!\n');
        return;
    end;
end;


fid = fopen(fname, 'r', 'l');
%%%% data starts 32 bytes from the file beginning for pineapple
meas_out_start_offset = fread(fid, 1, 'long'); 
fseek(fid, meas_out_start_offset, 'bof'); 

% Initialize for loop 1
ccMax = 1;
rrMax = 1;
psMax = 1;
ttMax = 1;
ecMax = 1;
CONT = 1;

sliceMax=0;
partitionMax=0;

% Start loop 1
if DISPLAY
    tic
end

ccc=1;

if(isempty(k_struct))
	fprintf('probing raw data file [%s]...\n',fname);
	while CONT == 1
		if(mod(ccc,100)==0)
			fprintf('loading [%d] k-space lines...\n',ccc);
		end;
    
		if(flag_va21)
			[adc_data, mdh] = read_mdh_adc_VA21(fid);
		else
			[adc_data, mdh] = read_mdh_adc(fid);
		end;
    
		if (mdh.EvalInfoMask(1)) % i.e. MDH_ACQEND
        
			CONT = 0;
        
		else
			ccMax = mdh.SamplesInScan;
        
			rr = mdh.LoopCounter.Line + 1;
			ps = max(mdh.LoopCounter.Partition + 1, ...
				mdh.LoopCounter.Slice + 1);
			tt = mdh.LoopCounter.Repetition + 1;
        
			%Nov, 16,2002; use "echo time" to get multiple averages.... :(
			ec = mdh.LoopCounter.Acquisition + 1;
        
			if (mdh.LoopCounter.Partition+1>partitionMax)
				partitionMax=mdh.LoopCounter.Partition+1;
			end;
			if (mdh.LoopCounter.Slice+1>sliceMax)
				sliceMax=mdh.LoopCounter.Slice+1;
			end;
        
			if rr > rrMax
				rrMax = rr;
			end
			if ps > psMax
				psMax = ps;
			end
			if tt > ttMax
            			ttMax = tt;
				if(flag_fileio)
					CONT=0;
				end;
			end
			if ec > ecMax
				ecMax = ec;
			end
       
		end
    
		ccc=ccc+1;
    
	end

	if(partitionMax>1)
		fprintf('3D sequence data...\n');
		flag_3D=1;
	else
		fprintf('2D sequence data...\n');
		flag_3D=0;
	end;


	if DISPLAY
		toc
	end
	k_struct.rrMax=rrMax;
	k_struct.ccMax=ccMax;
	k_struct.psMax=psMax;
	k_struct.ecMax=ecMax;
	k_struct.UsedChannels=mdh.UsedChannels;
	k_struct.flag_3D=flag_3D;
else
	fprintf('initializing with k_struct...\n');
	rrMax=k_struct.rrMax;
	ccMax=k_struct.ccMax;
	psMax=k_struct.psMax;
	ecMax=k_struct.ecMax;
	mdh.UsedChannels=k_struct.UsedChannels;
	flag_3D=k_struct.flag_3D;
end;
fclose(fid);

if(flag_scanonly)
	return;
end;

% Initialize for loop 2
fprintf('Total Used channel=%d\n',mdh.UsedChannels);

if(flag_fileio)
    if(flag_dec_freq)
		kvol = zeros([rrMax, ccMax/2, psMax, ecMax, mdh.UsedChannels]);
	   	navs = zeros(numNavs, ccMax/2, psMax, ecMax, mdh.UsedChannels );
	else
		kvol = zeros([rrMax, ccMax, psMax, ecMax, mdh.UsedChannels]);
		navs = zeros(numNavs, ccMax, psMax, ecMax, mdh.UsedChannels );				
	end;
	numADCs = rrMax*psMax*ecMax*mdh.UsedChannels;
else
	if(flag_dec_freq)
		kvol = zeros([rrMax, ccMax/2, psMax, ttMax, ecMax, mdh.UsedChannels]);
	    	navs = zeros(numNavs, ccMax/2, psMax, ttMax, ecMax, mdh.UsedChannels );
	else
		kvol = zeros([rrMax, ccMax, psMax, ttMax, ecMax, mdh.UsedChannels]);
		navs = zeros(numNavs, ccMax, psMax, ttMax, ecMax, mdh.UsedChannels );
	end;
	numADCs = rrMax*psMax*ttMax*ecMax*mdh.UsedChannels;
end;



PERC = 5;
counter = 1;
navcounter = 1;
fid = fopen(fname, 'r', 'l');
meas_out_start_offset = fread(fid, 1, 'long'); 
fseek(fid, meas_out_start_offset, 'bof'); 
CONT = 1;

if((~isempty(partial_fourier_den))&(~isempty(partial_fourier_num)))
	fprintf('partial fourier sequence!\n');
	flag_partial_fourier=1;
else
	flag_partial_fourier=0;
end;

% Start loop 2
if DISPLAY
    tic
end

rep_count(1)=-1;
acq_count(1)=-1;
time_stamp=[];
tt=1;
tt_old=-1;

ec_array=[];

adc_count=0;

flag_process_navs=0;
while CONT == 1

   
	if(flag_va21)
		[adc_data, mdh] = read_mdh_adc_VA21(fid);
	else
		[adc_data, mdh] = read_mdh_adc(fid);
	end;    	

	adc_count=adc_count+1;
	
	rr = mdh.LoopCounter.Line + 1;
	ps = max(mdh.LoopCounter.Partition + 1, ...
		mdh.LoopCounter.Slice + 1);
	
	%Nov, 16,2002; use "echo time" to get multiple averages.... :(		
	
	ec_array(end+1)=mdh.LoopCounter.Echo;

	ec = mdh.LoopCounter.Acquisition + 1;

	if(rep_count(end)~=(mdh.LoopCounter.Repetition))
		rep_count(end+1)=(mdh.LoopCounter.Repetition);
	end;
	
	if(acq_count(end)~=(mdh.LoopCounter.Acquisition))
		acq_count(end+1)=(mdh.LoopCounter.Acquisition);
	end;        

	%processing of cut-off data (nov. 4, 2002)
	adc_data(1:mdh.CutOffData.Pre)=0;
	adc_data(end-mdh.CutOffData.Post+1:end)=0;
    

	if(flag_dec_freq)
		adc_data=adc_data(1:2:end);
	end;
	
	if(flag_3D)
		%fprintf('3d fft read-out\n');
		adc_data=fftshift(fft(fftshift(adc_data)));
	end;
  
	if mdh.EvalInfoMask(1) % i.e. MDH_ACQEND	
       
		CONT = 0;
        
		rr = mdh.LoopCounter.Line + 1;
        
		ps = max(mdh.LoopCounter.Partition + 1, mdh.LoopCounter.Slice + 1);
        
		tt = mdh.LoopCounter.Repetition + 1;
        
		if(isempty(time_stamp))
			time_stamp(end+1)=1;
		else
			if(time_stamp(end)~=rep_count(end-1)+1)
				time_stamp(end+1)=rep_count(end-1)+1;
			end;
		end;
        
		if(flag_fileio)
			fprintf('archiving time point [%d]...\n',time_stamp(end));      

			if(flag_partial_fourier)
				ll=rrMax*(partial_fourier_den-partial_fourier_num)/partial_fourier_num;
				kvol_append=flipdim(flipdim(kvol(end-ll+1:end,:,:,:,:),1),2);
				kvol=cat(1,kvol_append,kvol);
			end;

			if(flag_3D)
	    		%fprintf('FFT at the partition dimension for 3D sequence...\n');
 	   			%kvol=fftshift(fft(fftshift(kvol,3),[],3),3);
	    	end;     
	    	kvol=mean(kvol,4);
	    
			for s=1:psMax
				for e=1:size(kvol,4)
                    
					k=squeeze(kvol(:,:,s,e,:));
                        
%					if(size(k,1)/2~=midline) %partial fourier
%						for c=1:size(k,3)
%							pad(:,:,c)=fliplr(flipud(k(end-(size(k,1)-midline*2)+1:end,:,c)));
%						end;
%						k=cat(1,pad,k);
%					end;

					fn=sprintf('%s_slice%s_avg%s_time%s_re.bfloat',fstem,num2str(s-1,'%03d'),num2str(e-1,'%03d'),num2str(time_stamp(end)-1,'%03d'));
					fmri_svbfile(real(k),fn);
					fn=sprintf('%s_slice%s_avg%s_time%s_im.bfloat',fstem,num2str(s-1,'%03d'),num2str(e-1,'%03d'),num2str(time_stamp(end)-1,'%03d'));                    
					fmri_svbfile(imag(k),fn);
				end;
			end;
		end;

	else  % i.e. NOT MDH_ACQEND

		midline=mdh.KSpaceCentreLineNo;
 		tt = mdh.LoopCounter.Repetition + 1;
		rr = mdh.LoopCounter.Line + 1;
		ps = max(mdh.LoopCounter.Partition + 1, mdh.LoopCounter.Slice + 1);


		if(isempty(time_stamp))
			time_stamp(end+1)=rep_count(end)+1;
		else
			if(time_stamp(end)~=rep_count(end)+1)
				time_stamp(end+1)=rep_count(end)+1;
			end;
		end;

		if(~isempty(archive_time))
			if(intersect(time_stamp(1:end-1),archive_time)==archive_time)
				CONT=0;
			end;
		end;

		if(flag_fileio)
			if(tt>tt_old&tt_old>0)
				fprintf('archiving time point [%d]...\n',time_stamp(end));           

				if(flag_partial_fourier)
					ll=rrMax*(partial_fourier_den-partial_fourier_num)/partial_fourier_num;
					kvol_append=flipdim(flipdim(kvol(end-ll+1:end,:,:,:,:),1),2);
					kvol=cat(1,kvol_append,kvol);
				end;

				if(flag_3D)
					%fprintf('FFT at the partition dimension for 3D sequence...\n');
					%kvol=fftshift(fft(fftshift(kvol,3),[],3),3);
				end;

				kvol=mean(kvol,4);
	
				for s=1:psMax
					for e=1:size(kvol,4)
						k=squeeze(kvol(:,:,s,e,:));
                        
%						if(size(k,1)/2~=midline) %partial fourier
%							for c=1:size(k,3)
%								pad(:,:,c)=fliplr(flipud(k(end-(size(k,1)-midline*2)+1:end,:,c)));
%							end;
%							k=cat(1,pad,k);
%						end;
			
						fn=sprintf('%s_slice%s_avg%s_time%s_re.bfloat',fstem,num2str(s-1,'%03d'),num2str(e-1,'%03d'),num2str(time_stamp(end)-1,'%03d'));
						fmri_svbfile(real(k),fn);
						fn=sprintf('%s_slice%s_avg%s_time%s_im.bfloat',fstem,num2str(s-1,'%03d'),num2str(e-1,'%03d'),num2str(time_stamp(end)-1,'%03d'));                    
						fmri_svbfile(imag(k),fn);
					
						for xx=1:size(k,3)
							img(:,:,xx)=fftshift(fft2(fftshift(k(:,:,xx))));
						end;
						fmri_mont(abs(img));
					end;
				end;
   	             
				if(flag_dec_freq)
					kvol = zeros([rrMax, ccMax./2, psMax, ecMax, mdh.UsedChannels]);
				else
					kvol = zeros([rrMax, ccMax, psMax, ecMax, mdh.UsedChannels]);
				end;
                
				PERC=5;
                
				counter=1;
			end;
		end;
        
		tt_old=tt;

		%ec = mdh.LoopCounter.Acquisition + 1;
		
%mdh.LoopCounter	
%find(mdh.EvalInfoMask')
%fprintf('[%d] adc line read...\n',adc_count);

        
		if mdh.EvalInfoMask(22) % i.e. MDH_PHASECOR
			if mdh.EvalInfoMask(25) % MDH_REFLECT
				adc_data = fliplr(adc_data);
			end
            
			if(flag_fileio)
				navs(ceil(navcounter/mdh.UsedChannels), :, ps, ec,mdh.ChannelId+1) = adc_data;
			else
				navs(ceil(navcounter/mdh.UsedChannels), :, ps, tt, ec,mdh.ChannelId+1) = adc_data;
			end;
            
			navcounter = navcounter + 1;
			
			flag_process_navs=1;
			
			if navcounter > 3*mdh.UsedChannels 


			end;
		else % i.e. NOT MDH_PHASOR
			if(flag_process_navs)
				fprintf('reset nav! [%d]\n',navcounter);
				%reset navigator counter
				navcounter = 1;
                
				if(flag_fileio)
					total_channel=size(navs,5);
				else
					total_channel=size(navs,6);
				end;

%				if(ec>1) %correct for weird multiple echoes (mar. 7, 2003).
%					keyboard;
%					navs=sum(navs,4);
%					ec=1;
%				end;
				
				%project navigators from all echoes
				if(flag_fileio)
					pnavs=max(navs,[],4);
					for ecc=1:size(navs,4)
						navs(:,:,:,ecc,:)=pnavs;
					end;
				else
					pnavs=max(navs,[],5);
					for ecc=1:size(navs,5)
						navs(:,:,:,:,ecc,:)=pnavs;
					end;
				end;

				for ch=1:total_channel
					if(flag_fileio)
						if(sum(sum(abs(navs(:,:,ps,ec,ch))))>0)
						else
							navs(:,:,ps,ec,ch)=navs(:,:,1,ec,ch);
						end;
%						corrvec{ps,ec,ch}=exp(sqrt(-1.0).*angle(fft(navs(1,:,ps,ec,ch))./fft(navs(2,:,ps,ec,ch))));
%						corrvec{ps,ec,ch}=exp(sqrt(-1.0).*angle(fft( 0.5*(navs(1,:,ps,ec,ch)+ navs(3,:,ps,ec,ch)))./fft(navs(2,:,ps,ec,ch))));
					else
						if(sum(sum(abs(navs(:,:,ps,tt,ec,ch))))>0)
						else
							navs(:,:,ps,tt,ec,ch)=navs(:,:,1,tt,ec,ch);
						end;

						corrvec{ps,tt,ec,ch}=exp(sqrt(-1.0).*angle(fft(navs(1,:,ps,tt,ec,ch))./fft(navs(2,:,ps,tt,ec,ch))));
%						corrvec{ps,tt,ec,ch}=exp(sqrt(-1.0).*angle(fft( 0.5*(navs(1,:,ps,tt,ec,ch)+ navs(3,:,ps,tt,ec,ch)))./fft(navs(2,:,ps,tt,ec,ch))));
					end;
                    
				
					%determine either positive or negative phase compensation.
					if(flag_fileio)
						%nav_odd=0.5*(navs(1,:,ps,ec,ch)+ navs(3,:,ps,ec,ch));
						%nav_even=navs(2,:,ps,ec,ch);
						nav_odd=(navs(1,:,ps,1,ch));
						nav_even=navs(2,:,ps,1,ch);

						%[dummy,m]=max(abs(navs(:,:,ps,ec,ch)),[],2);
						[dummy,m]=sort(abs(navs(:,:,ps,ec,ch))');
					else
						%nav_odd=0.5*(navs(1,:,ps,tt,ec,ch)+ navs(3,:,ps,tt,ec,ch));
						%nav_even=navs(2,:,ps,tt,ec,ch);
						nav_odd=(navs(1,:,ps,tt,1,ch));
						nav_even=navs(2,:,ps,tt,1,ch);
	
						[dummy,m]=max(abs(navs(:,:,ps,ec,ch)),[],2);
						[dummy,m]=sort(abs(navs(:,:,ps,ec,ch))');
					end;
					if(mean(m(end-5:end,1))>mean(m(end-5:end,2)))
						flag_neg(ps,ec,ch)=1;
					else
						flag_neg(ps,ec,ch)=0;
					end;
				end;	
				
				flag_process_navs=0;
			end;	
		
		        if(~isempty(who('flag_neg')))
				if (mdh.EvalInfoMask(25))
					adc_data = fliplr(adc_data);
					if(flag_neg(ps,ec,mdh.ChannelId+1))
						%disp('neg');
						if(flag_fileio)
							kvol(rr, :, ps, ec, mdh.ChannelId+1) = ifft(fft(adc_data).*(corrvec{ps,ec,mdh.ChannelId+1}));
						else
							kvol(rr, :, ps, tt, ec, mdh.ChannelId+1) = ifft(fft(adc_data).*(corrvec{ps,tt,ec,mdh.ChannelId+1}));
						end;
					else
						%disp('pos');
						if(flag_fileio)
							kvol(rr, :, ps, ec, mdh.ChannelId+1) = ifft(fft(adc_data).*conj(corrvec{ps,ec,mdh.ChannelId+1}));
						else
							kvol(rr, :, ps, tt, ec, mdh.ChannelId+1) = ifft(fft(adc_data).*conj(corrvec{ps,tt,ec,mdh.ChannelId+1}));
						end;
					end;
				else
					if(flag_fileio)
						kvol(rr, :, ps, ec, mdh.ChannelId+1) = adc_data;
					else
						kvol(rr, :, ps, tt, ec, mdh.ChannelId+1) = adc_data;
					end;
				end;
			end;
		end;
        
		if DISPLAY
			if 100*counter/numADCs > PERC;
				fprintf('%d%% done\n', PERC);
				PERC = PERC + 5;
			end
		end
		counter = counter + 1;
	end;
end;
fclose(fid);

fprintf('\n');



if DISPLAY
    fprintf('elapseed time=%3.3f (sec)\n',toc);
end


