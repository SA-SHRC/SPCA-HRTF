clear;
load('anthro.mat')
su=zeros(45,1);
ag=zeros(45,1);
for i = 1 : 45
    Mat = strcat(num2str(i),'/hrir_final.mat');
    load(Mat)
    su(i)=str2num(name(9:end));
    index=find(id==su(i));
    ag(i)=age(index);
    se(i)=sex(index);
    disp(['i=',num2str(i),';subject=',num2str(su(i)),';age=',num2str(ag(i)),';sex=',num2str(se(i))]);
end