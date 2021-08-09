function outdata = HRF_conv(indata, TR)
% Convolve design matrix with the hemodynamic response function (HRF). 
% Requires SPM. indata: 2D-design matrix. TR: repetition time in s. 
% MN, Nov. 2019

% HRF kernel
p(1) = 6; p(2) = 16; p(3) = 1; p(4) = 1; p(5) = 6; p(6) = 0; p(7) = 32; % spm-defaults
[hrf_Krnl,~] = spm_hrf(TR, p);

% convolution
for run = 1:size(indata, 1)
    outdata(run,:) = arrayfun(@(dm) cell2mat(arrayfun(@(reg) ...
        my_spm_conv(indata{run, dm}(reg,:), hrf_Krnl, reg),...
        1:size(indata{run, dm},1), 'uni', 0))', 1:size(indata,2), 'uni', 0);
end
end

% hand over to SPM
function tmp_conv = my_spm_conv(data2conv, hrf_Krnl, reg)
U.u = data2conv'; U.name = {num2str(reg)};
tmp_conv = spm_Volterra(U, hrf_Krnl);
end