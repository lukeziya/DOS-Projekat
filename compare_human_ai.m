% compare_human_ai_voice_features.m
% Skripta za pore?enje ljudskog i AI glasa koriste?i extractFeatures funkciju

clear all;
close all;
clc;

%% 1. UCITAJ AUDIO FAJLOVE (PROMENI PUTANJE)
% Ovde dodaj putanje do tvojih audio fajlova
human_audio_file = 'Andjela.wav';    % PROMENI OVO
ai_audio_file = 'AiAndjela.wav';         % PROMENI OVO

% Ako nemaš fajlove, generišemo simulirane
generate_samples = false; % Postavi na true ako nemaš fajlove

if generate_samples
    fprintf('Generišem simulirane audio fajlove...\n');
    fs = 16000;
    
    % Ljudski glas - sa više varijacija
    t_human = 0:1/fs:3; % 3 sekunde
    f0_human = 120;
    
    % Dodaj prirodni shimmer i jitter
    shimmer_var = 0.1 * sin(2*pi*3*t_human) + 0.05*randn(size(t_human));
    amp_env_human = 0.2 + 0.1*shimmer_var;
    human_voice = amp_env_human .* sin(2*pi*f0_human*t_human + 0.1*randn(size(t_human)));
    
    % AI glas - uniformniji
    t_ai = 0:1/fs:3;
    amp_env_ai = 0.3 * ones(size(t_ai)) + 0.01*randn(size(t_ai));
    ai_voice = amp_env_ai .* sin(2*pi*f0_human*t_ai);
    
    % Sa?uvaj fajlove
    audiowrite('sim_human_voice.wav', human_voice, fs);
    audiowrite('sim_ai_voice.wav', ai_voice, fs);
    
    human_audio_file = 'sim_human_voice.wav';
    ai_audio_file = 'sim_ai_voice.wav';
end

%% 2. EKSTRAKTUJ KARAKTERISTIKE ZA OBA GNASA
fprintf('Ekstrakcija karakteristika za ljudski glas...\n');
features_human = extractFeatures(human_audio_file);

fprintf('Ekstrakcija karakteristika za AI glas...\n');
features_ai = extractFeatures(ai_audio_file);

%% 3. NAPRAVI STRUKTURU SA FEATURE IMEIMA
feature_names = {
    'MFCC_mean', 'MFCC_std', 'Delta_mean', 'Delta_std', ...
    'Pitch_mean', 'Pitch_std', 'RMS_std', 'RMS_mean', ...
    'Jitter', 'Shimmer', ...
    'Spectral_Centroid_mean', 'Spectral_Centroid_std', ...
    'Spectral_Flatness_mean', 'Spectral_Flatness_std'
};

%% 4. PRIKAŽI REZULTATE U KONZOLI
fprintf('\n=== REZULTATI EKSTRAKCIJE KARAKTERISTIKA ===\n');
fprintf('LJUDSKI GLAS:\n');
for i = 1:length(feature_names)
    fprintf('  %-25s: %.4f\n', feature_names{i}, features_human(i));
end

fprintf('\nAI GLAS:\n');
for i = 1:length(feature_names)
    fprintf('  %-25s: %.4f\n', feature_names{i}, features_ai(i));
end

fprintf('\nRAZLIKE (Human - AI):\n');
differences = features_human - features_ai;
for i = 1:length(feature_names)
    fprintf('  %-25s: %.4f\n', feature_names{i}, differences(i));
end

%% 5. GRAFIKONI ZA PORE?ENJE

% 5.1 BAR PLOT za klju?ne karakteristike
figure('Position', [100 100 1400 800]);

% Odaberi klju?ne karakteristike za prikaz
key_features_idx = [9, 10, 5, 11, 13]; % Jitter, Shimmer, Pitch_mean, Spectral_Centroid, Flatness
key_feature_names = feature_names(key_features_idx);

subplot(2, 3, 1);
bar_data = [features_human(key_features_idx); features_ai(key_features_idx)]';
bar(bar_data);
set(gca, 'XTickLabel', key_feature_names, 'XTickLabelRotation', 45);
title('Klju?ne karakteristike glasa');
legend('Human', 'AI', 'Location', 'best');
ylabel('Vrednost');
grid on;

% 5.2 Radar plot za sve karakteristike
subplot(2, 3, 2);
% Normalizuj vrednosti za radar plot
features_norm_human = (features_human - min([features_human; features_ai])) ./ ...
                      (max([features_human; features_ai]) - min([features_human; features_ai]) + eps);
features_norm_ai = (features_ai - min([features_human; features_ai])) ./ ...
                   (max([features_human; features_ai]) - min([features_human; features_ai]) + eps);

% Prikaz samo najvažnijih za radar plot (bez MFCC detalja)
radar_features_idx = [5, 6, 9, 10, 11, 12, 13, 14]; % Pitch, Jitter, Shimmer, Spectral features
radar_feature_names = feature_names(radar_features_idx);

theta = linspace(0, 2*pi, length(radar_features_idx) + 1);
theta = theta(1:end-1);

