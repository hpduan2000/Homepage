# Pulse parameters analysis based on RDI
Written by H. P. Duan; hpduan2000@163.com; https://www.hpduan.cn  

## main
```matlab
% H.P.Duan; hpduan2000@csu.edu.cn
clear
clc
% Example: GM record information
% PEER NGA STRONG MOTION DATABASE RECORD
% Northridge-01, 1/17/1994, Newhall - W Pico Canyon Rd., 46

%% ..........(1) 读取地震波从peer
path = 'D:\HPduan\post_MATLAB\SolveResults_SCI4\ANR\file\';
fileName_acc = 'RSN1045_NORTHR_WPI046.AT2';
fileName_vel = 'RSN1045_NORTHR_WPI046.VT2';
[acc_series, dt, ~, ~] = getAmpDtPEER(path, fileName_acc);
[vel_series, ~, ~, ~] = getAmpDtPEER(path, fileName_vel);

%% ..........(2) 分解高频底波BGR和低频脉冲PTR
Tp = 2.98;
alpha_1 = 0.77;
[v_PTR, v_BGR] = FourthButterworth(vel_series, dt, Tp, alpha_1);

%% ..........(3) 人工低频脉冲APTR
Ap = 65;        % 脉冲幅值
fp = 0.3;       % 数字脉冲频率
t0 = 5.9;       % 数字脉冲幅值出现的时间
gama = 1.8;     % 随机参数
phase = 200;    % 相位
v_APTR = SynthesisPulse(vel_series, dt, Ap, fp, t0, gama, phase);

%% ..........(4) 人工波合成
v_OR = vel_series;              % cm/s
a_OR = acc_series;              % g
v_ANR =  v_BGR + v_APTR;        % cm/s
a_ANR = (diff(v_ANR)/dt)*1e-2;  % m/s2

%% ..........(5) 伪反应谱
sPeriod = load('sPeriod.txt');
[PSA_OR, PSV_OR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_OR * 9.8, dt);     % 原波的伪加速度谱和伪速度谱
[PSA_ANR, PSV_ANR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_ANR, dt);        % 人工波的伪加速度谱和伪速度谱

%% ..........(6) 绘图
figure('Name','OR和ANR的伪加速度谱')
loglog(sPeriod, PSA_OR)
hold on
loglog(sPeriod, PSA_ANR)

figure('Name','OR和ANR的伪速度谱')
loglog(sPeriod, PSV_OR)
hold on
loglog(sPeriod, PSV_ANR)

figure('Name','OR和ANR时程曲线')
plot((1:length(v_OR)).*dt,v_OR)
hold on
plot((1:length(v_ANR)).*dt,v_ANR)

figure('Name','PTR和APTR时程曲线')
plot((1:length(v_PTR)).*dt,v_PTR)
hold on
plot((1:length(v_APTR)).*dt,v_APTR)

%% ..........(7) 裁波
T1 = 2.1;  % 结构基本周期
[PGA_OR, Ds5_OR, Ds75_OR, Ds95_OR] = intensityCalculate(a_OR, dt, 'g', 0.05, T1, 0.05);
[PGA_ANR, Ds5_ANR, Ds75_ANR, Ds95_ANR] = intensityCalculate(a_ANR * 1e2, dt, 'cm/s^2', 0.05, T1, 0.05);

a_OR_5_75 = a_OR(Ds5_OR/dt : Ds75_OR/dt);
a_ANR_5_75 = a_ANR(Ds5_ANR/dt : Ds75_ANR/dt);

%% ..........(8) 输出三向地震动1:0.8:0.65
writematrix(a_OR_5_75, [path,'OR_AY.txt'])
writematrix(a_OR_5_75*0.8, [path,'OR_AX.txt'])
writematrix(a_OR_5_75*0.65, [path,'OR_AZ.txt'])

writematrix(a_ANR_5_75, [path,'ANR_AY.txt'])
writematrix(a_ANR_5_75*0.8, [path,'ANR_AX.txt'])
writematrix(a_ANR_5_75*0.65, [path,'ANR_AZ.txt'])

function v_APTR = SynthesisPulse(v_series, dt, Ap, fp, t0, gama, v_)
    % Random vibration simulation
    % .....Start: set key pars
    v = v_*(pi/180);
    % .....Must ensure the gama > 1;
    temp = 1;
    for t = dt:dt:dt*length(v_series)
        temp = temp; %#ok
        if (t0-gama/(2*fp))<=t && t<=(t0+gama/(2*fp))
            v_APTR(temp,:) = Ap*(1/2)*(1+cos(2*pi*fp*(t-t0)/gama))*cos(2*pi*fp*(t-t0)+v); %#ok
        else
            v_APTR(temp,:) = 0; %#ok
        end
        temp = temp + 1;
    end
    % .....End synthesis
end

function [v_PTR, v_BGR] = FourthButterworth(v_series, dt, Tp, alpha_1)
    fc = 1/(alpha_1*Tp-dt);       % truncation frequency
    fs = 1/dt;
    wn = 2*fc/fs;
    [b,a] = butter(4,wn,'low');   % design 4th-order butterworth
    v_PTR = filter(b,a,v_series); % pulse-type record-PTR
    v_BGR = v_series - v_PTR;     % high-frequency background record-BGR
end

function [wave, dt, NPTS, rsn] = getAmpDtPEER(filePath,fileName)
    fileid_shock = fopen([filePath,'/',fileName]);
    rsn = sscanf(char(fileName), 'RSN %f _');
    for i = 1:4
        timeline = fgetl(fileid_shock);
    end
    [time_infor,~] = strsplit(timeline,{'=',' ',','},...
        'CollapseDelimiters',true); % split the time information line
    NPTS = str2double(time_infor{2}); % read NPTS as num
    dt = str2double(time_infor{4}); % read DT as num
    Ce = textscan(fileid_shock,'%f');
    wave = zeros(NPTS,1);
    for i = 1:size(Ce{1},1)
        for j = 1:size(Ce,2)
            num = (i-1) * size(Ce,2) + j;
            wave(num) = Ce{j}(i);
        end
    end
    % Delet NaN
    wave(isnan(wave)) = [];
    fclose(fileid_shock);
end

function [PGA, Ds5, Ds75, Ds95] = intensityCalculate(wave, dt, units, kesi, T1, PGAratio)
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
    % PGAratio = 0.05;
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

function [PSA, PSV, SD, SA, SV, OUT] = SpectrumGMs(xi, sPeriod, gacc, dt)
    % Input:
    %       xi = ratio of critical damping (e.g., 0.05)
    %  sPeriod = vector of spectral periods
    %     gacc = input acceleration time series in cm/s2
    %       dt = sampling interval in seconds (e.g., 0.005)
    % Output:
    %      PSA = Pseudo-spectral acceleration ordinates
    %      PSV = Pseudo-spectral velocity ordinates
    %       SD = Spectral displacement ordinates
    %       SA = Spectral acceleration ordinates
    %       SV = Spectral velocity ordinates
    %      OUT = Time series of acceleration, velocity and displacemet response of SDF
    % Ref:
    % Wang, L.J. (1996). Processing of near-field earthquake accelerograms:
    % Pasadena, California Institute of Technology.

    vel = cumtrapz(gacc)*dt;
    disp = cumtrapz(vel)*dt;

    % Spectral solution
    for i = 1:length(sPeriod)
        omegan = 2*pi/sPeriod(i);
        C = 2*xi*omegan;
        K = omegan^2;
        y(:,1) = [0;0];
        A = [0 1; -K -C]; Ae = expm(A*dt); AeB = A\(Ae-eye(2))*[0;1];
        
        for k = 2:numel(gacc)
            y(:,k) = Ae*y(:,k-1) + AeB*gacc(k);
        end
        
        displ = (y(1,:))';                          % Relative displacement vector (cm)
        veloc = (y(2,:))';                          % Relative velocity (cm/s)
        foverm = omegan^2*displ;                    % Lateral resisting force over mass (cm/s2)
        absacc = -2*xi*omegan*veloc-foverm;         % Absolute acceleration from equilibrium (cm/s2)
        
        % Extract peak values
        displ_max(i) = max(abs(displ));             % Spectral relative displacement (cm)
        veloc_max(i) = max(abs(veloc));             % Spectral relative velocity (cm/s)
        absacc_max(i) = max(abs(absacc));           % Spectral absolute acceleration (cm/s2)
        
        foverm_max(i) = max(abs(foverm));           % Spectral value of lateral resisting force over mass (cm/s2)
        pseudo_acc_max(i) = displ_max(i)*omegan^2;  % Pseudo spectral acceleration (cm/s)
        pseudo_veloc_max(i) = displ_max(i)*omegan;  % Pseudo spectral velocity (cm/s)
        
        PSA(i) = pseudo_acc_max(i);                 % PSA (cm/s2)
        SA(i)  = absacc_max(i);                     % SA (cm/s2)
        PSV(i) = pseudo_veloc_max(i);               % PSV (cm/s)
        SV(i)  = veloc_max(i);                      % SV (cm/s)
        SD(i)  = displ_max(i);                      % SD  (cm)
    
        % Time series of acceleration, velocity and displacement response of
        % SDF oscillator
        OUT.acc(:,i) = absacc;
        OUT.vel(:,i) = veloc;
        OUT.disp(:,i) = displ;
    end
end
```
