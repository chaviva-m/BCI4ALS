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
addpath 'C:\Toolboxes\EEGLAB'               % update to your own computer path
eeglab;                                     % open EEGLAB 
highLim = 40;                               % filter data under 40 Hz
lowLim = 0.5;                               % filter data above 0.5 Hz
recordingFile = strcat(recordingFolder,'\EEG.xdf');

% (1) Load subject data (assume XDF)
EEG = pop_loadxdf(recordingFile, 'streamtype', 'EEG', 'exclude_markerstreams', {});
EEG.setname = 'MI_sub';

EEG.data = EEG.data(1:11, :);
EEG.nbchan = 11;

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

EEG.data = EEG.data(1:size(EEG_chans,1),:); 
EEG.nbchan = size(EEG_chans,1);

%% Plot raw data - my code
figure; hold on;
[~, exp_timeS] = min(abs(EEG.times - EEG.event(2).latency));
[~, exp_timeL] = min(abs(EEG.times - EEG.event(end-1).latency));
EEG_time_exp = EEG.times(exp_timeS:exp_timeL)-EEG.times(exp_timeS);
time_min = EEG_time_exp./(EEG.srate*60);
for ii = 1:size(EEG_chans,1)    
%     data_centered = EEG.data(ii,exp_timeS:exp_timeL) - mean(EEG.data(ii,exp_timeS:exp_timeL));
    plot(time_min, EEG.data(ii,exp_timeS:exp_timeL));   
end
xlabel('Time (min)')
xlim([time_min(1) time_min(end)])
markers = cellfun(@str2num, extractfield(EEG.event, 'type'), 'UniformOutput', false); 
markers = cell2mat(markers);
latencies = extractfield(EEG.event, 'latency');
markerIds = [1001, 3, 1, 2];
markerNames = {'BL', 'Idle', 'Left', 'Right'};
colors = {'k', 'r', 'b', 'm'};
h = []; hL = [];
for mm = 1:length(markerIds)
    markerIdx = markers == markerIds(mm);
    markerLat = latencies(markerIdx);
    markerIdxTime = arrayfun(@(x) find(abs(EEG_time_exp - x) == min(abs(EEG_time_exp - x))), markerLat, 'UniformOutput', false);
    markerIdxTime = cell2mat(markerIdxTime);
    h{end+1} = arrayfun(@(a)xline(a, colors{mm}, 'DisplayName', markerNames{mm}),EEG_time_exp(markerIdxTime)./(EEG.srate*60)); 
    hL(end+1) = h{end}(1);
end
legend(hL);
%% Plot raw data
eegplot(EEG.data)
%% PSD 
figure;
[spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'percent', 50,'freqrange',[0, 60],'electrodes','off');
legend(EEG_chans);
title('Raw data')

%% (3) Low-pass filter
% [spectra,freqs] = spectopo(EEG.data(1,:),0,EEG.srate,lowLim:1:highLim,EEG_chans);
EEG = pop_eegfiltnew(EEG, 'hicutoff',highLim,'plotfreqz',0);    % remove data above
EEG = eeg_checkset( EEG );
figure;
[spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'percent', 50,'freqrange',[0, 60],'electrodes','off');%, limits,title,freqfaq, percent);
title('Low pass filter')
legend(EEG_chans);
% (3) High-pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',lowLim,'plotfreqz',0);     % remove data under
EEG = eeg_checkset( EEG );
figure;
[spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'percent', 50,'freqrange',[0, 60],'electrodes','off');%, limits,title,freqfaq, percent);
title('High pass filter')
legend(EEG_chans);

% (4) Notch filter - this uses the ERPLAB filter
EEG  = pop_basicfilter( EEG,  1:EEG.nbchan, 'Boundary', 'boundary', 'Cutoff',  50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 );
EEG = eeg_checkset( EEG );
figure;
[spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'percent', 50,'freqrange',[0, 60],'electrodes','off');%, limits,title,freqfaq, percent);
title('Notch filter')
legend(EEG_chans);

%% ASR
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
%% ICA
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
% add channel locations
chanlocfile = 'C:\\Users\\chubb\\Documents\\BCI4ALS\\montage_ultracortex.ced'; % change this to path on computer
standard_1005_path = 'C:\\Toolboxes\\EEGLAB\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc'; % change this to path on computer
EEG=pop_chanedit(EEG, 'lookup',standard_1005_path,'load',{chanlocfile,'filetype','autodetect'});
EEG=pop_chanedit(EEG, 'lookup',standard_1005_path);
% add ICA labels
EEG = pop_iclabel(EEG, 'default');
% find components that are less than 50% brain activity
brain_label = find(strcmp(EEG.etc.ic_classification.ICLabel.classes, 'Brain'));
non_brain_components = find(EEG.etc.ic_classification.ICLabel.classifications(:,brain_label) < 0.4);
% remove these components
components_to_remove = [non_brain_components];
EEG = pop_subcomp( EEG, components_to_remove, 0);

%% LaPlacian spatial filter around C3 and C4
eegplot(EEG.data)
EEG.data(1,:) = EEG.data(1,:) -  mean(EEG.data(4:2:10,:), 1);
EEG.data(2,:) = EEG.data(2,:) -  mean(EEG.data(5:2:11,:), 1);
eegplot(EEG.data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% (5) Add advanced artifact removal functions %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% eegplot(EEG.data)
% [spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'percent', 50,'freqrange',[0, 60],'electrodes','off');

% Save the data into .mat variables on the computer
EEG_data = EEG.data;            % Pre-processed EEG data
EEG_event = EEG.event;          % Saved markers for sorting the data
save(strcat(recordingFolder,'\','cleaned_sub.mat'),'EEG_data');
save(strcat(recordingFolder,'\','EEG_events.mat'),'EEG_event');
save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');

% EEG = pop_runica(EEG)
% EEG3 = pop_topoplot(EEG2, EEG_chans)

end
