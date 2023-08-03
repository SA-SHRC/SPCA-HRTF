function hrir=itd_add(hrir, fs, itd)
z=fft(hrir,200);
mag=abs(z);
ang=unwrap(angle(z));
f=(0:length(z)-1)'*fs/length(z);
ang(1:100)=ang(1:100)-2*pi*itd*f(1:100)';
z(1:100)=mag(1:100).*cos(ang(1:100))+j*mag(1:100).*sin(ang(1:100));
re=real(z);
im=imag(z);
re(101) = 0; im(101) = 0; im(1) = 0;
for i=102:200 %实部偶对称，虚部奇对称
    re(:,i)=re(100-(i-102));
    im(:,i)=-im(100-(i-102));
end
tf=re+j*im;
hrir(:, :) = real(ifft(tf,200));
