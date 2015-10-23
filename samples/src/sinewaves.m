%SINEWAVES Export 2-D line plot of sample datafile 'sinewaves.tab'.

%% Add parent folder to path
oldpath = addpath('../../');

%% Initialize variables
prop = struct;

%% Import datafile
data = importfile('sinewaves.tab');

%% Plot amplitude as a function of time
hf = figure;
plot(data(:,1), data(:,2:end))

xlabel('Time (s)')
ylabel('Amplitude (V)')
grid on
box off

legend('Wave 1', 'Wave 2', 'Wave 3', 'Wave 4',...
    'Location', 'SouthWest')

%% Define properties
prop.Figure.PaperUnits = 'inches';
prop.Axes.XMinorTick = 'on';
prop.Axes.FontName = 'Times New Roman';
prop.Axes.FontSize = 11;

%% Print figure
printfg(hf, 'sinewaves', {'png', 'pdf', 'eps'}, [5 3], prop);

%% Restore path
path(oldpath)