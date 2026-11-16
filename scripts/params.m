% Microgrid parameters

dt = 60;
Ppk = 60;
Ebat = 100;
Pbmax = 50;

SOCmin = 0.10;
SOCmax = 0.95;
SOC0 = 0.50;

eta = 0.95;
Pgrid_target = 60;

price_hi = 0.40;
price_lo = 0.22;
feedin = 0.08;

Gmax = 200;

par_vec = [Pbmax SOCmin SOCmax Ebat Pgrid_target price_hi price_lo eta dt Gmax];
