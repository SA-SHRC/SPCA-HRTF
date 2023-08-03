
clear;

%% LOAD DATA
load(strcat('../net data/basis_train_front.mat'));
load(strcat('../net data/basis_train_back.mat'));
load(strcat('../net data/hav_train_front.mat'));
load(strcat('../net data/hav_train_back.mat'));
load(strcat('../net data/basis_test_front.mat'));
load(strcat('../net data/basis_test_back.mat'));
load(strcat('../net data/hav_test_front.mat'));
load(strcat('../net data/hav_test_back.mat'));
load(strcat('../net data/total_l.mat'));
load(strcat('../net data/total_r.mat'));

load('../net data/itd_test_front_total.mat');
load('../net data/itd_test_back_total.mat');
load('../net data/itd_train_front_total.mat');
load('../net data/itd_train_back_total.mat');

num = 200; % 主成分个数
train_num =60;
coe_train = zeros(num, 200, train_num);

for n = 1 : 101
    load(strcat('../net data/coeff_f', num2str(n), 'train_out.mat'))
    coe_train(:, n, :) = reshape(train_out', [num 1 train_num]);
end

coe_train_l = coe_train(:, :, 1:train_num/2);
coe_train_r = coe_train(:, :, (train_num/2+1):train_num);

for n = 102 : 200
    coe_train_l(:, n, :) = coe_train_l(:, 202-n, :);
    coe_train_r(:, n, :) = coe_train_r(:, 202-n, :);
end


test_num = 14;
coe_test = zeros(num, 200, test_num);

for n = 1 : 101
    load(strcat('../net data/coeff_f', num2str(n), 'test_out.mat'))
    coe_test(:, n, :) = reshape(test_out', [num 1 test_num]);
end

coe_test_l = coe_test(:, :, 1:test_num/2);
coe_test_r = coe_test(:, :, (test_num/2+1):test_num);

for n = 102 : 200
    coe_test_l(:, n, :) = coe_test_l(:, 202-n, :);
    coe_test_r(:, n, :) = coe_test_r(:, 202-n, :);
end
% 合并系数
coe_l = [permute(coe_train_l, [3, 1, 2]); permute(coe_test_l, [3, 1, 2])];
coe_l = permute(coe_l, [2, 3, 1]);
coe_r = [permute(coe_train_r, [3, 1, 2]); permute(coe_test_r, [3, 1, 2])];
coe_r = permute(coe_r, [2, 3, 1]);

total_num = 37;

%% Reconstruct HRTF

% 930个方向，1~625左耳；467~930右耳
dataSet = [1, 2 : 4 : 154, 170 : 4 : 454, 470 : 4 : 1250, 3 : 4 : 55, 71 : 4 : 555, 571 : 4 : 779, 795 : 4 : 1079, 1095 : 4 : 1247, 4 : 4 : 680, 696 : 4 : 1180, 1196 : 4 : 1248, 1237, 1241, 1245, 1249, 9, 13, 17, 309, 313, 317, 609, 613, 617, 933, 937, 941]; % 除测试集外930组数据
trainSet = dataSet([2 : 5 : 927, 3 : 5 : 928, 4 : 5 : 929, 5 : 5 : 930, 901, 906, 911, 916, 921, 926]); % 训练集：750组数据
validSet = dataSet(1 : 5 : 896); % 验证集：180组数据
testSet = [5, 21 : 4 : 305, 321 : 4 : 605, 621 : 4 : 929, 945 : 4 : 1233, 59, 63, 67, 158, 162, 166, 458, 462, 625, 559, 563, 567, 684, 688, 692, 783, 787, 791, 1083, 1087, 1091, 1184, 1188, 1192]; % 测试集：320组数据
trainingdata = [trainSet, validSet];
totalSet = [trainingdata, testSet];
[~, inds] = sort(totalSet);
% 合并基函数
basis_front = [basis_train_front; basis_test_front];
basis_back = [basis_train_back; basis_test_back];
hav_front = [hav_train_front; hav_test_front];
hav_back = [hav_train_back; hav_test_back];
% 调整基函数排序为 1~1250
basis_front = basis_front(inds, :); % 左耳水平角-80～80,右耳80～-80，下同
basis_back = basis_back(inds, :);
hav_front = hav_front(inds, :);
hav_back = hav_back(inds, :);

hd_l_front = zeros(total_num, 200, 625);
hd_r_front = zeros(total_num, 200, 625);
hrtf_l_front = zeros(total_num, 200, 625);
hrtf_r_front = zeros(total_num, 200, 625);
hd_l_back = zeros(total_num, 200, 625);
hd_r_back = zeros(total_num, 200, 625);
hrtf_l_back = zeros(total_num, 200, 625);
hrtf_r_back = zeros(total_num, 200, 625);

for i = 1 : total_num
    for l = 1 : 625
        hd_l_front(i, :, l) = coe_l(:, :, i)'*basis_front(l, :)';
        hd_l_back(i, :, l) = coe_l(:, :, i)'*basis_back(l, :)';
        hrtf_l_front(i, :, l) = hd_l_front(i, :, l) + hav_front(l) + total_l;
        hrtf_l_back(i, :, l) = hd_l_back(i, :, l) + hav_back(l) + total_l;
        r = l + 625; % 1250 - ceil(l/25)*25 + mod(l-1, 25) + 1; % 调整右耳水平角顺序为-80～80
        hd_r_front(i, :, l) = coe_r(:, :, i)'*basis_front(r, :)';
        hd_r_back(i, :, l) = coe_r(:, :, i)'*basis_back(r, :)';
        hrtf_r_front(i, :, l) = hd_r_front(i, :, l) + hav_front(r)+ total_r;
        hrtf_r_back(i, :, l) = hd_r_back(i, :, l) + hav_back(r) + total_r;
    end
end

%% 重建hrir
itd_front = [itd_train_front; itd_test_front];
itd_back = [itd_train_back; itd_test_back];
itd_front = reshape(itd_front, [625, total_num]); % 方向先变仰角后水平角，301～325为中平面
itd_back = reshape(itd_back, [625, total_num]);
hrir_front_l = zeros(total_num, 200, 625);
hrir_front_r = zeros(total_num, 200, 625);
hrir_back_l = zeros(total_num, 200, 625);
hrir_back_r = zeros(total_num, 200, 625);
for i = 1 : 625
    dirc = (ceil(i/25)*50-25); % 调整301～325为625
    [hrir_front_l(:, :, i), hrir_front_r(:, :, i)] = reconstr(hrtf_l_front(:, :, i), hrtf_r_front(:, :, i), itd_front(i, :), dirc, total_num);
    [hrir_back_l(:, :, i), hrir_back_r(:, :, i)] = reconstr(hrtf_l_back(:, :, i), hrtf_r_back(:, :, i), itd_back(i, :), dirc, total_num);
end
for i = 1:total_num
    sub_front_l = permute(reshape(squeeze(hrir_front_l(i, :, :))', [25, 25, 200]), [2, 1, 3]); % 调整行变化水平角，列仰角
    sub_front_r = permute(reshape(squeeze(hrir_front_r(i, :, :))', [25, 25, 200]), [2, 1, 3]);
    sub_back_l = permute(reshape(squeeze(hrir_back_l(i, :, :))', [25, 25, 200]), [2, 1, 3]);
    sub_back_r = permute(reshape(squeeze(hrir_back_r(i, :, :))', [25, 25, 200]), [2, 1, 3]);
    hrir_l = [sub_front_l, sub_back_l]; % 拼接为25×50×200标准存储顺序
    hrir_r = [sub_front_r, sub_back_r];
    outdir = ['../net data/', num2str(i), '/'];
    if(~isdir(outdir));mkdir(outdir);end
    save([outdir, 'hrir_predict_spca.mat'], 'hrir_l', 'hrir_r');
end