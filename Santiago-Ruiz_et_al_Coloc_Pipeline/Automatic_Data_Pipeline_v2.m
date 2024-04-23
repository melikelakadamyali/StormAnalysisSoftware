% Clear the workspacesave
clc;clear

% -------------------------------------------------------------------------
% values to change if needed
name{1} = "Thr181"; % First channel name
name{2} = "AT8"; % Second channel name
JointAreaFiler = 0.45; % Initial area filter to clean up the data.
Areafilter = [1.25 11]; % All the filters for the first channel (Thr231)
OverlapPerc = 30; % Percent of overlap between the two channels to be considered the same cluster.
minLocs = 10; % The minimum number of localizations needed in each channel after splitting.
Edges = [-1 -0.8 -0.3 0.3 0.8 1]; % The edges of the differences.
% -------------------------------------------------------------------------

% Load the session you want to analyze
[file,path] = uigetfile('*.mat','Load the MATLAB file');

% Do the analysis
if isequal(file,0)
    disp('User selected Cancel'); % Stop the script.
else

    % Step 1: Load data and make the savenames
    wb = waitbar(0,'Loading data... ');
    filename = fullfile(path,file);
    load(filename);
    
    savename{1} = [filename(1:end-4) '_pipeline.mat'];
    if exist(savename{1},'file') == 2
        delete(savename{1});
    end
    
    savename{2} = [filename(1:end-4) 'Summary.png'];
    if exist(savename{2},'file') == 2
        delete(savename{2});
    end
    
    savename{3} = [filename(1:end-4) 'Summary.xlsx'];
    if exist(savename{3},'file') == 2
        delete(savename{3});
    end

    waitbar(1,wb,'Loading data... ');
    clear filename file path
    pause(0.5)

    % Step 2: Calculate the correct areas
    waitbar(0,wb,'Recalculating areas... ');
    data_corr = cell(1,length(data));
    for i = 1:length(data)
        waitbar((i-0.5)/length(data),wb,'Recalculating areas... ');
        data_corr{i} = calcArea(data{i});
    end
    waitbar(1,wb,'Recalculating areas... ');
    pause(0.5)

    % Step 3: remove the outliers (requires user input)
    waitbar(0,wb,'Removing outliers... ');
    data_filtered = cell(1,length(data_corr));
    for i = 1:length(data_corr)
        waitbar((i-0.5)/length(data_corr),wb,'Removing outliers... ');
        data_filtered{i} = remove_outliers(data_corr{1,i});
    end
    waitbar(1,wb,'Removing outliers... ');
    clear i
    pause(0.5)

    % Step 4: Area filtering on the joint clusters
    waitbar(0,wb,'Filtering data based on area... ');
    data_cleaned = cell(1,length(data_filtered));
    for i = 1:length(data_filtered)
        waitbar((i-0.5)/length(data_filtered),wb,'Filtering the joint channel clusters based on area... ');
        data_cleaned{1,i} = filter_area(data_filtered{1,i},JointAreaFiler);
    end

    % Step 5: separate the data into NanoClusters - MidClusters - MacroClusters
    waitbar(0,wb,'Filtering data based on area... ');
    data_OrigNanoClusters = cell(1,length(data_cleaned));
    data_OrigMidClusters = cell(1,length(data_cleaned));
    data_OrigMacroClusters = cell(1,length(data_cleaned));

    for i = 1:length(data_cleaned)
        
        waitbar((i-0.5)/length(data_cleaned),wb,['Filtering data based on area... ',num2str(i),'/',num2str(length(data_cleaned))]);
        if ~isempty(data_cleaned{1,i})
            [tmp,data_OrigNanoClusters{1,i}] = filter_area(data_cleaned{1,i},Areafilter(1));
        end
        if ~isempty(tmp)
            [data_OrigMacroClusters{1,i},data_OrigMidClusters{1,i}] = filter_area(tmp,Areafilter(2));
        end

    end
    waitbar(1,wb,'Filtering data based on area... ');
    clear i AreaFilter tmp
    pause(0.5)

    % Step 6: do the overlap calculations
    waitbar(0/7,wb,'Running the overlap calculations - Nanoclusters');
    [data_NanoClusters] = OverlapCalculation(data_OrigNanoClusters,OverlapPerc,minLocs,JointAreaFiler);
    waitbar(1/7,wb,'Running the overlap calculations - Midclusters');
    [data_MidClusters] = OverlapCalculation(data_OrigMidClusters,OverlapPerc,minLocs,JointAreaFiler);
    waitbar(2/7,wb,'Running the overlap calculations - Macroclusters');
    [data_MacroClusters] = OverlapCalculation(data_OrigMacroClusters,OverlapPerc,minLocs,JointAreaFiler);

    % re-organize the clusters as some clusters may now have smaller areas
    % than before (i.e., midclusters may now be nanocluster, or
    % macroclusters may now be nano- or midclusters).
    [data_NanoClusters,data_MidClusters,data_MacroClusters] = reorganizeData(data_NanoClusters,data_MidClusters,data_MacroClusters,Areafilter);
    
    waitbar(3/7,wb,'Combining data results - Nanoclusters');
    NanoClusters = calcLocs(data_NanoClusters);
    AllNanoClusters = vertcat(NanoClusters{:});
    waitbar(4/7,wb,'Combining data results - Midclusters');
    MidClusters = calcLocs(data_MidClusters);
    AllMidClusters = vertcat(MidClusters{:});
    waitbar(5/7,wb,'Combining data results - Macroclusters');
    MacroClusters = calcLocs(data_MacroClusters);
    AllMacroClusters = vertcat(MacroClusters{:});

    waitbar(6/7,wb,'Plotting the results');
    Summary(:,1) = histcounts(AllNanoClusters(:,8),Edges);
    Summary(:,2) = histcounts(AllMidClusters(:,8),Edges);
    Summary(:,3) = histcounts(AllMacroClusters(:,8),Edges);
    Summary(:,4) = round(Summary(:,1)./sum(Summary(:,1))*100,2);
    Summary(:,5) = round(Summary(:,2)./sum(Summary(:,2))*100,2);
    Summary(:,6) = round(Summary(:,3)./sum(Summary(:,3))*100,2);
    Summary = flipud(Summary);
    legendlabel = {'AT8 ([1,0.8])','AT8>Thr231 ([0.8,0.3[)','Thr231=AT8 ([0.3,-0.3[)','Thr231>AT8 ([-0.3,-0.8[)','Thr231 ([-0.8,-1[)'};

    figure('Units','Normalized','OuterPosition',[0.02 0.02 0.95 0.95]);
    subplot(1,3,1);h = pie(Summary(:,1));title('NanoClusters','FontSize',15,'FontWeight','bold');set(h(2:2:end),{'HorizontalAlignment'},get(h(end:-2:2),{'HorizontalAlignment'}));set(gca(),'XDir','reverse')
    subplot(1,3,2);h = pie(Summary(:,2));title('MidClusters','FontSize',15,'FontWeight','bold');set(h(2:2:end),{'HorizontalAlignment'},get(h(end:-2:2),{'HorizontalAlignment'}));set(gca(),'XDir','reverse')
    subplot(1,3,3);h = pie(Summary(:,3));title('MacroClusters','FontSize',15,'FontWeight','bold');set(h(2:2:end),{'HorizontalAlignment'},get(h(end:-2:2),{'HorizontalAlignment'}));set(gca(),'XDir','reverse')
    legend(legendlabel,'FontSize',13,'FontWeight','bold')
    print(savename{2},'-dpng','-r300')
    close

    figure('Units','Normalized','OuterPosition',[0.02 0.02 0.95 0.95]);
    h1 = histogram(AllNanoClusters(:,8),linspace(-1,1,50),'Normalization','probability');hold on;
    h2 = histogram(AllMidClusters(:,8),linspace(-1,1,50),'Normalization','probability');
    h3 = histogram(AllMacroClusters(:,8),linspace(-1,1,50),'Normalization','probability');
    ax = axis;
    axis([ax(1) ax(2) ax(3) ax(4)*1.1])
    patch([-1 -0.8 -0.8 -1],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 0 1],'facealpha',0.3,'edgealpha',0)
    patch([-0.8 -0.3 -0.3 -0.8],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 0.5 1],'facealpha',0.3,'edgealpha',0)
    patch([-0.3 0.3 0.3 -0.3],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 1 1],'facealpha',0.3,'edgealpha',0)
    patch([0.3 0.8 0.8 0.3],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[0.5 1 1],'facealpha',0.3,'edgealpha',0)
    patch([0.8 1 1 0.8],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[0 0.925 0.925],'facealpha',0.3,'edgealpha',0)
    text(-0.975,ax(4)*1.025,'Thr231 (]-0.8,-1])','fontsize',12,'fontweight','bold')
    text(-0.675,ax(4)*1.025,'Thr231>AT8 (]-0.3,-0.8])','fontsize',12,'fontweight','bold')
    text(-0.125,ax(4)*1.025,'Thr231=AT8 (]0.3,-0.3])','fontsize',12,'fontweight','bold')
    text(0.425,ax(4)*1.025,'AT8>Thr231 (]0.8,0.3])','fontsize',12,'fontweight','bold')
    text(0.8,ax(4)*1.025,'AT8 ([1,0.8])','fontsize',12,'fontweight','bold')
    delete(h1);delete(h2);delete(h3)
    h(1) = histogram(AllNanoClusters(:,8),linspace(-1,1,50),'Normalization','probability','FaceColor','r','FaceALpha',0.5);hold on;
    h(2) = histogram(AllMidClusters(:,8),linspace(-1,1,50),'Normalization','probability','FaceColor','y','FaceALpha',0.5);
    h(3) = histogram(AllMacroClusters(:,8),linspace(-1,1,50),'Normalization','probability','FaceColor',[1 0.75 0],'FaceALpha',0.5);
    set(gca,'fontsize',12,'fontweight','bold');
    xlabel('Ratio [-]','fontsize',12,'fontweight','bold')
    ylabel('Probability [-]','fontsize',12,'fontweight','bold')
    legend(h(1:3),'NanoClusters','MidClusters','MacroClusters','location','best')
    print([savename{2}(1:end-4) 'hist1.png'],'-dpng','-r300')
    close

    figure('Units','Normalized','OuterPosition',[0.02 0.02 0.95 0.95]);
    h1 = histogram(AllNanoClusters(:,8),linspace(-1,1,50),'Normalization','probability');hold on
    axis([ax(1) ax(2) ax(3) ax(4)*1.1])
    patch([-1 -0.8 -0.8 -1],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 0 1],'facealpha',0.3,'edgealpha',0)
    patch([-0.8 -0.3 -0.3 -0.8],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 0.5 1],'facealpha',0.3,'edgealpha',0)
    patch([-0.3 0.3 0.3 -0.3],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 1 1],'facealpha',0.3,'edgealpha',0)
    patch([0.3 0.8 0.8 0.3],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[0.5 1 1],'facealpha',0.3,'edgealpha',0)
    patch([0.8 1 1 0.8],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[0 0.925 0.925],'facealpha',0.3,'edgealpha',0)
    text(-0.975,ax(4)*1.025,'Thr231 (]-0.8,-1])','fontsize',12,'fontweight','bold')
    text(-0.675,ax(4)*1.025,'Thr231>AT8 (]-0.3,-0.8])','fontsize',12,'fontweight','bold')
    text(-0.125,ax(4)*1.025,'Thr231=AT8 (]0.3,-0.3])','fontsize',12,'fontweight','bold')
    text(0.425,ax(4)*1.025,'AT8>Thr231 (]0.8,0.3])','fontsize',12,'fontweight','bold')
    text(0.8,ax(4)*1.025,'AT8 ([1,0.8])','fontsize',12,'fontweight','bold')
    delete(h1);
    histogram(AllNanoClusters(:,8),linspace(-1,1,50),'Normalization','probability','FaceColor','r','FaceALpha',0.5);
    set(gca,'fontsize',12,'fontweight','bold');xlabel('Ratio [-]','fontsize',12,'fontweight','bold');ylabel('Probability [-]','fontsize',12,'fontweight','bold');title('NanoClusters','FontSize',15,'FontWeight','bold');
    print([savename{2}(1:end-4) 'hist2_NanoClusters.png'],'-dpng','-r300')
    close

    figure('Units','Normalized','OuterPosition',[0.02 0.02 0.95 0.95]);
    h1 = histogram(AllMidClusters(:,8),linspace(-1,1,50),'Normalization','probability');hold on
    axis([ax(1) ax(2) ax(3) ax(4)*1.1])
    patch([-1 -0.8 -0.8 -1],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 0 1],'facealpha',0.3,'edgealpha',0)
    patch([-0.8 -0.3 -0.3 -0.8],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 0.5 1],'facealpha',0.3,'edgealpha',0)
    patch([-0.3 0.3 0.3 -0.3],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 1 1],'facealpha',0.3,'edgealpha',0)
    patch([0.3 0.8 0.8 0.3],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[0.5 1 1],'facealpha',0.3,'edgealpha',0)
    patch([0.8 1 1 0.8],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[0 0.925 0.925],'facealpha',0.3,'edgealpha',0)
    text(-0.975,ax(4)*1.025,'Thr231 (]-0.8,-1])','fontsize',12,'fontweight','bold')
    text(-0.675,ax(4)*1.025,'Thr231>AT8 (]-0.3,-0.8])','fontsize',12,'fontweight','bold')
    text(-0.125,ax(4)*1.025,'Thr231=AT8 (]0.3,-0.3])','fontsize',12,'fontweight','bold')
    text(0.425,ax(4)*1.025,'AT8>Thr231 (]0.8,0.3])','fontsize',12,'fontweight','bold')
    text(0.8,ax(4)*1.025,'AT8 ([1,0.8])','fontsize',12,'fontweight','bold')
    delete(h1);
    histogram(AllMidClusters(:,8),linspace(-1,1,50),'Normalization','probability','FaceColor','y','FaceALpha',0.5);
    set(gca,'fontsize',12,'fontweight','bold');xlabel('Ratio [-]','fontsize',12,'fontweight','bold');ylabel('Probability [-]','fontsize',12,'fontweight','bold');title('MidClusters','FontSize',15,'FontWeight','bold');
    print([savename{2}(1:end-4) 'hist2_MidClusters.png'],'-dpng','-r300')
    close

    figure('Units','Normalized','OuterPosition',[0.02 0.02 0.95 0.95]);
    h1 = histogram(AllMacroClusters(:,8),linspace(-1,1,50),'Normalization','probability');hold on
    axis([ax(1) ax(2) ax(3) ax(4)*1.1])
    patch([-1 -0.8 -0.8 -1],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 0 1],'facealpha',0.3,'edgealpha',0)
    patch([-0.8 -0.3 -0.3 -0.8],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 0.5 1],'facealpha',0.3,'edgealpha',0)
    patch([-0.3 0.3 0.3 -0.3],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[1 1 1],'facealpha',0.3,'edgealpha',0)
    patch([0.3 0.8 0.8 0.3],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[0.5 1 1],'facealpha',0.3,'edgealpha',0)
    patch([0.8 1 1 0.8],[ax(3) ax(3) ax(4)*1.1 ax(4)*1.1],[0 0.925 0.925],'facealpha',0.3,'edgealpha',0)
    text(-0.975,ax(4)*1.025,'Thr231 (]-0.8,-1])','fontsize',12,'fontweight','bold')
    text(-0.675,ax(4)*1.025,'Thr231>AT8 (]-0.3,-0.8])','fontsize',12,'fontweight','bold')
    text(-0.125,ax(4)*1.025,'Thr231=AT8 (]0.3,-0.3])','fontsize',12,'fontweight','bold')
    text(0.425,ax(4)*1.025,'AT8>Thr231 (]0.8,0.3])','fontsize',12,'fontweight','bold')
    text(0.8,ax(4)*1.025,'AT8 ([1,0.8])','fontsize',12,'fontweight','bold')
    delete(h1);
    histogram(AllMacroClusters(:,8),linspace(-1,1,50),'Normalization','probability','FaceColor',[1 0.75 0],'FaceALpha',0.5);
    set(gca,'fontsize',12,'fontweight','bold');xlabel('Ratio [-]','fontsize',12,'fontweight','bold');ylabel('Probability [-]','fontsize',12,'fontweight','bold');title('MacroClusters','FontSize',15,'FontWeight','bold');
    print([savename{2}(1:end-4) 'hist2_MacroClusters.png'],'-dpng','-r300')
    close

    Summary = array2table(Summary);
    Summary.Properties.VariableNames = {'NanoClusters Total','MidClusters Total','MacroClusters Total','NanoClusters Pct','MidClusters Pct','MacroClusters Pct'};
    Summary.Properties.RowNames = {'AT8 ([1,0.8])','AT8>Thr231 (]0.8,0.3])','Thr231=AT8 (]0.3,-0.3])','Thr231>AT8 (]-0.3,-0.8])','Thr231 (]-0.8,-1])'};

    for i = 1:length(NanoClusters)
        if ~isempty(NanoClusters{i})
            cellName = cell(1,8);
            cellName{1,1} = data_NanoClusters{i}.name;
            cellName(1,2:end) = {NaN};
            NanoClusters{i} = vertcat(cellName,num2cell(NanoClusters{i}));
        else
            NanoClusters{i} = [];
        end
    end
    NanoClusters = vertcat(NanoClusters{:});

    for i = 1:length(MidClusters)
        if ~isempty(MidClusters{i})
            cellName = cell(1,8);
            cellName{1,1} = data_MidClusters{i}.name;
            cellName(1,2:end) = {NaN};
            MidClusters{i} = vertcat(cellName,num2cell(MidClusters{i}));
        else
            MidClusters{i} = [];
        end
    end
    MidClusters = vertcat(MidClusters{:});

    for i = 1:length(MacroClusters)
        if ~isempty(MacroClusters{i})
            cellName = cell(1,8);
            cellName{1,1} = data_MacroClusters{i}.name;
            cellName(1,2:end) = {NaN};
            MacroClusters{i} = vertcat(cellName,num2cell(MacroClusters{i}));
        else
            MacroClusters{i} = [];
        end
    end
    MacroClusters = vertcat(MacroClusters{:});

    NanoClusters = cell2table(NanoClusters);NanoClusters.Properties.VariableNames = {'Cluster Number','Area','Total Locs', 'Thr231 Locs', 'Thr231 Density', 'AT8 Locs', 'AT8 Density','Ratio'};
    MidClusters = cell2table(MidClusters);MidClusters.Properties.VariableNames = {'Cluster Number','Area','Total Locs', 'Thr231 Locs', 'Thr231 Density', 'AT8 Locs', 'AT8 Density','Ratio'};
    MacroClusters = cell2table(MacroClusters);MacroClusters.Properties.VariableNames = {'Cluster Number','Area','Total Locs', 'Thr231 Locs', 'Thr231 Density', 'AT8 Locs', 'AT8 Density','Ratio'};

    writetable(Summary,savename{3},'sheet','Summary','WriteRowNames',true);
    writetable(NanoClusters,savename{3},'sheet','NanoClusters');
    writetable(MidClusters,savename{3},'sheet','MidClusters');
    writetable(MacroClusters,savename{3},'sheet','MacroClusters');

    waitbar(1,wb,'Plotting results... Finished');
    pause(0.5)
    
    % Step 7: Saving the data
    waitbar(0,wb,'Saving data... ');
    data = horzcat(data,data_corr,data_filtered,data_cleaned,data_NanoClusters,data_MidClusters,data_MacroClusters);
    data = data(~cellfun('isempty',data));
    save('-v7.3',savename{1},'data');
    waitbar(1,wb,'Saving data... ');
    close(wb)

end