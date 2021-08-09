function [test_acc] = model_test(train_weights, test_tCourse, test_DM)
% Model test. Use training weights to predict held out test data.
% This script computes the predicted time course and correlates it with the
% observed/simulated time course.
% M.Nau Nov 2019

for which_model = 1:size(test_DM,2)
    
    % test model
    test_yhat             =  sum(repmat(train_weights{which_model}',numel(test_tCourse),1).*[ones(1,numel(test_tCourse)); test_DM{which_model}]',2);
    test_acc(which_model) =  corr(test_tCourse,test_yhat, 'type', 'Pearson');
    
end
end