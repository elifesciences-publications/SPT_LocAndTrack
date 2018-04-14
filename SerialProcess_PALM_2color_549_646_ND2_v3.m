%   SerialProcess_PALM_2color_549_646_ND2_v3.m
%   Anders Sejr Hansen, September 2016
clear; clc; close all; clearvars -global

%   DESCRIPTION
%   This script takes as input a folder with Nikon Elements nd2 files,
%   where each file is a 2-color movie. 

%   v3: Re-wrote how nd2 files are read in. Very annoyingly, the standard
%   bfopen has a gigantic memory overhead. E.g. one two-color 4GB file can
%   take up >100 GB of RAM causing practically any computer to crash. To
%   deal with this issue, we now read in nd2 files using a reader wrapper.
%   This allows us to read in only one frame at a time which greatly
%   lessens the demands on memory. 

%%%%%%%%%%%%%%%%%%%% DEFINE INPUT AND OUTPUT PATHS %%%%%%%%%%%%%%%%%%%%%%%%
% specify input path with nd2 files:
input_path=('/Users/AndersSejrHansen/Dropbox/DataStorage/MicroscopyData/fixedPALM/');
output_path=('/Users/anderssejrhansen/Dropbox/MatLab/Lab/Microscopy/SingleParticleTracking/PALM/TwoColorPALM/PALM_reconstruction_data/');
% add the neccesary paths:
addpath(genpath(['.' filesep 'Batch_MTT_code' filesep])); % MTT & BioFormats
disp('added paths for MTT algorithm mechanics, bioformats...');


LocalizationError = -6; % Localization Error: -6 = 10^-6
Color1EmissionWavelength = 580; % wavelength in nm; consider emission max and filter cutoff
Color2EmissionWavelength = 664; % wavelength in nm; consider emission max and filter cutoff
ExposureTime = 25; % in milliseconds
NumDeflationLoops = 0; % Generaly keep this to 0; if you need deflation loops, you are imaging at too high a density;
MaxExpectedD = 0.05; % The maximal expected diffusion constant for tracking in units of um^2/s;
NumGapsAllowed = 1; % the number of gaps allowed in trajectories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% DEFINE STRUCTURED ARRAY WITH ALL THE SPECIFIC SETTINGS FOR LOC AND TRACK
% imaging parameters
impars.PixelSize=0.16; % um per pixel
impars.psf_scale=1.35; % PSF scaling
impars.NA=1.49; % NA of detection objective
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
trackpars.maxComp=3;
trackpars.maxOffTime=NumGapsAllowed;
trackpars.intLawWeight=0.9;
trackpars.diffLawWeight=0.5;


%%%%%%%%%%%%%% READ IN 2-Color TIFF FILES %%%%%%%%%%%%%%%%
%disp('-----------------------------------------------------------------');
%disp('reading in nd2 files; writing out MAT workspaces...');
%find all nd2 files:
ND2_files=dir([input_path,'*.nd2']);
Filenames = ''; %for saving the actual file name

for iter = 1:length(ND2_files)
    Filenames{iter} = ND2_files(iter).name(1:end-4);
