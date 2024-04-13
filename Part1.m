%% Open Voice
SampleRate = 21e3; 
NumBits = 16; 
NumChannels = 1; 
filename = "word.wav";

%% Threshold
[voice_signal, Fs1] = audioread(filename);
threshold = 2e-3;
for index = 1:length(voice_signal)
    if abs(voice_signal(index)) <= threshold
        voice_signal(index) = 0; 
    end
end
voice_player = audioplayer(voice_signal, Fs1);
play(voice_player)

%% Random white noise 
white_noise = randn(1, length(voice_signal));
audiowrite("noise.wav", white_noise, Fs1);

%% Spectrogram
window_size = Fs1 * 15e-3;
overlap_size = Fs1 * 5e-3;

figure
spectrogram(voice_signal, window_size, overlap_size, [], Fs1, 'yaxis')
fontsize(gca, 14, "points"); exportgraphics(gca, 'VoiceSpectrogram.pdf', 'ContentType', 'vector')

figure
spectrogram(white_noise, window_size, overlap_size, [], Fs1, 'yaxis')
fontsize(gca, 14, "points"); exportgraphics(gca, 'WhiteNoiseSpectrogram.pdf', 'ContentType', 'vector')
