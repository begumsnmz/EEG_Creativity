%% Epoch the data into trials and remove blinks

%Paths to EEGLAB and the file directory
addpath 'C:\Program Files\MATLAB\R2021b\eeglab2021.0';
%Change the path accordingly
addpath 'C:\Users\begum\Desktop\AUTRS Preprocessing Final\problem';

%Event lists for the different subjects/subject groups
%These were extracted since the stimuli type/latencies were not uniform
%across all subjects
events_G1 = load('events_G1_mat');
events_G2 = load('events_G2_mat');
events_20 = load('events_20_mat');
events_32 = load('events_32_mat');
events_906 = load('events_906_mat');

%% Load Data Files
%Change the path accordingly
P = 'C:\Users\begum\Desktop\AUTRS Preprocessing Final\problem';
S = dir(fullfile(P,'*.set'));

%Matrix to keep the epoch numbers
%This is to see how many epochs remain after removal wrt kurtosis of activity per subject
eyes_closed_epochs = zeros(1, numel(S));
eyes_open_epochs = zeros(1, numel(S));


%% Initialize configurations
counter = [1:20 22:37 39:76 906];
%counter = 38;

%Group 1:
group1 = [1:19 22:31 33:37 39:42];
%Group 2:
group2 = [43:76];

for k = 1:numel(S)
    subid = counter(k);
    filename = S(k).name;

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',filename ,'filepath',P);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );

%Match the current subject with their respective eventlist 
if ismember(subid,group1)
    EEG.event = events_G1.events_G1;
elseif ismember(subid, group2)
    EEG.event = events_G2.events_G2;
elseif (subid == 20)
    EEG.event = events_20.events_20;
elseif (subid == 32)
    EEG.event = events_32.events_32;
else
    EEG.event = events_906.events_906;
end

%Seperate the sub-epochs to eyes-closed/eyes-open conditions
EEG_closed = EEG;
EEG_closed.data = EEG.data(:,:,1);
EEG_closed.event = EEG.event(1:600);

EEG_open = EEG;
EEG_open.data = EEG.data(:,:,2);
EEG_open.event = EEG.event(1:600);

for cond = 1:2
    if (cond == 1)
        EEG1 = EEG_closed;
        EEG1.flag = "closed";
    else
        EEG1 = EEG_open;
        EEG1.flag = "open";
    end

EEG1 = pop_epoch( EEG1, {  'trial'  }, [0 0.2-0.004], 'epochinfo', 'yes');
[ALLEEG EEG1] = eeg_store(ALLEEG, EEG1, CURRENTSET); 
EEG1 = eeg_checkset( EEG1 );
EEG1 = pop_rmbase( EEG1, [],[]);

%% Reject trials in a dataset using kurtosis of activity
%SD threshold=6
EEG1 = pop_rejkurt(EEG1, 1, 1:32, 6, 6, 0, 1, 0, [], 0);
EEG1 = pop_rejepoch( EEG1, EEG1.reject.rejkurt, 0);

[ALLEEG EEG1] = eeg_store(ALLEEG, EEG1, CURRENTSET);

%% SAVE FILE
%The eyes-closed and eyes-open data are saved in separated files
    if subid < 10
        if cond == 1
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Separated\AUTRS_Eyes_Closed\\AUTRS_00' num2str(subid) '_TR_EC'];
        else
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Separated\AUTRS_Eyes_Open\\AUTRS_00' num2str(subid) '_TR_EO'];
        end    
    elseif subid < 77
        if cond == 1
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Separated\AUTRS_Eyes_Closed\\AUTRS_0' num2str(subid) '_TR_EC'];
        else
         %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Separated\AUTRS_Eyes_Open\\AUTRS_0' num2str(subid) '_TR_EO'];
        end
    else
        if cond == 1
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Separated\AUTRS_Eyes_Closed\\AUTRS_' num2str(subid) '_TR_EC'];
        else
        %Change the path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Separated\AUTRS_Eyes_Open\\AUTRS_' num2str(subid) '_TR_EO'];
        end
    end

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG1, 2,'savenew',savefilename,'gui','off'); 
EEG1 = eeg_checkset( EEG1 );

eeglab redraw;

%Save the value of the last subject "906" at the last column of the
%eyes_closed_epochs/eyes_open_epochs matrices
if (cond == 1)
    if (subid == 906)
        eyes_closed_epochs(end) = size(EEG1.data, 3);
    else
        eyes_closed_epochs(subid) = size(EEG1.data, 3);
    end
else
    if (subid == 906)
        eyes_open_epochs(end) = size(EEG1.data, 3);
    else
        eyes_open_epochs(subid) = size(EEG1.data, 3);
    end
end

end

end
