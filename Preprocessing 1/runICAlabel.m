%% RUN ICALabel from eeglab on pre-processed data

%Addpaths to access EEGLAB and the file directory
addpath 'C:\Program Files\MATLAB\R2021b\eeglab2021.0';
%Change the path accordingly
addpath 'C:\Users\begum\Desktop\EEG Preprocessing ALL FILES';

%% Load Data Files
%Change the path accordingly
P = 'C:\Users\begum\Desktop\EEG Preprocessing ALL FILES';
S = dir(fullfile(P,'*.set'));

%% Initialize configurations
counter = 38;
for k = 1:numel(S)
    subid = counter(k);
    filename = S(k).name;

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',filename ,'filepath',P);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );

%Run ICA decomposition ('runica')
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on', 'chanind', [1:32]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

%Automatic labelling with ICLabel
EEG = pop_iclabel(EEG, 'default');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

%Flag artifacts for muscle and eye in the [0.9 1] probability range
EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

%Remove flagged components marked in EEG.reject.gcompreject
EEG = pop_subcomp( EEG, [], 0);


%% SAVE FILE
    if subid < 10
        %Change the path accordingly
        savefilename = ['C:\\Users\\begum\\Desktop\\AUTRS PP Step 2 - ICLabel\\AUTRS_00' num2str(subid) '_ICLabel'];
    elseif subid < 77
        %Change the path accordingly
        savefilename = ['C:\\Users\\begum\\Desktop\\AUTRS PP Step 2 - ICLabel\\AUTRS_0' num2str(subid) '_ICLabel'];
    else
        %Change the path accordingly
        savefilename = ['C:\\Users\\begum\\Desktop\\AUTRS PP Step 2 - ICLabel\\AUTRS_' num2str(subid) '_ICLabel'];
    end

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',savefilename,'gui','off'); 
EEG = eeg_checkset( EEG );

eeglab redraw;

end