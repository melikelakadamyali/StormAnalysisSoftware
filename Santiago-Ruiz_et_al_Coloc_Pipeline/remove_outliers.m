function data_filtered = remove_outliers(data)
clusters = extract_clusters(data);
names = data.name;

areas = cellfun(@(x) x(1,3),clusters);
no_of_locs = cellfun(@(x) size(x,1),clusters);

ratio = log10(no_of_locs./areas);
ratio = ratio + abs(min(ratio))+0.1;
[counts,centers] = hist(ratio,100);

figure(1595)
set(gcf,'name','Clusters Remove Outlier','NumberTitle','off','color','w','units','normalized','position',[0.1 0.2 0.8 0.6],'menubar','none','toolbar','figure');
 
subplot(1,2,1)
ax = gca; cla(ax);
plot(centers,counts,'color','k')
set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
box on
title({'',regexprep(names,'_',' ')},'interpreter','latex','fontsize',16)

subplot(1,2,2)
ax = gca; cla(ax);
scatter(no_of_locs,areas,5,'b','filled')
set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
xlabel('Clusters No. of Locs','interpreter','latex','fontsize',16)
ylabel('Clusters Area','interpreter','latex','fontsize',16)
box on

happy = 0;

while happy == 0

    answer = inputdlg({'Sigma:'},'Input',[1 50],{'1'});

    sigma = str2double(answer{1});
    fit_results = fit_inside(centers,ratio,sigma);
    plot_fit_results(centers,counts,no_of_locs,areas,names,fit_results,sigma)

    answer = inputdlg({'Are you happy with this result (0: no; 1: yes)?:'},'Input',[1 50],{'1'});
    happy = str2double(answer{1});

    close(1596)

end

close(1595)

data_filtered = extract_filtered_data(clusters,fit_results,names);
    
end

function fit_results = fit_inside(centers,ratio,sigma_to)

    fit_to_hist = fitdist(ratio,'Normal');
    mu = fit_to_hist.mu;
    sigma = fit_to_hist.sigma;
    range(1) = min(centers)-0.1;
    range(2) = mu+sigma_to*sigma;
  
    centers_interp = linspace(min(centers),max(centers),5000);
    fit_to_hist = pdf(fit_to_hist,centers_interp);        
    
    idx = ratio>=range(1) & ratio<=range(2);    
    
    fit_results.idx = idx;
    fit_results.mu = mu;
    fit_results.range = range;
    fit_results.centers_interp = centers_interp;
    fit_results.fit_to_hist = fit_to_hist;

end

function plot_fit_results(centers,counts,no_of_locs,areas,names,fit_results,sigma) 
    
    figure(1596)
    set(gcf,'name','Outlier Removal','NumberTitle','off','color','w','units','normalized','position',[0.05 0.2 0.9 0.5],'menubar','none','toolbar','figure');
     
    to_keep_data(:,1) = no_of_locs(fit_results.idx);
    to_keep_data(:,2) = areas(fit_results.idx);

    removed_data(:,1) = no_of_locs(~fit_results.idx);
    removed_data(:,2) = areas(~fit_results.idx);

    subplot(1,2,1)
    ax = gca; cla(ax);
    plot(centers,counts/max(counts),'color','k','linewidth',1.5)
    hold on
    plot(fit_results.centers_interp,fit_results.fit_to_hist/max(fit_results.fit_to_hist),'color','m','linewidth',1.5)

    pgon = polyshape([0 fit_results.range(2) fit_results.range(2) 0],[0 0 1 1]);
    plot(pgon,'facecolor','b','facealpha',0.3,'edgecolor','none');
    line([fit_results.mu fit_results.mu],[0 1],'color','k','linewidth',1.5)
    text(fit_results.mu,0.9,['$\mu = $',num2str(fit_results.mu)],'interpreter','latex','fontsize',16)

    pgon = polyshape([fit_results.range(2) max(centers) max(centers) fit_results.range(2)],[0 0 1 1]);
    plot(pgon,'facecolor','r','facealpha',0.3,'edgecolor','none');
    line([fit_results.range(2) fit_results.range(2)],[0 1],'color','r','linewidth',1.5)
    text(fit_results.range(2),0.9,['$\mu + $',num2str(sigma),'$\sigma$'],'interpreter','latex','fontsize',16)
    set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
    xlim([min(centers) max(centers)])
    ylim([0 1])
    box on
    title({'',regexprep(names,'_',' '),},'interpreter','latex','fontsize',16)

    subplot(1,2,2)
    ax = gca; cla(ax);
    scatter(to_keep_data(:,1),to_keep_data(:,2),10,'b','filled')
    hold on
    scatter(removed_data(:,1),removed_data(:,2),10,'r','filled')
    title(regexprep(names,'_',' '),'interpreter','latex','fontsize',18)
    xlabel('Clusters No. of Locs','interpreter','latex','fontsize',18)
    ylabel('Clusters Area','interpreter','latex','fontsize',18)
    set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
    box on
   
end

function data_filtered = extract_filtered_data(clusters,fit_results,names)

    clusters_filtered = clusters(fit_results.idx);
    clusters_filtered = vertcat(clusters_filtered{:});

    data_filtered.x_data = clusters_filtered(:,1);
    data_filtered.y_data = clusters_filtered(:,2);
    data_filtered.area = clusters_filtered(:,3);
    data_filtered.type = 'loc_list';
    data_filtered.name = [names,'_filtered'];
    if size(clusters{1},2) == 4
        data_filtered.channel = clusters_filtered(:,4);
    end

end