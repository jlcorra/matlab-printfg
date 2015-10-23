%DECAYRATES Export 2-D line plot with y-axes on both sides.
% Shamelessly stolen from MATLAB documentation examples for plotyy.
% www.mathworks.com/help/matlab/ref/plotyy.html

%% Add parent folder to path
oldpath = addpath('../../');

%% Initialize variables
prop = struct;

%% Calculate sample data
x = 0:0.01:20;
y1 = 200*exp(-0.05*x).*sin(x);
y2 = 0.8*exp(-0.5*x).*sin(10*x);
y3 = 0.2*exp(-0.5*x).*sin(10*x);

%% Plot decay rates over time
hf = figure;
[hAx, hLine1, hLine2] = plotyy(x, y1, [x',x'], [y2',y3']);

%title('Multiple Decay Rates')
xlabel('Time (\mus)')

ylabel(hAx(1),'Slow Decay')
ylabel(hAx(2),'Fast Decay')

grid on
box off

%% Define properties
prop.Axes.XMinorTick = 'on';
prop.Axes.FontName = 'Times New Roman';
prop.Axes.FontSize = 11;

%% Print figure at 480x300px
printfg(hf, 'decayrates1', {'png', 'pdf', 'eps'}, [480 300], prop);

%% Print figure at 400x250px
% Work-around MATLAB positioning issues that cause labels to get cut-off
prop.Figure.PaperPosition = [-4, 5, 400-4, 250+5];
printfg(hf, 'decayrates2', 'pdf', [400 250], prop);

%% Restore path
path(oldpath)