function printfg(hFig, name, output, resize, prop)
%PRINTFG Print figure to a file using specified format
%
%   Prints the figure with the handle hfig to a file at the specified size 
%   using a supported format. If a style is provided, then this function will 
%   try to apply the corresponding properties to every axis, line, label, 
%   title and legend object found under figure hfig.
%
%   PRINTFG(hfig, 'filename', output)
%   PRINTFG(hfig, 'filename', output, [width, height])
%   PRINTFG(hfig, 'filename', output, [width, height], prop)
%
%   Arguments:
%       hFig    : Figure handle to print
%       name    : Output filename without extension
%       output  : Cell array of output formats
%       width   : Printing width (points by default)
%       height  : Printing height (points by default)
%       prop    : Struct array of figure properties to be overloaded
%
%   Examples:
%       printfg(hf1, 'figure1', 'png', [350 275]);
%       printfg(hf1, 'figure1', {'eps', 'png'}, [350 275]);
%       printfg(hf2, 'figure2', {'eps', 'png'}, [350 275], prop);
%
%   License:
%       MIT License (http://opensource.org/licenses/MIT)
%       Copyright (c) 2015 José L. Corrales <https://github.com/jlcorra>
%

%% Arguments
if nargin <= 2
    error('Requires handle to figure, filename and extension.');
end
if length(hFig) > 1 || ~isgraphics(hFig)
    error('Figure handle must be a single valid graphic object.');
end
if ~exist('resize', 'var')
    resize = [];
elseif ~isempty(resize) && length(resize) ~= 2
    error(['Print size must be a 2-element vector containing ',...
        'width and height.']);
end
if ~exist('prop', 'var')
    prop = struct();
end

% Make sure output is a cell array of strings
output = cellstr(output);

%% Recover figure handles
% Axis handles
% Filter legend & colorbar handles on MATLAB R2014a and earlier
if verLessThan('matlab','8.4.0')
    hAx = findobj(hFig, 'Type', 'Axes', '-not', 'Tag', 'legend',...
        '-not', 'Tag', 'colorbar');
else
    hAx = findobj(hFig, 'Type', 'Axes');
end

% Line handles
hLine = findobj(hAx, 'Type', 'Line');

% Legend handles
% On MATLAB R2014b and higher, legends have their own graphic object type
if verLessThan('matlab','8.4.0')
    hLeg = findobj(hFig, 'Type', 'Axes', 'Tag', 'legend');
else
    hLeg = findobj(hFig, 'Type', 'Legend');
end

%% Size properties
if isempty(resize)
    set(hFig, 'PaperPositionMode', 'auto');
    % Ensure paper size adjusts to figure size (no whitespace)
    paperp = get(hFig, 'PaperPosition');
    resize = [paperp(3), paperp(4)];
else
    defs.Figure.PaperUnits = 'points';
end

defs.Figure.PaperSize = [resize(1), resize(2)];
defs.Figure.PaperPositionMode = 'manual';
defs.Figure.PaperPosition = [0, 0, resize(1), resize(2)];

%% Figure properties
if isfield(prop, 'Figure')
    % Find default fields that were not overriden by the user
    fn = fieldnames(defs.Figure);
    fn = fn(~isfield(prop.Figure, fn));
    % Merge defaults with user properties
    for k = 1:length(fn)
        prop.Figure.(fn{k}) = defs.Figure.(fn{k});
    end
    set(hFig, prop.Figure);
else
    set(hFig, defs.Figure);
end

%% Plot lines & markers
if isfield(prop, 'Line')
    set(hLine, prop.Line);
end

%% Axis lines, ticks & tick labels
% [!] Axis font is also applied to legends and labels, depending on MATLAB
% version
if isfield(prop, 'Axes')
    set(hAx, prop.Axes);
end

%% Labels
if isfield(prop, 'XLabel')
    for n = 1:length(hAx)
        set(get(hAx(n), 'XLabel'), prop.XLabel);
    end
end
if isfield(prop, 'YLabel')
    for n = 1:length(hAx)
        set(get(hAx(n), 'YLabel'), prop.YLabel);
    end
end
if isfield(prop, 'ZLabel')
    for n = 1:length(hAx)
        set(get(hAx(n), 'ZLabel'), prop.ZLabel);
    end
end

%% Title
if isfield(prop, 'Title')
    for n = 1:length(hAx)
        set(get(hAx(n), 'Title'), prop.Title);
    end
end

%% Legend
if isfield(prop, 'Legend')
    set(hLeg, prop.Legend);
end

%% Remove additional whitespace margins
% Undocumented property, might cause some issues with the LaTeX interpreter
LooseInset = get(hAx, {'LooseInset'});
set(hAx, {'LooseInset'}, get(hAx, {'TightInset'}));

%% Print figure to file
for i = 1:length(output)
    filename = sprintf('%s.%s', name, output{i});
    switch output{i}
        case 'eps'
            % Workaround R2014b issues with PostScript printing margins 
            if verLessThan('matlab','8.4.0')
                print(hFig, filename, '-depsc', '-r300', '-painters');
            else
                print(hFig, filename, '-depsc', '-r300', '-loose',...
                    '-painters');
            end
        case 'pdf'
            print(hFig, filename, '-dpdf', '-r300', '-painters');
        otherwise
            saveas(hFig, filename, output{i});
    end
end

%% Restore whitespace margins
set(hAx, {'LooseInset'}, LooseInset);
