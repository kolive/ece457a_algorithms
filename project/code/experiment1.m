% comparing feature distribution of various VAD's
%

clear;clc;

if matlabpool('size')==0
    matlabpool open;
end
fprintf('Running on %d parallel labs.\n',matlabpool('size'));

load('./speakers.mat'); % WTF IS THIS?
nSpeakers = length(SPEAKERS);

% constants
fs  = 16000; % S: WHAT IS THIS?
Nw  = fs*.02;
Nsh = fs*.01;
nfft = 1024; %2^nextpow2(Nw*4);

% function to calculate short-term energy of a signal x
energy = @(x) sum(enframe(x,Nw,Nsh).^2,2);
% zero crossing rate:
sgn    = @(f) f>=0;
zcr    = @(f) sum(abs(sgn(f(:,2:end))-sgn(f(:,1:end-1))),2);

% initialize noise signal
noisetypes = {'babble';'buccaneer1';'buccaneer2';'destroyerengine';...
              'destroyerops';'f16';'factory1';'factory2';'hfchannel';...
              'leopard';'m109';'pink';'volvo';'machinegun';'white'};

% since this is iterating through every type of noise, we have to remove
% it.
noisetype = noisetypes{4};

fprintf('NOISE TYPE=%s--------------------------------------------\n',noisetype);

% This basically just calls `wavread()`
[n,n_fs] = read_audio(sprintf('../NOISEX-92/%s.wav',noisetype),'wav');
n = resample(n,fs,n_fs); % NOISEX-92 data was sampled at 19980Hz
n = n/max(abs(n)); % normalize n
En = energy(n); % defined earlier at the top of this file    
Pn = sum(En)/length(En); % average power?

SNR = 20:-5:-10;
nSNR = length(SNR);

nSpeakersUsing = 100; % 100 speakers, 1000 utterances

for snrcnt=1:nSNR
    snr = SNR(snrcnt);
    fprintf('SNR=%d dB--------------------------------------------\n',snr);

    sohn99 = cell(nSpeakers,1); % create array for feature value output of SOHN 1999

    parfor s=1:nSpeakersUsing
        % What is this `data` and what is it being used for?
        % It honestly looks like it's just used for determining n_gain. Is
        % it okay if we just hardcode it?
        data = load([SPEAKERS{s},'/data.mat']);
        x = data.x;
        ref = data.ref;

        % add noise to the desired SNR
        assert(length(n)>length(x));
        Ex = energy(x);
        Px = sum(Ex(ref==1))/sum(ref);  % speech power
        Pn1 = Px/(10^(snr/10));         % expected noise power: SNR = 10*log10(Px/Pn1);
        n_gain = sqrt(Pn1/Pn);          % noise gain
                                        %n_Gain(s,snrcnt)=n_gain; %debug
        n1 = n*n_gain;                  % adjust the signals
        y  = x + n1(1:length(x));       % is this mixing a noise signal?

        n_sample = n(end-fs*20:end);    % sample noise for calibration: last 20s

        % SOHN 1999
        pp = struct;
        pp.ti = Nsh/fs;                 % frame increment in seconds
        % output frame start/end in smaples and output activity likelihood
        % ratio
        [~,z] = vadsohn(n_sample,fs,'bn');
        temp = vadsohn(y,z,'bn');
        sohn99{s} = temp(:,3); % Why only the third column?
        fprintf('s=%3d,(%3d%%) %s\n',s,round(s/nSpeakersUsing*100),SPEAKERS{s});
    end

    save(sprintf('%s_%s_%ddB.mat','sohn99',noisetype,snr),'sohn99');

end