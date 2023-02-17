%% Moderation Analysis

%Change the path accordingly
addpath 'C:\Users\begum\Desktop\NewExcelSheets\subfile';

%Bands to do the moderation analysis on - Independent Variables
bandslist =  ["Beta"; "Delta"; "Theta"; "Alpha1" ; "Alpha2" ; "Alpha3"; "Alpha4"; "LowAlpha"; "HighAlpha"];
%List of moderators 
moderators = ["MeanEntCreativity"; "MeanCreativity"; "RealOriginalityMean"; "RealTotalIdeas"; 
    "CreDifOrMedian"; "CreDifNumberMedian"; "EntCreDif"; "DifRealOr"; "DifRealOrTIdeas"];

num_factors = length(moderators); %Factors to check as moderators
num_bands = length(bandslist); %number of bandwidths to check for

%Dependent Variable
dependent_var = "MeanEntOrientation";

% Load the Data
P = 'C:\Users\begum\Desktop\NewExcelSheets\subfile';
S = dir(fullfile(P,'*.xlsx'));

for f = 1:numel(S)
    filename = S(f).name;
    %Extract file name
    whichfile = erase(filename,'Mean.xlsx');
    
    T = readtable(fullfile(P,filename));
    
    %Change categorical variables to numerical ones for processing
    T.DifRealOrTIdeas = double(categorical(T.DifRealOrTIdeas));
    T.CreDifNumberMedian = double(categorical(T.CreDifNumberMedian));
    T.CreDifOrMedian = double(categorical(T.CreDifOrMedian));
    T.DifRealOr = double(categorical(T.DifRealOr));
    T.EntCreDif = double(categorical(T.EntCreDif));

    %Dependent variable
    dv_idx = find(string(T.Properties.VariableNames) == dependent_var); 
    Y = table2array(T(:, dv_idx));

    for b = 1:num_bands
     cols = bandslist(b); %which waveband to check

     %Independent Variable -the EEG channel variables-           
     k = strfind(T.Properties.VariableNames,cols);
     indices = find(~cellfun(@isempty,k)); %Indices containing vars for the waveband
    
     num_channels = length(indices);
     moderations = zeros(num_factors*numel(S), num_channels);

        for fac = 1:num_factors
            %Moderator Variable
            m_idx = find(string(T.Properties.VariableNames) == moderators(fac)); 
            factor = table2array(T(:, m_idx));

            analysis_mat = table2array(T(:, indices));

           for ch = 1:num_channels
                %Calculate the interaction term X*Z
                Z = factor;
                X = analysis_mat(:,ch);            
                XZ = X.*Z;
                total = [X Z XZ];
                %Fit linear regression model with all 3 predictors
                lm = fitlm(total,Y,'linear');
                coeffs = lm.Coefficients;
                %Save the pvalue for the interaction term
                pval =  table2array(coeffs("x3","pValue"));
                moderations(fac, ch) = pval;
           end
        end
    
%% Save everything in one excel workbook, in separate sheets
   writematrix(moderations,'ALPHA3MEAN_addedcols_allbands_moderations.xlsx','Sheet',cols,'WriteMode','append', 'AutoFitWidth', true)  
    end
end
