function pepsi_view_handle(param)
global pepsi_figure;
global pepsi_pointer;
global pepsi_spectrum_pointer;
global pepsi_pointer_handle;
global pepsi_ref_threshold;
global pepsi_data;
global pepsi_legend;
global pepsi_type;
global pepsi_now_zoomin;
global pepsi_axis_fullx;
global pepsi_axis_fully;
global pepsi_axis_image;
global pepsi_axis_spectrum;
global pepsi_gca;

cc=get(gcf,'currentchar');

switch lower(param)
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('pepsi view:\n\n');
                fprintf('q: exit pepsi_view\n');
                fprintf('\n\n fhlin@sep 10, 2004\n');
            case 'q'
                fprintf('\nterminating graph!\n');
                close_all;
            case 't'
                ButtonName=lower(inputdlg('spectrum type','',1,{sprintf('%s',pepsi_type)}));
                if(strmatch(ButtonName,strvcat('real')))
                    disp('spectrum in REAL');
                    redraw_all;
                    pepsi_type='real';
                elseif(strmatch(ButtonName,strvcat('imag')))
                    disp('spectrum in IMAG');
                    redraw_all;
                    pepsi_type='imag';
                elseif(strmatch(ButtonName,strvcat('abs')))
                    disp('spectrum in ABS');
                    redraw_all;
                    pepsi_type='abs';
                elseif(strmatch(ButtonName,strvcat('angle')))
                    disp('spectrum in ANGLE');
                    redraw_all;
                    pepsi_type='angle';
                else
                    fprintf(spritf('spectrum in %s',upper(pepsi_type)));
                    
                end
            case 'd'
                fprintf('change threshold...\n');
                fprintf('current threshold = %s\n',mat2str(pepsi_ref_threshold));
                def={num2str(pepsi_ref_threshold)};
                answer=inputdlg('change threshold',sprintf('current threshold = %s',mat2str(pepsi_ref_threshold)),1,def);
                if(~isempty(answer))
                    pepsi_ref_threshold=str2num(answer{1});
                    fprintf('updated threshold = %s\n',mat2str(pepsi_ref_threshold));
                    redraw_all;
                end;
            case 'z'
                subplot(212);
                if(pepsi_now_zoomin)
                    fprintf('zoom in...\n');
                    pepsi_axis_fullx=get(gca,'xlim');
                    pepsi_axis_fully=get(gca,'ylim');
                    %set(gca,'xlim',[1.5 4]);
                    set(gca,'xlim',[6 8]); ylim('auto');
                    pepsi_now_zoomin=0;
                else
                    fprintf('zoom out...\n');
                    set(gca,'xlim',pepsi_axis_fullx);
                    pepsi_now_zoomin=1;
                end;
            case 'm'
                subplot(212);
                fprintf('plotting markers...\n');
                yy=get(gca,'ylim');
                h_naa=line([2.02 2.02],yy,'color',[1 0 0],'linestyle',':');
                h_cre=line([3.03 3.03],yy,'color',[0 1 0],'linestyle',':');
                h_cho=line([3.25 3.25],yy,'color',[0 0 1],'linestyle',':');
            case 's'
                pepsi_ref_threshold=[];
                redraw_all;
            case 'f'
                fprintf('doing 3D FFT...')
                for i=1:length(pepsi_data)
                    pepsi_data{i}=fftshift(fft(fftshift(fftshift(fft(fftshift(fftshift(fft(fftshift(squeeze(pepsi_data{i}),1),[],1),1),2),[],2),2),3),[],3),3);
                end;
                redraw_all;
        end;
    case 'bd'
        if(gcf==pepsi_figure) %clicking on overlay figure
            if(gca==pepsi_axis_image)
                pepsi_gca=pepsi_axis_image;
                pp=get(gca,'currentpoint');
                pepsi_pointer(1)=round(pp(1,1));
                pepsi_pointer(2)=round(pp(1,2));
            end;
            if(gca==pepsi_axis_spectrum)
                pepsi_gca=pepsi_axis_spectrum;
                pp=get(gca,'currentpoint');
                pepsi_spectrum_pointer(1)=(pp(1,1));
                pepsi_spectrum_pointer(2)=(pp(1,2));
            end;
            
            redraw_all;
        end;
    case 'init'
        ref=squeeze(max(abs(pepsi_data{1}),[],1));
        sd=sort(ref(:));
        if(length(sd)>1)
            pepsi_ref_threshold=[sd(round(length(sd).*0.05)),sd(round(length(sd).*0.95))];
        else
            pepsi_ref_threshold=0;
        end;
        
        pepsi_pointer=[];
        
        if(isempty(pepsi_legend))
            for i=1:length(pepsi_data)
                pepsi_legend{i}=sprintf('spec %02d',i);
            end;
        end;
        
        redraw_all;
end;
return;


function close_all()
global pepsi_figure;

if(~isempty(pepsi_figure))
    close(pepsi_figure);
    pepsi_figure=[];
end;
return;


