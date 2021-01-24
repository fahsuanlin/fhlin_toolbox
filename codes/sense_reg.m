function [cc064, reg_param, U, S, V, s_prime,s_least]=sense_reg(varargin);

OBS=[];
flag_ivs=0;
flag_sep=0;
obs={};
ref={};
a=[];
profile_opt={};
prior=[];

recon_inv_lcurve=[];
recon_unreg=[];
cc064=[];
reg_param=[];


flag_reg_lcurve=0;
flag_reg_gcv=0;
flag_reg_snr=0;

A_total=[];
U=[];
S=[];
V=[];

C=[];
sig2=[];

s_prime={};
s_least={};
flag_sep=0;

flag_whiten=1;

flag_real_est=0;


flag_log=0;
file_log=[];

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
	case 'obs'
		OBS=option_value;
	case 'ref'
		ref=option_value;
	case 'a'
		a=option_value;
	case 'c'
		C=option_value;
	case 'sig2'
		sig2=option_value;
	case 'profile'
		profile_opt=option_value;
	case 'prior'
		prior=option_value;
	case 'flag_ivs'
		flag_ivs=option_value;
	case 'flag_reg_lcurve'
		flag_reg_lcurve=option_value;
	case 'flag_reg_gcv'
		flag_reg_gcv=option_value;
	case 'flag_reg_snr'
		flag_reg_snr=option_value;
	case 'flag_whiten'
		flag_whiten=option_value;
	case 'flag_sep',
		flag_sep=option_value;
	case 'flag_real_est'
		flag_real_est=option_value;
	case 'flag_log',
		flag_log=option_value;
	otherwise
		fprintf('unknown option [%s]!\n',option);
		fprintf('error!\n');
		return;
	end;
end;


time=[1:size(OBS,4)];
slice=[1:size(OBS,3)];

%iterative regularized reconstruction

for tt=1:length(time)
	for ss=1:length(slice)
		for i=1:size(ref{1,1,1},2)
  			% reconstruction preparation
			A=[];
			a_dummy=[];
			for j=1:size(ref,1)
				if(flag_ivs)
					rr=ref{j,ss,tt};
				else
					rr=profile_opt{j,ss,tt};
					rr(find(rr==0))=min(rr(find(rr)));
				end;
        
				ref_ss{ss,tt}=zeros(size(rr));

				A=[A;a.*repmat(transpose(rr(:,i)),[size(a,1),1])];
        		        a_dummy=[a_dummy;a];
                
				ref_ss{ss,tt}=ref_ss{ss,tt}+abs(ref{j,ss,tt}).^2;
			end;
    
			MODEL{ss,tt}(:,i)=A*prior{ss,tt}(:,i);
    
			%whitening
			if(flag_whiten)
