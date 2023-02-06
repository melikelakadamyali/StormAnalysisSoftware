function spt_plot_all_tracks(data)
figure(10568)
set(gcf,'name','All Tracks Plot','NumberTitle','off','color','w','units','normalized','position',[0.2 0.3 0.6 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    slider = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;

plot_menu=uimenu('Text','Plot Options');
uimenu(plot_menu,'Text','Plot Gridlines','ForegroundColor','k','CallBack',@plot_gridlines_callback);
uimenu(plot_menu,'Text','Remove Gridlines','ForegroundColor','k','CallBack',@remove_gridlines_callback);

plot_all_tracks_inside(data{slider_value}.tracks,data{slider_value}.name)

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);          
        plot_all_tracks_inside(data{slider_value}.tracks,data{slider_value}.name)
    end

    function plot_all_tracks_inside(data,name)
        ax = gca; cla(ax);
        hold on
        cellfun(@(C1) plot(C1(:,2),C1(:,3),'linewidth',1), data);
        title({['File Name = ',regexprep(name,'_',' ')],['Number of Tracks = ',num2str(length(data))]},'interpreter','latex','fontsize',14)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        pbaspect([1 1 1])
    end

    function plot_gridlines_callback(~,~,~)
        a = gca;
        XLim_Lower = floor(a.XLim(1));
        XLim_Upper = ceil(a.XLim(2));
        YLim_Lower = floor(a.YLim(1));
        YLim_Upper = ceil(a.YLim(2));
        
        x = XLim_Lower:0.117:XLim_Upper;
        y = YLim_Lower:0.117:YLim_Upper;
        
        for i = 1:size(x,2)
            line([x(i) x(i)],[YLim_Lower YLim_Upper],'Color','k')
        end
        for i = 1:size(y,2)
            line([XLim_Lower XLim_Upper],[y(i) y(i)],'Color','k')
        end
    end

    function remove_gridlines_callback(~,~,~)
        close(10568)
        spt_plot_all_tracks(data)
    end
end