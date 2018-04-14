%   SerialProcess_fastSPT_2color_549_646.m
%   Anders Sejr Hansen, August 2017
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
input_path=('/Users/anderssejrhansen/Google Drive/DataStorage/MicroscopyData/SPT//');
output_path=('/Users/anderssejrhansen/Dropbox/MatLab/Lab/Microscopy/SingleParticleTracking/Analysis/FastTrackingData/');
% add the neccesary paths:
addpath(genpath(['.' filesep 'Batch_MTT_code' filesep])); % MTT & BioFormats
disp('added paths for MTT algorithm mechanics, bioformats...');

LocalizationError = -6.25; % Localization Error: -6 = 10^-6
Color1EmissionWavelength = 580; % wavelength in nm; consider emission max and filter cutoff
Color2EmissionWavelength = 664; % wavelength in nm; consider emission max and filter cutoff
ExposureTime = 13.5; % in milliseconds
NumDeflationLoops = 0; % Generaly keep this to 0; if you need deflation loops, you are imaging at too high a density;
MaxExpectedD = 25; % The maximal expected diffusion constant for tracking in units of um^2/s;
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
trackpars.maxComp=5;
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
    %%% Use memory efficient system for reading in the nd2 files:
    [ Color1Tiff,  Color2Tiff] = MemoryEfficientND2reader_2colors( [input_path, Filenames{iter}, '.nd2']);   
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
    
    %%% Merging the two different colors to find color-crossings (tracking
    %   errors). data is structured array containing the following
    %   - ctrsX, ctrsY, signal, offset, radius, frame: these are all column
    %   vectors with 1 row for each localization
    %   - ctrsN: ctrsN is a column vector with 1 row for each frame in the
    %   movie. The value is the number of localizations per frame. Need to
    %   simply add these
    
    % VERY STRANGE OBSERVATION 2017-09-22
    %   Tracking depends on the PSF radius even though a particle has
    %   already been localized. For example, in "20170801_U2OS_C32_Halo-hCTCF_50nM_PA-549-646_1100mW_11-405_13msCam_cell04_Tracked"
    %   there is a particle localized in Color1 in frame 22 and no particle
    %   in Color2. If the Color1 psfStd is used, this particle is lost
    %   during the tracking, but if the mean of the Colo1+Color2 psfStds
    %   are used then this particle is not lost. 
    %   Thus, if we set psfStd = Color1.psfStd in the tracking for the
    %   mergedData, then this particle is lost, but otherwise it is
    %   included. This is very strange. 
    %   One very arbitrary way of dealing with this is to "pretend" to the
    %   algorithm that the merged_data radius is the same both colors. But
    %   since to do the localization properly the correct psfStd for that
    %   particular radius should be used, the easiest way of dealing with
    %   this is likely to allow for a small number of discrepancies between
    %   the single-color and dual-color localizations. 
    
    merged_data = struct();
    merged_data.ctrsX = [data1.ctrsX; data2.ctrsX];
    merged_data.ctrsY = [data1.ctrsY; data2.ctrsY];
    merged_data.signal = [data1.signal; data2.signal];
    merged_data.noise = [data1.noise; data2.noise];
    merged_data.offset = [data1.offset; data2.offset];
    merged_data.frame = [data1.frame; data2.frame];
    merged_data.radius = [data1.radius; data2.radius];
    % add ctrsN
    merged_data.ctrsN = data1.ctrsN + data2.ctrsN;
    % but the structures are not sorted; so need to sort the particles
    % based on frames:
    [vals, sorted_idx] = sort(merged_data.frame);
    merged_data.ctrsX = merged_data.ctrsX(sorted_idx);
    merged_data.ctrsY = merged_data.ctrsY(sorted_idx);
    merged_data.signal = merged_data.signal(sorted_idx);
    merged_data.offset = merged_data.offset(sorted_idx);
    merged_data.noise = merged_data.noise(sorted_idx);
    merged_data.frame = merged_data.frame(sorted_idx);
    merged_data.radius = merged_data.radius(sorted_idx);
    
    
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
    data2=buildTracks2_ASH(input_path, data2, impars, locpars, trackpars, data2.ctrsN, Color2Tiff);
    toc;
    
    tic; 
    disp('MTT ALGORITHM PART 2: track particles between frames for merged color 1 and 2');
    impars.wvlnth= mean([Color2EmissionWavelength/1000, Color1EmissionWavelength/1000]); %emission wavelength in um
    impars.psfStd= impars.psf_scale*0.55*(impars.wvlnth)/impars.NA/1.17/impars.PixelSize/2; % PSF standard deviation in pixels
    merged_data=buildTracks2_ASH(input_path, merged_data, impars, locpars, trackpars, merged_data.ctrsN, Color1Tiff);
    toc;
    
    %%%%%%%% SAVE THE TRAJECTORIES TO YOUR STRUCTURED ARRAY FORMAT %%%%%%%%
    tic;
    disp(['saving MATLAB workspace for movie ', num2str(iter), ' of ', num2str(length(Filenames))]);
    
    data_cell_array1 = data1.tr;
    data_cell_array2 = data2.tr;
    merged_data_cell_array = merged_data.tr;
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
    trackedPar1 = struct; trackedPar2 = struct; trackedPar_merged = struct;
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
    for i=1:length(merged_data_cell_array)
        %convert to um:
        trackedPar_merged(1,i).xy = impars.PixelSize .* merged_data_cell_array{i}(:,1:2);
        trackedPar_merged(1,i).Frame = merged_data_cell_array{i}(:,3);
        trackedPar_merged(1,i).TimeStamp = impars.FrameRate.* merged_data_cell_array{i}(:,3);
    end
    disp(['Localized and tracked ', num2str(size(trackedPar1,2)), ' trajectories for color 1']);
    disp(['Localized and tracked ', num2str(size(trackedPar2,2)), ' trajectories for color 2']);
    disp(['Localized and tracked ', num2str(size(trackedPar_merged,2)), ' trajectories for merged colors']);
    save([output_path, Filenames{iter}, '_Tracked.mat'], 'trackedPar1', 'trackedPar2', 'trackedPar_merged', 'settings');
    toc;
    clear Color1Tiff Color2Tiff data_cell_array1 data_cell_array2 trackedPar1 trackedPar2
    disp('-----------------------------------------------------------------');
    
end    

