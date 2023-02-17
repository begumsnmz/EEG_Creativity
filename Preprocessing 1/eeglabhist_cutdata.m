%% Remove continuous data segments with respect to stimuli 

% This script is for the initial cleaning of continuous EEG data before
% pre-processing

%The addpaths for EEGLAB and the respective data folder 
addpath 'C:\Program Files\MATLAB\R2021b\eeglab2021.0';
%Change the path accordingly
addpath 'C:\Users\begum\Desktop\eeg data\AUTRS\';

%To store the latencies for the eyes-open/eyes-closed
latencies = zeros(55,2);

for subid = [1:20 22:76 906]
%% LOAD FILES
    if subid < 10
        fid =  ['AUTRS_00' num2str(subid) '.vhdr'];
    elseif ismember(subid, [10, 20, 32, 43])
        fid = ['AUTRS_0' num2str(subid) '1.vhdr'];
    elseif subid<77
        fid = ['AUTRS_0' num2str(subid) '.set'];
    else
        fid = ['AUTRS_' num2str(subid) '.vhdr'];
    end

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    %Change the path accordingly
    EEG = pop_loadset('filename',fid ,'filepath','C:\Users\begum\Desktop\eeg data\AUTRS\problem');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',['AUTRS_00' num2str(subid) '_cut'],'gui','off'); 
    EEG = eeg_checkset( EEG );
    s = EEG.srate;
    pop_eegplot( EEG, 1, 0, 1);
   
    %% DATA REJECTION
    % Remove the SyncOut and boundary events
    EEG.event = EEG.event(~strcmp({EEG.event.type},'SyncOut'));
    EEG.event = EEG.event(~strcmp({EEG.event.type},'boundary'));
    EEG.event = EEG.event(~strcmp({EEG.event.type},'R  3'));

    % Remove unnecessary data intervals
    value = (EEG.event(1).latency-s - 120*s);
    EEG = eeg_eegrej(EEG, [0 value]); % remove data (from beginning until 120s before S7)

    EEG = eeg_eegrej(EEG, [EEG.event(2).latency+s EEG.event(3).latency-s]); % remove data (between S7 and R15)
    
    EEG = eeg_eegrej(EEG, [EEG.event(end).latency+s EEG.pnts]); % remove data (from R15 till end)
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); % store changes
    eeglab redraw % redraw interface   %%comment to shut down GUI

    %% CHECK LATENCIES
    % Obtain time until S7
    s7lat = EEG.event(2).latency;
    
    eyesclosed = s7lat/s;
    % Obtain time until first R15
    s15lat = EEG.event(3).latency;
    sendlat = EEG.event(end).latency;

    eyesopen = (sendlat-s15lat)/s;

    % Put it in the array
    latencies(subid, :) = [eyesclosed eyesopen];

    %% SAVE FILE
    if subid < 10
        filename = ['AUTRS_00' num2str(subid) '_cut2'];
    elseif subid <77
        filename = ['AUTRS_0' num2str(subid) '_cut2'];
    else
        filename = ['AUTRS_' num2str(subid) '_cut2'];
    end
    %Change the path accordingly
    filepath = 'C:\Users\begum\Desktop\NewCUT AUTRS_120s\problem';
    pop_saveset( EEG, filename, filepath);
    close all;
end