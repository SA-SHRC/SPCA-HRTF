function [ha, mtop, mright] = multiAxes(hf, nrow, ncol, margin, resolution, fontname, xlabels, ylabels, varargin)
% MULITAXES generates multiple axeses in a figure. The handles of axeses are arranged
% in a matrix with dimension of nrow*ncol. 
% hf : figure index
% nrow : number of rows of subplots
% ncol : number of columns of subplots
% margin : [top bottom left right headr tailr headc tailc rgap cgap] 0.03 ~ 0.3
% resolution : [height, width], 200
% fontname : 'Arial', 'Helvetica', 'Times New Roman', or 'Microsoft YaHei'
% varargin : properties of the axeses, such as, 'xtick', 'xlim', 'xgrid'
%            and so on.

% Zhongshu Ge, 2023-8-25, gezhongshu@foxmail.com

narginchk(8,40);

switch length(margin)
    case 1,
        margin(2:4) = margin(1);
        margin(5:10) = 0;
    case 4,
        margin(5:10) = 0;
end
mt = margin(1);
mb = margin(2);
ml = margin(3);
mr = margin(4);
rgap = margin(9);
cgap = margin(10);
htrc = zeros(nrow, ncol, 4); %  headr tailr headc tailc
htrc(1, :, 1) = margin(5);
htrc(:, 1, 2) = margin(7);
htrc(end, :, 3) = margin(6);
htrc(:, end, 4) = margin(8);
figure(hf);
clf;
axesH = (1 - (mt + mb + sum(margin(5:6)) + rgap*(nrow-1)))/nrow;
axesW = (1 - (mr + ml + sum(margin(7:8)) + cgap*(ncol-1)))/ncol;
if(isscalar(resolution)); resolution(2) = resolution(1);end
height = round(resolution(1)*nrow);
width = round(resolution(2)*ncol);
set(gcf, 'Position', [100 300-50*nrow width height], ...
    'PaperPosition', [0 0 width/35 height/35], ...
    'PaperSize', [width/35 height/35]);

% script = 'set(ha(row, col)';
% for i = 1:nargin-8
%     script = [script ', varargin{' num2str(i) '}'];
% end
% script = [script ');'];

for p = 1:nrow*ncol
    row = ceil(p/ncol);
    col = p - ncol*(row-1);
    ha(row, col) = axes('Position', [(ml+margin(7)*(col>1))+(col-1)*(axesW+cgap) ...
        (mb+margin(6)*(row<nrow))+(nrow-row)*(axesH+rgap) ...
        (axesW) + sum(htrc(row, col, [2 4])) ...
        (axesH) + sum(htrc(row, col, [1 3]))]);
    if(nargin>8)
%         eval(script);
        set(ha(row, col), 'fontname', fontname, varargin{:});
    end
    if(col>1)
        set(ha(row, col), 'YTickLabel', []);
    else
        ylabel(ylabels, 'fontname', fontname);
    end
    if(row<nrow)
        set(ha(row, col), 'XTickLabel', []);
    else
        xlabel(xlabels, 'fontname', fontname);
    end
    axis tight;
    hold on;
end
if(nargout>1)
    mtop = (mb)/nrow+(nrow-1)*axesH/nrow + (axesH+sum(htrc(1,1,1:2)))/nrow;
end
if(nargout>2)
    mright = (ml)/ncol+(ncol-1)*axesW/ncol + (axesW+sum(htrc(1,ncol,3:4)))/ncol;
end