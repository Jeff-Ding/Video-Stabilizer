% input_folder = 'D:\Downloads\stabile_test12'; %'E:\LSPIV_Database\20181004_Altar_Arizona_UAS';
% output_folder = 'D:\Downloads\stabile_test12\stable'; 'E:\LSPIV_Database\20181004_Altar_Arizona_UAS\vid_stab2';

% input_folder = 'E:\LSPIV_Database\20181004_Altar_Arizona_UAS';
% output_folder = 'E:\LSPIV_Database\20181004_Altar_Arizona_UAS\vid_stab3';
% input_folder = '\\igskikcwgsnas\Data\sUAS_Management\Projects\LlanoRiver_Flooding\MISSION02\COLLECT1\GoProHero4\LSPIV';
% output_folder = '\\igskikcwgsnas\Data\sUAS_Management\Projects\LlanoRiver_Flooding\MISSION02\COLLECT1\GoProHero4\LSPIV\stabile';
% file_type = 'jpg';
% video_length = 302;
% Gauss_levels = 1;

clear all; close all
[input_folder] = ...
    uigetdir(pwd, 'Select folder containing images to stabilize');
[output_folder] = ...
    uigetdir(pwd, 'Select or create folder to store stabilized images');
a=[dir([input_folder '/*.jpg']); dir([input_folder '/*.bmp']); dir([input_folder '/*.tif'])];
video_length=size(a,1);

prompt = {'Image file extension:','Number of frames:', 'Gaussian levels:'};
title = 'Stabilization settings';
dims = [1 35];
definput = {'jpg',num2str(video_length),'1'};
answer = inputdlg(prompt,title,dims,definput);
file_type = answer{1};
video_length = str2num(answer{2});
Gauss_levels = str2num(answer{3});


tic
stabilize(input_folder, output_folder, file_type, video_length, Gauss_levels)
toc