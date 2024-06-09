# File format from PEER NGA-West2 database 
Written by H. P. Duan; hpduan2000@csu.edu.cn; https://www.hpduan.cn  
## getAmpDtPEER.m
```matlab
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
```