%				A_white=A.*repmat(1./(sqrt(OBS{ss,tt}(:,i).*conj(OBS{ss,tt}(:,i)))),[1,size(A,2)]);
%				OBS_white=OBS{ss,tt}(:,i).*(1./(sqrt(OBS{ss,tt}(:,i).*conj(OBS{ss,tt}(:,i)))));
				A_white=A.*repmat(1.*(sqrt(OBS{ss,tt}(:,i).*conj(OBS{ss,tt}(:,i)))),[1,size(A,2)]);
				OBS_white=OBS{ss,tt}(:,i).*(1.*(sqrt(OBS{ss,tt}(:,i).*conj(OBS{ss,tt}(:,i)))));
			else
				A_white=A;
				OBS_white=OBS{ss,tt}(:,i);
			end;

			if(flag_real_est)
				A_white=cat(1,real(A_white),imag(A_white));
				OBS_white=cat(1,real(OBS_white),imag(OBS_white));
				a_dummy=cat(1,a_dummy,a_dummy);
			end;
		
			if(flag_sep)

				A_white_idx=zeros(size(A_white));
				A_white_idx(find(a_dummy))=1;
                
				obs_idx=zeros(1,size(A_white,1));
				fprintf('regularization [%d|%d]',i,size(ref{1},2));
				
				for jj=1:size(A_white,1)
					if(~obs_idx(jj))
						obs_idx(jj)=1;
                        
						row_idx=find(sum(abs(A_white_idx-repmat(A_white_idx(jj,:),[size(A_white_idx,1),1])),2)==0);
						col_idx=find(A_white_idx(jj,:));
                        
						obs_idx(row_idx)=1;
                   
						A_partial=A_white(row_idx,col_idx);
						
						[u,s,v]=svd(A_partial,0);
						s=diag(s);
						s_prime{ss,tt}(i,jj)=max(s);
						s_least{ss,tt}(i,jj)=min(s);

						if(flag_reg_lcurve)
							%fprintf('L-curve regularization [%d|%d]\n',i,size(ref{1},2));
							file_log=sprintf('lcurve_slice%03d_time%03d_line%03d_%03d.mat',ss,tt,i,jj);
							[cc064{ss,tt}(i,jj),rho_inv_lcurve{ss,tt}(:,i,jj),eta_inv_lcurve{ss,tt}(:,i,jj),reg_param{ss,tt}(:,i,jj)]=inverse_lcurve(u,s,OBS_white(row_idx),'prior',prior{ss,tt}(col_idx,i),'V',v,'log_idx',i,'flag_log',flag_log,'file_log',file_log);
 		   				end;

						if(flag_reg_gcv)
							%fprintf('GCV regularization [%d|%d]\n',i,size(ref{1},2));
							[cc064{ss,tt}(i,jj),reg_param{ss,tt}(:,i,jj)]=gcv(u,s,OBS_white(row_idx),'tikh');
 						end;
							
						if(flag_reg_snr)
							if(isempty(sig2))
								fprintf('ERROR! using SNR as regularization must provide noise level estimates (sig2)!\n');
								fprintf('\n');
								return;
							end;
							%fprintf('SNR regularization [%d|%d]\n',i,size(ref{1},2));        
							%if(isempty(C))
								C=eye(size(A_partial,1)).*sig2;
							%end;
							[u_c,s_c,v_c]=svd(C);
							power_noise=trace(C);
							power_signal=trace(A_partial*A_partial');
							mm=sqrt(pinv(s_c))*u_c'*OBS_white(row_idx);
							snr=abs(sum(mm.^2)./length(OBS_white(row_idx)));
							
							cs2=cumsum(s.^2);
							idx=find((cs2(end)-cs2(1:end-1))>0);
							num=cs2(1:end-1);
							den=(cs2(end)-cs2(1:end-1));
							snr_spectrum=inf.*ones(1,length(num));
							snr_spectrum=num(idx)./den(idx);

							idx=min(find(snr_spectrum>snr));
							if(isempty(idx))
								idx=length(s);
							end;
							if(idx>length(s))
								idx=length(s);
							elseif(idx<1)
								idx=1;
							end;


							cc064{ss,tt}(i,jj)=s(idx);



							%cc064{ss,tt}(i,jj)=real(power_signal./power_noise./(abs(sum(mm.^2)./length(OBS_white(row_idx)))));

							%fprintf('s_prime=%3.3f reg_labmda=%3.3f\n',s_prime{ss,tt}(i,jj),cc064{ss,tt}(i,jj));
						end;
						fprintf('.');
					end;
				end;
				fprintf('\n');
			else
				%determine regularization constant
				[u,s,v]=svd(A_white,0);
				
				s=diag(s);
				s_prime{ss,tt}(i)=max(s);
				s_least{ss,tt}(i)=min(s);

				if(flag_reg_lcurve)
					fprintf('L-curve regularization [%d|%d]\n',i,size(ref{1},2));
					file_log=sprintf('lcurve_slice%03d_time%03d_line%03d.mat',ss,tt,i);
					xx=max(find((s)));
					u=u(:,1:xx);
					s=s(1:xx);
					v=v(:,1:xx);
					[cc064{ss,tt}(i),rho_inv_lcurve{ss,tt}(:,i),eta_inv_lcurve{ss,tt}(:,i),reg_param{ss,tt}(:,i)]=inverse_lcurve(u,s,OBS_white,'prior',prior{ss,tt}(:,i),'V',v,'log_idx',i,'flag_log',flag_log,'file_log',file_log);
 		   		end;
	
				if(flag_reg_gcv)
					fprintf('GCV regularization [%d|%d]\n',i,size(ref{1},2));
					[cc064{ss,tt}(i),reg_param{ss,tt}(:,i)]=gcv(u,s,OBS_white,'tikh');
 				end;
    
				if(flag_reg_snr)
					fprintf('SNR regularization [%d|%d]\n',i,size(ref{1},2));        
					%[cc064(i)]=inverse_lcurve(u,s,OBS(:,i),'prior',prior(:,i),'V',v);
					
					if(isempty(sig2))
							fprintf('ERROR! using SNR as regularization must provide noise level estimates (sig2)!\n');
							fprintf('\n');
							return;
					end;
					
					%fprintf('SNR regularization [%d|%d]\n',i,size(ref{1},2));        
					%if(isempty(C))
						C=eye(size(A_white,1)).*sig2;
					%end;
					
					[u_c,s_c,v_c]=svd(C);
					power_noise=trace(C);
					power_signal=trace(A_white*A_white');
					mm=sqrt(pinv(s_c))*u_c'*OBS_white;
					snr=abs(sum(mm.^2)./length(OBS_white));
							
					cs2=cumsum(s.^2);
					snr_spectrum=cs2(1:end-1)./(cs2(end)-cs2(1:end-1));
					idx=min(find(snr_spectrum>snr));
					if(isempty(idx))
						idx=length(s);
					end;
					if(idx>length(s))
						idx=length(s);
					elseif(idx<1)
						idx=1;
					end;

					cc064{ss,tt}(i)=s(idx);
   				end;
			end;
		end;
	end;
end;

%save temp.mat ps pn ll


fprintf('DONE!\n');
