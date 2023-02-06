function shape_classification_plot(data)
clf(figure())
set(gcf,'name','Shape Classification','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.6],'menubar','none','toolbar','none')

file_menu = uimenu('Text','File');
uimenu(file_menu,'Text','Send Data to Workspace','Callback',@send_data);
uimenu(file_menu,'Text','Save Data as bin','Callback',@save_bin_callback);
uimenu(file_menu,'Text','Save Data as jpg','Callback',@save_jpg_callback);
uimenu(file_menu,'Text','Save Data as jpg (random selection)','Callback',@save_jpg_selected_clusters_callback);

features_menu = uimenu('Text','Features');
uimenu(features_menu,'Text','Features Information','Callback',@features_info);
uimenu(features_menu,'Text','Box Plot','Callback',@features_box_plot);
uimenu(features_menu,'Text','PCA Analysis','Callback',@pca_analysis);
uimenu(features_menu,'Text','Class Coefficient of Variation','Callback',@coeff_of_variation);

classification_menu = uimenu('Text','Classification');
uimenu(classification_menu,'Text','Gravitational Clustering','Callback',@gravitational_clustering);
uimenu(classification_menu,'Text','Decision Boundary Plot','Callback',@decision_boundary_plot);
uimenu(classification_menu,'Text','Dendrogram Graph','Callback',@dendrogram);
uimenu(classification_menu,'Text','Network Graph','Callback',@network);
uimenu(classification_menu,'Text','Clustergram','Callback',@clustergram);
uimenu(classification_menu,'Text','K-means','Callback',@kmeans);
uimenu(classification_menu,'Text','Hierarchical','Callback',@hierarchical);
uimenu(classification_menu,'Text','Self Organizing Map','Callback',@som);
uimenu(classification_menu,'Text','Supervised Classification','Callback',@supervised);
uimenu(classification_menu,'Text','Iterative Classification (Based on Linkage)','Callback',@iterative_linkage);
uimenu(classification_menu,'Text','Iterative Classification (Based on Distance)','Callback',@iterative_distance);
uimenu(classification_menu,'Text','Iterative Classification (Based on Linkage) Coeff Variation','Callback',@iterative_linkage_coeff_var);
uimenu(classification_menu,'Text','Iterative Classification (Based on Distance) Coeff Variation','Callback',@iterative_distance_coeff_var);
%uimenu(classification_menu,'Text','Iterative Pairwise clustering','Callback',@iterative_pairwise_clustering);

filter_menu = uimenu('Text','Filter');
uimenu(filter_menu,'Text','Filter Mass','Callback',@filter_mass);
uimenu(filter_menu,'Text','Filter Area','Callback',@filter_area);
uimenu(filter_menu,'Text','Filter Aspect Ratio','Callback',@filter_aspect_ratio);

plot_menu = uimenu('Text','Plot');
uimenu(plot_menu,'Text','Ellipses Graph','Callback',@ellipses_plot);

extract_class = uimenu('Text','Exctract Classes');
uimenu(extract_class,'Text','Extract Classes','Callback',@extract_classes);

for i=1:size(data.classes,1)
    total_no_of_clusters(i) = length(data.classes{i,1});
end
no_of_classes = size(data.classes,1);

slider_one_value = 1;
slider_two_value = 1;
if  no_of_classes>1
    slider_one_step=[1/(no_of_classes-1),0.25];
else
    slider_one_step = [0 0];
end
if no_of_classes>1
    slider_one = uicontrol('style','slider','units','normalized','position',[0.01,0.1,0.04,0.8],'value',1,'min',1,'max',no_of_classes,'sliderstep',slider_one_step,'Callback',{@sld_one_callback});
end

if length(data.classes{slider_one_value,1})>1
    slider_two_step=[1/(length(data.classes{slider_one_value,1})-1),1/(length(data.classes{slider_one_value,1})-1)];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.05,0.1,0.04,0.8],'value',1,'min',1,'max',length(data.classes{slider_one_value,1}),'sliderstep',slider_two_step,'Callback',{@sld_two_callback});
else
    slider_two_step=[0,0];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.05,0.1,0.04,0.8],'value',1,'min',1,'max',1,'sliderstep',slider_two_step,'Callback',{@sld_two_callback});
end
    
