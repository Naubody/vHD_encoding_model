% ----------------------------------------------------------------------- %
% vHD_encoding_model_simulation.
% Sample code for a voxel-wise encoding model of virtual head direction
% (vHD). This code simulates voxel-time-courses, builds various vHD-encoding
% models, trains them using cross-validated ridge-regression and tests them
% on held-out data. This code requires SPM12.
% M.Nau, Jan. 2020
%
% Reference:
% Behavior-dependent directional tuning in the human visual-navigation
% network. Nau, Navarro Schröder, Frey, Doeller. 2020. Nature Communications
%
% See methods and Supplementary Figure 4 for details.
% ----------------------------------------------------------------------- %

% -----------------------------  settings  ------------------------------ %

% path to SPM
addpath('X:\Matthias\Scripts\spm12');

% encoding model settings
sets.n_par_workers   = 24; % n parallel (parfor) workers
sets.widths          = [10 15 20 24 30 36 45 60]; % vHD-tuning widths
sets.test_run        = 3; % 3 by default, overall 5 runs
sets.TR              = 2.756; % TR in seconds

% simulation settings
sets.n_voxels        = 2500; % n simulated voxels
sets.model_flag      = 'bimodal'; % voxel tuning profile - options: 'unimodal', 'bimodal', 'random'
sets.noise_levels    = [1:10]; % noise level in stds
rng(0);

% ---------------------  load data & prepare model  --------------------- %

% build vHD models
models               = mk_HD_model(sets.widths);

% load navigation data of a sample participant, build design matrizes &
% convolve them with the HRF as implemented in SPM12
load('XYs_s120404162236.mat');
DMs                  = mk_design_matrix(models, nav_data);
DMs                  = HRF_conv(DMs, sets.TR);

% start parallel pool
if isempty(gcp('nocreate')) && sets.n_par_workers>1; parpool(sets.n_par_workers); end

% --------------------  start model training & test  -------------------- %
% The two outer loops for simModel & simNoise are to simulate time courses
% (sim_tCourses). These simulated time courses can be replaced e.g. by real 
% cleaned voxel time courses.

% loop over models (for time course simulation)
for simModel = 1:numel(sets.widths)
    
    % loop over noise levels (for time course simulation)
    for simNoise = 1:numel(sets.noise_levels)
        
        % simulate voxel time course
        sim_tCourses = mk_sim_tCourse(sets, DMs, simModel, simNoise);
        
        % model training and test
        test_acc = nan(sets.n_voxels, size(DMs,2)); % container for test accuracies
        parfor sim_vox = 1:sets.n_voxels
            
            % training
            train_runs     = 1:size(sim_tCourses,2); train_runs(sets.test_run) = [];
            train_DM       = [DMs(train_runs, :)];
            train_tCourses = sim_tCourses(:, train_runs, sim_vox);
            train_weights  = model_training(train_DM, train_tCourses, train_runs);
            
            % testing
            test_DM        = DMs(sets.test_run,:);
            test_tCourse   = sim_tCourses(:,sets.test_run, sim_vox);
            [test_acc(sim_vox,:)] = model_test(train_weights, test_tCourse, test_DM);
        end
        
        % collect model performance across simulated models & noise levels
        acc.all(:,:,simModel, simNoise)    = test_acc;
        acc.mean(simModel,simNoise,:)      = mean(test_acc);
    end
end

% ---------------------- save & visualize results  ---------------------- %
save(sprintf('acc_%s.mat', sets.model_flag), 'acc');
sets.DMs = DMs; mkPlots(sets, acc);


% -------  if you are reading this, thank you for your interest!  ------- %