% School of Civil Engineering, Central South University
% H.P.Duan, hpduan2000@csu.edu.cn
% https://www.hpduan.cn
function Results_Res = LinearRegress(x, y)
    [p,S] = polyfit(x,y,1);
    a = p(:,1); % Regression coefficients
    b = p(:,2); % constant
    y_ = sum(y)/length(y);
    for i = 1:length(y)
        SS_tot_(i) = (y(i)-y_)^2; %#ok
    end
    SS_tot = sum(SS_tot_);
    for i = 1:length(y)
        SS_res_(i) = (y(i)-(a*x(i)+b))^2; %#ok
    end
    SS_res = sum(SS_res_);
    R2 = 1-(SS_res/SS_tot); % R2
    beta = sqrt(SS_res/(length(y)-2));  % effectiveness
    kesi = beta/a; % general evaluate
    Results_Res = table(a, R2, beta, kesi);
end