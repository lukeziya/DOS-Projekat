
clc; clear; close all;

humanFile = 'Andjela.wav'; 
aiFile = 'AiAndjela.wav';


[yH, fsH] = audioread(humanFile);
[yA, fsA] = audioread(aiFile);


sec = 1;
yH = yH(1:min(fsH*sec, length(yH)));
yA = yA(1:min(fsA*sec, length(yA)));

figure('Name', 'Analiza Digitalne Obrade Signala: Human vs AI', 'NumberTitle', 'off');

%% --- SPEKTROGRAM ---
% Pokazuje kako se frekvencije mijenjaju kroz vrijeme
subplot(2,2,1);
spectrogram(yH, hamming(512), 256, 512, fsH, 'yaxis');
title('Spektrogram: Ljudski Glas (Neuredan)');

subplot(2,2,2);
spectrogram(yA, hamming(512), 256, 512, fsA, 'yaxis');
title('Spektrogram: AI Glas (Previše gladak)');

%% --- PERIODOGRAM (PSD - Power Spectral Density) ---

subplot(2,2,3);
[pxxH, fH] = periodogram(yH, rectwin(length(yH)), length(yH), fsH);
plot(fH, 10*log10(pxxH), 'b');
grid on; xlabel('Hz'); ylabel('dB/Hz');
title('Periodogram: Ljudski (Fluktuacije)');

subplot(2,2,4);
[pxxA, fA] = periodogram(yA, rectwin(length(yA)), length(yA), fsA);
plot(fA, 10*log10(pxxA), 'r');
grid on; xlabel('Hz'); ylabel('dB/Hz');
title('Periodogram: AI (Stabilna snaga)');

%% --- SKALOGRAM (Wavelet transformacija) ---

figure('Name', 'Skalogram (Wavelet Analiza)', 'NumberTitle', 'off');

cwt(yH, fsH);
title('Skalogram: Ljudski (Prirodne varijacije u vremenu/frekvenciji)');

figure('Name', 'Skalogram (Wavelet Analiza)', 'NumberTitle', 'off');
cwt(yA, fsA);
title('Skalogram: AI (Matemati?ka pravilnost)');

%% --- VREMENSKI DOMEN (Envelope) ---
figure('Name', 'Envelope i Mikro-oscilacije', 'NumberTitle', 'off');
[upH, ~] = envelope(yH);
[upA, ~] = envelope(yA);

subplot(2,1,1);
plot(yH, 'Color', [0.7 0.7 0.7]); hold on; plot(upH, 'b', 'LineWidth', 1.5);
title('Envelope: Ljudski (Nepravilan Shimmer)');
legend('Signal', 'Anvelopa');

subplot(2,1,2);
plot(yA, 'Color', [0.7 0.7 0.7]); hold on; plot(upA, 'r', 'LineWidth', 1.5);
title('Envelope: AI (Uniforman Shimmer)');
legend('Signal', 'Anvelopa');