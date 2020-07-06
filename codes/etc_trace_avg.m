function etc_trace_avg()
%calcuate average

global etc_trace_obj;


if(isempty(etc_trace_obj.trigger)) return; end;
if(isempty(etc_trace_obj.trigger_now)) return; end;

%if(~etc_trace_obj.flag_trigger_avg)
IndexC = strcmp(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
trigger_match_idx = find(IndexC);
trigger_match_time_idx=etc_trace_obj.trigger.time(trigger_match_idx);
trigger_match_time_idx=sort(trigger_match_time_idx);
fprintf('[%d] trigger {%s} found at time index [%s].\n',length(trigger_match_idx),etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx));


tmp=[];
aux_tmp={};

trials=[];
aux_trials={};
for idx=1:length(etc_trace_obj.aux_data)
    aux_tmp{idx}=[];
end;
n_avg=0;

time_pre_idx=abs(round(etc_trace_obj.fs*etc_trace_obj.avg.time_pre));
time_post_idx=abs(round(etc_trace_obj.fs*etc_trace_obj.avg.time_post));

try
    hObject=findobj('tag','checkbox_avg_tfr');
    flag_tfr=get(hObject,'Value');
    hObject=findobj('tag','edit_avg_tfr_f');
    tfr_f=str2double(get(hObject,'String'));
    hObject=findobj('tag','edit_avg_tfr_cycle');
    tfr_w=str2double(get(hObject,'String'));
catch
    flag_tfr=0;
end;

%%% calculate AVG....
if(flag_tfr)
    fprintf('averaging TFR....');
else
    fprintf('averaging....');
end;
for idx=1:length(trigger_match_time_idx)
    if(~etc_trace_obj.flag_trigger_avg)
        if((trigger_match_time_idx(idx)-time_pre_idx>=1)&&(trigger_match_time_idx(idx)+time_post_idx<=size(etc_trace_obj.data,2)))
            if(isempty(tmp))
                if(etc_trace_obj.avg.flag_baseline_correct)
                    tmp=etc_trace_obj.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    tmp=tmp-repmat(mean(tmp(:,1:time_pre_idx),2),[1 size(tmp,2)]);
                else
                    tmp=etc_trace_obj.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                end;
                
                if(flag_tfr)
                    tmp=abs(inverse_waveletcoef(tfr_f,tmp,etc_trace_obj.fs,tfr_w));
                end;
                
                if(etc_trace_obj.avg.flag_trials)
                    trials(:,:,n_avg+1)=tmp;
                end;
            else
                if(etc_trace_obj.avg.flag_baseline_correct)
                    ttmp=etc_trace_obj.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]);
                    
                    if(flag_tfr)
                        ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                    end;
                    
                    tmp=tmp+ttmp;
                else
                    ttmp=etc_trace_obj.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    
                    if(flag_tfr)
                        ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                    end;
                    
                    tmp=tmp+ttmp;
                end;
                if(etc_trace_obj.avg.flag_trials)
                    trials(:,:,n_avg+1)=ttmp;
                end;
            end;
            
            for ii=1:length(etc_trace_obj.aux_data)
                if(isempty(aux_tmp{ii}))
                    if(etc_trace_obj.avg.flag_baseline_correct)
                        ttmp=etc_trace_obj.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]);
                        
                        if(flag_tfr)
                            ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                        end;
                        
                        aux_tmp{ii}=ttmp;
                    else
                        ttmp=etc_trace_obj.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        
                        if(flag_tfr)
                            ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                        end;
                        
                        aux_tmp{ii}=ttmp;
                    end;
                    if(etc_trace_obj.avg.flag_trials)
                        aux_trials{ii}(:,:,n_avg+1)=ttmp;
                    end;
                else
                    if(etc_trace_obj.avg.flag_baseline_correct)
                        ttmp=etc_trace_obj.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]);
                        
                        if(flag_tfr)
                            ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                        end;
                        
                        aux_tmp{ii}=aux_tmp{ii}+ttmp;
                    else
                        ttmp=etc_trace_obj.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        
                        if(flag_tfr)
                            ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                        end;
                        
                        aux_tmp{ii}=aux_tmp{ii}+ttmp;
                    end;
                    if(etc_trace_obj.avg.flag_trials)
                        aux_trials{ii}(:,:,n_avg+1)=ttmp;
                    end;
                end;
            end;
            
            %figure(10);
            %subplot(211); plot(etc_trace_obj.data(1:31,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx)'); subplot(212); plot(etc_trace_obj.aux_data{idx}(1:31,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx)');
            
            n_avg=n_avg+1;
        end;
    else
        if((trigger_match_time_idx(idx)-time_pre_idx>=1)&&(trigger_match_time_idx(idx)+time_post_idx<=size(etc_trace_obj.buffer.data,2)))
            if(isempty(tmp))
                if(etc_trace_obj.avg.flag_baseline_correct)
                    tmp=etc_trace_obj.buffer.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    tmp=tmp-repmat(mean(tmp(:,1:time_pre_idx),2),[1 size(tmp,2)]);
                else
                    tmp=etc_trace_obj.buffer.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                end;
                
                if(flag_tfr)
                    tmp=abs(inverse_waveletcoef(tfr_f,tmp,etc_trace_obj.fs,tfr_w));
                end;
                
                if(etc_trace_obj.avg.flag_trials)
                    trials(:,:,n_avg+1)=tmp;
                end;
            else
                if(etc_trace_obj.avg.flag_baseline_correct)
                    ttmp=etc_trace_obj.buffer.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]);
                    
                    if(flag_tfr)
                        ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                    end;
                    
                    tmp=tmp+ttmp;
                else
                    ttmp=etc_trace_obj.buffer.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    
                    if(flag_tfr)
                        ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                    end;
                    
                    tmp=tmp+ttmp;
                end;
                if(etc_trace_obj.avg.flag_trials)
                    trials(:,:,n_avg+1)=ttmp;
                end;
            end;
            
            for ii=1:length(etc_trace_obj.buffer.aux_data)
                if(isempty(aux_tmp{ii}))
                    if(etc_trace_obj.avg.flag_baseline_correct)
                        ttmp=etc_trace_obj.buffer.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]);
                        
                        if(flag_tfr)
                            ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                        end;
                        
                        aux_tmp{ii}=ttmp;
                    else
                        ttmp=etc_trace_obj.buffer.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        
                        if(flag_tfr)
                            ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                        end;
                        
                        aux_tmp{ii}=ttmp;
                    end;
                    if(etc_trace_obj.avg.flag_trials)
                        aux_trials{ii}(:,:,n_avg+1)=ttmp;
                    end;
                else
                    if(etc_trace_obj.avg.flag_baseline_correct)
                        ttmp=etc_trace_obj.buffer.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]);
                        
                        if(flag_tfr)
                            ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                        end;
                        
                        aux_tmp{ii}=aux_tmp{ii}+ttmp;
                    else
                        ttmp=etc_trace_obj.buffer.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        
                        if(flag_tfr)
                            ttmp=abs(inverse_waveletcoef(tfr_f,ttmp,etc_trace_obj.fs,tfr_w));
                        end;
                        
                        aux_tmp{ii}=aux_tmp{ii}+ttmp;
                    end;
                    if(etc_trace_obj.avg.flag_trials)
                        aux_trials{ii}(:,:,n_avg+1)=ttmp;
                    end;
                end;
            end;
            
            n_avg=n_avg+1;
        end;
    end;
