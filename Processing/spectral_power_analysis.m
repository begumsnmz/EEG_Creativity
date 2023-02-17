%% Alpha-Power Analysis on Preprocesed Resting-State Data
close all; clear all; clc;

%Addpaths for EEGLAB and the file directory
addpath 'C:\Program Files\MATLAB\R2021b\eeglab2021.0';
%%Change the path accordingly
addpath 'C:\Users\begum\Desktop\Internship';

load('channel_labels.mat');

%% Store values in Struct
num_powers = 4; %number of avr power ranges we calculate
nchan = 32; %number of channels
nsub = 76; %number of subjects
srate = 250; %sampling rate
results = zeros(num_powers*nsub, nchan+1);

e=2; %Calculate eyes-closed and open separately (e=1:Eyes Closed, e=2:Eyes Open)
%% Load Data Files
if e==1 
filename = 'Eyes_Closed.mat';
else 
filename = 'Eyes_Open.mat';
end

load(filename, '-mat');

%% ALPHA POWER ANALYSIS 
counter = [1:20 22:76 906];

for k = 1:length(counter)
    subid = counter(k);
    dataset = Data(k).data;
    results((k-1)*num_powers+1:k*num_powers, 1) = subid;
    for ch=1:size(dataset,1)-1
        %%Method 1: pwelch
        NOVERLAP = 0;
        NFFT = srate;
        WINDOW = srate;
        [spectra,freqs] = pwelch(dataset(ch,:),WINDOW*2,NOVERLAP, NFFT, srate);
    
%         % Set the following frequency bands: delta=1-4, theta=4-8, lowAlpha=8-10, highAlpha=10-13, beta=13-30, gamma=30-80.
%         deltaIdx   = find(freqs>1 & freqs<4);
%         thetaIdx   = find(freqs>=4 & freqs<8);            
%         lowAlphaIdx  = find(freqs>=8 & freqs<10);  
%         highAlphaIdx = find(freqs>10 & freqs<=13);
%         betaIdx  = find(freqs>13 & freqs<30);
%         gammaIdx = find(freqs>30 & freqs<80);

        % Set the following frequency bands: Alpha1=8-13, Alpha2=7.5-12.5, Alpha3=7.5-10, Alpha4=10-12.5
        Alpha1Idx   = find(freqs>=8 & freqs<=13);
        Alpha2Idx   = find(freqs>=7.5 & freqs<=12.5);            
        Alpha3Idx  = find(freqs>=7.5 & freqs<=10);  
        Alpha4Idx = find(freqs>=10 & freqs<=12.5);
        
%         % Compute absolute power.
%         deltaPower = mean(10.^(spectra(deltaIdx)/10));
%         thetaPower = mean(10.^(spectra(thetaIdx)/10));
%         lowAlphaPower = mean(10.^(spectra(lowAlphaIdx)/10));
%         highAlphaPower = mean(10.^(spectra(highAlphaIdx)/10));
%         betaPower  = mean(10.^(spectra(betaIdx)/10));
%         gammaPower = mean(10.^(spectra(gammaIdx)/10));

        % Compute absolute power.
         Alpha1Power = mean(10.^(spectra(Alpha1Idx)/10));
         Alpha2Power = mean(10.^(spectra(Alpha2Idx)/10));
         Alpha3Power = mean(10.^(spectra(Alpha3Idx)/10));
         Alpha4Power = mean(10.^(spectra(Alpha4Idx)/10));

        total_powers = [Alpha1Power; Alpha2Power; Alpha3Power; Alpha4Power;];
        results((k-1)*num_powers+1:k*num_powers, ch+1) = total_powers;
    end
end
