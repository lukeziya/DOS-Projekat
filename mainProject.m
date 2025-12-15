

humanVoice_folder = 'pravi\Real';
aiVoice_folder = 'vjest\Fake';

humanFiles = dir(fullfile(humanVoice_folder, '*.wav'));
aiFiles = dir(fullfile(aiVoice_folder, '*.wav'));

min_count = min(length(humanFiles), length(aiFiles));

select_human = humanFiles(randperm(length(humanFiles), min_count));
select_ai = aiFiles(randperm(length(aiFiles), min_count));

allFiles = [select_human; select_ai];
allFiles = allFiles(randperm(length(allFiles)));


DataMatrix = [];
ResultVector = [];

disp('--- Analiza karakteristika glasova ---');

for i = 1 : length(allFiles)

        filePath = fullfile(allFiles(i).folder, allFiles(i).name);

        features = extractFeatures(filePath);

        DataMatrix = [DataMatrix; features];

        

        if contains(allFiles(i).folder, 'Real')
            ResultVector = [ResultVector; 1]; % 1 = ljudski glas
        else
            ResultVector = [ResultVector;0]; % 0 = ai glas
        end
end

disp(['Ukupno uzoraka: ', num2str(length(ResultVector))]);
disp(['Human: ', num2str(sum(ResultVector == 1)),', AI: ', num2str(sum(ResultVector == 0))]);

% U praksi se najcesce 70-80% koristi za train skup

trainRatio = 0.75;
numFiles =  length(allFiles);
numTrain = round(numFiles * trainRatio);

randomInd = randperm(length(ResultVector));
trainInd = randomInd(1 : numTrain);
testInd = randomInd(numTrain + 1 : end);

disp(['Trening - Human: ', num2str(sum(ResultVector(trainInd) == 1)), ...
      ', AI: ', num2str(sum(ResultVector(trainInd) == 0))]);
disp(['Test - Human: ', num2str(sum(ResultVector(testInd) == 1)), ...
      ', AI: ', num2str(sum(ResultVector(testInd) == 0))]);
  
  
trainData = DataMatrix(trainInd, :);
trainLabels = ResultVector(trainInd);
testData = DataMatrix(testInd, :);
testLabels = ResultVector(testInd);




SVMModel = fitcsvm(trainData, trainLabels,'Standardize', true, 'KernelFunction','rbf', 'ClassNames', [0 1], 'Cost', [0 10; 1 0], 'OptimizeHyperparameters',{ 'BoxConstraint', 'KernelScale'},'HyperparameterOptimizationOptions', struct('MaxObjectiveEvaluations', 50));

disp('--- Testiranje modela ---');

predictedLabels = predict(SVMModel, testData);

accuracy = sum(predictedLabels == testLabels) / length(testLabels);

disp('----------------------------------------------------');
disp(['Tacnost modela na testnom skupu: ', num2str(accuracy * 100), '%']);
disp('----------------------------------------------------');


save('SVMModel.mat', 'SVMModel');
disp('Obuceni model je sacuvan kao SVMModel.mat');

