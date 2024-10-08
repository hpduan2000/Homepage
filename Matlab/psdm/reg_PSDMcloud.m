% School of Civil Engineering, Central South University
% H.P.Duan, hpduan2000@csu.edu.cn
% https://www.hpduan.cn
% Probabilistic Seismic Demand Model
function [y_fitF, beta, std,res,R2,stats] = reg_PSDMcloud(xdata, ydata, residualModel, fitModel, varargin)
    % Default parameters
    ip = inputParser;
    % default
    addParameter(ip,'beta0',[]);  % Axis View (optional)
    parse(ip,varargin{:});  % update
    % read the par.
    beta0 = ip.Results.beta0;
    % Fitting data
    if strcmp(residualModel, 'LN')
        datax = log(xdata);
        datay = log(ydata);
    elseif strcmp(residualModel, 'N')
        datax = xdata;
        datay = ydata;
    end
    % Fitting
    if strcmp(fitModel, 'linear')
        % fit
        dataX = [ones(size(datax,1),1),datax]; % ones(n,1) for the constant term
        [beta,~,res,~,stats] = regress(datay,dataX);  % linear regression
        std = stats(4)^0.5;  % standard deviation
        R2 = stats(1);
        % prediction
        y_fitF = @(beta, x) beta(1) + x.*beta(2);  % mu PSDM
        xForFit = [min(datax); max(datax)];  % predict
        y_fit = y_fitF(beta, xForFit);
    elseif strcmp(fitModel, 'bilinear')
        % bilinear model for PSDM
        y_fitF = @(beta, x) (x <= beta(1)) .* (beta(2) + beta(3).*x) + ...
            (x > beta(1))  .* (beta(4) + beta(5).*x);
        [beta,resnorm,residual] = lsqcurvefit(y_fitF,beta0,datax,datay); % NLSM
        % std depends on the res(x) for the left and right of the breakpoint IM*
        [~, IMstarNum] = min(abs(datax-beta(1)));  % find the IM* num. at datax
        std = [(sum((residual(1:IMstarNum)).^2)./(IMstarNum-2))^0.5;...
            (sum((residual(IMstarNum+1:end)).^2)./(size(residual,1)-IMstarNum-2))^0.5];
        R2 = NaN;
        stats = NaN;
        % prediction
        xForFit = [min(datax); beta(1); max(datax)];  % predict
        y_fit = y_fitF(beta, xForFit);
    end
end
