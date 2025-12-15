function features = extractFeatures(audioFile)

[y, fs] = audioread(audioFile);

y = y(:,1);

frameDuration = 0.03;
frameLen = round(frameDuration * fs);
frameShift = round(frameLen / 2);
%windowVector = hamming(frameLen, 'periodic');


% 1. MFCC (Mel-Frequency Cepstral Coefficients)

mfccs = mfcc(y,fs,'WindowLength', frameLen,'OverlapLength', frameShift);
mfccs(isinf(mfccs)) = 0;
mfccs(isnan(mfccs)) = 0;

d1 = [zeros(1, size(mfccs, 2)); diff(mfccs, 1, 1)];

mfcc_mean = mean(mfccs, 'omitnan');
mfcc_std = std(mfccs, 0 ,'omitnan');
delta_mean = mean(d1, 'omitnan');
delta_std = std(d1, 0 ,'omitnan');


% 2.Pitch (Osnovna frekvencija)

pitch_file = pitch(y,fs,'WindowLength', frameLen, 'OverlapLength', frameShift);

pitch_mean = mean(pitch_file, 'omitnan');
pitch_std = std(pitch_file, 'omitnan');


% 3. Jitter

jitter = mean(abs(diff(pitch_file)), 'omitnan') / (pitch_mean + eps);


% 4. RMS (Energija - Root Mean Square)

numFrames = floor((length(y) - frameLen) / frameShift) + 1;

rms_values = zeros(numFrames, 1);

for k = 1 : numFrames
    startIndex = (k-1) * frameShift + 1;
    endIndex = startIndex + frameLen -1;
    rms_values(k) = rms(y(startIndex : endIndex));
end

rms_mean = mean(rms_values, 'omitnan');
rms_std = std(rms_values, 'omitnan');


% 5. Shimmer 

shimmer = mean(abs(diff(rms_values)), 'omitnan') / (rms_mean + eps);

% 6. Spectral Centroid


numFrames = floor((length(y) - frameLen) / frameShift) + 1;
spectral_centroid = zeros(numFrames,1);

for k = 1:numFrames
    idx1 = (k-1)*frameShift + 1;
    idx2 = idx1 + frameLen - 1;

    frame = y(idx1:idx2) .* hamming(frameLen);
    F = abs(fft(frame));
    F = F(1:floor(end/2));
    f = (0:length(F)-1)' * fs / frameLen;

    spectral_centroid(k) = sum(f .* F) / (sum(F) + eps);
end

spectral_centroid_mean = mean(spectral_centroid,'omitnan');
spectral_centroid_std  = std(spectral_centroid,'omitnan');


% 7. Spectral Flatness (Odnos geometrijske i aritmeticke sredine)


flatness = zeros(numFrames,1);

for k = 1:numFrames
    idx1 = (k-1)*frameShift + 1;
    idx2 = idx1 + frameLen - 1;

    frame = y(idx1:idx2) .* hamming(frameLen);
    F = abs(fft(frame));
    F = F(1:floor(end/2)) + eps;

    flatness(k) = exp(mean(log(F))) / mean(F);
end

flat_mean = mean(flatness,'omitnan');
flat_std  = std(flatness,'omitnan');



features = [mfcc_mean, mfcc_std, delta_mean, delta_std,pitch_mean, pitch_std, rms_std,rms_mean, ...
                jitter, shimmer, spectral_centroid_mean,spectral_centroid_std, flat_mean,flat_std];
end

