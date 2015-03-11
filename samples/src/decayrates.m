%DECAYRATES Export 2-D line plot with y-axes on both sides.
close all
clear all

%% Add upper directory to path
addpath ../../

%% Sample data
x = 0:0.01:20;
y1 = 200*exp(-0.05*x).*sin(x);
y2 = 0.8*exp(-0.5*x).*sin(10*x);
y3 = 0.2*exp(-0.5*x).*sin(10*x);

%% Plot data
hf = figure;
[hAx, hLine1, hLine2] = plotyy(x, y1, [x',x'], [y2',y3']);

title('Multiple Decay Rates')
xlabel('Time (\mus)')

ylabel(hAx(1),'Slow Decay')
ylabel(hAx(2),'Fast Decay')

grid on
box off

%% Properties
prop.Figure.PaperUnits = 'inches';
prop.Axes.XMinorTick = 'on';
prop.Axes.FontName = 'Times New Roman';
prop.Axes.FontSize = 11;

%% Export
printfg(hf, 'decayrates', {'png', 'pdf', 'eps'}, [5 3], prop);

%% Restore path
rmpath ../../