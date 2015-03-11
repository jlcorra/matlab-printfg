function printfg(hfig, name, output, resize, prop)
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
%       hfig    : Figure handle to print
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
%   See also: SAVEAS, PRINT.

%   For the full copyright and license information, please view the LICENSE
%   file that was distributed with this source code.
%
%   @license http://opensource.org/licenses/MIT MIT License
%   @copyright Copyright (c) 2014 José L. Corrales

%% Arguments
if nargin <= 2
    error('Requires handle to figure, filename and extension.');
end
if length(hfig) > 1 || ~isgraphics(hfig)
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
    hax = findobj(get(hfig, 'Children'), 'Type', 'Axes',...
        '-not', 'Tag', 'legend', '-not', 'Tag', 'colorbar');
else
    hax = findobj(get(hfig, 'Children'), 'Type', 'Axes');
end

% Plot handles
hpl = findobj(get(hax, 'Children'), 'Type', 'Line');

% Legend handles
% On MATLAB R2014b and higher, legends have their own graphic object type
if verLessThan('matlab','8.4.0')
    hlg = findobj(get(hfig, 'Children'), 'Type', 'Axes', 'Tag', 'legend');
else
    hlg = findobj(get(hfig, 'Children'), 'Type', 'Legend');
end

%% Figure size properties
if isempty(resize)
    % Ensure paper size adjusts to figure size (no whitespace)
    set(hfig, 'PaperPositionMode', 'auto');
    paperp = get(hfig, 'PaperPosition');
    resize = [paperp(3), paperp(4)];
elseif ~isfield(prop, 'Figure') || ~isfield(prop.Figure, 'PaperUnits')
    prop.Figure.PaperUnits = 'points';
end

if ~isfield(prop, 'Figure') || ~isfield(prop.Figure, 'PaperSize')
    prop.Figure.PaperSize = [resize(1), resize(2)];
end
if ~isfield(prop, 'Figure') || ~isfield(prop.Figure, 'PaperPositionMode')
    prop.Figure.PaperPositionMode = 'manual';
end
if ~isfield(prop, 'Figure') || ~isfield(prop.Figure, 'PaperPosition')
    prop.Figure.PaperPosition = [0, 0, resize(1), resize(2)];
end

%% Apply properties
% Figure
if isfield(prop, 'Figure')
    set(hfig, prop.Figure);
end
% Plot lines & markers
if isfield(prop, 'Line')
    set(hpl, prop.Line);
end
% Axis lines, ticks & tick labels
% [!] Axis font is also applied to legends and labels, depending on MATLAB
% version
if isfield(prop, 'Axes')
    set(hax, prop.Axes);
end
% Labels
if isfield(prop, 'XLabel')
    set(get(hax, 'XLabel'), prop.XLabel);
end
if isfield(prop, 'YLabel')
    set(get(hax, 'YLabel'), prop.YLabel);
end
if isfield(prop, 'ZLabel')
    set(get(hax, 'ZLabel'), prop.ZLabel);
end
% Title
if isfield(prop, 'Title')
    set(get(hax, 'Title'), prop.Title);
end
% Legend
if isfield(prop, 'Legend')
    set(hlg, prop.Legend);
end

%% Remove additional whitespace margins
% Undocumented property, might cause some issues with the LaTeX interpreter
LooseInset = get(hax, {'LooseInset'});
set(hax, {'LooseInset'}, get(hax, {'TightInset'}));

%% Print figure to file
for i = 1:length(output)
    filename = sprintf('%s.%s', name, output{i});
    switch output{i}
        case 'eps'
            % Workaround R2014b issues with PostScript printing margins 
            if verLessThan('matlab','8.4.0')
                print(hfig, filename, '-depsc', '-r300', '-painters');
            else
                print(hfig, filename, '-depsc', '-r300', '-loose',...
                    '-painters');
            end
        case 'pdf'
            print(hfig, filename, '-dpdf', '-r300', '-painters');
        otherwise
            saveas(hfig, filename, output{i});
    end
end

%% Restore whitespace margins
set(hax, {'LooseInset'}, LooseInset);
