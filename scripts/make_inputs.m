%% Generate daily microgrid input data

% Generate one day of microgrid data
d = make_day(1);

% Create time vector (seconds)

t = (0:length(d.Pev)-1)' * dt;
% Create timeseries objects
ts_Pev = timeseries(d.Pev, t);
ts_Ppv = timeseries(d.Ppv, t);
ts_price = timeseries(d.price, t);

% Create data folder if it does not exist
if ~exist('data', 'dir')
    mkdir('data');
end

% Save input data
save(fullfile('data', 'inputs_day1.mat'), ...
    'ts_Pev', 'ts_Ppv', 'ts_price');

% Plot generated profiles
figure;

subplot(3,1,1);
plot(t/3600, d.Ppv);
ylabel('PV Power (kW)');
grid on;

subplot(3,1,2);
plot(t/3600, d.Pev);
ylabel('EV Demand (kW)');
grid on;

subplot(3,1,3);
plot(t/3600, d.price);
ylabel('Price (EUR/kWh)');
xlabel('Time (hours)');
grid on;