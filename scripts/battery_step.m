function SOCn = battery_step(Pb, SOC, par)

SOCmin = par(2);
SOCmax = par(3);
Ebat = par(4);
eta = par(8);
dt = par(9);

if Pb >= 0
    % Discharging
    dE = -Pb / eta * dt / 3600;
else
    % Charging
    dE = -Pb * eta * dt / 3600;
end

SOCn = SOC + dE / Ebat;

SOCn = min(max(SOCn, SOCmin), SOCmax);

end