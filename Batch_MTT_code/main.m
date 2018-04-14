clear all 
%%
dir_path=('/Users/anderssejrhansen/Dropbox/MatLab/Lab/Microscopy/SingleParticleTracking/SoftwarePackages/SLIMFAST_batch_fordist/TestData/');

% imaging parameters
impars.PixelSize=0.16; % um per pixel
impars.psf_scale=1.35; % PSF scaling
impars.wvlnth=0.580; %emission wavelength in um
impars.NA=1.49; % NA of detection objective
impars.psfStd= impars.psf_scale*0.55*(impars.wvlnth)/impars.NA/1.17/impars.PixelSize/2; % PSF standard deviation in pixels
impars.FrameRate=0.025; %secs
impars.FrameSize=0.025; %secs

% localization parameters
locpars.wn=9; %detection box in pixels
locpars.errorRate=-6; % error rate (10^-)
locpars.dfltnLoops=0; % number of deflation loops
locpars.minInt=0; %minimum intensity in counts
locpars.maxOptimIter= 50; % max number of iterations
locpars.termTol=-2; % termination tolerance
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
trackpars.Dmax=0.05;
trackpars.searchExpFac=1.2;
trackpars.statWin=10;
trackpars.maxComp=3;
trackpars.maxOffTime=1;
trackpars.intLawWeight=0.9;
trackpars.diffLawWeight=0.5;

cfiles=dir([dir_path,'*.tif']);
for cstk=1:size(cfiles,1)

    clear data
    impars.name=cfiles(cstk).name(1:end-4);
    %% localize particles
    data = localizeParticles(dir_path,impars, locpars);
    %% trackparticles
    % data=buildTracks(ctrsN,dir_path,data,impars, locpars, trackpars);
    data=buildTracks2(dir_path, data,impars, locpars, trackpars, data.ctrsN);
    save([dir_path, impars.name, '_data.mat'],'data')  
end
