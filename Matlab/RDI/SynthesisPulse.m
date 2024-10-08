% School of Civil Engineering, Central South University
% H.P.Duan, hpduan2000@csu.edu.cn
% https://www.hpduan.cn
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