function [test_results] = MI5_modelTraining(recordingFolder)
% MI5_LearnModel_Scaffolding outputs a weight vector for all the features
% using a simple multi-class linear approach.
% Add your own classifier (SVM, CSP, DL, CONV, Riemann...), and make sure
% to add an accuracy test.

%% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2021. You are free to use, change, adapt and
% so on - but please cite properly if published.

%% Read the features & labels 

FeaturesTrain = cell2mat(struct2cell(load(strcat(recordingFolder,'\FeaturesTrainSelected.mat'))));   % features for train set
LabelTrain = cell2mat(struct2cell(load(strcat(recordingFolder,'\LabelTrain.mat'))))';                % label vector for train set

% label vector
LabelTest = cell2mat(struct2cell(load(strcat(recordingFolder,'\LabelTest.mat'))))';      % label vector for test set
FeaturesTest = cell2mat(struct2cell(load(strcat(recordingFolder,'\FeaturesTest.mat'))));   % features for test set

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Split to train and validation sets %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% test data
%FeaturesTrain = [FeaturesTrain LabelTrain'];
rounds = 50;
P = 0.70 ;

valAccuracy = zeros(1,rounds);
for c = 1:rounds
    
    [samples,features_num] = size(FeaturesTrain) ;
    idx = randperm(samples)  ;
    Training = FeaturesTrain(idx(1:round(P*samples)),:) ; 
    Validation = FeaturesTrain(idx(round(P*samples)+1:end),:) ;
    LabelTraining = LabelTrain(idx(1:round(P*samples)),:) ; 
    LabelValidation = LabelTrain(idx(round(P*samples)+1:end),:) ;

    %testPrediction = classify(FeaturesTest,FeaturesTrain,LabelTrain,'linear');          % classify the test set using a linear classification object (built-in Matlab functionality)
%     W = LDA(Training,LabelTraining); 
    t = templateSVM('Standardize',true, 'BoxConstraint', 1, 'Kernelfunction', 'linear', 'Solver', 'SMO');
    Mdl = fitcecoc(Training,LabelTraining, 'Learner', t, 'Coding', 'onevsone');
    yPred = predict(Mdl, Validation);
    valAccuracy(c) = sum(yPred == LabelValidation)/length(LabelValidation);
end

display(['Validation accuracy: ' num2str(mean(valAccuracy))]); 
                                                 % train a linear discriminant analysis weight vector (first column is the constants)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Add your own classifier %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Test data
% test prediction from linear classifier
test_results = (testPrediction'-LabelTest);                                         % prediction - true labels = accuracy
test_results = (sum(test_results == 0)/length(LabelTest))*100;
disp(['test accuracy - ' num2str(test_results) '%'])

save(strcat(recordingFolder,'\TestResults.mat'),'test_results');                    % save the accuracy results
save(strcat(recordingFolder,'\WeightVector.mat'),'W');                              % save the model (W)

end


