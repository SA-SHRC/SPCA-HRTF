% This script is not refined for the renewed function multiAxes.m

% clear;
% 
% % 集外数据
% load(strcat('../net data/basis_test_front.mat'));
% load(strcat('../net data/basis_test_back.mat'));
% load(strcat('../net data/basis_test_ori_front.mat'));
% load(strcat('../net data/basis_test_ori_back.mat'));
% 
% % 集内数据
% load(strcat('../net data/basis_train_front.mat'));
% load(strcat('../net data/basis_train_back.mat'));
% load(strcat('../net data/basis_train_ori_front.mat'));
% load(strcat('../net data/basis_train_ori_back.mat'));
% 
% % 选择要计算的对象
% out_front = [basis_train_front; basis_test_front];
% out_back = [basis_train_back; basis_test_back];
% ori_front = [basis_train_ori_front; basis_test_ori_front];
% ori_back = [basis_train_ori_back; basis_test_ori_back];
% 
% testSet = [5, 21 : 4 : 305, 321 : 4 : 605, 621 : 4 : 929, 945 : 4 : 1233, 59, 63, 67, 158, 162, 166, 458, 462, 466, 559, 563, 567, 684, 688, 692, 783, 787, 791, 1083, 1087, 1091, 1184, 1188, 1192]; % 测试集：320组数据
% dataSet = [1, 2 : 4 : 154, 170 : 4 : 454, 470 : 4 : 1250, 3 : 4 : 55, 71 : 4 : 555, 571 : 4 : 779, 795 : 4 : 1079, 1095 : 4 : 1247, 4 : 4 : 680, 696 : 4 : 1180, 1196 : 4 : 1248, 1237, 1241, 1245, 1249, 9, 13, 17, 309, 313, 317, 609, 613, 617, 933, 937, 941]; % 除测试集外930组数据
% trainSet = dataSet([2 : 5 : 927, 3 : 5 : 928, 4 : 5 : 929, 5 : 5 : 930, 901, 906, 911, 916, 921, 926]); % 训练集：750组数据
% validSet = dataSet(1 : 5 : 896); 
% [set, order] = sort([trainSet, validSet, testSet]);
% 
% cmax = max(max([out_front; out_back]), max([ori_front; ori_back]));
% cmin = min(min([out_front; out_back]), min([ori_front; ori_back]));
% clim = [cmin', cmax'];
% clim = [zeros(200, 1), cmax' - cmin'];
% out = [reshape(out_front(order, :), [25, 25, 2, 200]); reshape(out_back(order, :), [25, 25, 2, 200])];
% ori = [reshape(ori_front(order, :), [25, 25, 2, 200]); reshape(ori_back(order, :), [25, 25, 2, 200])];
% 
% 
% save('./data_basis', 'out', 'ori', 'cmax', 'cmin', 'clim');

load('./data_basis', 'out', 'ori', 'cmax', 'cmin', 'clim');
clim = clim + repmat(cmin', 1,2);
clim = repmat([min(clim(1:4, 1)) max(clim(1:4, 2))], 4, 1);
cmin(:) = 0;

azims = [-80 -65 -55 -45:5:45 55 65 80];
elevs = -45:5.625:235;

NOrd = 4;
margin = [0.03 0.2 0.4 0.1 ... top bottom left right
    0.25 0 0 0 ... headr tailr headc tailc
    0.03 0.05];% rgap cgap
margin = [0.03 0.2 0.3 0.4 ... top bottom left right
    0 0 0 0 ... headr tailr headc tailc
    0.03 0.05];% rgap cgap
[ha, ~, mr] = multiAxes(1, 2, NOrd, margin, [200 150], 'Times New Roman', 'Azimuth (Deg)', 'Elevation (Deg)', ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on');%, 'XTick', azims, 'YTick', elevs
gcf;
colormap(gray);

for col=1:NOrd
%     strOrd = {'1st', '2nd', '3rd', '4th', '5th', '6th'};
    axes(ha(1, col));
    surf(azims, elevs, ori(:,:,1,col)-cmin(col), 'edgecolor', 'none');
%     shading interp;
    caxis(clim(col, :));
    view(0,90);
%     colorbar('northoutside');
    axes(ha(2, col));
    surf(azims, elevs, out(:,:,1,col)-cmin(col), 'edgecolor', 'none');
%     shading interp;
    caxis(clim(col, :));
    view(0,90);
%     axes(ha(3, col));
%     surf(azims, elevs, abs(out(:,:,1,col) - ori(:,:,1,col)), 'edgecolor', 'none');
%     shading interp;
%     caxis(clim(col, :));
%     view(0,90);
% print(['../latex/' num2str(n) 'spc.eps'], '-deps');
% pause;
end

axes('position', [mr, 0.1, 0.98-mr, 0.75]);
% set(gca, 'fontname', 'microsoft yahei');
caxis(clim(col, :));
axis off;
colorbar('west');

% print(['../latex_final/spc1-4.pdf'], '-dpdf');
% print(['../latex_final/spc1-4.png'], '-dpng', '-r600');