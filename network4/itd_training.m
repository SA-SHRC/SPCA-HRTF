 
clear;
clc;

%% Output data
load(strcat('../net data/itd.mat'));
itd_train_front = zeros(18750,1);
itd_train_back = zeros(18750,1);

for p = 1 : 30
    for d = 1 : 1250
        if mod(ceil(d/25), 2) == 1
            if mod(d,25) ~= 0
                itd_train_front(((p-1)*625+floor(ceil(d/25)/2)*25+mod(d,25)), :) = itd(d, p);
            else
                itd_train_front(((p-1)*625+floor(ceil(d/25)/2)*25+25), :) = itd(d, p);
            end
        else
            if mod(d,25) ~= 0
                itd_train_back(((p-1)*625+(ceil(d/25)/2-1)*25+mod(d,25)), :) = itd(d, p);
            else
                itd_train_back(((p-1)*625+(ceil(d/25)/2-1)*25+25), :) = itd(d, p);
            end   
        end
    end
end

% real output of test set
itd_test_front = zeros(4375,1);
itd_test_back = zeros(4375,1);

for p = 1 : 7
    for d = 1 : 1250
        if mod(ceil(d/25), 2) == 1
            if mod(d,25) ~= 0
                itd_test_front(((p-1)*625+floor(ceil(d/25)/2)*25+mod(d,25)), :) = itd(d, p+30);
            else
                itd_test_front(((p-1)*625+floor(ceil(d/25)/2)*25+25), :) = itd(d, p+30);
            end
        else
            if mod(d,25) ~= 0
                itd_test_back(((p-1)*625+(ceil(d/25)/2-1)*25+mod(d,25)), :) = itd(d, p+30);
            else
                itd_test_back(((p-1)*625+(ceil(d/25)/2-1)*25+25), :) = itd(d, p+30);
            end   
        end
    end
end

