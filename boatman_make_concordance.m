%boatman_make_concordance 
% Matches all commodities, from any HS version, to HSCPC
% Assumes HSCPC is based on HS96

disp('Running Boatman HS-HSCPC concordance maker...');

% Current directory
current_dir = [fileparts(which(mfilename)) filesep]; 
addpath(genpath(current_dir));

% Read HSCPC and HS definitions
[~,~, raw] = xlsread([current_dir '/hscpc-definitions.xlsx'], 'Commodities'); 
hscpc_labels = raw;

col_idx_hs6 = find(strcmp(hscpc_labels(1,:),'HS6'));

[~,~, raw] = xlsread([current_dir 'hs-concordances/HS-SITC-BEC_Correlations_2022_bis.xlsx']); 
correlations = raw;

clear raw

% Find the unique HS versions and ignore HS96
hs_versions = correlations(1,1:7);
%hs_versions(find(strcmp(hs_versions,'HS96'))) = [];
col_idx_hs96 = find(strcmp(correlations(1,:),'HS96'));

% Crop correlations
header_correl = correlations(1,:);
correlations = correlations(2:end,:);

% Perform matching
header = {'hs-version', 'idx-original', 'idx-hs96', 'idx-hscpc'};

concordance = [];
for j = 1:size(hs_versions,2)
    
    hs_n = hs_versions{j};
    disp(['Matching ' hs_n]);

    col_idx_hsj = find(strcmp(header_correl,hs_n));

    new_block = cell(size(correlations,1),size(header,2));
    z = 1;
    
    for i = 1:size(correlations,1)
        
        %HS96 match
        hs_j = correlations{i, col_idx_hsj};
        hs_96 = correlations{i, col_idx_hs96};

        % HSCPC match
        hscpc_match = find(strcmp(hscpc_labels(:,col_idx_hs6),hs_96));

        if isempty(hscpc_match)
            disp(['Could not match: ' hs_96]);
        else
            hscpc_idx = num2str(hscpc_labels{hscpc_match,1});
    
            % Save match
            new_block(z,:) = {hs_n hs_j hs_96 hscpc_idx};
            z = z + 1;
        end

    end

    % Append
    if z <= size(new_block,1)
        new_block(z:end,:) = [];
    end
    concordance = [concordance; new_block];

end

% Write to disk
hs_hscpc_conc = [header; concordance];
save([current_dir '/boatman-hs-x-hscpc-conc.mat'], 'hs_hscpc_conc');

disp('Finished');