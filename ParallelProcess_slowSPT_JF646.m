%   ParallelProcess_fastSPT_JF646.m
%   Anders Sejr Hansen, April 2017
clear; clc; close all; clearvars -global

%   DESCRIPTION
%   This script takes as input a folder with nd2 files and then outputs
%   workspaces with tracked single molecules. Briefly, it uses the
%   BioFormats package to read in nd2 files. Please double-check that this
%   does not change the pixel intensity values. Nikon keeps updating the
%   nd2 file format, so if you are using mis-matched Nikon Elements
%   software versions and bioformat versions, this is a major issue that
%   you should be aware of. Next, the script feeds the images as a 3D
%   matrix into the localization part of the MTT algorithm (Part 1) and
%   subsequently, the tracked particles are fed into the tracking part of
%   the MTT algorithm (Part 2). 

%   PARALLEL UPDATE
%   Previously, running in parallel was not possible because of the huge
%   memory overhead of bfopen in bioformats, which could cause even 4 parallel jobs
%   to take up >80GB of memory. However, with the new implementation of
%   BioFormats, where you read in a frame at a time using bfGetReader, this
%   problem is avoided and you can run things in parallel.

%%%%%%%%%%%%%%%%%%%% DEFINE INPUT AND OUTPUT PATHS %%%%%%%%%%%%%%%%%%%%%%%%
% specify input path with nd2 files:
input_path=('/Users/anderssejrhansen/Google Drive/DataStorage/MicroscopyData/SPT/');
output_path=('/Users/anderssejrhansen/Dropbox/MatLab/Lab/Microscopy/SingleParticleTracking/Analysis/SlowTrackingData/');
% add the neccesary paths:
addpath(genpath(['.' filesep 'Batch_MTT_code' filesep])); % MTT & BioFormats
disp('added paths for MTT algorithm mechanics, bioformats...');


%output_path = input_path;
%%%%% make output folder if it does not already exist
if exist(output_path,'dir')
    % OK, output_path exists and is a directory (== 7). 
    disp('The given output folder exists. MATLAB workspaces will be save to:');
    disp(output_path);
else
    mkdir(output_path);
    disp('The given output folder did not exist, but was just created. MATLAB workspaces will be save to:');
    disp(output_path);
end

%%%%% DEFINE THE KEY PARAMETERS %%%%%
NumWorkers = 10; % input the maximum number of workers available on your computer: too many and you will run out of memory
LocalizationError = -6.25; % Localization Error: -6 = 10^-6
EmissionWavelength = 664; % wavelength in nm; consider emission max and filter cutoff
ExposureTime = 500; % in milliseconds
NumDeflationLoops = 0; % Generaly keep this to 0; if you need deflation loops, you are imaging at too high a density;
MaxExpectedD = 0.08; % The maximal expected diffusion constant for tracking in units of um^2/s;
NumGapsAllowed = 2; % the number of gaps allowed in trajectories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% DEFINE STRUCTURED ARRAY WITH ALL THE SPECIFIC SETTINGS FOR LOC AND TRACK
% imaging parameters
impars.PixelSize=0.16; % um per pixel
impars.psf_scale=1.35; % PSF scaling
impars.wvlnth= EmissionWavelength/1000; %emission wavelength in um
impars.NA=1.49; % NA of detection objective
impars.psfStd= impars.psf_scale*0.55*(impars.wvlnth)/impars.NA/1.17/impars.PixelSize/2; % PSF standard deviation in pixels
impars.FrameRate= ExposureTime/1000; %secs
impars.FrameSize= ExposureTime/1000; %secs

% localization parameters
locpars.wn=9; %detection box in pixels
locpars.errorRate= LocalizationError; % error rate (10^-)
locpars.dfltnLoops= NumDeflationLoops; % number of deflation loops
locpars.minInt=0; %minimum intensity in counts
locpars.maxOptimIter= 50; % max number of iterations
locpars.termTol= -2; % termination tolerance
locpars.isRadiusTol=false; % use radius tolerance
locpars.radiusTol=50; % radius tolerance in percent
locpars.posTol= 1.5;%max position refinement
locpars.optim = [locpars.maxOptimIter,locpars.termTol,locpars.isRadiusTol,locpars.radiusTol,locpars.posTol];
locpars.isThreshLocPrec = false;
locpars.minLoc = 0;
locpars.maxLoc = inf;
locpars.isThreshSNR = false;
locpars.minSNR = 0;
locpars.maxSNR = inf;
locpars.isThreshDensity = false;

