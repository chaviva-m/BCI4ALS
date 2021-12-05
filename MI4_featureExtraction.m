function [] = MI4_featureExtraction(recordingFolder)
%% This function extracts features for the machine learning process.
% Starts by visualizing the data (power spectrum) to find the best powerbands.
% Next section computes the best common spatial patterns from all available
% labeled training trials. The next part extracts all learned features.
% This includes a non-exhaustive list of possible features (commented below).
% At the bottom there is a simple feature importance test that chooses the
% best features and saves them for model training.


%% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.

%% Load previous variables:
load(strcat(recordingFolder,'EEG_chans.mat'));                  % load the openBCI channel location
load(strcat(recordingFolder,'MIData.mat'));                     % load the EEG data
targetLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\trainingVec'))));

labels = {'Left', 'Right', 'Idle'};

Features2Select = 10;                                           % number of featuers for feature selection
num4test = 5;                                                   % define how many test trials after feature extraction
numClasses = length(unique(targetLabels));                      % set number of possible targets (classes)
Fs = 125;                                                       % openBCI Cyton+Daisy by Bluetooth sample rate
trials = size(MIData,1);                                        % get number of trials from main data variable
[R, C] = size(EEG_chans);                                       % get EEG_chans (char matrix) size - rows and columns
chanLocs = reshape(EEG_chans',[1, R*C]);                        % reshape into a vector in the correct order
numChans = size(MIData,2);                                      % get number of channels from main data variable

%% Visual Feature Selection: Power Spectrum
% init cells for  Power Spectrum display
motorDataChan = {};
welch = {};
idxTarget = {};
freq.low = 0.5;                             % INSERT the lowest freq 
freq.high = 40;                             % INSERT the highst freq 
freq.Jump = 1;                              % SET the freq resolution
f = freq.low:freq.Jump:freq.high;           % frequency vector
window = 40;                                % INSERT sample size window for pwelch
noverlap = 20;                              % INSERT number of sample overlaps for pwelch
vizChans = [1,2];                           % INSERT which 2 channels you want to compare

% create power spectrum figure:
f1 = figure('name','PSD','NumberTitle','off');
sgtitle(['Power Spectrum For The Choosen Electrode']);
% compute power Spectrum per electrode in each class
psd = nan(numChans,numClasses,2,1000); % init psd matrix
for chan = 1:numChans
    motorDataChan{chan} = squeeze(MIData(:,chan,:))';                   % convert the data to a 2D matrix fillers by channel
    nfft = 2^nextpow2(size(motorDataChan{chan},1));                     % take the next power of 2 length of the specific trial length
    welch{chan} = pwelch(motorDataChan{chan},window, noverlap, f, Fs);  % calculate the pwelch for each electrode
    figure(f1);
    subplot(numChans,1,chan)
%     figure;
    for class = 1:numClasses
        idxTarget{class} = find(targetLabels == class);                 % find the target index
        plot(f, log10(mean(welch{chan}(:,idxTarget{class}), 2)));       % ploting the mean power spectrum in dB by each channel & class
        hold on
        ylabel([EEG_chans(chan,:)]);                                    % add name of electrode
        for trial = 1:length(idxTarget{class})                          % run over all concurrent class trials
            [s,spectFreq,t,psd] = spectrogram(motorDataChan{chan}(:,idxTarget{class}(trial)),window,noverlap,nfft,Fs);  % compute spectrogram on specific channel
            multiPSD(trial,:,:) = psd;
        end
        
        % compute mean spectrogram over all trials with same target
        totalSpect(chan,class,:,:) = squeeze(mean(multiPSD,1));
        clear multiPSD psd
    end
    legend(labels)
end
% manually plot (surf) mean spectrogram for channels C4 + C3:
mySpectrogram(t,spectFreq,totalSpect,numClasses,vizChans,EEG_chans)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Add your own data visualization here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idleIdx = find(targetLabels == 3);                  % find idle trials
leftIdx = find(targetLabels == 1);                  % find left trials
rightIdx = find(targetLabels == 2);                 % find right trials

% visualize voltage as a function of time
for channel = vizChans
    figure; hold on;
    title(EEG_chans(channel,:))
    for trial = 1:trials
        if any(trial==leftIdx), c='b'; elseif any(trial==rightIdx), c='r'; else, c='g';end
        plot(squeeze(MIData(trial,channel,:)), 'color', c);
    end
end


%% Common Spatial Patterns
% create a spatial filter using available EEG & labels
% we will "train" a mixing matrix (wTrain) on 80% of the trials and another
% mixing matrix (wViz) just for the visualization trial (vizTrial). This
% serves to show an understandable demonstration of the process.

% Begin by splitting into two classes:
leftClass = MIData(targetLabels == 1,:,:);
rightClass = MIData(targetLabels == 2,:,:);

% Aggregate all trials into one matrix
overallLeft = [];
overallRight = [];
idleIdx = find(targetLabels == 3);                  % find idle trials
leftIdx = find(targetLabels == 1);                  % find left trials
rightIdx = find(targetLabels == 2);                 % find right trials
rightIndices = rightIdx(randperm(length(rightIdx)));% randomize right indexs
leftIndices  = leftIdx(randperm(length(leftIdx)));   % randomize left indexs
idleIndices  = idleIdx(randperm(length(idleIdx)));   % randomize idle indexs
minTrials = min([length(leftIndices), length(rightIndices)]);
percentIdx = floor(0.8*minTrials);                  % this is the 80% part...
for trial=1:percentIdx
    overallLeft = [overallLeft squeeze(MIData(leftIndices(trial),:,:))];
    overallRight = [overallRight squeeze(MIData(rightIndices(trial),:,:))];
end
vizTrial = 5;       % cherry-picked!
% visualize the CSP data:
figure;
subplot(1,2,1)      % show a single trial before CSP seperation
scatter3(squeeze(leftClass(vizTrial,1,:)),squeeze(leftClass(vizTrial,2,:)),squeeze(leftClass(vizTrial,3,:)),'b'); hold on
scatter3(squeeze(rightClass(vizTrial,1,:)),squeeze(rightClass(vizTrial,2,:)),squeeze(rightClass(vizTrial,3,:)),'g');
title('Before CSP')
legend('Left','Right')
xlabel('channel 1')
ylabel('channel 2')
zlabel('channel 11')
% find mixing matrix (wAll) for all trials:
[wTrain, lambda, A] = csp(overallLeft, overallRight);

% find mixing matrix (wViz) just for visualization trial:
[wViz, lambdaViz, Aviz] = csp(squeeze(leftClass(vizTrial,:,:)), squeeze(rightClass(vizTrial,:,:)));
rightClassCSP = (wViz'*squeeze(rightClass(vizTrial,:,:)));
leftClassCSP = (wViz'*squeeze(leftClass(vizTrial,:,:)));
rightClassCSP = (wViz'*squeeze(rightClass(vizTrial,:,:)));

subplot(1,2,2)      % show a single trial after CSP seperation
scatter3(squeeze(leftClassCSP(1,:)),squeeze(leftClassCSP(2,:)),squeeze(leftClassCSP(11,:)),'b'); hold on
scatter3(squeeze(rightClassCSP(1,:)),squeeze(rightClassCSP(2,:)),squeeze(rightClassCSP(11,:)),'g');
title('After CSP')
legend('Left','Right')
xlabel('CSP dimension 1')
ylabel('CSP dimension 2')
zlabel('CSP dimension 11')

clear leftClassCSP rightClassCSP Wviz lambdaViz Aviz

%% Spectral frequencies and times for bandpower features:
% frequency bands
% informative
bands{1} = [10,30]; % right
bands{2} = [10,16]; % right
bands{3} = [18,30]; % left
bands{4} = [20,30]; % left
bands{5} = [18,30]; % idle
    
% times of frequency band features
times{1} = round((0.32*Fs : 0.48*Fs));  % right class
times{2} = round((1.28*Fs : 1.44*Fs));  % right class
times{3} = round((2.4*Fs : 2.56*Fs));   % left class
times{4} = round((3.36*Fs : 3.52*Fs));  % left class
times{5} = round((4.32*Fs : 4.48*Fs));  % idle

numSpectralFeatures = length(bands);                        % how many features exist overall 

%% Extract features 
MIFeaturesLabel = NaN(trials,numChans,numSpectralFeatures); % init features + labels matrix
MIFeaturesName = cell(trials,numChans,numSpectralFeatures); % names of features
for trial = 1:trials                                % run over all the trials
    
    % CSP: using W computed above for all channels at once
    temp = var((wTrain'*squeeze(MIData(trial,:,:)))');   % apply the CSP filter on the current trial EEG data
%     CSPFeatures(trial,:) = temp(1:3);               % add the variance from the first 3 eigenvalues
    CSPFeatures(trial,:) = temp([1,2,11]);               % add the variance from the first 3 eigenvalues
    clear temp                                      % clear the variable to free it for the next loop
    
    for channel = 1:numChans                        % run over all the electrodes (channels)
        n = 1;                                      % start a new feature index
        for feature = 1:numSpectralFeatures                 % run over all spectral band power features from the section above
            % Extract features: bandpower +-1 Hz around each target frequency
            MIFeaturesLabel(trial,channel,n) = bandpower(squeeze(MIData(trial,channel,times{feature})),Fs,bands{feature});
            MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': bandpower ' num2str(bands{feature}(1)) '-' num2str(bands{feature}(2)) ' Hz ' ...
                num2str(times{feature}(1)/Fs) ':' num2str(times{feature}(end)/Fs) ' min'];
            n = n+1;            
        end
        disp(strcat('Extracted Powerbands from electrode:',EEG_chans(channel,:)))
        
        
        % NOVEL Features - an explanation for each can be found in the class presentation folder
        
        % Normalize the Pwelch matrix
        pfTot = sum(welch{channel}(:,trial));               % Total power for each trial
        normlizedMatrix = welch{channel}(:,trial)./pfTot;   % Normalize the Pwelch matrix by dividing the matrix in its sum for each trial
        disp(strcat('Extracted Normalized Pwelch Matrix from electrode:',EEG_chans(channel,:)))
        
        
        % Root Total Power
        MIFeaturesLabel(trial,channel,n) = sqrt(pfTot);     % Square-root of the total power
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': square-root of total power'];
        n = n + 1;
        disp(strcat('Extracted Root Total Power from electrode:',EEG_chans(channel,:)))
        
        
        % Spectral Moment
        MIFeaturesLabel(trial,channel,n) = sum(normlizedMatrix.*f'); % Calculate the spectral moment
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': spectral moment'];
        n = n + 1;
        disp(strcat('Extracted Normalized Pwelch Matrix from electrode:',EEG_chans(channel,:)))
        
        
        % Spectral Edge
        probfunc = cumsum(normlizedMatrix);                 % Create matrix of cumulative sum
        % frequency that 90% of the power resides below it and 10% of the power resides above it
        valuesBelow = @(z)find(probfunc(:,z)<=0.9);         % Create local function
        % apply function to each element of normlizedMatrix
        fun4Values = arrayfun(valuesBelow, 1:size(normlizedMatrix',1), 'un',0);
        lengthfunc = @(y)length(fun4Values{y})+1;           % Create local function for length
        % apply function to each element of normlizedMatrix
        fun4length = cell2mat(arrayfun(lengthfunc, 1:size(normlizedMatrix',1), 'un',0));
        MIFeaturesLabel(trial,channel,n) = f(fun4length);   % Insert it to the featurs matrix
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': spectral edge'];
        n = n + 1;
        disp(strcat('Extracted Spectral Edge from electrode:',EEG_chans(channel,:)))
        
        
        % Spectral Entropy
        MIFeaturesLabel(trial,channel,n) = -sum(normlizedMatrix.*log2(normlizedMatrix)); % calculate the spectral entropy
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': spectral entropy'];
        n = n + 1;
        disp(strcat('Extracted Spectral Entropy from electrode:',EEG_chans(channel,:)))
        
        
        % Slope
        transposeMat = (welch{channel}(:,trial)');          % transpose matrix
        % create local function for computing the polyfit on the transposed matrix and the frequency vector
        FitFH = @(k)polyfit(log(f(1,:)),log(transposeMat(k,:)),1);
        % convert the cell that gets from the local func into matrix, perform the
        % function on transposeMat, the slope is in each odd value in the matrix
        % Apply function to each element of tansposeMat
        pFitLiner = cell2mat(arrayfun(FitFH, 1:size(transposeMat,1), 'un',0));
        MIFeaturesLabel(trial,channel,n)=pFitLiner(1:2 :length(pFitLiner));
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': slope'];
        n = n + 1;
        disp(strcat('Extracted Slope from electrode:',EEG_chans(channel,:)))
        
        
        % Intercept
        % the slope is in each double value in the matrix
        MIFeaturesLabel(trial,channel,n)=pFitLiner(2:2:length(pFitLiner));
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': intercept'];
        n= n + 1;
        disp(strcat('Extracted Intercept from electrode:',EEG_chans(channel,:)))
        
        
        % Mean Frequency
        % returns the mean frequency of a power spectral density (PSD) estimate, pxx.
        % The frequencies, f, correspond to the estimates in pxx.
        MIFeaturesLabel(trial,channel,n) = meanfreq(normlizedMatrix,f);
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': mean frequency'];
        n = n + 1;
        disp(strcat('Extracted Mean Frequency from electrode:',EEG_chans(channel,:)))
        
        
        % Occupied bandwidth
        % returns the 99% occupied bandwidth of the power spectral density (PSD) estimate, pxx.
        % The frequencies, f, correspond to the estimates in pxx.
        MIFeaturesLabel(trial,channel,n) = obw(normlizedMatrix,f);
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': occupied bandwidth'];
        n = n + 1;
        disp(strcat('Extracted Occupied bandwidth from electrode:',EEG_chans(channel,:)))
        
        
        % Power bandwidth
        MIFeaturesLabel(trial,channel,n) = powerbw(normlizedMatrix,Fs);
        MIFeaturesName{trial,channel,n} = [EEG_chans(channel,:) ': power bandwidth'];
        n = n + 1;
        disp(strcat('Extracted Power bandwidth from electrode:',EEG_chans(channel,:)))
               
    end
end



% z-score all the features
MIFeaturesLabel = zscore(MIFeaturesLabel);

% Reshape into 2-D matrix
MIFeatures = reshape(MIFeaturesLabel,trials,[]);
MIFeaturesName2D = reshape(MIFeaturesName, trials, []);
MIFeatures = [CSPFeatures MIFeatures];              % add the CSP features to the overall matrix
MIFeaturesName2D = [repmat({'CSP1'},1,size(MIFeaturesName2D,1))'...
                    repmat({'CSP2'},1,size(MIFeaturesName2D,1))'...
                    repmat({'CSP11'},1,size(MIFeaturesName2D,1))'...
                    MIFeaturesName2D];
                    

AllDataInFeatures = MIFeatures;
save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');

testIdx = randperm(length(idleIdx),num4test);                       % picking test index randomly
testIdx = [idleIdx(testIdx) leftIdx(testIdx) rightIdx(testIdx)];    % taking the test index from each class
testIdx = sort(testIdx);                                            % sort the trials

% split test data
FeaturesTest = MIFeatures(testIdx,:,:);     % taking the test trials features from each class
LabelTest = targetLabels(testIdx);          % taking the test trials labels from each class

% split train data
FeaturesTrain = MIFeatures;
FeaturesTrain (testIdx ,:,:) = [];          % delete the test trials from the features matrix, and keep only the train trials
LabelTrain = targetLabels;
LabelTrain(testIdx) = [];                   % delete the test trials from the labels matrix, and keep only the train labels

%% Feature Selection (using neighborhood component analysis)
class = fscnca(FeaturesTrain,LabelTrain);   % feature selection
% sorting the weights in desending order and keeping the indexs
[~,selected] = sort(class.FeatureWeights,'descend');
% taking only the specified number of features with the largest weights
SelectedIdx = selected(1:Features2Select);
disp('Features selected:');
for ii = 1:length(SelectedIdx)
    disp(MIFeaturesName2D{1,SelectedIdx(ii)});
end
FeaturesTrainSelected = FeaturesTrain(:,SelectedIdx);       % updating the matrix feature
FeaturesTest = FeaturesTest(:,SelectedIdx);                 % updating the matrix feature
% saving
save(strcat(recordingFolder,'\FeaturesTrain.mat'),'FeaturesTrain');
save(strcat(recordingFolder,'\FeaturesTrainSelected.mat'),'FeaturesTrainSelected');
save(strcat(recordingFolder,'\FeaturesTest.mat'),'FeaturesTest');
save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
save(strcat(recordingFolder,'\LabelTest.mat'),'LabelTest');
save(strcat(recordingFolder,'\LabelTrain.mat'),'LabelTrain');

disp('Successfuly extracted features!');

end

