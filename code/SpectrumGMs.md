# Ground Motion Response Specrtum
Written by H. P. Duan; hpduan2000@163.com; https://www.hpduan.cn  

## function
```matlab
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
```