function mkPlots(sets, acc)
% Visualize basic results. 
% This script plots the results for all models and noise levels tested, 
% the effect of noise and some simulated voxel time courses.
% MNau Nov. 2019

% want to save the figures?
savePlots = 0;

% ----------------------------------------------------------------------- %
% Model results: This figure shows model accuracies averaged across voxels. 
% Each subplot shows the results for a different true tuning width used to 
% generate the simulated time course. 
% If a tuning width of e.g. 10 degrees was used to generate the simulated 
% time course, then the vHD-kernels modeling 10 degrees are expected to
% show the highest accuracies. 
% The effect of noise is normalized for visualization.

pix_scr = get(0,'screensize'); 
figure('Position', [pix_scr(1), pix_scr(4)/2, pix_scr(3), pix_scr(4)/4]);
for cModel = 1:numel(sets.widths)
    subplot(1,numel(sets.widths),cModel);
    tmp = (squeeze(acc.mean(cModel,:,:)))';
    tmp = (tmp - min(tmp))./range(tmp);
    imagesc(tmp);
    xlabel('Noise (std of signal)'); ylabel('Tested vHD-width');
    set(gca, 'YTickLabels', sets.widths);
    title(sprintf('True width: %d deg', sets.widths(cModel)));
end
subplot(1,numel(sets.widths),1); text(1.5,1.5,sprintf('Tuning profile: \n%s', sets.model_flag))
if savePlots == 1; saveas(gcf,sprintf('results_%s_model.svg', sets.model_flag)); end
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% Effect of noise on model performance
% This figure shows the a detrimental impact of noise on model performance
options.handle     = figure;
options.color_area = [128 193 219]./255;
options.color_line = [ 52 148 186]./255;
options.alpha      = 0.4;
options.line_width = 2;
options.error      = 'sem';
plot_areaerrorbar(cell2mat(arrayfun(@(vox) mean(squeeze(mean(acc.all(vox,:,:,:)))),1:size(acc.all,1), 'uni', 0)'),options)
title('Effect of noise')
ylabel('Model performance (r)'); xlabel('Noise (std of signal)')
if savePlots == 1; saveas(gcf,sprintf('noise_%s_model.svg', sets.model_flag)); end
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% typical voxel time course at various noise levels
figure; n = 1;
for cNoise = [0, 1, 10]
    sim_tCourse     =   sum(sets.DMs{3, round(numel(sets.widths)/2+1)}([3 8],:),1);
    added_noise     =   std(sim_tCourse)*cNoise;
    sim_tCourse     =   zscore([sim_tCourse + normrnd(0,added_noise,size(sim_tCourse))]');
    subplot(4,1,n); plot(sim_tCourse); n = n + 1;
    title(sprintf('%d std noise', cNoise)); box off;
    xlabel('Time / TRs'); ylabel('signal amplitude'); xlim([0, 200]);
    tmp_table(:,n-1) = sim_tCourse; 
end
sim_tCourse     =   sum(sets.DMs{3, round(numel(sets.widths)/2)+1}([3 8],:),1);
sim_tCourse     =   cell2mat(arrayfun(@(x) zscore([sim_tCourse + normrnd(0,added_noise,size(sim_tCourse))]'), 1:sets.n_voxels,'uni', 0));
subplot(4,1,n); plot(mean(sim_tCourse,2));
title(sprintf('%d std noise, mean across %d equally tuned voxels', cNoise, sets.n_voxels));
xlabel('Time / TRs'); ylabel('signal amplitude'); box off; xlim([0, 200]);
if savePlots == 1; saveas(gcf,sprintf('tCourse_bidirectional_model.svg', sets.model_flag)); end
end
% ----------------------------------------------------------------------- %
