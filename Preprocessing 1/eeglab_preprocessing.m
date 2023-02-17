%% Pre-processing on EEGLAB

%Addpaths to access EEGLAB and the file directory
addpath 'C:\Program Files\MATLAB\R2021b\eeglab2021.0';
%Change the path accordingly
addpath 'C:\Users\begum\Desktop\NewCUT AUTRS_120s\problem';

%% Load the Data
%Change the path accordingly
P = 'C:\Users\begum\Desktop\NewCUT AUTRS_120s\problem';
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

%Remove channels x-dir, y-dir and z-dir
EEG = pop_select( ALLEEG,'nochannel',{'x_dir','y_dir','z_dir'});

%Band-stop (notch) filter at 50 Hz
EEG = pop_eegfiltnew(EEG, 'locutoff',48,'hicutoff',52,'revfilt',1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 

%High-pass filter with cutoff 0.5 Hz
EEG = pop_eegfiltnew(EEG, 'locutoff',0.5);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
EEG = eeg_checkset( EEG );

%Re-referencing channels (avr)
EEG = pop_reref( EEG, [],'exclude',[33:36] );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'gui','off'); 
EEG = eeg_checkset( EEG );

%Interpolation of bad channels ('Fp1' and 'Fp2')
EEG = pop_interp(EEG, [1  32], 'spherical');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 

%Detrending 
EEG.data = detrend(EEG.data')';

%Rereferencing again
EEG = pop_reref( EEG, [],'exclude',33);

%% SAVE FILE
    if subid < 10
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\AUTRS Preprocessing EEGLAB Add\\AUTRS_00' num2str(subid) '_PP1'];
    elseif subid <77
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG Preprocessing ALL FILES\problem\\AUTRS_0' num2str(subid) '_PP1'];
    else
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\AUTRS Preprocessing EEGLAB Add\\AUTRS_' num2str(subid) '_PP1'];
    end
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'savenew',savefilename,'gui','off'); 
EEG = eeg_checkset( EEG );

eeglab redraw;
end