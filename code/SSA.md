# Statistical significance analysis (SSA)
Written by H. P. Duan; hpduan2000@163.com; https://www.hpduan.cn  

## subfunction
(1) Shapiro-Wilk test: https://www.hpduan.cn/code/swtest.md

## function
```matlab
function p2 = SSA(x,y,alpha)
    % Ensure the sample data is a VECTOR
    % make a log function transfor for origin datas
    data1 = log(x);
    data2 = log(y);
    [m,n] = size(data1);
    % ESA framework
    [~, p1_data1, ~] = swtest(data1, alpha);
    [~, p1_data2, ~] = swtest(data2, alpha);
    if p1_data1 >= alpha && p1_data2 >= alpha
        [~, p2] = ttest2(data1(:,i), data2(:,i), 'Vartype', 'unequal');
        % Test the null hypothesis H0, that is, the two data vectors come from a population with equal means, 
        % without assuming that the population also has homogeneous variances.
    else
        p2 = ranksum(data1, data2);
    end
end
```