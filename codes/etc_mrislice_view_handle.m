function etc_mrislice_view_handle(param,varargin)

global etc_mrislice_view;

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
    case 'redraw'
        redraw(varargin{1});
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('interactive rendering commands:\n\n');
                fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
                fprintf('q: exit\n');
                fprintf('g: GUI\n');
                fprintf('c: switch on/off the colorbar\n');
                fprintf('\n\n fhlin@oct. 6 2017\n');
            case 'a'
                fprintf('archiving...\n');
                fn=sprintf('etc_mrislice_view.tif');
                fprintf('saving [%s]...\n',fn);
                print(fn,'-dtiff');
            case 'q'
                fprintf('\nterminating graph!\n');
                for f_idx=1:length(etc_mrislice_view.img)
                    etc_delete(etc_mrislice_view.fig_vol(f_idx));
                    etc_delete(etc_mrislice_view.fig_img(f_idx));
                end;
            case 'r'
                fprintf('\nredrawing...\n');
                redraw;
            case 'g'
                %fprintf('\nGUI...\n');
                for i=1:length(etc_mrislice_view.fig_vol)
                    if(gcf==etc_mrislice_view.fig_vol(i))
                            if(isgraphics(etc_mrislice_view.fig_gui(i)))
                                flag_new=0;
                            else
                                flag_new=1;
                                etc_mrislice_view.f_idx=i;
                            end;
                        if(flag_new)
                            etc_mrislice_view.fig_gui(i)=etc_mrislice_view_gui;
                            set(etc_mrislice_view.fig_gui(i),'userdata',i); %use the 'userdata'field to index the data entry
                            set(etc_mrislice_view.fig_gui(i),'unit','pixel');
                            pos=get(etc_mrislice_view.fig_gui(i),'pos');
                            pos_vol=get(etc_mrislice_view.fig_vol(i),'pos');
                            set(etc_mrislice_view.fig_gui(i),'pos',[pos_vol(1)-pos(3), pos_vol(2), pos(3), pos(4)]);
                        else
                            figure(etc_mrislice_view.fig_gui(i));
                        
                        end;

                        figure(etc_mrislice_view.fig_vol(i));
                        
                        break;
                    end;
                end;
                
            otherwise
                %fprintf('pressed [%c]!\n',cc);
        end;
    case 'bd'
        for f_idx=1:length(etc_mrislice_view.img)
            if(gcf==etc_mrislice_view.fig_vol(f_idx))
                
                figure(etc_mrislice_view.fig_vol(f_idx));
                break;
            elseif(gcf==etc_mrislice_view.fig_img(f_idx))
                
                figure(etc_mrislice_view.fig_img(f_idx));
                break;
            end;
        end;
end;

return;



function draw_pointer()

return;


function draw_stc()

return;

function redraw(f_idx)
global etc_mrislice_view;

%for f_idx=1:length(etc_mrislice_view.img)
    figure(etc_mrislice_view.fig_vol(f_idx));
    
    xd = etc_mrislice_view.hsp(f_idx).XData;
    yd = etc_mrislice_view.hsp(f_idx).YData;
    zd = etc_mrislice_view.hsp(f_idx).ZData;
    
    figure(etc_mrislice_view.fig_vol(f_idx));
    %etc_delete(etc_mrislice_view.h_slice(f_idx));
    delete(etc_mrislice_view.h_slice(f_idx));
    [x,y,z]=meshgrid(([1:size(etc_mrislice_view.img{f_idx},1)]-1-size(etc_mrislice_view.img{f_idx},1)/2).*etc_mrislice_view.vox_dim{f_idx}(1),([1:size(etc_mrislice_view.img{f_idx},2)]-1-size(etc_mrislice_view.img{f_idx},2)/2).*etc_mrislice_view.vox_dim{f_idx}(2),([1:size(etc_mrislice_view.img{f_idx},3)]-1-size(etc_mrislice_view.img{f_idx},3)/2).*etc_mrislice_view.vox_dim{f_idx}(3));
    etc_mrislice_view.h_slice(f_idx)=slice(x,y,z,double(etc_mrislice_view.img{f_idx}),xd,yd,zd);
    set(etc_mrislice_view.h_slice(f_idx),'edgecolor','none');
        
    figure(etc_mrislice_view.fig_img(f_idx));
    
    pos1=get(etc_mrislice_view.fig_vol(f_idx),'pos');
    pos2=get(etc_mrislice_view.fig_img(f_idx),'pos');
    pos2(1)=pos1(1)+pos1(3);
    set(etc_mrislice_view.fig_img(f_idx),'pos',pos2);
    imagesc(get(etc_mrislice_view.h_slice(f_idx),'cdata'))
    colormap(gray);
    set(gca,'pos',[0 0 1 1]);
    set(etc_mrislice_view.fig_img(f_idx),'color','k');
    axis off image;
    
    
    %set focus back to volume
    figure(etc_mrislice_view.fig_vol(f_idx));
   
    
%end;




return;


