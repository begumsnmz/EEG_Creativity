%% Correlation Analysis

%Path to table that contains correlation variables
%Change the path accordingly
addpath 'C:\Users\begum\Desktop\correlation_mat';

%Table 1 obtains correlation without including the channel asymmetry variables
%Table 2 obtains correlations without including the channel asymmetry variables

% Variables for Table 1
% correlation_cols = ["Age"; "Sex"; "MeanEntOrientation"; "Alpha4ACenFrontal"; "MeanEntCreativity"; 
%     "RealOriginalityMean"; "RealTotalIdeas"];

% Variables for Table 2
correlation_cols = ["Age"; "Sex"; "MeanEntOrientation"; 
    "Alpha4Fp2Fp1"; "Alpha4F4F3"; "Alpha4FC2FC1"; "Alpha4ACenFrontal"; 
    "MeanEntCreativity"; "RealOriginalityMean"; "RealTotalIdeas"];

% Load the Data
P = 'C:\Users\begum\Desktop\correlation_mat';
S = dir(fullfile(P,'*.xlsx'));

filename = S.name;
T = readtable(fullfile(P,filename));

%Extract the columns with the given correlation variables in written  order
all_colls = string(T.Properties.VariableNames) == correlation_cols;
col_idx = zeros(length(correlation_cols), 1);

for r=1:size(all_colls,1)
    col_idx(r) = find(all_colls(r, :));
end

%Indexed matrix with the relevant columns to apply correlation
corr_mat =  table2array(T(:, col_idx));

%Obtain the means and stds of each variable
means = mean(corr_mat, 1)';
stds = std(corr_mat, 1)';

%Obtain the correlation coefficients and their respective pvalues
[R, P] = corrcoef(corr_mat);

%Save all the results in a struct
COR_2.VarNames = correlation_cols;
COR_2.VarIDX = col_idx;
COR_2.matrix = corr_mat;
COR_2.means = means;
COR_2.stds = stds;
COR_2.R = R;
COR_2.P = P;

save("Correlations_2_Retest.mat", "COR_2");
