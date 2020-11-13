%% VideoStabilizer
% This is a implementation of the stablization code and algorithm described
% here: http://www.cs.dartmouth.edu/farid/downloads/publications/tr07.pdf.
%
% See the github readme for more details: https://github.com/frank-engel-usgs/Video-Stabilizer
%
% Original code by: Jeff Ding
%                   (https://github.com/Jeff-Ding/Video-Stabilizer)
% Modifications by: Frank Engel

clc
javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel')
[input_folder] = ...
    uigetdir(pwd, 'Select folder containing images to stabilize');
if ischar(input_folder) % The user did not hit "Cancel"
    [output_folder] = ...
        uigetdir(pwd, 'Select or create folder to store stabilized images');
    if ~ischar(output_folder) % The user hit cancel, disp warning and close
        warndlg('No output folder specified, exiting script...')
        return
    else
        a=[dir([input_folder '/*.jpg']); dir([input_folder '/*.bmp']); dir([input_folder '/*.tif']); dir([input_folder '/*.png'])];
        video_length=size(a,1);
        b=[dir([input_folder '/*.jgw']); dir([input_folder '/*.tfw']); dir([input_folder '/*.pgw']); dir([input_folder '/*.wld'])];
        [~,~,image_ext] = fileparts(a(1).name);
        prompt = {'Image file extension:','Number of frames:', 'Gaussian levels:'};
        title = 'Stabilization settings';
        dims = [1 35];
        definput = {image_ext(end-2:end),num2str(video_length),'1'};
        answer = inputdlg(prompt,title,dims,definput);
        file_type = answer{1};
        video_length = str2num(answer{2});
        Gauss_levels = str2num(answer{3});
       
        stabilize(input_folder, output_folder, file_type, video_length, Gauss_levels)
        if ~isempty(b)  % world files exist
            disp('world files exist')
            c=[dir([output_folder '/*.jpg']); dir([output_folder '/*.bmp']); dir([output_folder '/*.tif']); dir([output_folder '/*.png'])];
            wldfileNames = { b.name };
            simgfileNames = { c.name };
            [~,~,wld_ext] = fileparts(b(1).name);
            for k = 1 : length(b)
                thisFileName = wldfileNames{k};
                thisSimgName = simgfileNames{k};
                inputFullFileName = fullfile(input_folder, thisFileName);
                outputBaseFileName = sprintf('%s%s', thisSimgName(1:end-4), wld_ext); %TODO: make use the appropriate ext
                outputFullFileName = fullfile(output_folder, outputBaseFileName);
                copyfile(inputFullFileName, outputFullFileName);
            end
        end
    end
else
    return
end