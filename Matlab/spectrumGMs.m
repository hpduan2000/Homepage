% School of Civil Engineering, Central South University
% H.P.Duan, hpduan2000@csu.edu.cn
% https://www.hpduan.cn
function [PSA, PSV, SD, SA, SV, OUT] = spectrumGMs(xi, sPeriod, gacc, dt)
% Input:
%       xi = ratio of critical damping (e.g., 0.05)
%  sPeriod = vector of spectral periods
%     gacc = input acceleration time series in m/s2
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
    displ = (y(1,:))';                          % Relative displacement vector (m)
    veloc = (y(2,:))';                          % Relative velocity (m/s)
    foverm = omegan^2*displ;                    % Lateral resisting force over mass (m/s2)
    absacc = -2*xi*omegan*veloc-foverm;         % Absolute acceleration from equilibrium (m/s2)
    % Extract peak values
    displ_max(i) = max(abs(displ));             % Spectral relative displacement (m)
    veloc_max(i) = max(abs(veloc));             % Spectral relative velocity (m/s)
    absacc_max(i) = max(abs(absacc));           % Spectral absolute acceleration (m/s2)
    foverm_max(i) = max(abs(foverm));           % Spectral value of lateral resisting force over mass (m/s2)
    pseudo_acc_max(i) = displ_max(i)*omegan^2;  % Pseudo spectral acceleration (m/s)
    pseudo_veloc_max(i) = displ_max(i)*omegan;  % Pseudo spectral velocity (m/s)
    PSA(i) = pseudo_acc_max(i);                 % PSA (m/s2)
    SA(i)  = absacc_max(i);                     % SA (m/s2)
    PSV(i) = pseudo_veloc_max(i);               % PSV (m/s)
    SV(i)  = veloc_max(i);                      % SV (m/s)
    SD(i)  = displ_max(i);                      % SD  (m)
    % Time series of acceleration, velocity and displacement response of
    % SDF oscillator
    OUT.acc(:,i) = absacc;
    OUT.vel(:,i) = veloc;
    OUT.disp(:,i) = displ;
end
