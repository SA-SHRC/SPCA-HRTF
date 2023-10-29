hrirpath = '../results/matlab/hrir/';
dirs = dir([hrirpath, '*']);
dirs = dirs([dirs.isdir]);
dirs = {dirs(3:end).name};

methods = {'kemar', 'predict_spca', 'predict_pca'};
legends = {'Generic', 'SPCA', 'PCA'};
LM = length(methods);
LM = 2;

load('../data/training data/30/hrir_final.mat'); % the data of Kemar dummy head
% hrirKemar = hrir_l;
    egy = sum(hrir_l.^2, 3);
hrtfKemar = 20*log10(abs(fft(hrir_l, [], 3)));
% hrtfKemar = abs(fft(hrir_l, [], 3));
hrtfKemar = hrtfKemar(:, :, 1:101);
% hrir = [reshape(permute(hrir_l, [2, 1, 3]), [1250, 1, 200]), reshape(permute(hrir_r, [2, 1, 3]), [1250, 1, 200])];
SDs = zeros(25, 50, 101, LM+1, length(dirs)); % azim, elev, freq, method, subject
names = cell(length(dirs), 1);

azi = [-80 -65 -55 -45 -40 -35 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35 40 45 55 65 80];
ele = -45+5.625*(0:49);

[elev, azim] = meshgrid(ele, azi);

for i = 1:length(dirs)
    oripath = ['../data/training data/', dirs{i}, '/'];
    hpath = [hrirpath, dirs{i}, '/'];
    load([oripath 'hrir_final.mat']);
        eTmp = sum(hrir_l.^2, 3);
        hrir_l = hrir_l.*repmat(sqrt(egy./eTmp), [1, 1, 200]);
    hrtfRef = 20*log10(abs(fft(hrir_l, [], 3)));
%     hrtfRef = abs(fft(hrir_l, [], 3));
    hrtfRef = hrtfRef(:, :, 1:101);
%         hrtfR = permute(hrtfRef, [3, 2, 1]);
%         hrtfR = hrtfR(:, :);
    names{i} = name;
    
    for im = 1:LM
        if im > 1
            load([hpath 'hrir_' methods{im} '.mat']);
                eTmp = sum(hrir_l.^2, 3);
                hrir_l = hrir_l.*repmat(sqrt(egy./eTmp), [1, 1, 200]);
            hrtfTmp = 20*log10(abs(fft(hrir_l, [], 3)));
%             hrtfTmp = abs(fft(hrir_l, [], 3));
            hrtfTmp = hrtfTmp(:, :, 1:101);
            if(isinf(mean(hrtfTmp)))
                return;
            end
        else
            hrtfTmp = hrtfKemar;
        end
        