shape_classification_plot_inside(data.classes,slider_one_value,slider_two_value,total_no_of_clusters,no_of_classes,data.name)

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        slider_two_value= 1;
        if length(data.classes{slider_one_value,1})>1            
            slider_two_step=[1/(length(data.classes{slider_one_value,1})-1),1/(length(data.classes{slider_one_value,1})-1)];
            slider_two.Value = slider_two_value;
            slider_two.Min = 1;
            slider_two.Max = length(data.classes{slider_one_value,1});
            slider_two.SliderStep = slider_two_step;  
            slider_two.Position = [0.05,0.1,0.04,0.8];
        else
            slider_two.Position = [-0.2,0.1,0.04,0.8];
        end
        shape_classification_plot_inside(data.classes,slider_one_value,slider_two_value,total_no_of_clusters,no_of_classes,data.name)
    end

    function sld_two_callback(~,~,~)
        if length(data.classes{slider_one_value,1})>1
            slider_two_value = round(slider_two.Value);
            shape_classification_plot_inside(data.classes,slider_one_value,slider_two_value,total_no_of_clusters,no_of_classes,data.name)
        end
    end 
  
    function send_data(~,~,~)
        send_data_to_workspace(data)
    end

    function save_bin_callback(~,~,~)
        shape_classification_save_results_bin(data)
    end

    function save_jpg_callback(~,~,~)
        shape_classification_save_results_jpg(data)
    end

    function save_jpg_selected_clusters_callback(~,~,~)
        shape_classification_save_results_selected_clusters(data)
    end

    function features_info(~,~,~)
        shape_classification_features_info(data)
    end

    function features_box_plot(~,~,~)
        shape_classification_features_box_plot(data)
    end

    function pca_analysis(~,~,~)
        shape_classification_pca_analysis(data)
    end

    function coeff_of_variation(~,~,~)
        shape_classification_coeff_of_variation(data)
    end

    function gravitational_clustering(~,~,~)
        shape_classification_gravitational_clustering(data)
    end

    function decision_boundary_plot(~,~,~)
        shape_classification_decision_boundary_plot(data)
    end

    function dendrogram(~,~,~)
        shape_classification_dendrogram_graph(data)
    end

    function network(~,~,~)
        shape_classification_network_graph(data.classes)
    end

    function clustergram(~,~,~)
        shape_classification_clustergram(data.classes)
    end

    function kmeans(~,~,~)
        shape_classification_kmeans(data)
    end

    function hierarchical(~,~,~)
        shape_classification_hierarchical(data)
    end

    function som(~,~,~)
        shape_classification_som(data)
    end

    function supervised(~,~,~)
        shape_classification_supervised_clustering(data)
    end

    function iterative_linkage(~,~,~)
        shape_classification_iterative_linkage_clustering(data)
    end 

    function iterative_distance(~,~,~)
        shape_classification_iterative_distance_clustering(data)
    end 

    function iterative_linkage_coeff_var(~,~,~)
        shape_classification_iterative_linkage_coeff_var_clustering(data)
    end 

    function iterative_distance_coeff_var(~,~,~)
        shape_classification_iterative_distance_coeff_var_clustering(data)
    end 

    function iterative_pairwise_clustering(~,~,~)
        shape_classification_iterative_pairwise_clustering(data)
    end 

    function filter_mass(~,~,~)
        shape_classification_filter_mass(data)
    end

    function filter_area(~,~,~)
        shape_classification_filter_area(data)
    end

    function filter_aspect_ratio(~,~,~)
        shape_classification_filter_aspect_ratio(data)
    end

    function ellipses_plot(~,~,~)
        shape_classification_ellipses_plot(data)
    end

    function extract_classes(~,~,~)
        shape_classification_extract_classes(data)
    end
end

function shape_classification_plot_inside(classes,slider_one_value,slider_two_value,total_no_of_clusters,no_of_classes,name)
data_to_plot = classes{slider_one_value,1}{slider_two_value};
parameters = classes{slider_one_value,2};
group = classes{slider_one_value,4}{slider_two_value};

[~,data_to_plot] = pca(data_to_plot);

l = parameters(:,7);
w = parameters(:,8);

for i = 1:size(classes,1)
    colors{i} = unique(cell2mat(classes{i,4}));
end
colors = unique(vertcat(colors{:}));
c_map = colormap(jet);
c_map = interp1(1:256,c_map,linspace(1,256,max(colors)));  
scatter(data_to_plot(:,1),data_to_plot(:,2),5,c_map(group,:),'filled')

set(gca,'color','k')
xlim([-max(l)/2 max(l)/2])
ylim([-max(w)/2 max(w)/2])
axis equal
axis off
title({'','',['File Name =',regexprep(name,'_',' ')],['Total number of clusters =',num2str(sum(total_no_of_clusters))],['Class Color=',num2str(classes{slider_one_value,4}{slider_two_value})],['Class numer =',num2str(slider_one_value),'/',num2str(no_of_classes)],['Cluster number =',num2str(slider_two_value),'/',num2str(length(classes{slider_one_value,1}))],['Mass =',num2str(size(data_to_plot,1)),'  Area =',num2str(classes{slider_one_value,2}(slider_two_value,2))],['Length =',num2str(classes{slider_one_value,2}(slider_two_value,7)),'  Width =',num2str(classes{slider_one_value,2}(slider_two_value,8))]},'interpreter','latex','fontsize',14)
end