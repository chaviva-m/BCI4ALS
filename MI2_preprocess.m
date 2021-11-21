function [] = MI2_preprocess(recordingFolder)
%% Offline Preprocessing
% Assumes recorded using Lab Recorder.
% Make sure you have EEGLAB installed with ERPLAB & loadXDF plugins.

% [recordingFolder] - where the EEG (data & meta-data) are stored.

% Preprocessing using EEGLAB function.
% 1. load XDF file (Lab Recorder LSL output)
% 2. look up channel names - YOU NEED TO UPDATE THIS
% 3. filter data above 0.5 & below 40 Hz
% 4. notch filter @ 50 Hz
% 5. advanced artifact removal (ICA/ASR/Cleanline...) - EEGLAB functionality

%% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.

%% Some parameters (this needs to change according to your system):
% update to your own computer path 
addpath("C:\Users\nitai seri\Desktop\study\university\year3\BCI\eeglab2021.1\plugins\erplab8.20\erplab8.20\pop_functions")
addpath(genpath('C:\Users\nitai seri\Desktop\study\university\year3\BCI\liblsl-Matlab-1.14.0-Win_amd64_R2020b\liblsl-Matlab'));
addpath(genpath('C:\Users\nitai seri\Desktop\study\university\year3\BCI\eeglab2021.1'))


eeglab;                                     % open EEGLAB 
highLim = 40;                               % filter data under 40 Hz
lowLim = 0.5;                               % filter data above 0.5 Hz
recordingFile = strcat(recordingFolder,'Week_6_recording_trainingVec-Shir.xdf');

% (1) Load subject data (assume XDF)
EEG = pop_loadxdf(recordingFile, 'streamtype', 'EEG', 'exclude_markerstreams', {});
EEG.setname = 'MI_sub';


% EEG.data = EEG.data(1:11, :);
% EEG.nbchan = 11;

% (2) Update channel names - each group should update this according to
% their own openBCI setup.
EEG_chans(1,:) = 'C03';
EEG_chans(2,:) = 'C04';
EEG_chans(3,:) = 'C0Z';
EEG_chans(4,:) = 'FC1';
EEG_chans(5,:) = 'FC2';
EEG_chans(6,:) = 'FC5';
EEG_chans(7,:) = 'FC6';
EEG_chans(8,:) = 'CP1';
EEG_chans(9,:) = 'CP2';
EEG_chans(10,:) = 'CP5';
EEG_chans(11,:) = 'CP6';


%% (3) Low-pass filter
EEG = pop_eegfiltnew(EEG, 'hicutoff',highLim,'plotfreqz',1);    % remove data above
EEG = eeg_checkset( EEG );
% (3) High-pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',lowLim,'plotfreqz',1);     % remove data under
EEG = eeg_checkset( EEG );
% (4) Notch filter - this uses the ERPLAB filter
EEG  = pop_basicfilter( EEG,  1:15 , 'Boundary', 'boundary', 'Cutoff',  50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 );
EEG = eeg_checkset( EEG );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% (5) Add advanced artifact removal functions %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eegplot(EEG.data)
EEG.data(1,:) = EEG.data(1,:) - (EEG.data(4,:)+EEG.data(6,:)+EEG.data(8,:)+EEG.data(10,:))/4;
EEG.data(2,:) = EEG.data(2,:) - (EEG.data(5,:)+EEG.data(7,:)+EEG.data(9,:)+EEG.data(11,:))/4;
eegplot(EEG.data)


% Save the data into .mat variables on the computer
EEG_data = EEG.data;            % Pre-processed EEG data
EEG_event = EEG.event;          % Saved markers for sorting the data
save(strcat(recordingFolder,'\','cleaned_sub.mat'),'EEG_data');
save(strcat(recordingFolder,'\','EEG_events.mat'),'EEG_event');
save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');
                
end
