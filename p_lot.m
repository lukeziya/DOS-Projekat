clc; clear; close all;

humanFile = 'slavica.wav';
aiFile    = 'ttsmaker-file-2025-12-14-14-38-42.wav';

Fh = extractFeatures(humanFile);
Fa = extractFeatures(aiFile);

featureNames = { ...
    'MFCC mean','MFCC std', ...
    'Delta MFCC mean','Delta MFCC std', ...
    'Pitch mean','Pitch std', ...
    'RMS std','RMS mean', ...
    'Jitter','Shimmer', ...
    'Spec Centroid mean','Spec Centroid std', ...
    'Spec Flatness mean','Spec Flatness std'};

%% =======================
% 1. NORMALIZOVANI BAR GRAF (SVE)
%% =======================
Fn_h = Fh ./ max([Fh;Fa],[],1);
Fn_a = Fa ./ max([Fh;Fa],[],1);

figure('Color','w','Name','Sve karakteristike');
bar([Fn_h; Fn_a]','grouped')
grid on
legend('Human','AI','Location','northoutside','Orientation','horizontal')
set(gca,'XTickLabel',featureNames,'XTickLabelRotation',45)
ylabel('Normalizovana vrijednost')
title('AI vs Human – kompletno pore?enje feature-a')

%% =======================
% 2. PITCH + JITTER + SHIMMER
%% =======================
idx = [5 6 9 10];

figure('Color','w')
bar([Fh(idx); Fa(idx)]','grouped')
grid on
legend('Human','AI')
set(gca,'XTickLabel',featureNames(idx))
title('Pitch, Jitter i Shimmer')

%% =======================
% 3. SPEKTRALNE OSOBINE
%% =======================
idx = [11 12 13 14];

figure('Color','w')
bar([Fh(idx); Fa(idx)]','grouped')
grid on
legend('Human','AI')
set(gca,'XTickLabel',featureNames(idx))
title('Spektralne karakteristike')

%% =======================
% 4. MFCC vs DELTA MFCC
%% =======================
idx = [1 2 3 4];

figure('Color','w')
bar([Fh(idx); Fa(idx)]','grouped')
grid on
legend('Human','AI')
set(gca,'XTickLabel',featureNames(idx))
title('MFCC i Delta MFCC statistike')

%% =======================
% 5. RAZLIKE (AI - HUMAN)
%% =======================
figure('Color','w')
bar(Fa - Fh)
grid on
set(gca,'XTickLabel',featureNames,'XTickLabelRotation',45)
ylabel('Razlika vrijednosti')
title('Razlika karakteristika (AI ? Human)')