polarplot(theta, features_norm_human(radar_features_idx), 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
polarplot(theta, features_norm_ai(radar_features_idx), 'r-o', 'LineWidth', 2, 'MarkerSize', 8);
title('Radar dijagram (normalizovano)');
legend('Human', 'AI', 'Location', 'best');
set(gca, 'ThetaTick', rad2deg(theta), 'ThetaTickLabel', radar_feature_names);

% 5.3 Shimmer i Jitter pore?enje
subplot(2, 3, 3);
scatter(features_human(9), features_human(10), 100, 'b', 'filled', 'DisplayName', 'Human');
hold on;
scatter(features_ai(9), features_ai(10), 100, 'r', 'filled', 'DisplayName', 'AI');
xlabel('Jitter');
ylabel('Shimmer');
title('Jitter vs Shimmer');
legend('Location', 'best');
grid on;

% Dodaj procentualnu razliku
jitter_diff = (features_human(9) - features_ai(9)) / features_ai(9) * 100;
shimmer_diff = (features_human(10) - features_ai(10)) / features_ai(10) * 100;
text(0.05, 0.9, sprintf('Jitter diff: %.1f%%\nShimmer diff: %.1f%%', ...
    jitter_diff, shimmer_diff), 'Units', 'normalized', 'FontSize', 10);

% 5.4 Spectral karakteristike
subplot(2, 3, 4);
spectral_features = [features_human(11:12), features_human(13:14); 
                     features_ai(11:12), features_ai(13:14)]';
bar(spectral_features);
set(gca, 'XTickLabel', {'Centroid Mean', 'Centroid Std', 'Flatness Mean', 'Flatness Std'}, ...
    'XTickLabelRotation', 45);
title('Spektralne karakteristike');
ylabel('Vrednost');
legend('Human', 'AI', 'Location', 'best');
grid on;

% 5.5 Pitch i RMS varijabilnost
subplot(2, 3, 5);
pitch_rms_data = [features_human(5:6), features_human(7:8); 
                  features_ai(5:6), features_ai(7:8)]';
bar(pitch_rms_data);
set(gca, 'XTickLabel', {'Pitch Mean', 'Pitch Std', 'RMS Mean', 'RMS Std'}, ...
    'XTickLabelRotation', 45);
title('Pitch i RMS karakteristike');
ylabel('Vrednost');
legend('Human', 'AI', 'Location', 'best');
grid on;

% 5.6 Heatmap razlika
subplot(2, 3, 6);
diff_matrix = [features_human; features_ai; differences]';
imagesc(diff_matrix);
colorbar;
title('Heatmap karakteristika');
ylabel('Karakteristike');
xlabel('Human | AI | Razlika');
set(gca, 'YTick', 1:length(feature_names), 'YTickLabel', feature_names, ...
    'XTick', 1:3, 'XTickLabel', {'Human', 'AI', 'Diff'});
colormap(jet);

%% 6. TABELA REZULTATA
fprintf('\n=== SUMARNA TABELA ===\n');
fprintf('%-30s %-12s %-12s %-12s\n', 'Karakteristika', 'Human', 'AI', 'Razlika');
fprintf('%s\n', repmat('-', 66, 1));
for i = 1:length(feature_names)
    fprintf('%-30s %-12.4f %-12.4f %-12.4f\n', ...
        feature_names{i}, features_human(i), features_ai(i), differences(i));
end

%% 7. DECIZIONA ANALIZA
fprintf('\n=== ANALIZA ZA RAZLI?ITOST ===\n');

% Karakteristike gde ve?a vrednost zna?i "više ljudski"
higher_is_human = [9, 10, 6]; % Jitter, Shimmer, Pitch_std

% Karakteristike gde manja vrednost zna?i "više ljudski"
lower_is_human = [13]; % Spectral Flatness

human_score = 0;
ai_score = 0;

for idx = higher_is_human
    if features_human(idx) > features_ai(idx)
        human_score = human_score + 1;
    else
        ai_score = ai_score + 1;
    end
end

for idx = lower_is_human
    if features_human(idx) < features_ai(idx)
        human_score = human_score + 1;
    else
        ai_score = ai_score + 1;
    end
end

fprintf('Human score: %d/4\n', human_score);
fprintf('AI score: %d/4\n', ai_score);

if human_score > ai_score
    fprintf('Glas pokazuje više ljudskih karakteristika.\n');
elseif ai_score > human_score
    fprintf('Glas pokazuje više AI karakteristika.\n');
else
    fprintf('Glas je neutralan - teško je re?i.\n');
end

%% 8. SA?UVAJ REZULTATE
save('voice_comparison_results.mat', 'features_human', 'features_ai', ...
    'feature_names', 'differences', 'human_score', 'ai_score');

% Sa?uvaj grafikone
saveas(gcf, 'voice_features_comparison.png');
saveas(gcf, 'voice_features_comparison.fig');

fprintf('\nAnaliza završena!\n');
fprintf('Grafikoni sa?uvani kao voice_features_comparison.png\n');
fprintf('Podaci sa?uvani u voice_comparison_results.mat\n');