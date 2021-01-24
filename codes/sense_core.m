function [recon_reg, reg_lambda, recon_unreg, g_factor_reg, g_factor_unreg, x_lambda, x_unreg, recon_ref, reg_bg_psd,unreg_bg_psd, reg_bg_var, unreg_bg_var]=sense_core(varargin);

OBS=[];
flag_ivs=0;
flag_sep=0;
obs={};
ref={};
a=[];
profile_opt={};
prior=[];

recon_reg=[];
recon_unreg=[];
reg_lambda={};

flag_reg=1;
flag_unreg=1;
flag_bg=0;
flag_bg_psd=0;
reg_lambda=[];

A_total=[];
U=[];
S=[];
V=[];
reg_bg_psd=[];
reg_bg_var=[];
unreg_bg_psd=[];
unreg_bg_var=[];

flag_whiten=0;

recon_channel_weight=[];

flag_real_est=0;

flag_display=0;

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
    case 'profile'
        profile_opt=option_value;
    case 'prior'
        prior=option_value;
    case 'flag_ivs'
        flag_ivs=option_value;
    case 'alias_factor'
        alias_factor=option_value;
    case 'flag_reg'
        flag_reg=option_value;
    case 'flag_unreg'
        flag_unreg=option_value;
    case 'flag_bg'
    	flag_bg=option_value;    
    case 'flag_bg_psd'
    	flag_bg_psd=option_value;
    case 'flag_whiten'
        flag_whiten=option_value;
    case 'flag_display'
	flag_display=option_value;
    case 'reg_lambda'
        reg_lambda=option_value;
    case 'u'
        U=option_value;
    case 's'
        S=option_value;
    case 'v'
        V=option_value;
    case 'a_total'
        A_total=option_value;
    case 'flag_sep'
	flag_sep=option_value;
    case 'recon_channel_weight'
	recon_channel_weight=option_value;
    case 'flag_real_est'
        flag_real_est=option_value;
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
		g_factor_unreg{ss,tt}=zeros(size(a,2),size(OBS{1},2));
		g_factor_reg{ss,tt}=zeros(size(a,2),size(OBS{1},2));
		x_unreg{ss,tt}=zeros(size(a,2),size(OBS{1},2));
		x_lambda{ss,tt}=zeros(size(a,2),size(OBS{1},2));

		for i=1:size(ref{1,1,1},2)
		    if(isempty(U)|isempty(S)|isempty(V)|isempty(A_total))
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
				A=[A;a.*repmat(transpose(rr(:,i)),[size(a,1),1])];
				a_dummy=[a_dummy; a];
    			end;
    			MODEL(:,i)=A*prior{ss,tt}(:,i);
			end;    
			if(flag_sep)
          			%whitening
				if(flag_whiten)
					A_white=A.*repmat(1.*(sqrt(OBS{ss,tt}(:,i).*conj(OBS{ss,tt}(:,i)))),[1,size(A,2)]);
					OBS_white=OBS{ss,tt}(:,i).*(1.*(sqrt(OBS{ss,tt}(:,i).*conj(OBS{ss,tt}(:,i)))));
				else
					A_white=A;
					OBS_white=OBS{ss,tt}(:,i);
				end;

                		if(flag_real_est)
                    			A_white=cat(1,real(A_white),imag(A_white));
                    			OBS_white=cat(1,real(OBS_white),imag(OBS_white));
                		end;
                		A_white_idx=zeros(size(A_white));
                		A_white_idx(find(a_dummy))=1;

				obs_idx=zeros(1,size(A_white,1));
                
				for jj=1:size(A_white,1)
					if(~obs_idx(jj))
						if(flag_display)
							fprintf('.');
						end;
						obs_idx(jj)=1;
						row_idx=find(sum(abs(A_white_idx-repmat(A_white_idx(jj,:),[size(A_white_idx,1),1])),2)==0);
						col_idx=find(A_white_idx(jj,:));
						obs_idx(row_idx)=1;

						A_partial=A_white(row_idx,col_idx);
						[u,s,v]=svd(A_partial,0);
						s=diag(s);

						if(flag_bg|flag_bg_psd)
							for kk=1:size(A_partial,2)
								for pp=1:size(A_partial,1)
									for qq=1:size(A_partial,1)
										RR(pp,qq,kk)=0;
										for ll=1:size(A_partial,2)
											RR(pp,qq,kk)=RR(pp,qq,kk)+(kk-ll).^2*A_partial(pp,ll)*conj(A_partial(qq,ll));	
										end;
									end;
								end;
							end;
						end;
								
						if(flag_reg)
							if(~flag_bg)