%         hrtf = permute(hrtfTmp, [3, 2, 1]);
%         hrtf = hrtf(:, :);
%         projection = zeros(1250, 1250);
%         for is = 1:1250
%             dif = repmat(hrtf(:, is), 1, 1250) - hrtfR;
%             sds = sqrt(mean(dif.^2, 1));
%             [~, ind] = min(sds);
%             projection(is, ind) = 1;
%         end
%         figure(1);
%         mesh(projection');
%         axis equal tight;
%         view(0, 90);
%         title(methods{im}, 'interpreter', 'none')
%         return
        
        SDs(:, :, :, im, i) = (hrtfTmp - hrtfRef);
    end
    SDs(:, :, :, end, i) = hrtfRef;
end
save('./SDs_left.mat', 'SDs');

% %% t-test for SD
close all;
load('./SDs_left.mat', 'SDs');
% pairs = [1 2; 1 3; 2 3]';
% fqs = 8:8:size(SDs, 3);
% % fqs = 1:100;
% subs = 25:31;
% SD = reshape(permute(abs(SDs(:, :, fqs, 1:LM, subs)), [1 2 5 3 4]), [1250*length(subs), length(fqs), 3]);
% merr = squeeze(mean(SD));
% for p = pairs
%     [H, P] = ttest(SD(:, :, p(1)), SD(:, :, p(2)));
%     err = merr(:, p(1)) - merr(:, p(2));
%     figure;
%     [ax, h1, h2] = plotyy(fqs*44100/200/1e3, H.*(1 - (err<0)*2)',...
%         fqs*44100/200/1e3, P, ...
%         @(x,y)(plot(x, y, 'bo')), @plot);
%     axes(ax(2));
%     hold on
%     plot(fqs*44100/200/1e3, [0.05; 1]*ones(1, length(fqs)), 'r--');
%     set(ax(1), 'YTick', [-1 0 1], 'YTickLabel', {methods{p(1)}, 'no diff', methods{p(2)}}, ...
%         'YTickLabelRotation', 90);
%     ylabel(ax(1), 'method with smaller errs');
%     ylim(ax(1), [-3 1.5]);
%     set(ax(2), 'YTick', [0.001 0.01 0.1 1], 'YTickLabel', [0.001 0.01 0.1 1], ...
%         'YScale', 'log', 'YTickLabelRotation', 90);
%     ylabel(ax(2), 'p-value');
%     ylim(ax(2), [0.0005 1e6]);
%     xlim(ax(1), [0 22.1]);
%     xlim(ax(2), [0 22.1]);
% end

%%
SFRS = SDs(:, :, 1:100, 1:LM, :) + repmat(SDs(:, :, 1:100, end, :), [1 1 1 LM 1]);
SFRS(:, :, :, LM+1, :) = SDs(:, :, 1:100, end, :);
fqs = [56];%[5, 20, 60];
choose = 22;%9 12 13 22
cmax = squeeze(max(max(max(max(SFRS(:,:, :, :, choose), [], 5), [], 4), [], 2), [], 1));
cmin = squeeze(min(min(min(min(SFRS(:,:, :, :, choose), [], 5), [], 4), [], 2), [], 1));
clim = [cmin*0.6 cmax];

NCol = LM+1;
NRow = length(fqs);
margin = [0.03 0.2 0.08 0 ... top bottom left right
    0 0 0 0.08 ... headr tailr headc tailc
    0.03 0.03];% rgap cgap
ha = multiAxes(1, NRow, NCol, margin, [200 150], 'Times New Roman', 'Azimuth (Deg)', 'Elevation (Deg)', ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on');%, 'XTick', azims, 'YTick', elevs
gcf;
colormap(gray);

sub =4;
for ifq = 1:NRow
    fq = (fqs(ifq) - 1) / 200 * 44100;
        axes(ha(ifq, 1));
        surface(azim, elev, mean(SFRS(:, :, fqs(ifq), end, choose), 5), 'edgecolor', 'none');
%         shading interp;
        caxis(clim(fqs(ifq), :));
        if(ifq == 1)
%             title('original');
%             colorbar('northoutside');
        end
%             ylabel([num2str(fq) ' Hz']);
    for im = 1:LM
        axes(ha(ifq, 1+im));
        surface(azim, elev, mean(SFRS(:, :, fqs(ifq), im, choose), 5), 'edgecolor', 'none');
%         shading interp;
        caxis(clim(fqs(ifq), :));
        if(im == LM)
%             title(methods{im}, 'interpreter', 'none');
            colorbar('eastoutside');
        end
    end
end

% print(['../latex_final/SFRS_22_12k'], '-dpdf');
% print(['../latex_final/SFRS_22_12k'], '-dpng', '-r600');

choose = 25:31; % the test set
SD = abs(SDs(:, :, 1:100, 1:LM, choose));
SDmean = mean(SD(:, :, :, :, :), 5);
SDstd = std(SDmean(:, :, :), [], 3);
SDmf = mean(SD(:, :, :, :, :), 3);
SDms = mean(SDmf, 5);
% SDmean = mean(SDmean(:, :, :), 3);

cmax = squeeze(max(max(max(SDmf(:,:, :, :, :), [], 4), [], 2), [], 1));
cmin = squeeze(min(min(min(SDmf(:,:, :, :, :), [], 4), [], 2), [], 1));
clim = [cmin cmax];

NCol = LM;
NRow = 0;
margin = [0.03 0.2 0.12 0 ... top bottom left right
    0 0 0 0.14 ... headr tailr headc tailc
    0.03 0.03];% rgap cgap
ha = multiAxes(2, NRow+1, NCol, margin, [200 150], 'Times New Roman', 'Azimuth (Deg)', 'Elevation (Deg)', ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on');%, 'XTick', azims, 'YTick', elevs
gcf;
colormap(gray);

sub =4;
for im = 1:LM
    for isub = 1:NRow
        axes(ha(isub, im));
        surface(azim, elev, SDmf(:, :,1, im, isub), 'edgecolor', 'none');
%         shading interp;
        caxis(clim(isub, :));
        axis tight
        if(im == LM)
%             title(methods{im}, 'interpreter', 'none');
            colorbar('eastoutside');
        end
    end
        axes(ha(NRow+1, im));
        surface(azim, elev, SDms(:, :,1, im), 'edgecolor', 'none');
        caxis([min(SDms(:)), max(SDms(:))]);
        if(im == LM)
%             title(methods{im}, 'interpreter', 'none');
            colorbar('eastoutside');
        end
end

% print(['../latex_final/SD_25-31'], '-dpdf');
% print(['../latex_final/SD_25-31'], '-dpng', '-r600');

% SD: azim, elev, freq, method, subject -> freq, method, subject, azim, elev
SD = permute(abs(SDs(:, :, 1:100, 1:LM, choose)), [3, 4, 5, 1, 2]); 
SDmean = mean(SD(:, :, :, :), 4); % mean across directions
SDstd = std(SDmean(:, :, :), [], 3); % std across subjects
SDmean = mean(SDmean(:, :, :), 3); % mean across subjects
fqs = ((1:101) - 1)'*44100/200/1e3;
ltp = {'-o', '--s', ':>'};
figure(3);
set(gcf, 'position', [100 100 900 600]);
clf;
hold on
for im = 1:LM
    h(im) = errorbar(fqs(8:8:end)-0.2, SDmean(8:8:end, im), SDstd(8:8:end, im), ['k' ltp{im}], 'markersize', 8);
end
legend(legends(1:LM), 'location', 'best', 'fontname', 'Times New Roman');
xlabel('Frequency (kHz)');
ylabel('SD magnitude (dB)');
xlim([0 22.5]);
ylim([0 9]);
set(gca, 'box', 'on', 'fontname', 'Times New Roman', 'xtick', round(fqs(8:8:end),1));%, 'fontsize', 14
grid on;
% print(['../latex_final/SD_fq.png'], '-dpng', '-r600');
legend(gca, 'boxoff');
% print(['../latex_final/SD_fq.eps'], '-deps');
fprintf('Mean SD of the SPCA method among all the subjects and frequency bins is %.2f dB.\n', mean(SDmean(:, 2)))