% tracking parameters
trackpars.trackStart=1;
trackpars.trackEnd=inf;
trackpars.Dmax= MaxExpectedD;
trackpars.searchExpFac=1.2;
trackpars.statWin=10;
trackpars.maxComp=5;
trackpars.maxOffTime=NumGapsAllowed;
trackpars.intLawWeight=0.9;
trackpars.diffLawWeight=0.5;


%%%%%%%%%%%%%% READ IN ND2 FILES AND CONVERT TO TIFF FILES %%%%%%%%%%%%%%%%
%disp('-----------------------------------------------------------------');
%disp('reading in nd2 files; writing out MAT workspaces...');
%find all nd2 files:
nd2_files=dir([input_path,'*.nd2']);
Filenames = ''; %for saving the actual file name
temp_struct_for_save = struct;

for iter = 1:length(nd2_files)
    % get the relevant file name
    Filenames{iter} = nd2_files(iter).name(1:end-4);
    % generate dummy structure to temporarily save localization and tracking
    % output to make it possible for the code to otherwise run in parallel.
    % This approach assumes that the algorithm parameters are identical for all
    % of the workspaces:
    temp_struct_for_save(iter).blah = [];
end

% open a parallel pool with the specified number of workers (not to exceed
% CPU number obviously)
parpool('local', min([NumWorkers, length(Filenames)]))
% read in the nd2 file using BioFormats:
tic;
parfor iter = 1:length(Filenames)
    %disp('-----------------------------------------------------------------');
    %tic; 
    disp(['reading in nd2 file ', num2str(iter), ' of ', num2str(length(nd2_files)), ' total nd2 files']);
     
    %%% read ND2-file to using external memory efficient function:
    imgs_3d_matrix = MemoryEfficientND2reader( [input_path, Filenames{iter}, '.nd2']);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%% MTT ALGORITHM PART 1: LOCALIZE ALL PARTICLES %%%%%%%%%%%%%%
    disp('MTT ALGORITHM PART 1: localize particles in all of the workspaces');

    %disp(['localizing all particles in movie number ', num2str(iter), ' of ', num2str(length(Filenames))]);
    data_loc = localizeParticles_ASH(input_path,impars, locpars, imgs_3d_matrix);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%% MTT ALGORITHM PART 2: TRACK PARTICLES BETWEEN FRAMES %%%%%%%%%
    disp('MTT ALGORITHM PART 2: track particles between frames');
    %tic; 
    %disp(['tracking all localized particles from movie ', num2str(iter), ' of ', num2str(length(Filenames))]);
    data_track=buildTracks2_ASH(input_path, data_loc,impars, locpars, trackpars, data_loc.ctrsN, imgs_3d_matrix);
    %toc;
    
    % save the tracked trajectories to the dummy structure to make it work
    % inside a parallel loops:
    temp_struct_for_save(iter).data_cell_array = data_track.tr;
    temp_struct_for_save(iter).Width = size(imgs_3d_matrix,2);
    temp_struct_for_save(iter).Height = size(imgs_3d_matrix,1);
    temp_struct_for_save(iter).Frames = size(imgs_3d_matrix,3);
end    
toc;
% shut down the parallel session pool:
p = gcp;
delete(p)
    
for iter = 1:length(Filenames)
    %%%%%%%% SAVE THE TRAJECTORIES TO YOUR STRUCTURED ARRAY FORMAT %%%%%%%%
    tic;
    disp(['saving MATLAB workspace for movie ', num2str(iter), ' of ', num2str(length(Filenames))]);
    data_cell_array = temp_struct_for_save(iter).data_cell_array;
    % save the name:
    impars.name = Filenames{iter};
    % save meta-data
    settings.Delay = impars.FrameRate;
    settings.px2micron = impars.PixelSize;
    settings.TrackingOptions = trackpars;
    settings.LocOptions = locpars;
    settings.AcquisitionOptions = impars;
    settings.Filename = impars.name;
    settings.Width = temp_struct_for_save(iter).Width;
    settings.Height = temp_struct_for_save(iter).Height;
    settings.Frames = temp_struct_for_save(iter).Frames;
    trackedPar = struct;
    for i=1:length(data_cell_array)
        %convert to um:
        trackedPar(1,i).xy =  impars.PixelSize .* data_cell_array{i}(:,1:2);
        trackedPar(i).Frame = data_cell_array{i}(:,3);
        trackedPar(i).TimeStamp = impars.FrameRate.* data_cell_array{i}(:,3);
    end
    disp(['Localized and tracked ', num2str(length(trackedPar)), ' trajectories']);
    save([output_path, Filenames{iter}, '_Tracked.mat'], 'trackedPar', 'settings');
    toc;
    clear imgs_3d_matrix imgs_3d_double data_cell_array trackedPar
    disp('-----------------------------------------------------------------');
end    

