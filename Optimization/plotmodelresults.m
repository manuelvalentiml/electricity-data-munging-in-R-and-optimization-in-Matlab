function plotmodelresults(SWx, SWm, Ix, Im, K, c)
    
    color = [0.7 0.4];
    
    homepath = cd(cd('..'));
    
    filesupply = strcat(homepath, '/Data/MungedData/ES-D-1-Sun-OffP.csv');
    filedemand = strcat(homepath, '/Data/MungedData/ES-S-1-Sun-OffP.csv');
    constrainedsupply = strcat(homepath, '/Optimization/constrainedsupply.csv');
    constraineddemand = strcat(homepath, '/Optimization/constraineddemand.csv');
    regsupply = strcat(homepath, '/Optimization/regsupply.csv');
    regdemand = strcat(homepath, '/Optimization/regdemand.csv');

    datasupply = readtable(filesupply, 'Delimiter', ';', 'ReadVariableNames', false, 'ReadRowNames', false);
    datademand = readtable(filedemand, 'Delimiter', ';', 'ReadVariableNames', false, 'ReadRowNames', false);
    datasupply = table2array(datasupply(:,1:4));
    datademand = table2array(datademand(:,1:4));
    constrainedsupply = dlmread(constrainedsupply,' ');
    constraineddemand = dlmread(constraineddemand,' ');
    regsupply = dlmread(regsupply,' ');
    regdemand = dlmread(regdemand,' ');
    
    figure(1);
    hold all;
    supply = scatter(datasupply(:,1),datasupply(:,2), 7, 'MarkerEdgeColor', [color(1) color(1) color(1)]);
    demand = scatter(datademand(:,1),datademand(:,2), 7, 'MarkerEdgeColor', [color(2) color(2) color(2)]);
    regs = plot(regsupply(:,1), regsupply(:,2),'Color','black','LineWidth',1);
    cons = plot(constrainedsupply(:,1), constrainedsupply(:,2),'Color','black','LineWidth',2.5);
    cond = plot(constraineddemand(:,1), constraineddemand(:,2),'Color','black','LineWidth',2.5);
    regd = plot(regdemand(:,1), regdemand(:,2),'Color','black','LineWidth',1);
    ylim([0 200]);
    legend('Supply','Demand','Linear Regression','Constrained Regression','Location','SouthEast');
    title('Supply and demand curves example');
    xlabel('Power (MWh)');
    ylabel('Price (?)');
    xt = get(gca,'XTick');
    set(gca,'XTickLabel',num2str(get(gca,'XTick').'))
   
    %%%%%
    
    filename = strcat(homepath,'/Optimization/parameters.csv');
    [country,month,weekday,vazio,alphaX,betaX,gammaX,deltaX,alphaM,betaM,gammaM,deltaM,hours] = import_iberian_data(filename);
    
    figure(2);
    hold all;
    demandspain = scatter(betaX, alphaX,'MarkerEdgeColor','black','Marker','x');
    demandportugal = scatter(betaM, alphaM,'MarkerEdgeColor','black','Marker','.');
    legend('Spain','Portugal','Location','SouthEast');
    title('Demand parameter estimation');
    xlabel('Slope Beta (Euro/MWh)');
    ylabel('Constant Alpha(Euro)');

    %%%%%
  
    figure(3);
    hold all;
    demandspain = scatter(deltaX, gammaX,'MarkerEdgeColor','black','Marker','x');
    demandportugal = scatter(deltaM, gammaM,'MarkerEdgeColor','black','Marker','.');
    legend('Spain','Portugal','Location','SouthEast');
    title('Demand parameter estimation');
    xlabel('Slope Delta (Euro/MWh)');
    ylabel('Constant Gamma(Euro)');
    hline = refline(0,0);
    set(hline,'Color','black');%hline.Color = 'black';

    %%%%%
    
    [x,xmax] = max( (SWx - Ix) <= .001);
    
    xmax = xmax - 1;
    
    figure(4);
    hold off;
    x = plot (c/1000, (Ix+Im)./c);
    set(x,'Color','black');

    hold all;
    xlim([0 c(xmax)./1000]);
    xlabel('Cost of transmission capacity (kEuro/MW)');
    ylabel('Transmission capacity (MW)');
    title('Transmission capacity investment as a function of transmission cost');

    %%%%%
    
    figure(5);
    hold off;
    spain = plot (c/1000, Ix ./ (Ix + Im),'--');
    hold all;
    portugal = plot (c/1000, Im ./ (Ix + Im),'-.');
    ylim([-1 2]);
    xlim([0 c(xmax)./1000]);
    xlabel('Cost of transmission capacity (kEuro/MW)');
    ylabel('Ratio (%)');
    title('Investment ratio as a function of transmission cost');
    set(portugal,'Color','black');
    set(spain,'Color','black')
    hleg = legend('Spain','Portugal');
    hline = refline(0,1);
    set(hline,'Color','black');
    hline = refline(0,0);
    set(hline,'Color','black');
    yt = get(gca,'XTick');
    set(gca,'XTickLabel', sprintf('%.0f|',yt))
    
    %%%%%
    
    figure(6);
    hold off;
    spain = plot (c/1000, Ix ./ 10^6,'--');
    hold all;
    portugal = plot (c/1000, Im ./ 10^6,'-.');
    xlim([0 c(xmax)./1000]);
    xlabel('Cost of transmission capacity (kEuro/MW)');
    ylabel('Investment cost (MEuro)');
    title('Investment as a function of transmission cos');
    set(portugal,'Color','black');
    set(spain,'Color','black');
    hleg = legend('Spain','Portugal','Location','NorthWest');
    hline = refline(0,0);
    set(hline,'Color','black');
    
    %%%%%
    
    figure(7);
    hold off;
    spain = plot (c/1000, SWx / 10^6,'--');
    hold all;
    portugal = plot (c/1000, SWm / 10^6,'-.');
    reduced = plot (c/1000, (SWx - Ix) / 10^6,':');
    xlim([0 c(xmax)./1000]);
    xlabel('Cost of transmission capacity (kEuro/MW)');
    ylabel('Variation in social welfare (MEuro)');
    title('Variation in social welfare as a function of transmission cost');
    set(portugal,'Color','black');
    set(spain,'Color','black');
    set(reduced,'Color','black');
    hleg = legend('Spain without investment costs','Portugal without investment costs','Spain/Portugal considering investment costs');
end