%% Input data
azimu = [-80 -65 -55 -45 -40 -35 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35 40 45 55 65 80]';
eleva = -45+5.625*(0:49);
eleva_front = eleva(1:25);
eleva_back = eleva(26:50);
train_ele_front = repmat(eleva_front', [750 1]);
train_ele_back = repmat(eleva_back', [750 1]);
test_ele_front = repmat(eleva_front', [350 1]);
test_ele_back = repmat(eleva_back', [350 1]);
for c = 1 : 25
    azi(((c-1)*25+1) : ((c-1)*25+25)) = repmat(azimu(c), [25 1]);
end

train_azi = repmat(azi', [30 1]);
test_azi = repmat(azi', [14 1]);

% Anthropometric parameters of train data
load(strcat('../training data/inl_training_itd.mat'));

for m = 1 : 30
    anthro_train(((m-1)*625+1) : ((m-1)*625+625), :) = repmat(inl_training_itd(m, 1:3), [625 1]);
end

% Anthropometric parameters of test data
load(strcat('../test data/inl_test.mat'));
load(strcat('../net data/inl_Subs.mat'));
for l = 1 : 14
    anthro_test(((l-1)*625+1) : ((l-1)*625+625), :) = repmat(inl_test(l, 1:3), [625 1]);
end

input_front = [anthro_train, train_azi, train_ele_front];
input_back = [anthro_train, train_azi, train_ele_back];

test_input_front = [anthro_test, test_azi, test_ele_front];
test_input_back = [anthro_test, test_azi, test_ele_back];

%% data selection
% 共1250个方向，即1250组数据，分前后各625组
testSet = [1, 5, 21 : 4 : 305, 321 : 4 : 605, 621, 625, 59, 63, 67, 158, 162, 166, 458, 462, 466, 559, 563, 567]; % 测试集：160组数据
dataSet = [2 : 4 : 154, 170 : 4 : 454, 470 : 4 : 622, 3 : 4 : 55, 71 : 4 : 555, 571 : 4 : 623, 4 : 4 : 624, 9, 13, 17, 309, 313, 317, 609, 613, 617]; % 除测试集外465组数据
trainSet = dataSet([2 : 5 : 462, 3 : 5 : 463, 4 : 5 : 464, 5 : 5 : 455]); % 训练集：370组数据
validSet = dataSet([1 : 5 : 461, 460, 465]); % 验证集：95组数据

traindata = [];
testdata = [];
for i = 1 : 30
    traindata = [traindata, (i-1)*625+trainSet];
end
for i = 1 : 30
    traindata = [traindata, (i-1)*625+validSet];
end
for i = 1 : 7
    testdata = [testdata, (i-1)*625+testSet];
end

train_in_front = input_front (traindata, :);
test_in_front = test_input_front (testdata, :);
train_in_back = input_back (traindata, :);
test_in_back = test_input_back (testdata, :);

itd_train_ori_front = itd_train_front (traindata);
itd_test_ori_front = itd_test_front (testdata);
itd_train_ori_back = itd_train_back (traindata);
itd_test_ori_back = itd_test_back (testdata);

save(strcat('../net data/itd_test_ori_front.mat'),'itd_test_ori_front')
save(strcat('../net data/itd_test_ori_back.mat'),'itd_test_ori_back')
save(strcat('../net data/itd_train_ori_front.mat'),'itd_train_ori_front')
save(strcat('../net data/itd_train_ori_back.mat'),'itd_train_ori_back')

% normalize
[train_in_front, mu_front, sigma_front] = zscore(train_in_front);
test_in_front = normalize(test_in_front, mu_front, sigma_front);
[itd_train_ori_front, mu_front_out, sigma_front_out] = zscore(itd_train_ori_front);

[train_in_back, mu_back, sigma_back] = zscore(train_in_back);
test_in_back = normalize(test_in_back, mu_back, sigma_back);
[itd_train_ori_back, mu_back_out, sigma_back_out] = zscore(itd_train_ori_back);

%% Training
% front
rand('state',0)
nn_front = nnsetup([5 10 10 10 1]);
opts_front.numepochs = 20000;   %  Number of full sweeps through data
opts_front.batchsize = 5;  %  Take a mean gradient step over this many samples
opts_front.plot = 0; %  enable plotting
[nn_front, L_front] = nntrain(nn_front, train_in_front(1:11100, :), itd_train_ori_front(1:11100), opts_front, train_in_front(11101:13950, :), itd_train_ori_front(11101:13950), 500);
save('../net data/network_itd_front_final.mat', 'nn_front', 'L_front');

% back
rand('state',0)
nn_back = nnsetup([5 10 10 10 1]);
opts_back.numepochs = 20000;   %  Number of full sweeps through data
opts_back.batchsize = 5;  %  Take a mean gradient step over this many samples
opts_back.plot = 0; %  enable plotting
[nn_back, L_back] = nntrain(nn_back, train_in_back(1:11100, :), itd_train_ori_back(1:11100), opts_back, train_in_back(11101:13950, :), itd_train_ori_back(11101:13950), 500);
save('../net data/network_itd_back_final.mat', 'nn_back', 'L_back');

%% Testing
train_in_front = input_front;
test_in_front = test_input_front;
train_in_back = input_back;
test_in_back = test_input_back;

itd_train_ori_front = itd_train_front;
itd_test_ori_front = itd_test_front;
itd_train_ori_back = itd_train_back;
itd_test_ori_back = itd_test_back;

% normalize
[train_in_front, mu_front, sigma_front] = zscore(train_in_front);
test_in_front = normalize(test_in_front, mu_front, sigma_front);
[itd_train_ori_front, mu_front_out, sigma_front_out] = zscore(itd_train_ori_front);

[train_in_back, mu_back, sigma_back] = zscore(train_in_back);
test_in_back = normalize(test_in_back, mu_back, sigma_back);
[itd_train_ori_back, mu_back_out, sigma_back_out] = zscore(itd_train_ori_back);

% front
load('../net data/network_itd_front_final.mat');
nn_front.testing = 1;
nn_out_front = nnff(nn_front, test_in_front, zeros(size(test_in_front,1), nn_front.size(end)));
nn_front.testing = 0;

itd_test_front=nn_out_front.a{end};
itd_test_front = itd_test_front.*repmat(sigma_front_out, [size(itd_test_front,1) 1])+repmat(mu_front_out, [size(itd_test_front,1) 1]);
% save(strcat('../net data/itd_test_front_total.mat'),'itd_test_front');
save(strcat('../net data/itd_Subs_front_total.mat'),'itd_test_front');

% back
load('../net data/network_itd_back_final.mat');
nn_back.testing = 1;
nn_out_back = nnff(nn_back, test_in_back, zeros(size(test_in_back,1), nn_back.size(end)));
nn_back.testing = 0;

itd_test_back=nn_out_back.a{end};
itd_test_back = itd_test_back.*repmat(sigma_back_out, [size(itd_test_back,1) 1])+repmat(mu_back_out, [size(itd_test_back,1) 1]);

% save(strcat('../net data/itd_test_back_total.mat'),'itd_test_back');
save(strcat('../net data/itd_Subs_back_total.mat'),'itd_test_back');
disp('test done');

%% Testing of training data
% front
nn_front.testing = 1;
nn_train_front = nnff(nn_front, train_in_front, zeros(size(train_in_front,1), nn_front.size(end)));
nn_front.testing = 0;

itd_train_front=nn_train_front.a{end};
itd_train_front = itd_train_front.*repmat(sigma_front_out, [18750 1])+repmat(mu_front_out, [18750 1]);
save(strcat('../net data/itd_train_front_total.mat'),'itd_train_front')

% back
nn_back.testing = 1;
nn_train_back = nnff(nn_back, train_in_back, zeros(size(train_in_back,1), nn_back.size(end)));
nn_back.testing = 0;

itd_train_back=nn_train_back.a{end};
itd_train_back = itd_train_back.*repmat(sigma_back_out, [18750 1])+repmat(mu_back_out, [18750 1]);

save(strcat('../net data/itd_train_back_total.mat'),'itd_train_back')
