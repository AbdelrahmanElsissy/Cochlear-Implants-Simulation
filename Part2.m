%% Filter bank 
SamplingFrequency = 21e3;
LowFrequency = 100; 
HighFrequency = 8e3;
NumberOfFilters = 10;
NumberOfBorders = NumberOfFilters + 1;
FrequencyPoints = logspace(log10(LowFrequency), log10(HighFrequency), NumberOfBorders);
BorderIndices = 1:1:NumberOfBorders;
figure
stem(BorderIndices, FrequencyPoints)
set(gca,'yscale','log')
grid
ylim([10^2 10^4])
ylabel("Frequency (Hz)"); xlabel("Borders")
fontsize(gca, 14, "points"); exportgraphics(gca, 'FilterFrequencies.pdf', 'ContentType', 'vector')

%% Filter definition and magnitude plot
[h, w] = deal(cell(1, NumberOfFilters));
[b, a] = deal(cell(1, NumberOfFilters));

for i = 1:NumberOfFilters
    [b{i}, a{i}] = butter(2, FrequencyPoints(i:i+1)./(SamplingFrequency/2));
    [h{i}, w{i}] = freqz(b{i}, a{i}, SamplingFrequency, SamplingFrequency);
end

figure
hold on
for i = 1:NumberOfFilters
    plot(w{i}, 20*log10(abs(h{i})));
end
yline(-3, "--");
hold off
set(gca,'xscale','log')
grid
xlabel("Frequency (Hz)"); ylabel("Magnitude (dB)")
xlim([10^1.9 10^4]); 
ylim([-12 0]);
fontsize(gca, 14, "points"); exportgraphics(gca, 'FilterMagnitudes.pdf', 'ContentType', 'vector')

%% Filtering
[wordSignal, WordSamplingFrequency] = audioread("word.wav");
[noiseSignal, NoiseSamplingFrequency] = audioread("noise.wav");

FilteredWord = cell(1, NumberOfFilters);
FilteredNoise = cell(1, NumberOfFilters);

for i = 1:NumberOfFilters
    FilteredWord{i} = filter(b{i}, a{i}, wordSignal);
    FilteredNoise{i} = filter(b{i}, a{i}, noiseSignal);
end

OutputChannels = cell(1, NumberOfFilters);

for i = 1:NumberOfFilters
    OutputChannels{i} = audioplayer(FilteredWord{i}, SamplingFrequency);
end

play(OutputChannels{2});
play(OutputChannels{9});

windowSize = SamplingFrequency * 15e-3;
overlapSize = SamplingFrequency * 5e-3;

figure
spectrogram(FilteredWord{2}, windowSize, overlapSize, [], SamplingFrequency, 'yaxis')
set(gca, 'YScale', "log")
fontsize(gca, 14, "points"); exportgraphics(gca, 'FilteredWord2.pdf', 'ContentType', 'vector')

figure
spectrogram(FilteredNoise{2}, windowSize, overlapSize, [], SamplingFrequency, 'yaxis')
set(gca, 'YScale', "log")
fontsize(gca, 14, "points"); exportgraphics(gca, 'FilteredNoise2.pdf', 'ContentType', 'vector')

figure
spectrogram(FilteredWord{9}, windowSize, overlapSize, [], SamplingFrequency, 'yaxis')
set(gca, 'YScale', "log")
fontsize(gca, 14, "points"); exportgraphics(gca, 'FilteredWord9.pdf', 'ContentType', 'vector')

figure
spectrogram(FilteredNoise{9}, windowSize, overlapSize, [], SamplingFrequency, 'yaxis')
set(gca, 'YScale', "log")
fontsize(gca, 14, "points"); exportgraphics(gca, 'FilteredNoise9.pdf', 'ContentType', 'vector')

%% Vocoder
Envelope = cell(1, NumberOfFilters);
CompressedEnvelope = cell(1, NumberOfFilters);
ModulatedSignal = cell(1, NumberOfFilters);

for i = 1:NumberOfFilters
    Envelope{i} = abs(hilbert(FilteredWord{i}));
    CompressedEnvelope{i} = (log10(1+300.*Envelope{i})) / (log10(1+300));
    ModulatedSignal{i} = CompressedEnvelope{i} .* FilteredNoise{i};
end

VocodedSignal = sum(cat(3, ModulatedSignal{:}), 3);

VocoderPlayer = audioplayer(VocodedSignal, SamplingFrequency);
play(VocoderPlayer)
audiowrite("vocoded_signal.wav", VocodedSignal, SamplingFrequency)

figure
spectrogram(VocodedSignal, windowSize, overlapSize, [], SamplingFrequency, 'yaxis')
fontsize(gca, 14, "points"); exportgraphics(gca, 'VocodedSpectrogram.pdf', 'ContentType', 'vector')
