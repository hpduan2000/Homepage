% Using Matlab for ANSYS Batch processing
% Written by H. P. Duan; hpduan2000@csu.edu.cn; https://www.hpduan.cn  
function Time = creatTimeFile(dt,NPTS,outpath)
for i = 1:NPTS
    Time(i,:) = dt*i;
end
writematrix(num2str(Time, '%16.6E'),[outpath, 'TIME.txt'])