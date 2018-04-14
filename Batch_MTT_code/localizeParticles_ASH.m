% localizeParticles_ASH.m
% Anders Sejr Hansen, August 2016
% Modified from M.Mir to take 3d image matrix directly as function input,
% rather than reading it in as a TIFF-stack. 

% UPDATE on April 13, 2017
% Anders Sejr Hansen
% Previous version divided signal intensity by 2.3133 for unknown reasons.
% Get rid of this, since it interferes with calculations. 

function dat = localizeParticles_ASH(dir_path,impars, locpars, imstack)

startPnt=1;
nframes=size(imstack,3);
endPnt=nframes;
%startPnt localization procedure
    data = cell(endPnt-startPnt+1,1);
    ctrsN = cell(endPnt-startPnt+1,1);

%%
    for frame = startPnt:endPnt
        cimg=imstack(:,:,frame);
        %disp(['current frame is: ', num2str(frame)]);
        [data{frame} , ~, ctrsN{frame}] = ...
            detect_et_estime_part_1vue_deflt(...
            double(cimg),...
            locpars.wn, impars.psfStd,chi2inv(1-1/10^(locpars.errorRate*-1),1),...
            locpars.dfltnLoops,size(cimg,2),size(cimg,1),locpars.minInt,locpars.optim);
    end
 %%
    
    time = [];
    for frame = startPnt:endPnt
        time = [time;ones(ctrsN{frame},1)*frame];
    end %for
    data = [vertcat(data{:}) time];
  %%
    dat.ctrsX=data(:,2);
    dat.ctrsY=data(:,1); 
    dat.signal=data(:,3);
    dat.noise=sqrt(data(:,4));
    dat.offset=data(:,5);
    dat.radius=data(:,6);
    dat.frame=data(:,8);
%     dat.alpha=data(:,3);
  
%     figure, imshow(cimg)
%     hold on
%     scatter(data(:,2),data(:,1))
%     hold off
    
%      streamToDisk(data,...
%         [dir_path impars.name])
%     save([dir_path, impars.name, 'loc_data.mat'],'dat')  
    ctrsN = vertcat(ctrsN{:});
    dat.ctrsN=ctrsN;
    
% what data gives out
%  liste_param = [Pi+i , ... %y-coordinate
%         Pj+j , ... %x-coordinate
%         alpha , ... %mean amplitude
%         sig2 , ... %noise power
%         offset, ... %background level
%         r , ... %r0
%         result_ok ];
    
    
end