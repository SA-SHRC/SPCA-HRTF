
clear;
clc;

%% calculate the average of all the HRTFs | 求所有HRTF的平均
itd = zeros(1250,45);
total_l = 0;
total_r = 0;
hrtf_l = zeros(1250,200,45);
hrtf_r = zeros(1250,200,45);
hav_l = zeros(1250,1);
hav_r = zeros(1250,1);
for i = 1 : 45
     Mat = strcat('../../data/training data/', num2str(i), '/hrir_final.mat');
     load(Mat);  
     for j = 1 : 25
         for k = 1 : 50
             itd (((j-1)*50+k) ,i) = ITD (j ,k);
             hrtf_l (((j-1)*50+k) ,: ,i) = 20*log10(abs(fft(hrir_l (j ,k ,:))));
             hrtf_r (((j-1)*50+k) ,: ,i) = 20*log10(abs(fft(hrir_r (j ,k ,:))));
         end
     end
     for m = 1 : 1250
         total_l = total_l + hrtf_l (m ,: ,i);
         total_r = total_r + hrtf_r (m ,: ,i); 
     end
end

total_l = total_l/(1250*45);
total_r = total_r/(1250*45);


%% calculate Hd
tf_l = zeros(1250,200,45);
tf_r = zeros(1250,200,45);
htf_l = zeros(1250,200,45);
htf_r = zeros(1250,200,45);
hd_l = zeros(9000,1250);
hd_r = zeros(9000,1250);
num = 200; % the number of principal components | 选取的主成分个数
pc_l = zeros(200,num,45);
pc_r = zeros(200,num,45);

for i = 1 : 45
     for m = 1 : 1250
         tf_l (m ,: ,i) = hrtf_l (m ,: ,i) - total_l;
         tf_r (m ,: ,i) = hrtf_r (m ,: ,i) - total_r;
     end
end

for i = 1 : 45
    for j = 1 : 200
        hav_l = hav_l  + tf_l (: , j, i);
        hav_r = hav_r  + tf_r (: , j, i);
    end
end
hav_l = hav_l/(200*45);
hav_r = hav_r/(200*45);

for i = 1 : 45
     for j = 1 : 200
         htf_l (: ,j ,i) = tf_l (: ,j ,i) - hav_l;
         htf_r (: ,j ,i) = tf_r (: ,j ,i) - hav_r;
         hd_l (((i-1)*200+j), :) = htf_l (: ,j ,i)';
         hd_r (((i-1)*200+j), :) = htf_r (: ,j ,i)';
     end
end

%% calculate PCs 
 [coeff_l, score_l, latent_l] = pca(hd_l,'Centered',0,'Economy',0);
 [coeff_r, score_r, latent_r] = pca(hd_r,'Centered',0,'Economy',0);
 p_l = score_l (: ,1:num);
 p_r = score_r (: ,1:num);

 for p = 1 : 45
     for q = 1 : 200
         pc_l (q ,: ,p) = p_l ((p-1)*200+q, :);
         pc_r (q ,: ,p) = p_r ((p-1)*200+q, :);
     end
 end

%% save the data | 保存数据
datapath = '../data/';
if ~isdir(datapath)
    mkdir(datapath);
end
vars = {'itd', 'pc_l', 'pc_r', 'hd_l', 'hd_r', 'total_l', 'total_r', ...
    'hav_l', 'hav_r', 'coeff_l', 'coeff_r', 'score_l', 'score_r'};
for v = 1:length(vars)
    save(fullfile(datapath, [vars{v}, '.mat']), vars{v});
end
