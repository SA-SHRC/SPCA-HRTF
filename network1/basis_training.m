
clear;

%% DATA
load(strcat('../net data/coeff_l.mat'));
load(strcat('../net data/coeff_r.mat'));

num = 200; % 主成分个数
coe_l = coeff_l (: ,1:num);
coe_r = coeff_r (: ,1:num);

coe_l_front = zeros(625,num);
coe_r_front = zeros(625,num);
coe_l_back = zeros(625,num);
coe_r_back = zeros(625,num);
for i = 1 :25
    coe_l_front((((i-1)*25+1): i*25), :) = coe_l((((i-1)*50+1):((i-1)*50+25)), :);
    coe_r_front((((i-1)*25+1): i*25), :) = coe_r((((i-1)*50+1):((i-1)*50+25)), :);
    coe_l_back((((i-1)*25+1): i*25), :) = coe_l((((i-1)*50+26):((i-1)*50+50)), :);
    coe_r_back((((i-1)*25+1): i*25), :) = coe_r((((i-1)*50+26):((i-1)*50+50)), :);
end

ref_l_front = repmat(coe_l (609, :), [625 1]); % 左耳 reference
ref_r_front = repmat(coe_r (609, :), [625 1]);
ref_l_back = repmat(coe_l (641, :), [625 1]);
ref_r_back = repmat(coe_r (641, :), [625 1]);

