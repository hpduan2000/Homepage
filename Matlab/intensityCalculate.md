# intensity calculate
Written by H. P. Duan; hpduan2000@csu.edu.cn; https://www.hpduan.cn  
## intensityCalculate.m
```matlab
function [PGA, Ds5, Ds75, Ds95] = intensityCalculate(wave, dt, units)
    %%% Unit
    if strcmp(units, 'g')
        scalar = 9.80;
    elseif strcmp(units, 'cm/s^2') || strcmp(units, 'gal')
        scalar = 0.01;
    end
    acc = wave.*scalar;  % in m/s^2
    g = 9.80;
    unitCM = 100;
    %%% Time - Accelerogram
    timemax = size(acc,1) * dt;
    time = (0: dt: timemax - dt)';
    timeTot = time(end);
    vel = cumtrapz(time,acc);
    dsp = cumtrapz(time,vel);
    %%% Calculate a variety of intensity measure
    %%% Peak value of time history
    % PGA in g
    [maxValue, index] = max(abs(acc));
    PGA = [time(index) maxValue/g];
    % PGV in cm/s
    [maxValue, index] = max(abs(vel));
    PGV = [time(index) maxValue*unitCM];
    % PGD in cm
    [maxValue, index] = max(abs(dsp));
    PGD = [time(index) maxValue*unitCM];
    % Bracketed duration at specific percentage of PGA (default = 5%)
    PGAratio = 0.05;
    accAbs = abs(acc);
    idStart = find(accAbs >= PGAratio*PGA(2)*g,1,'first');
    idEnd = find(accAbs >= PGAratio*PGA(2)*g,1,'last');
    Db_005 = time(idEnd) - time(idStart);
    % Significant duration for a proportion (percentage) of the total Arias Intensity is accumulated (default is the interval between the 5% and 95% thresholds)
    IaTime = pi/(2*g)*cumtrapz(time,acc.^2);   % Arias Intensity
    idStart = find(IaTime >= IaTime(end)*0.05,1,'first');
    Ds5 = time(idStart);  % D5% time

    idEnd = find(IaTime >= IaTime(end)*0.75,1,'first');  % D5-75
    Ds75 = time(idEnd);  % D75% time
    Ds5_75 = time(idEnd) - time(idStart);

    idEnd = find(IaTime >= IaTime(end)*0.95,1,'first');  % D5-95
    Ds5_95 = time(idEnd) - time(idStart);
    Ds95 = time(idEnd);  % D95% time
end
```