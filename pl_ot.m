clc; clear; close all;

%% U?itaj audio fajlove
humanFile = 'clip_21.wav';
aiFile    = 'ttsmaker-file-2025-12-14-14-38-42.wav';

F_human = extractFeatures(humanFile);
F_ai    = extractFeatures(aiFile);

%% Imena feature-a (MORA odgovarati redoslijedu u extractFeatures)
featureNames = { ...
    'MFCC mean','MFCC std', ...
    'Delta MFCC mean','Delta MFCC std', ...
    'Pitch mean','Pitch std', ...
    'RMS std','RMS mean', ...
    'Jitter','Shimmer', ...
    'Spec Centroid mean','Spec Centroid std', ...
    'Spec Flatness mean','Spec Flatness std'};

%% Normalizacija (radi ljepšeg pore?enja)
Fh = F_human ./ max([F_human; F_ai], [], 1);
Fa = F_ai    ./ max([F_human; F_ai], [], 1);

%% BAR GRAFIK – kompletno pore?enje
figure('Color','w','Name','AI vs Human – Feature Comparison');

bar([Fh; Fa]','grouped')
grid on

legend('Human','AI','Location','northoutside','Orientation','horizontal')
set(gca,'XTickLabel',featureNames,'XTickLabelRotation',45)

ylabel('Normalizovana vrijednost')
title('Pore?enje karakteristika: Ljudski glas vs AI glas')

%%
idx = [5 6 9 10]; % pitch mean, pitch std, jitter, shimmer

figure('Color','w')
bar([F_human(idx); F_ai(idx)]','grouped')
set(gca,'XTickLabel',featureNames(idx))
legend('Human','AI')
grid on
title('Pitch, Jitter i Shimmer – klju?ne razlike')


%%
idx = [11 12 13 14]; % centroid & flatness

figure('Color','w')
bar([F_human(idx); F_ai(idx)]','grouped')
set(gca,'XTickLabel',featureNames(idx))
legend('Human','AI')
grid on
title('Spektralne karakteristike')
