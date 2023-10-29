% This script is not refined for the renewed function multiAxes.m

% clear;
% 
% load('../net data/itd_test_front_total.mat');
% load('../net data/itd_test_back_total.mat');
% load('../net data/itd_train_front_total.mat');
% load('../net data/itd_train_back_total.mat');
total_num = 37;
% itd_front = [itd_train_front; itd_test_front];
% itd_back = [itd_train_back; itd_test_back];
% out_front = reshape(itd_front, [625, total_num])/44.1; % 方向先变仰角后水平角，301～325为中平面
% out_back = reshape(itd_back, [625, total_num])/44.1;
% 
% load('../net data/itd.mat');
% ori = reshape(itd(:, 1:total_num), [50 25 total_num])/44.1;
% 
% cmax = max(max([out_front; out_back]), max(reshape(ori, [1250, total_num])));
% cmin = min(min([out_front; out_back]), min(reshape(ori, [1250, total_num])));
% clim = [cmin', cmax'];
% clim = [zeros(37, 1), cmax' - cmin'];
% out = [reshape(out_front(:, :), [25, 25, 37]); reshape(out_back(:, :), [25, 25, 37])];
% out(:,:,1:30) = [];
% ori(:,:,1:30) = [];
% clim(1:30, :) = [];
% cmax(1:30) = [];
% cmin(1:30) = [];
% save('./data_itds', 'out', 'ori', 'cmax', 'cmin', 'clim');

load('./data_itds', 'out', 'ori', 'cmax', 'cmin', 'clim');

azims = [-80 -65 -55 -45:5:45 55 65 80];
elevs = -45:5.625:235;

testSet = [1, 5, 21 : 4 : 305, 321 : 4 : 605, 621, 625, 59, 63, 67, 158, 162, 166, 458, 462, 466, 559, 563, 567]; % 测试集：160组数据
[i,j] = ind2sub([25 25], testSet);
indMat = zeros(50, 25, total_num);
for ind = 1:length(i)
    indMat(i(ind), j(ind), :) = 1;
    indMat(i(ind)+25, j(ind), :) = 1;
end

% ori(~indMat) = -5;

NRow = 1;%7;
margin = [0.03 0.2 0.3 0 ... top bottom left right
    0 0 0 0.3 ... headr tailr headc tailc
    0.03 0.05];% rgap cgap
ha = multiAxes(1, NRow, 2, margin, [200 150], 'Times New Roman', 'Azimuth (Deg)', 'Elevation (Deg)', ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on');%, 'XTick', azims, 'YTick', elevs
gcf;
colormap(gray);

for row=1:NRow
%     strOrd = {'1st', '2nd', '3rd', '4th', '5th', '6th'};
    axes(ha(1, 1));
    surf(azims, elevs, ori(:,:,4)-cmin(4), 'edgecolor', 'none');
%     shading interp;
    caxis(clim(row, :));
    view(0,90);
    axes(ha(1, 2));
    surf(azims, elevs, out(:,:,4)-cmin(4), 'edgecolor', 'none');
%     shading interp;
    caxis(clim(row, :));
    view(0,90);
    colorbar('eastoutside');
%     axes(ha(3, col));
%     surf(azims, elevs, abs(out(:,:,col) - ori(:,:,col)), 'edgecolor', 'none');
%     shading interp;
%     caxis(clim(col, :));
%     view(0,90);
% print(['../latex/' num2str(n) 'spc.eps'], '-deps');
% pause;
end

print(['../latex_final/itd_34'], '-dpdf');
print(['../latex_final/itd_34'], '-dpng', '-r600');