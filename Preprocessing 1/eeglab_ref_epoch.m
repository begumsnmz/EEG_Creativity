%% Epoch the preprocessed data

%The addpaths for EEGLAB and the respective data folder 
addpath 'C:\Program Files\MATLAB\R2021b\eeglab2021.0';
%Change the path accordingly
addpath 'C:\Users\begum\Desktop\AUTRS PP Step 2 - ICLabel\problem';

%% Load Data Files
%Change the path accordingly
P = 'C:\Users\begum\Desktop\AUTRS PP Step 2 - ICLabel\problem';
S = dir(fullfile(P,'*.set'));

%% Initialize configurations
counter = [1:20 22:76 906];
for k = 1:numel(S)
    subid = counter(k);
    filename = S(k).name;

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',filename ,'filepath',P);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );

%Remove unnecessary events from eventlist
EEG.event = EEG.event(~strcmp({EEG.event.type},'boundary'));
EEG.event = EEG.event(~strcmp({EEG.event.type},'R  3'));
EEG.event = EEG.event(~strcmp({EEG.event.type},'R  7'));
EEG.event = EEG.event(~strcmp({EEG.event.type},'R 15'));
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%Epoch data with respect to the 
EEG = pop_editeventvals(EEG,'insert',{1,[],[],[],[],[],[],[],[],[]},'changefield',{1,'latency',1},'changefield',{1,'duration',0.004},'changefield',{1,'type','Start'},'changefield',{1,'code','Start'});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

if subid<43
    stim = 'S  7';
elseif subid<77
    stim = 'S  1';
else
    stim = 'S  5';
end

EEG = pop_epoch( EEG, {  stim  'Start'  }, [-1  121], 'epochinfo', 'yes');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );


%Remove baseline from each epoch (1000 ms)
EEG = pop_rmbase( EEG, [-1000 0] ,[],[1:32] );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); 

%Re-referencing channels (avr)
EEG = pop_reref( EEG, [],'exclude', 33);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); 
EEG = eeg_checkset( EEG );

%% SAVE FILE
    if subid < 10
       %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\AUTRS Preprocessing Final\\AUTRS_00' num2str(subid) '_Final'];
    elseif subid < 77
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\AUTRS Preprocessing Final\\AUTRS_0' num2str(subid) '_Final'];
    else
        %Change the path accordingly
       savefilename = ['C:\Users\begum\Desktop\AUTRS Preprocessing Final\\AUTRS_' num2str(subid) '_Final'];
    end

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',savefilename,'gui','off'); 
EEG = eeg_checkset( EEG );

end