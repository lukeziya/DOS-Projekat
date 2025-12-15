
    if exist('SVMModel.mat', 'file');
        load('SVMModel.mat', 'SVMModel');
        disp('Uspjesno ucitan obuceni SVM model!');
    else
        error('SVMModel nije pronadjen. Prvo napravite modl u mainProject.m');
    end


testFolder = 'C:\Users\kukec\Desktop\ETF Materijali\TRECA godina\Peti semestar\DOS\Projekat\AI Voice Detection\ai';
audioFiles = dir(fullfile(testFolder, '*.wav'));

numFiles = length(audioFiles);

if numFiles == 0
    error('Nema .wav fajlova u navedenom folderu!');
end

numHuman = 0;
numAi = 0;
numFailed = 0;

for i = 1 : numFiles
    
    filePath = fullfile(testFolder, audioFiles(i).name);
    
    try
        
        features = extractFeatures(filePath);
        
        prediction = predict(SVMModel, features);
        
        if prediction == 1
            numHuman = numHuman + 1;
            fprintf('Detektovan human file: %s\n', audioFiles(i).name);
        else
            numAi = numAi + 1;
            
        end
        
    catch
        fprintf('Greska pri obradi fajla: %s\n', audioFiles(i).name);
        numFailed = numFailed + 1;
    end
end

percentHuman = (numHuman / numFiles) * 100;
percentAi = (numAi / numFiles) * 100;
percentFailed = (numFailed / numFiles) * 100;


fprintf('\n--- REZULTATI TESTIRANJA ---\n');
fprintf('Ukupno testirano fajlova: %d\n', numFiles);
fprintf('Testirani folder: %s\n', testFolder);
fprintf('Prepoznato kao LJUDSKI glas: %d (%.2f%%)\n', numHuman, percentHuman);
fprintf('Prepoznato kao AI glas: %d (%.2f%%)\n', numAi, percentAi);
fprintf('Neuspjesno obradjeno: %d (%.2f%%)\n', numFailed, percentFailed);
fprintf('----------------------------\n');



        
