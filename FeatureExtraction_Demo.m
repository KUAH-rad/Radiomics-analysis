clear; clc;

%% 1. Set file directory
root_dir = '';
img_name  = ''; 
roi_name = '';

save_name = ''; 

folder_list = dir(root_dir);
tmp_name = {folder_list.name}';
folder_list = tmp_name([folder_list.isdir]');
folder_list(1:2)  = [];

%% 2. Set Initial parameters
bins = 32;
max_dist = 3;
mask_threshold = 0.5;
disp_prog = true;
type = 2; % 1=Min-Max, 2=Mean+-alpha*Std
alpha = 3;
Conver_Z_score = true;

% 3. Loop for each folder
max_patients = length(folder_list);
% max_patients = 35;

for itr = 1:max_patients
    cur_dir = folder_list{itr};
    
    disp(['-------------------' num2str(itr) ' / ' num2str(max_patients) '-------------------']);       
    
    % 1. Load Image data
    img_list = rdir([root_dir filesep cur_dir filesep '**' filesep img_name]);
    if isempty(img_list)
        disp(['Folder: ' cur_dir ' does not have images.']);
        continue;
    end
    [img_data, img_size, img_res, status, msg] = Get_nii(img_list.name);
    if status ~= 1
        disp(['File: ' img_list.name ' has a problem.']);
        disp(msg);
        continue;
    end
    
    
    % 2. Load Mask data
    roi_list = rdir([root_dir filesep cur_dir filesep '**' filesep roi_name]);
    if isempty(roi_list)
        disp(['Folder: ' cur_dir ' does not have mask images.']);
        continue;
    end
    [mask, mask_size, mask_res, status, msg] = Get_nii(roi_list.name);
    if status ~= 1
        disp(['File: ' roi_list.name ' has a problem.']);
        disp(msg);
        continue;
    end
    
    % 3. Calc Texture features
    disp(['Processing File Name: ' img_list.name]);
    
    
    [texture{itr}, status, msg] = Calc_texture(double(ic), double(rc), bins, max_dist, mask_threshold, mask_res, disp_prog, type, alpha);
    
end



%% 4. Save Total Results
% 1) Gather all patients data
for itr =80% 1 : length(texture)
    % Loop for patients
    data_patient = [];
    texture_cur = texture{itr};
    filter_name = fieldnames(texture_cur);
    for itr_filter = 1 : length(filter_name)
        % Loop for Wavelet-filters...
        result = texture_cur.(filter_name{itr_filter});
        
        % 1) Add First-order and Shape
        if strcmpi(filter_name{itr_filter}, 'NONE')
            data_filter = [struct2cell(result.FO); struct2cell(result.SHAPE)];
        else
            data_filter = [struct2cell(result.FO)];
        end
        % 2) Add GLCM
        for itr_dist = 1 : max_dist
            data_filter = [data_filter; struct2cell(result.GLCM{itr_dist})];
        end
        % 2) Add RL
        data_filter = [data_filter; struct2cell(result.RL)];
        data_patient = [data_patient; cell2mat(data_filter)];
    end
    
    if itr == 1
        total_data = zeros(size(data_patient, 1), length(texture));        
    end
    total_data(:, itr) = data_patient;
end

% 2) Save as csv format
csvwrite([root_dir filesep save_name '.csv'], total_data);

% 3) Convert as Z-score
if Conver_Z_score
    mean_mat = repmat(mean(total_data, 2), [1 size(total_data, 2)]);
    std_mat = repmat(std(total_data, 0, 2), [1 size(total_data, 2)]);
    z_data = (total_data - mean_mat) ./ std_mat;
    
    % 4) Save as csv format
    csvwrite([root_dir filesep save_name '_Z.csv'], z_data);
end

