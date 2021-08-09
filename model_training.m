function weights = model_training(all_DM, all_tCourses, all_runs)
% Model training: fit model weights for all regressors in the design matrix 
% using L2-regularized ridge regression. This is a three-step process.
%
% First, estimate weights for various regularization parameters (lambda) 
% using parts of the training data. Second, use these weights to predict 
% held-out validation data. These steps are being cross-validated. 
% Third, find best predicting lamdba and estimate final weights using the 
% full training data set.
%
% Note: if you want to interpret differences in weights across voxels, you
% need to average lambda across voxels before estimating the final training 
% weights. We did this in the published article, but do not do this here
% for the sake of simplicity. Please reach out if you have any questions.
% M.Nau Nov. 2019

% lambda search space
lambda          =   logspace(0,7,10);

% find optimal lambda via cross-validation
for which_model =   1:size(all_DM,2)
    clearvars C
    for val_run =   1:numel(all_runs)
        
        % define which runs are being tested
        train_runs  = 1:numel(all_runs); train_runs(val_run) = [];
        
        % training data
        train_tCourse = all_tCourses(:,train_runs); train_tCourse = train_tCourse(:);
        
        % design matrix
        train_DM    = [all_DM{train_runs, which_model}]';
        
        % fit model for all lambdas
        betas       = ridge(train_tCourse, train_DM, lambda, 0);
        
        % predict validation data
        val_tCourse = all_tCourses(:,val_run);
        n_TRs       = numel(val_tCourse);
        for k = 1:numel(lambda)
            yhat    =  sum(repmat(betas(:,k)',n_TRs,1).*[ones(1,n_TRs); all_DM{val_run, which_model}]',2); %yhat
            C(val_run, k) = corr(val_tCourse,yhat, 'type', 'Pearson');
        end
    end
    
    % find optimal lambda and fit final model weights 
    lambda_prime         = lambda(nanmean(C,1) == max(nanmean(C,1)));
    weights{which_model} = ridge(all_tCourses(:), [all_DM{:, which_model}]', lambda_prime, 0);
end
end