end;
tmp=tmp./n_avg;
for idx=1:length(etc_trace_obj.aux_data)
    aux_tmp{idx}=aux_tmp{idx}./n_avg;
end;
fprintf('[%d] trials averaged...\n',n_avg);
etc_trace_obj.avg.n_avg=n_avg;


if(etc_trace_obj.avg.flag_z)
    if(~isempty(time_pre_idx))
        try
            tmp=etc_z(tmp,1:time_pre_idx,'flag_baseline_correct',1);
            
            for idx=1:length(etc_trace_obj.aux_data)
                aux_tmp{idx}=etc_z(aux_tmp{idx},1:time_pre_idx,'flag_baseline_correct',1);
            end;
        catch ME
            fprintf('error in calculating the Z scores...\n');
            return;
        end;
    else
        fprintf('no baseline. error in calculating the z-scores!\n'); return;
    end;
end;

etc_trace_obj.avg.trials=trials;
etc_trace_obj.avg.aux_trials=aux_trials;

if(~etc_trace_obj.flag_trigger_avg)
    %update data
    etc_trace_obj.buffer.data=etc_trace_obj.data;
    etc_trace_obj.buffer.aux_data=etc_trace_obj.aux_data;
    etc_trace_obj.buffer.aux_data_name=etc_trace_obj.aux_data_name;
    etc_trace_obj.buffer.aux_data_idx=etc_trace_obj.aux_data_idx;
    etc_trace_obj.buffer.trigger_now=etc_trace_obj.trigger_now;
    etc_trace_obj.buffer.trigger=etc_trace_obj.trigger;
    etc_trace_obj.buffer.time_begin=etc_trace_obj.time_begin;
    etc_trace_obj.buffer.time_select_idx=etc_trace_obj.time_select_idx;
    etc_trace_obj.buffer.time_window_begin_idx=etc_trace_obj.time_window_begin_idx;
    etc_trace_obj.buffer.time_duration_idx=etc_trace_obj.time_duration_idx;
    etc_trace_obj.buffer.ylim=etc_trace_obj.ylim;
end;

etc_trace_obj.data=tmp;
etc_trace_obj.aux_data=aux_tmp;
%etc_trace_obj.trigger=[];
etc_trace_obj.time_begin=-abs(etc_trace_obj.avg.time_pre);
etc_trace_obj.time_select_idx=1;
etc_trace_obj.time_window_begin_idx=1;

hObject=findobj('tag','listbox_time_duration');
contents = cellstr(get(hObject,'String'));
ii=round(cellfun(@str2num,contents).*etc_trace_obj.fs);
[dummy,vv]=min(abs(ii-size(etc_trace_obj.data,2)));
etc_trace_obj.time_duration_idx=round(str2num(contents{vv})*etc_trace_obj.fs);

etc_trcae_gui_update_time;


hObject=findobj('tag','checkbox_trigger_avg');
set(hObject,'Value',1);

hObject=findobj('tag','listbox_trigger');
set(hObject,'Enable','off');
hObject=findobj('tag','pushbutton_trigger_rr');
set(hObject,'Enable','off');
hObject=findobj('tag','pushbutton_trigger_ff');
set(hObject,'Enable','off');
hObject=findobj('tag','edit_trigger_time_idx');
set(hObject,'Enable','off');
hObject=findobj('tag','edit_trigger_time');
set(hObject,'Enable','off');

etc_trace_obj.flag_trigger_avg=1;
%end;