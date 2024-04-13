%% Record and save the voice
SampleRate = 21e3; 
NumBits = 16; 
NumChannels = 1; 
voice_recorder = audiorecorder(SampleRate, NumBits, NumChannels);
voice_recorder.StartFcn = 'disp(''Start speaking.'')';
voice_recorder.StopFcn = 'disp(''End of recording.'')';
recordblocking(voice_recorder,2);
play(voice_recorder); 
voice_data = getaudiodata(voice_recorder); 

filename = "word.wav";
audiowrite(filename, voice_data, SampleRate)