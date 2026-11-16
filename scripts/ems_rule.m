function Pb = ems_rule(Pev, Ppv, SOC, price, par)

% Extract parameters
Pbmax = par(1);
SOCmin = par(2);
SOCmax = par(3);
Ebat = par(4);
Pgrid_target = par(5);
price_hi = par(6);
price_lo = par(7);
eta = par(8);
dt = par(9);
Gmax = par(10);

% Net power demand
Net = Pev - Ppv;

% Default battery power
Pb = 0;

% Energy management decisions
if Net < 0
    Pb = max(Net, -Pbmax);

elseif price >= price_hi || Net > Pgrid_target
    Pb = min(Net, Pbmax);

elseif price <= price_lo && SOC < 0.5
    Pb = -0.5 * Pbmax;
end

% SOC-aware power limits
Pdischarge_SOC = max(0, (SOC - SOCmin) * Ebat * eta * 3600 / dt);
Pcharge_SOC = max(0, (SOCmax - SOC) * Ebat * 3600 / (eta * dt));

Pb = min(Pb, Pdischarge_SOC);
Pb = max(Pb, -Pcharge_SOC);

% Battery power limits
Pb = min(max(Pb, -Pbmax), Pbmax);

% Maximum grid import constraint
if Net - Pb > Gmax
    Pb = max(Pb, Net - Gmax);
end

end