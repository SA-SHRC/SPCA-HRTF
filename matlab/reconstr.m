function [hrir_l, hrir_r] = reconstr (hrtf_l, hrtf_r, itd, dir, pn)
% 信号重建

rebuiltphase_l = zeros(pn, 200);
magn_l = 10.^(hrtf_l/20); %左耳幅度
magn_l_log = log(magn_l); %左耳对数幅度，以e为底
for i = 1 : pn
    rebuiltphase_l(i, :) = -imag(hilbert(magn_l_log(i, :))); %重建相位
end
hr_l = magn_l.*cos(rebuiltphase_l)+1i*magn_l.*sin(rebuiltphase_l); %重建后hrtf的对数表示
for i = 1 : pn
%     hrir_l(i, 21:220) = real(ifft(hr_l(i, :))); %左耳时域
    hrir_l(i, :) = real(ifft(hr_l(i, :))); %左耳时域
end

rebuiltphase_r = zeros(pn, 200);
magn_r = 10.^(hrtf_r/20); %左耳幅度
magn_r_log = log(magn_r); %左耳对数幅度，以e为底
for i = 1 : pn
    rebuiltphase_r(i, :) = -imag(hilbert(magn_r_log(i, :))); %重建相位
end
hr_r = magn_r.*cos(rebuiltphase_r)+1i*magn_r.*sin(rebuiltphase_r); %重建后hrtf的对数表示
for i = 1 : pn
%     hrir_r(i, 21:220) = real(ifft(hr_r(i, :))); %右耳时域
    hrir_r(i, :) = real(ifft(hr_r(i, :))); %右耳时域
end
% hrir_l = hrir_l(:, 1:200);
% hrir_r = hrir_r(:, 1:200);

fs = 44100;
itd = itd/fs; % 转化成时间单位（秒）

if dir > 625
    for i = 1 : length(itd)
        hrir_l(i, :) = itd_add(hrir_l(i, :), fs, itd(i));
    end
elseif dir < 625
    for i = 1 : length(itd)
        hrir_r(i, :) = itd_add(hrir_r(i, :), fs, itd(i));
    end
elseif dir == 625
    for i = 1 : length(itd)
        if max(hrir_l(i, :)) > max(hrir_r(i, :))
            hrir_r(i, :) = itd_add(hrir_r(i, :), fs, itd(i));
        else
            hrir_l(i, :) = itd_add(hrir_l(i, :), fs, itd(i));
        end
    end
else
    error('err')
end

% figure(2);plot(1:200,hrir_l(1,:)); hold on;plot(1:200,hrir_r(1,:)); hold off;
% figure;plot(1:200,hrtf_l(1,:));hold on;plot(1:200,hrtf_r(1,:))