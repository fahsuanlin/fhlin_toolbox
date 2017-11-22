
function etc_prep_topo_handle(param,varargin)
global toposcalp_prep_obj;

cc=[];

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    switch lower(option_name)
        case 'c0'
            cc='c0';
        case 'cc'
            cc=option;
    end;
end;

if(isempty(cc))
    cc=get(gcf,'currentchar');
end;

switch lower(param)
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('interactive rendering commands:\n\n');
                fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
                fprintf('q: exit\n');
                fprintf('s: smooth overlay \n');
                fprintf('d: interactive threshold change\n');
                fprintf('c: switch on/off the colorbar\n');
                fprintf('u: show cluster labels from files\n');
                fprintf('\n\n fhlin@dec 25, 2014\n');
            case 's'
                fprintf('saving data...\n');
                answer = inputdlg('saving electrod info...');
                save(answer{1},'toposcalp_prep_obj');
                fprintf('[%s.mat] saved!\n',answer{1});
            case 'd'
                if(toposcalp_prep_obj.ch_idx>1)
                    toposcalp_prep_obj.ch_idx=toposcalp_prep_obj.ch_idx-1;
                    toposcalp_prep_obj.electrodes_pos(end,:)=[];
                    toposcalp_prep_obj.electrodes_vertex(end)=[];
                    delete(toposcalp_prep_obj.electrode_label_h(end));
                    toposcalp_prep_obj.electrode_label_h(end)=[];
                    delete(toposcalp_prep_obj.click_point(toposcalp_prep_obj.ch_idx));
                    toposcalp_prep_obj.click_point(toposcalp_prep_obj.ch_idx)=[];
                    
                    toposcalp_prep_obj.flag_done=0;
                    
                    fprintf('click to locate electrode [%s]]\n',toposcalp_prep_obj.electrodes{toposcalp_prep_obj.ch_idx});
                    
                end;
        end;
    case 'bd'
        if(~toposcalp_prep_obj.flag_done)
            pt=inverse_select3d(toposcalp_prep_obj.P);
            if(~isempty(pt))
                toposcalp_prep_obj.click_point(toposcalp_prep_obj.ch_idx)=plot3(pt(1),pt(2),pt(3),'.');
                
                %toposcalp_prep_obj.click_point(toposcalp_prep_obj.ch_idx)=sphere(20);
                %v=get(toposcalp_prep_obj.click_point(toposcalp_prep_obj.ch_idx),'vertex');
                %v(:,1)=v(:,1)+pt(1);
                %v(:,2)=v(:,3)+pt(2);
                %v(:,3)=v(:,3)+pt(3);
                %set(toposcalp_prep_obj.click_point(toposcalp_prep_obj.ch_idx),'facecolor','r','edgecolor','none','vertex',v);
                
                set(toposcalp_prep_obj.click_point(toposcalp_prep_obj.ch_idx),'color','r');
                toposcalp_prep_obj.electrode_label_h(toposcalp_prep_obj.ch_idx)=text(pt(1),pt(2),pt(3),toposcalp_prep_obj.electrodes{toposcalp_prep_obj.ch_idx});
                set(toposcalp_prep_obj.electrode_label_h(toposcalp_prep_obj.ch_idx),'color','y','fontname','helvetica','fontsize',18);
                
                toposcalp_prep_obj.ch_idx=toposcalp_prep_obj.ch_idx+1;
                
                [dummy,min_idx]=min(sum(abs(toposcalp_prep_obj.verts-repmat(pt(:)',[size(toposcalp_prep_obj.verts,1),1])).^2,2));
                
                toposcalp_prep_obj.electrodes_pos(toposcalp_prep_obj.ch_idx,:)=pt';
                toposcalp_prep_obj.electrodes_vertex(toposcalp_prep_obj.ch_idx)=min_idx;
                
                if(toposcalp_prep_obj.ch_idx<=length(toposcalp_prep_obj.electrodes))
                    fprintf('click to locate electrode [%s]]\n',toposcalp_prep_obj.electrodes{toposcalp_prep_obj.ch_idx});
                else
                    fprintf('DONE!\n');
                    toposcalp_prep_obj.flag_done=1;
                    
                    T=delaunayn(toposcalp_prep_obj.verts);
                    K = dsearchn(toposcalp_prep_obj.verts,T,toposcalp_prep_obj.electrodes_pos);
                    toposcalp_prep_obj.verts_os_electrode_idx=K;

                    %save electrode and head model info
                    verts=toposcalp_prep_obj.verts;
                    faces=toposcalp_prep_obj.faces;
                    fvc=toposcalp_prep_obj.fvc;
                    verts_electrode_idx=toposcalp_prep_obj.verts_os_electrode_idx;
                    save('bem.mat','verts','faces','verts_electrode_idx','fvc');

                end;
            end;
        end;
        
end;

return;