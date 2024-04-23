# Artificially synthesized near-fault pulse-type ground motions
Written by H. P. Duan; hpduan2000@163.com; https://www.hpduan.cn  

## function
(1) getAmpDtPEER: https://www.hpduan.cn/code/getAmpDtPEER.md  
(2) FourthButterworth: https://www.hpduan.cn/code/FourthButterworth.md  
(3) SynthesisPulse: https://www.hpduan.cn/code/SynthesisPulse.md  
(4) SpectrumGMs: https://www.hpduan.cn/code/SpectrumGMs.md  

## main
```matlab
%% Record-Decomposition Incorporation (RDI) main by H.P.Duan; hpduan2000@csu.edu.cn
%  Ref: Effects of Near-Fault Motions and Artificial Pulse-Type Ground Motions on Super-Span Cable-Stayed Bridge Systems
%  (2017, Journal of Bridge Engineering, S.Li, et al.)
clear
clc
warning off
% Read GM records of velocity time series
filepath = '******';  % floder
filename1 = 'RSN1045_NORTHR_WPI046.VT2';  % file name volicity
filename2 = 'RSN1045_NORTHR_WPI046.AT2';  % file name acceleration
[v_series, dt, ~, ~] = getAmpDtPEER(filepath, filename1);
[a_series, ~, ~, ~] = getAmpDtPEER(filepath, filename2);
% Decomposition
Tp = 8;      % pluse period (Tp)
alpha_1 = 0.77; % empirical coefficient
[v_PTR, v_BGR] = FourthButterworth(v_series, dt, Tp, alpha_1);
% Incorporation
Ap = 65;    % pulse amplitude
fp = 0.3;   % mathematical pulse frequency
t0 = 5.9;   % appear time of mathematical pulse amplitude
gama = 1.8; % random par
v_ = 200;   % phase par
v_APTR = SynthesisPulse(v_series, dt, Ap, fp, t0, gama, v_);
% pseudo-spectral velocity
a_PTR = (diff(v_PTR)/dt)*1e-2;   % m/s2
a_APTR = (diff(v_APTR)/dt)*1e-2; % m/s2
sPeriod = load('sPeriod.txt');
[~, PSV1, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_PTR, dt);
[~, PSV2, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_APTR, dt);
figure
plot(sPeriod,PSV1.*1e2)
hold on
plot(sPeriod,PSV2.*1e2)
legend('PTR','APTR')
set(gcf,'unit','centimeters','position',[10 10 30 10])
% Results
v_OR = v_series;        % cm/s
v_ANR = v_APTR + v_BGR; % cm/s
figure
plot((1:length(v_OR)).*dt,v_OR)
hold on
plot((1:length(v_ANR)).*dt,v_ANR)
legend('OR','ANR')
set(gcf,'unit','centimeters','position',[10 10 30 10])
figure
plot((1:length(v_PTR)).*dt,v_PTR)
hold on
plot((1:length(v_APTR)).*dt,v_APTR)
legend('PTR','APTR')
set(gcf,'unit','centimeters','position',[10 10 30 10])
```

