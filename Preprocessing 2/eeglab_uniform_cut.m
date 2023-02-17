%% Obtain uniform epoch lengths across both conditions

%Addpaths to EEGLAB and file directory
addpath 'C:\Program Files\MATLAB\R2021b\eeglab2021.0';
%Change path accordingly
addpath 'C:\Users\begum\Desktop\AUTRS Preprocessing Final';

%Matrices that have the amount of epochs kept per subject 
% (after epoch rejection wrt kurtosis of activity)
closed = load('eyes_closed_std6.mat');
open = load('eyes_open_std6.mat');

%Find the overall minimum across both conditions
Cmin = min(closed.eyes_closed_epochs);
Omin = min(open.eyes_open_epochs);

if Cmin<Omin
    overall_min = Cmin;
else
    overall_min = Omin;
end


cond = 1; %Flag for the conditions cond=1: eyes closed, cond=2: eyes open
%% Load Data Files
if (cond == 1)
    P = 'C:\Users\begum\Desktop\EEG AUTRS Separated\AUTRS_Eyes_Closed\problem';
else
    P = 'C:\Users\begum\Desktop\EEG AUTRS Separated\AUTRS_Eyes_Open\problem';
end

S = dir(fullfile(P,'*.set'));

%% Initialize configurations
%counter = [1:20 22:37 39:76 906];
counter = 38;
for k = 1:numel(S)
    subid = counter(k);
    filename = S(k).name;

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',filename ,'filepath',P);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
%EEG = eeg_checkset( EEG );

%Keep the first n epoch across all subjects and conditions to obtain uniform data length
EEG.data = EEG.data(:,:,1:overall_min);

%% SAVE FILE
    if subid < 10
        if cond == 1
        %Change path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Uniform\AUTRS_Eyes_Closed\\AUTRS_00' num2str(subid) '_U_EC'];
        else
         %Change path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Uniform\AUTRS_Eyes_Open\\AUTRS_00' num2str(subid) '_U_EO'];
        end    
    elseif subid < 77
        if cond == 1
        %Change path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Uniform\AUTRS_Eyes_Closed\\AUTRS_0' num2str(subid) '_U_EC'];
        else
        %Change path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Uniform\AUTRS_Eyes_Open\\AUTRS_0' num2str(subid) '_U_EO'];
        end
    else
        if cond == 1
        %Change path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Uniform\AUTRS_Eyes_Closed\\AUTRS_' num2str(subid) '_U_EC'];
        else
        %Change path accordingly
        savefilename = ['C:\Users\begum\Desktop\EEG AUTRS Uniform\AUTRS_Eyes_Open\\AUTRS_' num2str(subid) '_U_EO'];
        end
    end

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'savenew',savefilename,'gui','off'); 

end

