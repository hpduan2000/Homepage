% School of Civil Engineering, Central South University
% H.P.Duan, hpduan2000@csu.edu.cn
% https://www.hpduan.cn
function [Pf, IMlim] = cdf_PSDAcloud(IM_file, EDP_file, EDP_ls, IMlim)
    IM = IM_file; % load IM.txt
    EDP = EDP_file; %load EDP.txt
    x = log(IM); % ln-ln
    y = log(EDP); % ln-ln
    [EDP_fitF, beta, std, ~, ~, ~] = reg_PSDMcloud(x,y,'N','linear');
    xmax = max(x);
    xmin = min(x);
    ymax = EDP_fitF(beta,xmax);
    ymin = EDP_fitF(beta,xmin);
    x1 = [xmin,xmax];
    y1 = [ymin,ymax];
    % Fragility analysis
    mu = log(EDP_ls);  %### Limit State
    sigma = std;
    EDPpred = EDP_fitF(beta,log(IMlim));
    Pf = cdf('Normal',EDPpred,mu,sigma); % cdf for EDP
    Pf = Pf';
    IMlim = IMlim';
end

