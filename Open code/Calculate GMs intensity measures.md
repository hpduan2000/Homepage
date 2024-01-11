# Calculate GMs intensity measures (IMs)

# Subfunction
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

# Input
    % hpduan2000@csu.edu.cn
    % INPUT:
    % path % records file folder
    % recordName % record file name
    % 
    % [wave, dt, ~, ~] = getAmpDtPEER(path, recordName);
    % units = 'g';   % or 'cm/s^2', all will be translated into m/s
    % kesi = 0.05;  % 5% damping ratio
    % T1 = 0.61;  % the natural period of the structure
    % PGAratio = 0.05;  % Bracketed duration limit
    % 
    % imTable = intensityCalculate(recordName, wave, dt, units, kesi, T1, PGAratio);

# Function
    function imTable = intensityCalculate(recordFileName, wave, dt, units,...
    kesi, T1, PGAratio)

    %%% Initialization
    imTable = table;
    recordName = strsplit(recordFileName, '.');  % filter the extension
    imTable.recordName = recordName{1};

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
    % timemax = size(acc,2) * dt;
    time = (0: dt: timemax - dt)';
    timeTot = time(end);
    vel = cumtrapz(time,acc);
    dsp = cumtrapz(time,vel);

    %%% Calculate a variety of intensity measure

    %%% Peak value of time history
    % PGA in g
    [maxValue, index] = max(abs(acc));
    imTable.PGA = [time(index) maxValue/g];
    % PGV in cm/s
    [maxValue, index] = max(abs(vel));
    imTable.PGV = [time(index) maxValue*unitCM];
    % PGD in cm
    [maxValue, index] = max(abs(dsp));
    imTable.PGD = [time(index) maxValue*unitCM];
    % Vmax/Amax in s
    imTable.('Vmax/Amax') = (imTable.PGV(2)/unitCM)/(imTable.PGA(2)*g);

    %%% Energy-related and Root-mean-suare (RMS) of time history
    % Aria Intensity
    imTable.Ia = pi/(2*g)*trapz(time,acc.^2);  % in m/s
    imTable.aRMS = (imTable.Ia/(pi/(2*g))/timeTot)^0.5/g;  % in g
    % Characteristic Intensity
    imTable.Ic = imTable.aRMS^(3/2) * timeTot^0.5; 
    % Specific Energy Density
    imTable.SED = trapz(time,vel.^2)*unitCM^2;  % in cm^2/s
    imTable.vRMS = (imTable.SED/timeTot)^0.5;  % in cm/s
    % Cumulative Absolute Velocity
    imTable.CAV = trapz(time,abs(acc))*unitCM;  % in cm/s
    imTable.dRMS = (trapz(time,dsp.^2)/timeTot)^0.5*unitCM;  % in cm

    %%% Spectra-related
    [T, peak_abs, ~] = responseSpectrum(...
        wave,dt,kesi,0,0.01,0,'A',0);

    % Predominate Period
    [maxValue, index] = max(peak_abs);
    imTable.Tp = [T(index) maxValue];
    % Spectral acceleration at the fundamental period T1
    imTable.SaT1 = [T1 peak_abs(T1/0.01+1)];
    % Spectral acceleration at 0.2 s
    imTable.Sa_02s = peak_abs(0.2/0.01+1);
    % Spectral acceleration at 1.0 s
    imTable.Sa_1s = peak_abs(1.0/0.01+1);

    % Duratioin-related
    % Uniform duration
    %
    % Bracketed duration at specific percentage of PGA (default = 5%)
    % PGAratio = 0.05;
    accAbs = abs(acc);
    idStart = find(accAbs >= PGAratio*imTable.PGA(2)*g,1,'first');
    idEnd = find(accAbs >= PGAratio*imTable.PGA(2)*g,1,'last');
    imTable.Db_005 = time(idEnd) - time(idStart);
    % Significant duration for a proportion (percentage) of the total Arias Intensity is accumulated (default is the interval between the 5% and 95% thresholds)
    IaTime = pi/(2*g)*cumtrapz(time,acc.^2);   % Arias Intensity
    idStart = find(IaTime >= IaTime(end)*0.05,1,'first');
    imTable.Ds5 = time(idStart);  % D5% time
    idEnd = find(IaTime >= IaTime(end)*0.75,1,'first');  % D5-75
    imTable.Ds75 = time(idEnd);  % D75% time
    imTable.Ds5_75 = time(idEnd) - time(idStart);
    idEnd = find(IaTime >= IaTime(end)*0.95,1,'first');  % D5-95
    imTable.Ds5_95 = time(idEnd) - time(idStart);
    imTable.Ds95 = time(idEnd);  % D95% time
    % Effective duration for the start and end of the strong shaking phase are identified by absolute criteria.
    % (default: I0 = 0.01m/s, De = If - I0 = 0.125m/s for the strong shaking phase)
    % (That with Ia < 0.135m/s is neglected. And DE = 0.05~0.15m/s, only particularly sensitive for records from events with multiple ruptures.)
    % idStart = find(IaTime >= 0.28,1,"first");
    % idEnd = find(IaTime >= 5.38,1,"first");  % D5-75
    % IaTime(end)
    % imTable.De = time(idEnd) - time(idStart);

    %%% Spectral acceleration at other periods in dT = 0.01s
    sz = size(peak_abs,1);   % size of abs Sa
    varTypes = repmat({'double'},1,sz);   % var types of the table
    varNames = cellfun(@(x) ['Ts',num2str(x,'%.2f')],num2cell(T),'UniformOutput',false);  % var name: 'Ts0.20'
    T2 = table('Size',[1 sz],'VariableTypes',varTypes,'VariableNames',varNames);   % initial table
    T2(1,:) = num2cell(peak_abs');   % designate values to the table
    imTable = [imTable, T2];   % get the final table
    end