[x_lambda{ss,tt}(col_idx,i)] = my_tikhonov(u,s,v,OBS_white(row_idx),reg_lambda{ss,tt}(i,jj),prior{ss,tt}(col_idx,i));

								f=(s.^2+reg_lambda{ss,tt}(i,jj).^2')./s;
								g_factor_reg{ss,tt}(col_idx,i)=sqrt(diag((v.*repmat(f'.^(-2),[size(v,1),1]))*v').*diag((v.*repmat(s'.^(2),[size(v,1),1]))*v'));
								est_inv_lcurve{ss,tt}(row_idx,i)=A_partial*x_lambda{ss,tt}(col_idx,i);
								WW=pinv(A_partial'*A_partial)*A_partial';
								
								if(flag_bg_psd)
									for kk=1:size(A_partial,2)
										reg_bg_psd{ss,tt}(col_idx(kk),i)=WW(kk,:)*RR(:,:,kk)*WW(kk,:)';
										reg_bg_var{ss,tt}(col_idx(kk),i)=WW(kk,:)*WW(kk,:)';
									end;
								end;
							else
								AA=sum(A_partial,2);
								for kk=1:size(A_partial,2)
									TT=inv(RR(:,:,kk)+reg_lambda{ss,tt}(i,jj).*eye(size(RR(:,:,kk),1)))*AA;
									x_lambda{ss,tt}(col_idx(kk),i)=(OBS_white(row_idx)'*TT)./(AA'*TT);
									
									if(flag_bg_psd)
										reg_bg_psd{ss,tt}(col_idx(kk),i)=(TT./(AA'*TT))'*RR(:,:,kk)*(TT./(AA'*TT));
										reg_bg_var{ss,tt}(col_idx(kk),i)=(TT./(AA'*TT))'*(TT./(AA'*TT));
									end;
								end;
								g_factor_reg{ss,tt}(col_idx,i)=sqrt(reg_bg_var{ss,tt}(col_idx,i).*diag((v.*repmat(s'.^(2),[size(v,1),1]))*v'));
							end;
						end;

				    		if(flag_unreg)
				    			if(~flag_bg)
								WW=pinv(A_partial'*A_partial)*A_partial';

								x_unreg{ss,tt}(col_idx,i)=WW*OBS_white(row_idx);

								g_factor_unreg{ss,tt}(col_idx,i)=sqrt(diag((v.*repmat(s'.^(-2),[size(v,1),1]))*v').*diag((v.*repmat(s'.^(2),[size(v,1),1]))*v'));
								
								if(flag_bg_psd)
									for kk=1:size(A_partial,2)
										unreg_bg_psd{ss,tt}(col_idx(kk),i)=WW(kk,:)*RR(:,:,kk)*WW(kk,:)';
										unreg_bg_var{ss,tt}(col_idx(kk),i)=WW(kk,:)*WW(kk,:)';
									end;
								end;
							else
								AA=sum(A_partial,2);
								for kk=1:size(A_partial,2)
									TT=pinv(RR(:,:,kk))*AA;
									x_unreg{ss,tt}(col_idx(kk),i)=(OBS_white(row_idx)'*TT)./(AA'*TT);
									
									if(flag_bg_psd)
										unreg_bg_psd{ss,tt}(col_idx(kk),i)=(TT./(AA'*TT))'*RR(:,:,kk)*(TT./(AA'*TT));
										unreg_bg_var{ss,tt}(col_idx(kk),i)=(TT./(AA'*TT))'*(TT./(AA'*TT));
									end;
								end;
								g_factor_unreg{ss,tt}(col_idx,i)=sqrt(unreg_bg_var{ss,tt}(col_idx,i).*diag((v.*repmat(s'.^(2),[size(v,1),1]))*v'));
							end;
						end;  				
					end;
				end;
				if(flag_display) fprintf('line [%02d|%02d] completed\n',i,size(A,2)); end;
			else
        			%whitening
				if(flag_whiten)
					A_white=A.*repmat(1./(sqrt(OBS{ss,tt}(:,i).*conj(OBS{ss,tt}(:,i)))),[1,size(A,2)]);
					OBS_white=OBS{ss,tt}(:,i).*(1./(sqrt(OBS{ss,tt}(:,i).*conj(OBS{ss,tt}(:,i)))));
				else
					A_white=A;
					OBS_white=OBS{ss,tt}(:,i);
				end;
                		if(flag_real_est)
                    			A_white=cat(1,real(A_white),imag(A_white));
                    			OBS_white=cat(1,real(OBS_white),imag(OBS_white));
                		end;
                		[u,s,v] = svd(A_white,0);
				s = diag(s); 
				if(flag_reg)
					%using regularization?
					if(isempty(reg_lambda))
  	                  			if(~isempty(profile_opt))
					    		[reg_lambda,reg_param]=sense_reg('ref',ref,'obs',OBS,'a',a,'flag_ivs',flag_ivs,'profile',profile_opt,'prior',prior,'flag_reg_lcurve',1);   
    	                			else
				 	   		[reg_lambda,reg_param]=sense_reg('ref',ref,'obs',OBS,'a',a,'flag_ivs',flag_ivs,'prior',prior,'flag_reg_lcurve',1);   
      		              			end;
					end;

					%Tikhonov regularization reconstruction
					if(flag_display) fprintf('Tikhnonov regularization recon...\n'); end;
					[x_lambda{ss,tt}(:,i)] = my_tikhonov(u,s,v,OBS_white,reg_lambda{ss,tt}(i),prior{ss,tt}(:,i));

	                		f=(s.^2+reg_lambda{ss,tt}(i).^2')./s;
 	 	              		g_factor_reg{ss,tt}(:,i)=sqrt(diag((v.*repmat(f'.^(-2),[size(v,1),1]))*v').*diag((v.*repmat(s'.^(2),[size(v,1),1]))*v'));
  	 				
					est_inv_lcurve{ss,tt}(:,i)=A_white*x_lambda{ss,tt}(:,i);
				end;
				
				if(flag_unreg)
					x_unreg{ss,tt}(:,i)=pinv(A_white'*A_white)*A_white'*OBS_white;

					g_factor_unreg{ss,tt}(:,i)=sqrt(diag((v.*repmat(s'.^(-2),[size(v,1),1]))*v').*diag((v.*repmat(s'.^(2),[size(v,1),1]))*v'));
				end;

				if(flag_display) fprintf('[%d|%d]...reg=[%4.4f]\n',i,size(ref{1,1,1},2),reg_lambda{ss,tt}(i)); end;
			end;

			if(flag_display)
				figure(1);
				subplot(221);
				plot([1:size(A_white,1)],real(A_white*x_lambda{ss,tt}(:,i)),'k',[1:size(A_white,1)],real(A_white*prior{ss,tt}(:,i)),'r',[1:size(OBS_white,1)],real(OBS_white),'b');
				legend({'reg. model','prior model','meas.'});
				title('measurement difference-real');
				subplot(222);
				plot([1:size(A_white,1)],real(A_white*x_lambda{ss,tt}(:,i)),'k',[1:size(A_white,1)],imag(A_white*prior{ss,tt}(:,i)),'r',[1:size(OBS_white,1)],imag(OBS_white),'b');
				legend({'reg. model','prior model','meas.'});				
				title('measurement difference-imag');
				subplot(223);
				plot([1:size(prior{ss,tt},1)],real(prior{ss,tt}(:,i)),'r',[1:size(x_lambda{ss,tt},1)],real(x_lambda{ss,tt}(:,i)),'b');
				legend('prior','reg. recon.');				
				title('prior difference-real');
				subplot(224);
				plot([1:size(prior{ss,tt},1)],imag(prior{ss,tt}(:,i)),'r',[1:size(x_lambda{ss,tt},1)],imag(x_lambda{ss,tt}(:,i)),'b');
				legend('prior','reg. recon.');				
				title('prior difference-imag');
			end;
		end;

		if(isempty(recon_channel_weight))
			recon_channel_weight=ones(1,size(ref,1));
		end;

		recon_reg{ss,tt}=zeros(size(ref{1,ss,tt}));
		for i=1:size(ref,1)
			if(flag_ivs)
				recon_reg{ss,tt}=recon_reg{ss,tt}+recon_channel_weight(i).*abs(ref{i,ss,tt}.*x_lambda{ss,tt}).^2;
			else
				recon_reg{ss,tt}=recon_reg{ss,tt}+recon_channel_weight(i).*abs(profile_opt{i,ss,tt}.*x_lambda{ss,tt}).^2;
			end;
		end;
		recon_reg{ss,tt}=sqrt(recon_reg{ss,tt});

		recon_unreg{ss,tt}=zeros(size(ref{1,ss,tt}));
		for i=1:size(ref,1)
			if(flag_ivs)
				recon_unreg{ss,tt}=recon_unreg{ss,tt}+recon_channel_weight(i).*abs(ref{i,ss,tt}.*x_unreg{ss,tt}).^2;
			else
				recon_unreg{ss,tt}=recon_unreg{ss,tt}+recon_channel_weight(i).*abs(profile_opt{i,ss,tt}.*x_unreg{ss,tt}).^2;
			end;
		end;
		recon_unreg{ss,tt}=sqrt(recon_unreg{ss,tt});

		recon_ref{ss,tt}=zeros(size(ref{1,ss,tt}));
		for i=1:size(ref,1)
			if(flag_ivs)
				recon_ref{ss,tt}=recon_ref{ss,tt}+recon_channel_weight(i).*abs(ref{i,ss,tt}).^2;
			else
				recon_ref{ss,tt}=recon_ref{ss,tt}+recon_channel_weight(i).*abs(ref{i,ss,tt}).^2;
			end;
		end;
		recon_ref{ss,tt}=sqrt(recon_ref{ss,tt});

		subplot(223)
		imagesc(abs(recon_reg{ss,tt}));
		title('recon (inv-l-curve)');
		axis off image;

		subplot(224)
		imagesc(abs(recon_unreg{ss,tt}));
		title('recon');
		axis off image;
	end;
end;

if(flag_display)
	fprintf('SENSE Recon done!\n');
end;