azimu = [-80 -65 -55 -45 -40 -35 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35 40 45 55 65 80]';
eleva = -45+5.625*(0:49);
eleva_front = eleva(1:25);
eleva_back = eleva(26:50);
ele_front = repmat(eleva_front', [25 1]);
ele_back = repmat(eleva_back', [25 1]);

for c = 1 : 25
    azi(((c-1)*25+1) : ((c-1)*25+25)) = repmat(azimu(c), [25 1]);
end

right_left = zeros(625, 1);
for i = 1 : 25
    right_left(((i-1)*25+1) : (i*25)) = ((625-i*25+1) : (625-(i-1)*25));
end
azi_r = zeros(625, 1);
for i = 1 : 625
    azi_r(i) = azi(right_left(i));
end
azi_l = azi';

input_front = [ref_l_front, azi_l, ele_front; ref_r_front, azi_r, ele_front];
output_front = [coe_l_front; coe_r_front];
input_back = [ref_l_back, azi_l, ele_back; ref_r_back, azi_r, ele_back];
output_back = [coe_l_back; coe_r_back];

% 共1250个方向，即1250组数据
testSet = [5, 21 : 4 : 305, 321 : 4 : 605, 621 : 4 : 929, 945 : 4 : 1233, 59, 63, 67, 158, 162, 166, 458, 462, 466, 559, 563, 567, 684, 688, 692, 783, 787, 791, 1083, 1087, 1091, 1184, 1188, 1192]; % 测试集：320组数据
dataSet = [1, 2 : 4 : 154, 170 : 4 : 454, 470 : 4 : 1250, 3 : 4 : 55, 71 : 4 : 555, 571 : 4 : 779, 795 : 4 : 1079, 1095 : 4 : 1247, 4 : 4 : 680, 696 : 4 : 1180, 1196 : 4 : 1248, 1237, 1241, 1245, 1249, 9, 13, 17, 309, 313, 317, 609, 613, 617, 933, 937, 941]; % 除测试集外930组数据
trainSet = dataSet([2 : 5 : 927, 3 : 5 : 928, 4 : 5 : 929, 5 : 5 : 930, 901, 906, 911, 916, 921, 926]); % 训练集：750组数据
validSet = dataSet(1 : 5 : 896); % 验证集：180组数据

train_in_front = input_front ([trainSet, validSet], :);
test_in_front = input_front (testSet, :);
train_in_back = input_back ([trainSet, validSet], :);
test_in_back = input_back (testSet, :);

basis_train_ori_front = output_front ([trainSet, validSet], :);
basis_test_ori_front = output_front (testSet, :);
basis_train_ori_back = output_back ([trainSet, validSet], :);
basis_test_ori_back = output_back (testSet, :);

save(strcat('../net data/basis_test_ori_front.mat'),'basis_test_ori_front')
save(strcat('../net data/basis_test_ori_back.mat'),'basis_test_ori_back')
save(strcat('../net data/basis_train_ori_front.mat'),'basis_train_ori_front')
save(strcat('../net data/basis_train_ori_back.mat'),'basis_train_ori_back')

% normalize
[train_in_front, mu_front, sigma_front] = zscore(train_in_front);
test_in_front = normalize(test_in_front, mu_front, sigma_front);
[basis_train_ori_front, mu_front_out, sigma_front_out] = zscore(basis_train_ori_front);

[train_in_back, mu_back, sigma_back] = zscore(train_in_back);
test_in_back = normalize(test_in_back, mu_back, sigma_back);
[basis_train_ori_back, mu_back_out, sigma_back_out] = zscore(basis_train_ori_back);

%% Training
% front
rand('state',0)
nn_front = nnsetup([(num+2) 180 180 180 num]);
opts_front.numepochs = 20000;   %  Number of full sweeps throubgh data
opts_front.batchsize = 10;  %  Take a mean gradient step over this many samples
opts_front.plot = 0; %  enable plotting
[nn_front, L_front] = nntrain(nn_front, train_in_front(1:750, :), basis_train_ori_front(1:750, :), opts_front, train_in_front(751:930, :), basis_train_ori_front(751:930, :),500);

% back
rand('state',0)
nn_back = nnsetup([(num+2) 180 180 180 num]);
opts_back.numepochs = 20000;   %  Number of full sweeps through data
opts_back.batchsize = 10;  %  Take a mean gradient step over this many samples
opts_back.plot = 0; %  enable plotting
[nn_back, L_back] = nntrain(nn_back, train_in_back(1:750, :), basis_train_ori_back(1:750, :), opts_back, train_in_back(751:930, :), basis_train_ori_back(751:930, :),500);

%% Testing
% front
nn_front.testing = 1;
nn_out_front = nnff(nn_front, test_in_front, zeros(size(test_in_front,1), nn_front.size(end)));
nn_front.testing = 0;

basis_test_front=nn_out_front.a{end};
basis_test_front = basis_test_front.*repmat(sigma_front_out, [320 1])+repmat(mu_front_out, [320 1]);
save(strcat('../net data/basis_test_front.mat'),'basis_test_front')

% back
nn_back.testing = 1;
nn_out_back = nnff(nn_back, test_in_back, zeros(size(test_in_back,1), nn_back.size(end)));
nn_back.testing = 0;

basis_test_back=nn_out_back.a{end};
basis_test_back = basis_test_back.*repmat(sigma_back_out, [320 1])+repmat(mu_back_out, [320 1]);

save(strcat('../net data/basis_test_back.mat'),'basis_test_back')

%% Testing of training data
% front
nn_front.testing = 1;
nn_train_front = nnff(nn_front, train_in_front, zeros(size(train_in_front,1), nn_front.size(end)));
nn_front.testing = 0;

basis_train_front=nn_train_front.a{end};
basis_train_front = basis_train_front.*repmat(sigma_front_out, [930 1])+repmat(mu_front_out, [930 1]);
save(strcat('../net data/basis_train_front.mat'),'basis_train_front')

% back
nn_back.testing = 1;
nn_train_back = nnff(nn_back, train_in_back, zeros(size(train_in_back,1), nn_back.size(end)));
nn_back.testing = 0;

basis_train_back=nn_train_back.a{end};
basis_train_back = basis_train_back.*repmat(sigma_back_out, [930 1])+repmat(mu_back_out, [930 1]);

save(strcat('../net data/basis_train_back.mat'),'basis_train_back')

%% GUI training data
GUI_training = [coe_l(609, :), -90, 0; coe_l(609, :), 90, 0; coe_l(609, :), -90, 22.5; coe_l(609, :), 90, 22.5; coe_l(609, :), -90, 45; coe_l(609, :), 90, 45; coe_r(609, :), -90, 0; coe_r(609, :), 90, 0; coe_r(609, :), -90, 22.5; coe_r(609, :), 90, 22.5; coe_r(609, :), -90, 45; coe_r(609, :), 90, 45];

% normalize
GUI_training = normalize(GUI_training, mu_front, sigma_front);

% front
nn_front.testing = 1;
nn_GUI_training = nnff(nn_front, GUI_training, zeros(size(GUI_training,1), nn_front.size(end)));
nn_front.testing = 0;

GUI_training_front=nn_GUI_training.a{end};
GUI_training_front = GUI_training_front.*repmat(sigma_front_out, [size(GUI_training,1) 1])+repmat(mu_front_out, [size(GUI_training,1) 1]);
save(strcat('../net data/GUI_training_front.mat'),'GUI_training_front')