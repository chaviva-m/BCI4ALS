% EEGLAB history file generated on the 28-Nov-2021
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadxdf('C:\Users\Elyasaf\Documents\school\BCI\week6 - recordings\EEG.xdf' , 'streamtype', 'EEG', 'exclude_markerstreams', {});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','shir','gui','off'); 
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','C:\\Users\\Elyasaf\\Documents\\school\\BCI\\BCI4ALS\\montage_ultracortex.ced','load',{'C:\\Users\\Elyasaf\\Documents\\school\\BCI\\BCI4ALS\\montage_ultracortex.ced','filetype','autodetect'});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG, 'nochannel',[12:16] );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','C:\\Users\\Elyasaf\\Documents\\school\\BCI\\BCI4ALS\\montage_ultracortex.ced','load',{'C:\\Users\\Elyasaf\\Documents\\school\\BCI\\BCI4ALS\\montage_ultracortex.ced','filetype','autodetect'});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','C:\\Toolboxes\\EEGLAB\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',45,'plotfreqz',1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 0, 1, 1);
EEG = eeg_checkset( EEG );
pop_selectcomps(EEG, [1:11] );
EEG = eeg_checkset( EEG );
EEG = pop_iclabel(EEG, 'default');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
eeglab redraw;
