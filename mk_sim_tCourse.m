function simulated_tCourses = mk_sim_tCourse(sets, DMs, cModel, cNoise)
% Simulate voxel time course for different directional tuning profiles.
%
% This script simulates voxel time courses reflecting either unimodal
% directional tuning (one random direction), bimodal tuning (two random 
% directions) or random tuning (randomly many random directions). To do so, 
% it re-uses the analysis design matrix, combines the regressors depending 
% on the desired tuning profile and adds pre-defined Gaussian noise.  
% M.Nau, Nov. 2019

% loop over voxels
simulated_tCourses  = nan(size(DMs{1, cModel},2), size(DMs,1), sets.n_voxels);
for cVox            = 1:sets.n_voxels
    
    % select tuning
    cDirs = 1:size(DMs{1,cModel},1); cDirs = randperm(numel(cDirs));
    if strcmp(sets.model_flag, 'unimodal');    cDirs = cDirs(1);
    elseif strcmp(sets.model_flag, 'bimodal'); cDirs = cDirs(1:2);
    elseif strcmp(sets.model_flag, 'random');  cDirs = cDirs(1:randi(size(DMs{1,cModel},1)));
    else; fprintf('\n Tuning not specified');
    end
    
    % build timecourses
    sim_tCourse = cell2mat(arrayfun(@(run) sum(DMs{run, cModel}(cDirs,:), 1), 1:size(DMs,1), 'uni', 0)');
    
    % add gaussian noise
    added_noise     =   mean(std(sim_tCourse,[],2))*sets.noise_levels(cNoise);
    sim_tCourse     =   [sim_tCourse + normrnd(0,added_noise,size(sim_tCourse))]';
    
    % collect output
    simulated_tCourses(:,:,cVox) = zscore(sim_tCourse, [], 2);
end