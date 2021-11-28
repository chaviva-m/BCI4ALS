% filename = 'C:\Users\hadarl\Downloads\EEG_Team.xdf';
filename = recPath;
montage_file = 'montage_ultracortex.ced';
bins_config_file = 'bins_left_right.txt';
epochStartTime = -5000;
epochEndTime = 5000;


[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadxdf(filename , 'streamtype', 'EEG', 'exclude_markerstreams', {});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 
EEG=pop_chanedit(EEG, 'lookup',montage_file,'load',{montage_file 'filetype' 'autodetect'});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG=pop_chanedit(EEG, 'lookup','C:\\MatlabToolboxes\\eeglab2019_1\\plugins\\dipfit\\standard_BESA\\standard-10-5-cap385.elp');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',45,'plotfreqz',1);
eeglab redraw
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'saveold','before_filt','gui','off'); 
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG, 'nochannel',{'T8' 'PO3' 'PO4'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'saveold','before_chan_removed','gui','off'); 
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','off','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'saveold','before_cleanrawdata','gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'saveold','before_reref','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );


EEG = eeg_checkset( EEG );
EEG = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } ); % GUI: 06-Dec-2015 09:37:20
EEG = eeg_checkset( EEG );
% For some reason, for the first time you use the bins file, you need to
% open it with writing permissions, i.e.:
% fopen(bins_config_file,'w')
EEG = pop_binlister( EEG , 'BDF', bins_config_file, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); % GUI: 06-Dec-2015 09:37:43
EEG = eeg_checkset( EEG );
EEG = pop_epochbin( EEG , [epochStartTime  epochEndTime], 'none'); % [-200 0]); % GUI: 06-Dec-2015 09:37:59
EEG = eeg_checkset( EEG );

eeglab redraw

figure; pop_newtimef( EEG, 1, 1, [-1000  4992], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'C3', 'baseline',[0], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1, 'winsize', 125);
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 5, [-1000  4992], [3         0.5] , 'topovec', 5, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'C4', 'baseline',[0], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1, 'winsize', 125);
