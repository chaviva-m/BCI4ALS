addpath(genpath('C:\Users\Elyasaf\Documents\school\BCI\installations\liblsl-Matlab-1.14.0-Win_amd64_R2020b\liblsl-Matlab'));
lib = lsl_loadlib(); version = lsl_library_version(lib);
addpath("C:\Toolboxes\eeglab2021.1\plugins\erplab8.20\erplab8.20\pop_functions")
addpath(genpath("C:\Toolboxes\EEGLAB\"))
% eeglab
% recPath = "C:\Users\Elyasaf\Documents\school\BCI\week6 - recordings\"
recPath = "C:\Users\Elyasaf\Documents\school\BCI\week 7 - nitai\"

% reading channel location - first pop channels 12:16 with select data,
% then load the montage location files, which will only find you the
% labels. then do the set location again with the default path and select
% ok.