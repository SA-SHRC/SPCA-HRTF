% This script is not refined for the renewed function multiAxes.m

% 
% clear;
% 
% % 集外数据
% load(strcat('../net data/hav_test_front.mat'));
% load(strcat('../net data/hav_test_back.mat'));
% load(strcat('../net data/hav_test_ori_front.mat'));
% load(strcat('../net data/hav_test_ori_back.mat'));
% 
% % 集内数据
% load(strcat('../net data/hav_train_ori_front.mat'))
% load(strcat('../net data/hav_train_ori_back.mat'))
% load(strcat('../net data/hav_train_front.mat'))
% load(strcat('../net data/hav_train_back.mat'))
% 
% % 选择要计算的对象
% out_front = [hav_train_front; hav_test_front];
% out_back = [hav_train_back; hav_test_back];
% ori_front = [hav_train_ori_front; hav_test_ori_front];
% ori_back = [hav_train_ori_back; hav_test_ori_back];
% l = 466+159; %集内为466，集外为159
% r = 464+161; %集内为464，集外为161
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
% clim = [0, cmax' - cmin'];
% out = [reshape(out_front(order), [25, 25, 2]); reshape(out_back(order), [25, 25, 2])];
% ori = [reshape(ori_front(order), [25, 25, 2]); reshape(ori_back(order), [25, 25, 2])];
% 
% save('./data_ctfs', 'out', 'ori', 'cmax', 'cmin', 'clim');

load('./data_ctfs', 'out', 'ori', 'cmax', 'cmin', 'clim');
clim = clim + repmat(cmin', 1,2);
cmin(:) = 0;

azims = [-80 -65 -55 -45:5:45 55 65 80];
elevs = -45:5.625:235;


NRow = 1;
margin = [0.03 0.2 0.3 0 ... top bottom left right
    0 0 0 0.3 ... headr tailr headc tailc
    0.03 0.05];% rgap cgap
ha = multiAxes(1, NRow, 2, margin, [200 150], 'Times New Roman', 'Azimuth (Deg)', 'Elevation (Deg)', ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on');%, 'XTick', azims, 'YTick', elevs
gcf;
colormap(gray);

for row=1:NRow
%     strOrd = {'1st', '2nd', '3rd', '4th', '5th', '6th'};
    axes(ha(row, 1));
    surf(azims, elevs, ori(:,:,row)-cmin, 'edgecolor', 'none');
%     shading interp;
    caxis(clim);
    view(0,90);
    axes(ha(row, 2));
    surf(azims, elevs, out(:,:,row)-cmin, 'edgecolor', 'none');
%     shading interp;
    caxis(clim);
    view(0,90);
    colorbar('eastoutside');
%     axes(ha(row, 3));
%     surf(azims, elevs, abs(out(:,:,row) - ori(:,:,row)), 'edgecolor', 'none');
%     shading interp;
%     caxis(clim);
%     view(0,90);
% print(['../latex/' num2str(n) 'spc.eps'], '-deps');
% pause;
end

print(['../latex_final/ctf_L'], '-dpdf');
print(['../latex_final/ctf_L'], '-dpng', '-r600');