function redraw_all()
global pepsi_figure;
global pepsi_data;
global pepsi_pointer;
global pepsi_spectrum_pointer;
global pepsi_ref_threshold;
global pepsi_legend;
global pepsi_ref;
global pepsi_type;
global pepsi_bandwidth;
global pepsi_b0;
global pepsi_cf;
global pepsi_axis_fullx;
global pepsi_axis_fully;
global pepsi_now_zoomin;
global pepsi_axis_image;
global pepsi_axis_spectrum;
global pepsi_gca;
global pepsi_x_axis;
global pepsi_spectrum_line;

figure(pepsi_figure);


pepsi_axis_image=subplot(211);

xx=[];
if(isempty(pepsi_spectrum_pointer))
    ref=squeeze(max(abs(pepsi_data{1}),[],1));
else
    if(pepsi_gca==pepsi_axis_spectrum)

        [dummy,xx]=min(abs(pepsi_spectrum_pointer(1)-pepsi_x_axis));
        
        ref=squeeze(abs(pepsi_data{1}(xx,:,:)));
    else
        ref=squeeze(max(abs(pepsi_data{1}),[],1));
    end;
end;
if(~isempty(pepsi_ref_threshold))
    imagesc(ref, pepsi_ref_threshold);
else
    imagesc(ref);
    pepsi_ref_threshold=get(gca,'clim');
end;
colormap(gray);
axis off image;
pepsi_ref=ref;


if(~isempty(pepsi_pointer))
    if((pepsi_pointer(1)<=size(pepsi_data{1},2))&(pepsi_pointer(1)>=1)&(pepsi_pointer(2)<=size(pepsi_data{1},3))&(pepsi_pointer(2)>=1))
        pepsi_axis_spectrum=subplot(212);
        for i=1:length(pepsi_data)
            spectrum(:,i)=pepsi_data{i}(:,round(pepsi_pointer(2)),round(pepsi_pointer(1)));
        end;
        if(isempty(pepsi_bandwidth))
            xx=[1:size(spectrum,1)];
        else
            %using the first spectrum for water reference
            [dummy,max_idx]=max(spectrum(:,1));
            cppm=4.7;                           %proton peak as 4.7 PPM
            if(~isempty(pepsi_b0))
                cf=pepsi_b0*42.58.*1e6;         %center frequency of water peak in Hz
            elseif(~isempty(pepsi_cf))
                cf=cf;                          %center frequency of water peak in Hz
            end;
            
            df=pepsi_bandwidth./size(spectrum,1);
            dppm=pepsi_bandwidth./cf.*1e6./size(spectrum,1);
            x_freq=fliplr(([1:size(spectrum,1)]-max_idx).*df+cf);
            x_ppm=(([1:size(spectrum,1)]-max_idx).*dppm+cppm);
            
            pepsi_x_axis=x_ppm;
            
            pepsi_axis_fullx=[min(x_ppm) max(x_ppm)];
        end;
        
        switch(lower(pepsi_type))
            case 'real'
                plot(x_ppm,real(spectrum));
            case 'imag'
                plot(x_ppm,imag(spectrum));
            case 'abs'
                plot(x_ppm,abs(spectrum));
            case 'angle'
                plot(x_ppm,unwrap(angle(spectrum)));
        end;
        
        try
            delete(pepsi_spectrum_line);
        catch
            pepsi_spectrum_line=[];
        end;
        
       
        if(~isempty(pepsi_spectrum_pointer))
            pepsi_spectrum_line=line([pepsi_spectrum_pointer(1) pepsi_spectrum_pointer(1)],get(gca,'ylim')); set(pepsi_spectrum_line,'color',[1 1 1].*0.5,'linewidth',1);
        end;
        
        axis tight;
        if(~pepsi_now_zoomin)
                    pepsi_axis_fullx=get(gca,'xlim');
                    pepsi_axis_fully=get(gca,'ylim');
                    set(gca,'xlim',[1.5 4]);
        end;
        legend(pepsi_legend);
        draw_pointer;
    end;
end;




return;     

function draw_pointer()
global pepsi_pointer;
global pepsi_pointer_handle
global pepsi_figure;

if(isempty(pepsi_pointer)) return; end;

if(~isempty(pepsi_pointer_handle))
    if(ishandle(pepsi_pointer_handle))
        delete(pepsi_pointer_handle);
        pepsi_pointer_handle=[];
    else
        pepsi_pointer_handle=[];
    end;
end;

if(~isempty(pepsi_figure))
    if(ishandle(pepsi_figure))
        figure(pepsi_figure);
        ax=get(pepsi_figure,'child');
        set(gcf,'currentaxes',ax(end));
        pepsi_pointer_handle=text(pepsi_pointer(1),pepsi_pointer(2),'+');
        set(pepsi_pointer_handle,'verticalalignment','middle');
        set(pepsi_pointer_handle,'horizontalalignment','center');
        set(pepsi_pointer_handle,'color',[1 0 0]);
    else
        pepsi_figure=[];
    end;
end;

return;

