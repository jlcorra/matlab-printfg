function print_fig(hfig, filename, format, resize, properties)
%PRINT_FIG Print figure to a file using specified format
%
%   Prints the figure with the handle hfig to the file filename at the 
%   specified size using a supported format. If a style is provided, then
%   this function will try to apply the corresponding properties to every 
%   plot, axis, label and legend object found under figure hfig.
%
%   PRINT_FIG(hfig, 'filename', format)
%   PRINT_FIG(hfig, 'filename', format, [width, height])
%   PRINT_FIG(hfig, 'filename', format, [width, height], properties)
%
%   Arguments:
%       hfig    : Figure handle to print
%       filename    : Filename without extension
%       format  : Output format. See SAVEAS or PRINT for supported formats
%       width   : Printing width in points
%       height  : Printing height in points
%       properties  : Struct array of figure properties to be overloaded
%
%   Examples:
%       print_fig(hf1, 'figure1', 'png', [350 275]);
%       print_fig(hf1, 'figure1', {'eps', 'png'}, [350 275]);
%       print_fig(hf2, 'figure2', {'eps', 'png'}, [350 275], style);
%
%   See also: SAVEAS, PRINT.

%   For the full copyright and license information, please view the LICENSE
%   file that was distributed with this source code.
%
%   @license http://opensource.org/licenses/MIT MIT License
%   @copyright Copyright (c) 2014 José L. Corrales

%% Arguments
if nargin <= 2
    error('Requires handle to figure, filename and format.');
end

%% Recover figure handles
% Axis handles
hax = findall(hfig, 'Type', 'Axes');
hax = hax(~ismember(get(hax, 'Tag'), {'legend', 'colorbar'}));

% Plot handles
hpl = findall(hfig, 'Type', 'Line');

% Legend handles
hlg = findall(hfig, 'Type', 'Axes', 'Tag', 'legend');
%hlg = hlg(ismember(get(hlg, 'Interpreter'), {'latex'}));

%% Default properties
% Some safe standard properties definitions that make plots look nice by
% default. Overload as neccessary.
prop.Axes.Box = 'off';
prop.Axes.LineWidth = 1;

prop.Line.LineWidth = 1;
prop.Line.MarkerSize = 6;

%% Printing dimensions
if ~exist('resize', 'var') || isempty(resize)
    prop.Figure.PaperPositionMode = 'auto';
elseif length(resize) == 2
    prop.Figure.PaperUnits = 'points';
    prop.Figure.PaperPositionMode = 'manual';
    prop.Figure.PaperPosition = [0, 0, resize(1), resize(2)];
else
    error(['Figure dimensions must be a 2-element vector containing ',...
        'width and height.']);
end

%% Overload default properties with user style
f1 = {'Figure', 'Line', 'Axes', 'Label', 'Title', 'Legend'};
% Dynamic fieldnames are only supported in R2014a and above
if exist('properties', 'var') && ~isempty(properties)
    for i = find(isfield(properties, f1))
        f2 = fieldnames(properties.(f1{i}));
        for k = 1:length(f2)
            prop.(f1{i}).(f2{k}) = properties.(f1{i}).(f2{k});
        end
    end
end

%% Figure
if isfield(prop, 'Figure') && ~isempty(prop.Figure)
    set(hfig, prop.Figure);
end

%% Plot lines & markers
if isfield(prop, 'Line') && ~isempty(prop.Line)
    set(hpl, prop.Line);
end

%% Axis lines & ticks
% [!] Axis font is also applied to legends
if isfield(prop, 'Axes') && ~isempty(prop.Axes)
    set(hax, prop.Axes);
end

%% Axis labels & title
% Apply label properties to title, overload if neccessary
if isfield(prop, 'Label') && ~isempty(prop.Label)
    set(cell2mat(get(hax, {'XLabel', 'YLabel', 'Title'})), prop.Label);
end
if isfield(prop, 'Title') && ~isempty(prop.Title)
    set(get(hax, 'Title'), prop.Title);
end

%% Legends
if isfield(prop, 'Legend') && ~isempty(prop.Legend)
    set(hlg, prop.Legend);
end

%% Remove additional whitespace margins
% Undocumented property, might cause some issues with the LaTeX interpreter
% Can be disabled through overloading, i.e.:
%   properties.Axes.TightInset = get(gca, 'LooseInset')
LooseInset = get(hax, {'LooseInset'});
set(hax, {'LooseInset'}, get(hax, {'TightInset'}));

%% Print figure to file
format = cellstr(format);
for i = 1:length(format)
    switch format{i}
        case 'eps'
            print(hfig, '-depsc2', filename);
        case {'png', 'jpeg', 'tiff'}
            print(hfig, ['-d', format{i}], '-r150', filename);
        otherwise
            saveas(hfig, filename, format{i});
    end
end

%% Restore whitespace margins
set(hax, {'LooseInset'}, LooseInset);

end
