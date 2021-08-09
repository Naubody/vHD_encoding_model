function DM = mk_design_matrix(model, behavior)
% Building the design matrix for the virtual head direction (vHD) model
% 
% This script computes the overlap between the vHD time course & the kernels 
% & creates a design matrix for later model fitting. 
% M.N. Nov 2019

for run = 1:numel(behavior) % 5 scanning runs 
    
    % vHD over time in degrees
    tmp_DM = round(rad2deg(behavior{run}.headDir))+1; tmp_DM(tmp_DM==361) = 1;
    
    % Compute overlap between vHD time course and vHD kernels.
    tmp_DM = arrayfun(@(z) cell2mat(arrayfun(@(y) arrayfun(@(x) ...
        model{z}(y,tmp_DM(x)),1:length(behavior{run}.headDir), ...
        'uni', 1), 1:size(model{z},1), 'uni', 0)'), 1:numel(model), 'uni', 0);
    
    % normalize regressors (scale from 0 to 1)
    tmp_DM = arrayfun(@(z)(tmp_DM{z} - min(tmp_DM{z}, [], 2))./ range(tmp_DM{z}, 2), 1:numel(tmp_DM), 'uni', 0);
    
    % calculate median across TR
    DM(run,:) = arrayfun(@(z) cell2mat(arrayfun(@(y) arrayfun(@(x)...
        median(tmp_DM{z}(y, behavior{run}.TR_idz{x})),...
        1:numel(behavior{run}.TR_idz), 'uni', 1), 1:size(tmp_DM{z},1), 'uni', 0)'), 1:numel(tmp_DM), 'uni', 0);
end
end