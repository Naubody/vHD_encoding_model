# Voxel-wise encoding model of navigation behavior
Analysis & voxel-time-course simulation code for: 
Behavior-dependent directional tuning in the human visual-navigation network. 
Nau, Navarro Schröder, Frey, Doeller. 2020. Nature Communications

This code simulates voxel time courses, builds various encoding models of virtual head direction (vHD), trains 
them using cross-validated ridge regression, and finally tests them on held-out data. The model also estimates the vHD-tuning width for each voxel (similar to population receptive field mapping). 
Requires SPM12.

Click [HERE](https://www.nature.com/articles/s41467-020-17000-2/figures/2) for a 
visual depiction of the pipeline.

# How to run the code
1) Download code
1) Open the script: "vHD_simulation.m"
2) Set path to SPM
3) Adjust the number of parallel workers to match your computer specs 
4) Click "run"

To get a first immpression, I recommend reducing the number of voxels for the 
first runs to speed tings up.

# Log file
The code makes use of the navigation data of a sample participant. The log file
contains two relevant variables: "headDir", the virtual head direction over time 
(higher temporal resolution than the imaging data) and "TR_idz", the linear 
indizes corresponding to each value in headDir split into TRs/functional images.
The file contains data of all 5 scanning runs.

# Output and results
The script will visualize the results of the simulations as shown in the paper's
SFig. 4C.

# Adapting this code to analyse fMRI data
You can easily adapt this simulated code for new fMRI-data analyses by replacing
the simulated voxel time courses for real ones (e.g. taken from an ROI). In this
case, preprocess & clean your data beforehand incl. nuisance regression of head-
motion parameters...).

# Questions?
If you have any comments or questions, please reach out to me: 
matthias.nau[at]nih.gov
