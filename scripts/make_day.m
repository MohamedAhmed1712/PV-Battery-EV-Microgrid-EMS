function d = make_day(seed)

rng(seed);

dt = 60;
N = 1440;
t = (0:N-1)'*dt;
h = t/3600;

% --- PV power (kW) ---
% A curve showing the irradiance throught the day e.g. at h=6, G=0 so that's the sunrise and beginning of day, h=12, g=1 
% so that means its at midday and etc. 
% it also uses guassian smoothing equation to approximate the simulation % into real time cloud variations
Ppk = 60;

G = 1000*max(0, sin(pi*(h-6)/12)).^1.2;

cloud = 0.4 + 0.6*rescale(smoothdata(rand(N,1),'gaussian',45));

Ppv = Ppk*(G/1000).*cloud*0.97;

% --- tariff (EUR/kWh) ---
%create a vector with a column containing (N) elements and assigning the 
%tarrif price for each element representing the price of each minute 
%throughout the day.
price = 0.30*ones(N,1);

% Note that the tying relation between price and h is due to the similar 
% vector structure which is a method called indexing.

price(h<6 | h>=22) = 0.20;
price(h>=17 & h<21) = 0.45;

% --- EV load (kW) ---
%creates a 24-element column vector representing 
%the EV arrival rate for each hour of the day.
hrs = (0:23)';

lam = 0.5*ones(24,1); % arrivals per hour

lam(hrs>=7 & hrs<10) = 2;
lam(hrs>=10 & hrs<17) = 4;
lam(hrs>=17 & hrs<21) = 5;
lam(hrs>=21) = 1.5;

Pch = 50;
nPorts = 2;

portFree = zeros(nPorts,1);
lost = 0;
Pev = zeros(N,1);

for k = 1:N

    if rand < lam(floor(h(k))+1)*dt/3600

        E = 15 + 25*rand; % requested energy, kWh

        idx = find(portFree <= t(k), 1);

        if isempty(idx)

            lost = lost + 1; % both chargers busy

        else

            dur = E/Pch*3600; % charging time, s

            portFree(idx) = t(k) + dur;

            kk = k:min(N, k + ceil(dur/dt) - 1);

            Pev(kk) = Pev(kk) + Pch;

        end
    end
end

d = struct('t',t,'h',h,'Ppv',Ppv,...
           'price',price,'Pev',Pev,...
           'lost',lost,'dt',dt);

end