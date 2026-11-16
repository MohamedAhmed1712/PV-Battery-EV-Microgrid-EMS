%% MICROGRID EMS - MAIN SCRIPT
% PV + Battery + EV Charging Microgrid
% Rule-Based Energy Management System

clearvars;
clc;
close all;

%% 1. Locate project directory

% Find main.m
script_path = which('main');

if isempty(script_path)
    error('Cannot locate main.m');
end

script_dir = fileparts(script_path);
project_dir = fileparts(script_dir);

cd(project_dir);
addpath(fullfile(project_dir, 'scripts'));

%% 2. Initialize parameters

run(fullfile(project_dir, 'scripts', 'params.m'));

%% 3. Generate input profiles

run(fullfile(project_dir, 'scripts', 'make_inputs.m'));

%% 4. Load Simulink model

model = 'microgrid_v1';

load_system(fullfile(project_dir, 'models', ...
    [model '.slx']));

%% 5. Run simulation

fprintf('\nRunning Microgrid EMS simulation...\n');

simOut = sim(model);

%% 6. Extract simulation results

Pg = simOut.Pg_log.Data(:);
Pb = simOut.Pb_log.Data(:);
Pev = simOut.Pev_log.Data(:);
Ppv = simOut.Ppv_log.Data(:);
SOC = simOut.SOC_log.Data(:);

t = simOut.Pg_log.Time(:);

%% 7. Validate power balance

balance_error = max(abs(Pg - (Pev - Ppv - Pb)));

%% 8. Align electricity prices

price = interp1( ...
    ts_price.Time(:), ...
    ts_price.Data(:), ...
    t, 'previous', 'extrap');

%% 9. Calculate EMS electricity cost

cost_rate = max(Pg,0).*price ...
          - max(-Pg,0).*feedin;

C_independent = sum( ...
    cost_rate(1:end-1).*diff(t)/3600);

C_EMS = simOut.TotalCost.Data(end);

%% 10. Calculate baseline without battery

Pg_baseline = Pev - Ppv;

baseline_rate = max(Pg_baseline,0).*price ...
              - max(-Pg_baseline,0).*feedin;

C_baseline = sum( ...
    baseline_rate(1:end-1).*diff(t)/3600);

%% 11. Calculate economic savings

savings = C_baseline - C_EMS;

savings_pct = 100*savings/C_baseline;

%% 12. Display results

fprintf('\n========== MICROGRID EMS RESULTS ==========\n');

fprintf('Without battery: %.2f EUR\n', C_baseline);
fprintf('With EMS:        %.2f EUR\n', C_EMS);

fprintf('Daily savings:   %.2f EUR\n', savings);
fprintf('Cost reduction:  %.2f %%\n', savings_pct);

fprintf('\n========== VALIDATION ==========\n');

fprintf('Independent cost: %.2f EUR\n', C_independent);

fprintf('Cost difference: %.8f EUR\n', ...
    abs(C_EMS-C_independent));

fprintf('Power balance error: %.8f kW\n', balance_error);

fprintf('Maximum grid import: %.2f kW\n', max(Pg));

fprintf('Minimum SOC: %.2f %%\n', min(SOC)*100);
fprintf('Maximum SOC: %.2f %%\n', max(SOC)*100);
fprintf('Final SOC: %.2f %%\n', SOC(end)*100);

%% 13. Save results

results_dir = fullfile(project_dir, 'results');

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

save(fullfile(results_dir, 'simulation_final.mat'), ...
    'Pg', 'Pb', 'Pev', 'Ppv', 'SOC', 't', ...
    'C_EMS', 'C_baseline', 'savings', ...
    'savings_pct', 'balance_error');

fprintf('\nSimulation completed successfully!\n');