end
% read in the ND2 file:
for iter = 1:length(Filenames)
    disp('-----------------------------------------------------------------');
    tic; 
    disp(['reading in ND2 file ', num2str(iter), ' of ', num2str(length(ND2_files)), ' total ND2 files']);
    %%% read ND2-file:
    %%% Clear unnecesarry variables to preserve memory

    % Construct an empty Bio-Formats reader
    r = bfGetReader();
    % Decorate the reader with the Memoizer wrapper
    r = loci.formats.Memoizer(r);
    % Initialize the reader with an input file
    % If the call is longer than a minimal time, the initialized reader will
    % be cached in a file under the same directory as the initial file
    % name .large_file.bfmemo
    r.setId([input_path, Filenames{iter}, '.nd2']);
    
    % First figure out how many frames:
    TotFrames = r.getImageCount();
    
    % Read in the first frame to get size of images:
    first_frame = bfGetPlane(r, 1);
    
    % Define empty TIFF-like matrices. Very annoyingly, Nikon Elements make every other frame each color. So
    % make two new tiff stacks for each color that are half the length in
    % the 3rd dimension:
    Color1Tiff = zeros(size(first_frame,1), size(first_frame,2), round(TotFrames/2));
    Color2Tiff = zeros(size(first_frame,1), size(first_frame,2), round(TotFrames/2));
    
    % now read in only one frame at a time to save on memory
    for FrameIter = 1:size(Color1Tiff,3)
        Color1Tiff(:,:,FrameIter) = bfGetPlane(r,2*(FrameIter-1)+1);
        Color2Tiff(:,:,FrameIter) = bfGetPlane(r,2*(FrameIter-1)+2);
    end
    
    % Close the reader
    r.close()
    
    toc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%% MTT ALGORITHM PART 1: LOCALIZE ALL PARTICLES %%%%%%%%%%%%%%
    disp(['localizing all particles in movie number ', num2str(iter), ' of ', num2str(length(Filenames))]);
    tic; 
    disp('MTT ALGORITHM PART 1: localize particles in Color 1');
    impars.wvlnth= Color1EmissionWavelength/1000; %emission wavelength in um
    impars.psfStd= impars.psf_scale*0.55*(impars.wvlnth)/impars.NA/1.17/impars.PixelSize/2; % PSF standard deviation in pixels
    impars.name = Filenames{iter};
    data1 = localizeParticles_ASH(input_path,impars, locpars, Color1Tiff);
    toc;
    tic; 
    disp('MTT ALGORITHM PART 1: localize particles in Color 2');
    impars.wvlnth= Color2EmissionWavelength/1000; %emission wavelength in um
    impars.psfStd= impars.psf_scale*0.55*(impars.wvlnth)/impars.NA/1.17/impars.PixelSize/2; % PSF standard deviation in pixels
    impars.name = Filenames{iter};
    data2 = localizeParticles_ASH(input_path,impars, locpars, Color2Tiff);
    toc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%% MTT ALGORITHM PART 2: TRACK PARTICLES BETWEEN FRAMES %%%%%%%%%
    disp(['tracking all localized particles from movie ', num2str(iter), ' of ', num2str(length(Filenames))]);
    tic; 
    disp('MTT ALGORITHM PART 2: track particles between frames for color 1');
    impars.wvlnth= Color1EmissionWavelength/1000; %emission wavelength in um
    impars.psfStd= impars.psf_scale*0.55*(impars.wvlnth)/impars.NA/1.17/impars.PixelSize/2; % PSF standard deviation in pixels
    data1=buildTracks2_ASH(input_path, data1,impars, locpars, trackpars, data1.ctrsN, Color1Tiff);
    toc;
    tic; 
    disp('MTT ALGORITHM PART 2: track particles between frames for color 2');
    impars.wvlnth= Color2EmissionWavelength/1000; %emission wavelength in um
    impars.psfStd= impars.psf_scale*0.55*(impars.wvlnth)/impars.NA/1.17/impars.PixelSize/2; % PSF standard deviation in pixels
    data2=buildTracks2_ASH(input_path, data2,impars, locpars, trackpars, data2.ctrsN, Color2Tiff);
    toc;
    
    %%%%%%%% SAVE THE TRAJECTORIES TO YOUR STRUCTURED ARRAY FORMAT %%%%%%%%
    tic;
    disp(['saving MATLAB workspace for movie ', num2str(iter), ' of ', num2str(length(Filenames))]);
    
    data_cell_array1 = data1.tr;
    data_cell_array2 = data2.tr;
    % save meta-data
    settings.Delay = impars.FrameRate;
    settings.px2micron = impars.PixelSize;
    settings.TrackingOptions = trackpars;
    settings.LocOptions = locpars;
    settings.AcquisitionOptions = impars;
    settings.Filename = impars.name;
    settings.Width = size(Color1Tiff,2);
    settings.Height = size(Color1Tiff,1);
    settings.Frames = size(Color1Tiff,3);
    %Make a separate trackedPar for each color
    trackedPar1 = struct; trackedPar2 = struct;
    for i=1:length(data_cell_array1)
        %convert to um:
        trackedPar1(1,i).xy = impars.PixelSize .* data_cell_array1{i}(:,1:2);
        trackedPar1(1,i).Frame = data_cell_array1{i}(:,3);
        trackedPar1(1,i).TimeStamp = impars.FrameRate.* data_cell_array1{i}(:,3);
    end
    for i=1:length(data_cell_array2)
        %convert to um:
        trackedPar2(1,i).xy = impars.PixelSize .* data_cell_array2{i}(:,1:2);
        trackedPar2(1,i).Frame = data_cell_array2{i}(:,3);
        trackedPar2(1,i).TimeStamp = impars.FrameRate.* data_cell_array2{i}(:,3);
    end
    disp(['Localized and tracked ', num2str(size(trackedPar1,2)), ' trajectories for color 1']);
    disp(['Localized and tracked ', num2str(size(trackedPar2,2)), ' trajectories for color 2']);
    save([output_path, Filenames{iter}, '_Tracked.mat'], 'trackedPar1', 'trackedPar2', 'settings');
    toc;
    clear Color1Tiff Color2Tiff data_cell_array1 data_cell_array2 trackedPar1 trackedPar2
    disp('-----------------------------------------------------------------');
end    

