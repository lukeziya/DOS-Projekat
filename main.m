
load('SVMModel.mat', 'SVMModel');
disp('Uspjesno ucitan obuceni SVM model!');

file = 'Andjela.wav';

disp(['Analiza karakteristika za fajl: ',file]);

singleFeatures = extractFeatures(file);

disp('Pokretanje predikcije');

predict_Label = predict(SVMModel, singleFeatures);

disp('----------------------------------------------------');
disp('REZULTAT KLASIFIKACIJE:');

if predict_Label == 1
    disp('Ovaj audio zapis je klasifikovan kao: LJUDSKI GLAS');
    
elseif predict_Label == 0
    disp('Ovaj audio zapis je klasifikovan kao: AI GENERISAN GLAS');

else
    disp('Doslo je do neocekivane greske u predikciji.');
end

disp(['Numericka vrednost predikcije: ', num2str(predict_Label)]);
disp('----------------------------------------------------');