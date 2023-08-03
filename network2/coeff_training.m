function coeff_training (fn) 

% clear;
% fn = 67;

%% Output data
load(strcat('../net data/pc_l.mat'));
load(strcat('../net data/pc_r.mat'));

num = 200; % 主成分个数
p_l = reshape(pc_l(fn ,: ,: ),[num 45])';
p_r = reshape(pc_r(fn ,: ,: ),[num 45])';

% p_l_train = p_l(1:35, :);
% p_r_train = [p_r(1:30, :); p_r(33:37, :)];
% p_l_test = p_l(36:37, :);
% p_r_test = p_r(31:32, :);
p_l_train = p_l(1:30, :);
p_r_train = p_r(1:30, :);
p_l_test = p_l(31:37, :);
p_r_test = p_r(31:37, :);

save(strcat('../net data/coeff_f', num2str(fn), '_train_ori_l.mat'),'p_l_train')
save(strcat('../net data/coeff_f', num2str(fn), 'train_ori_r.mat'),'p_r_train')
save(strcat('../net data/coeff_f', num2str(fn), 'test_ori_l.mat'),'p_l_test')
save(strcat('../net data/coeff_f', num2str(fn), 'test_ori_r.mat'),'p_r_test')

%% Input data

% Anthropometric parameters of train data and test data
load(strcat('../training data/inl_training.mat'));
load(strcat('../training data/inr_training.mat'));
load(strcat('../test data/inl_test.mat'));
load(strcat('../test data/inr_test.mat'));

% train_in = [inl_training; inl_test(1:5, :); inr_training; inr_test(3:7, :)];
% train_out = [p_l_train; p_r_train];
% test_in = [inl_test(6:7, :); inr_test(1:2, :)];
train_in = [inl_training; inr_training];
train_out = [p_l_train; p_r_train];
test_in = [inl_test; inr_test];

%% train NN

% normalize
[train_in, mu_in, sigma_in] = zscore(train_in);
test_in = normalize(test_in, mu_in, sigma_in);
[train_out, mu_out, sigma_out] = zscore(train_out);

% train
rand('state',0)
nn = nnsetup([8 8 num]);
% nn = nnsetuppp([8 100 100 27 5 num]);
opts.numepochs = 20000;   %  Number of full sweeps through data
opts.batchsize = 10;  %  Take a mean gradient step over this many samples
opts.plot = 0; %  enable plotting
R = randperm(60);
[nn, L] = nntrain(nn, train_in(R(1:50), :), train_out(R(1:50), :), opts, train_in(R(51:60), :), train_out(R(51:60), :), 500);

%% testing
nn.testing = 1;
nn_out = nnff(nn, test_in, zeros(size(test_in,1), nn.size(end)));
nn.testing = 0;

test_out=nn_out.a{end};
test_out = test_out.*repmat(sigma_out, [14 1])+repmat(mu_out, [14 1]);

save(strcat('../net data/coeff_f', num2str(fn), 'test_out.mat'),'test_out')

%% testing of training data
nn.testing = 1;
nn_out_train = nnff(nn, train_in, zeros(size(train_in,1), nn.size(end)));
nn.testing = 0;

train_out=nn_out_train.a{end};
train_out = train_out.*repmat(sigma_out, [60 1])+repmat(mu_out, [60 1]);

save(strcat('../net data/coeff_f', num2str(fn), 'train_out.mat'),'train_out')

%% testing of subjective experiment
% subjectName ={'CGF','CJF','GZS','LJ','LR','NYD','PC','QY','SMJ','ST','WYW','LX','HYK','GS'};
load(strcat('../net data/newsubject_l.mat'));
load(strcat('../net data/newsubject_r.mat'));
subject_test_in = [subject_l; subject_r];
% subject_test_in = [inl_training(30, :); inl_training(30, :)];
% [14.0126185048060, 22.0902436700302,19.9756989602717];

% normalize
subject_test_in = normalize(subject_test_in, mu_in, sigma_in);

nn.testing = 1;
nn_out_sub = nnff(nn, subject_test_in, zeros(size(subject_test_in,1), nn.size(end)));
nn.testing = 0;

subject_test_out=nn_out_sub.a{end};
subject_test_out = subject_test_out.*repmat(sigma_out, [size(subject_test_in,1) 1])+repmat(mu_out, [size(subject_test_in,1) 1]);

save(strcat('../coeff/coeff_f', num2str(fn), 'subject_test_out.mat'),'subject_test_out')