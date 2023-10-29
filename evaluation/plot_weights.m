% This script is not refined for the renewed function multiAxes.m


% clear;
% 
% num = 200; % 主成分个数
% 
test_num = 14;
train_num =60;
% % 集外数据
% coe_test = zeros(num, 200, test_num);
% coe_test_ori_l = zeros(num, 200, test_num/2);
% coe_test_ori_r = zeros(num, 200, test_num/2);
% 
% for n = 1 : 101
%     load(strcat('../net data/coeff_f', num2str(n), 'test_out.mat'))
%     coe_test(:, n, :) = reshape(test_out', [num 1 test_num]);
% end
% 
% coe_test_l = coe_test(:, :, 1:test_num/2);
% coe_test_r = coe_test(:, :, (test_num/2+1):test_num);
% 
% for n = 1 : 101
%     load(strcat('../net data/coeff_f', num2str(n), 'test_ori_l.mat'))
%     load(strcat('../net data/coeff_f', num2str(n), 'test_ori_r.mat'))
%     coe_test_ori_l(:, n, :) = reshape(p_l_test', [num 1 test_num/2]);
%     coe_test_ori_r(:, n, :) = reshape(p_r_test', [num 1 test_num/2]);
% end
% for n = 102 : 200
%     coe_test_l(:, n, :) = coe_test_l(:, 202-n, :);
%     coe_test_r(:, n, :) = coe_test_r(:, 202-n, :);
%     coe_test_ori_l(:, n, :) = coe_test_ori_l(:, 202-n, :);
%     coe_test_ori_r(:, n, :) = coe_test_ori_r(:, 202-n, :);
% end
% 
% 
% % 集内数据
% coe_train = zeros(num, 200, train_num);
% coe_train_ori_l = zeros(num, 200, train_num/2);
% coe_train_ori_r = zeros(num, 200, train_num/2);
% 
% for n = 1 : 101
%     load(strcat('../net data/coeff_f', num2str(n), 'train_out.mat'))
%     coe_train(:, n, :) = reshape(train_out', [num 1 train_num]);
% end
% 
% coe_train_l = coe_train(:, :, 1:train_num/2);
% coe_train_r = coe_train(:, :, (train_num/2+1):train_num);
% 
% for n = 1 : 101
%     load(strcat('../net data/coeff_f', num2str(n), '_train_ori_l.mat'))
%     load(strcat('../net data/coeff_f', num2str(n), 'train_ori_r.mat'))
%     coe_train_ori_l(:, n, :) = reshape(p_l_train', [num 1 train_num/2]);
%     coe_train_ori_r(:, n, :) = reshape(p_r_train', [num 1 train_num/2]);
% end
% for n = 102 : 200
%     coe_train_l(:, n, :) = coe_train_l(:, 202-n, :);
%     coe_train_r(:, n, :) = coe_train_r(:, 202-n, :);
%     coe_train_ori_l(:, n, :) = coe_train_ori_l(:, 202-n, :);
%     coe_train_ori_r(:, n, :) = coe_train_ori_r(:, 202-n, :);
% end
% 
% % 选择要计算的对象
% coe_l = cat(3,coe_train_l,coe_test_l);
% coe_r = cat(3,coe_train_r,coe_test_r);
% coe_ori_l = cat(3,coe_train_ori_l,coe_test_ori_l);
% coe_ori_r = cat(3,coe_train_ori_r,coe_test_ori_r);
l = train_num/2+test_num/2; 
r = l;
% 
% save('./data_weights', 'coe_l', 'coe_r', 'coe_ori_l', 'coe_ori_r');

load('./data_weights', 'coe_l', 'coe_r', 'coe_ori_l', 'coe_ori_r');

cmax = squeeze(max(max([coe_l; coe_ori_l])));
cmin = squeeze(min(min([coe_l; coe_ori_l])));
clim = [cmin, cmax];
cmin(:) = 0;
% clim = [zeros(r, 1), cmax - cmin];

fs=44100;
f=(0:size(coe_l, 2)-1)'*fs/size(coe_l, 2);
x = f(1:floor(length(f)/2)+1)'/1000;
y = 1:50;
indx = 1:length(x);

NCol = 1;
margin = [0.03 0.25 0.1 0.01 ... top bottom left right
    0.3 0 0 0 ... headr tailr headc tailc
    0.03 0.05];% rgap cgap
margin = [0.03 0.25 0.08 0.1 ... top bottom left right
    0 0 0 0 ... headr tailr headc tailc
    0.03 0.01];% rgap cgap
[ha, ~, mr] = multiAxes(1, 2, NCol, margin, [150 500], 'Times New Roman', 'Order Index', 'Frequency (kHz)', ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on');%, 'XTick', azims, 'YTick', elevs, 'YTick', [0:10:40]
gcf;
colormap(gray);

for col=4%(1:NCol)+32
    colx = 1;%mod(col-1, 5)+1;
    axes(ha(1, colx));
    surf(y, x, coe_ori_l(y,indx,col)'-cmin(col), 'edgecolor', 'none');
%     shading interp;
    caxis(clim(col, :));
    view(0,90);
%     colorbar('northoutside');
    axes(ha(2, colx));
    surf(y, x, coe_l(y,indx,col)'-cmin(col), 'edgecolor', 'none');
%     shading interp;
    caxis(clim(col, :));
    view(0,90);
%     axes(ha(3, colx));
%     surf(y, x, abs(coe_l(y,indx,col) - coe_ori_l(y,indx,col))', 'edgecolor', 'none');
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

print(['../latex_final/weights1-50'], '-dpdf');
print(['../latex_final/weights1-50'], '-dpng', '-r600');

err_coe_l = abs(coe_ori_l(:, 1:101, :) - coe_l(:, 1:101, :));
err = squeeze(mean(err_coe_l, 1));
%%
figure(2);
clf;
plot(x(1:100), err(1:100, 4), '-', x(1:100), mean(err(1:100, :), 2), '--');
xlim([0 21]);
xlabel('Frequency (kHz)', 'fontname', 'Times New Roman');
ylabel('prediction error (dB)', 'fontname', 'Times New Roman');
legend({'subject_033', 'average'}, 'location', 'best', 'interpreter', 'none', 'fontname', 'Times New Roman');

set(gcf, 'position', [100 100 600 300], ...
    'PaperPosition', [0 0 600/35 300/35], ...
    'PaperSize', [600/35 300/35]);
print(['../latex_final/weights_err'], '-dpng', '-r600');
legend('boxoff');
print(['../latex_final/weights_err'], '-deps');