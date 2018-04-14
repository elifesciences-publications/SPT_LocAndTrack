function data=buildTracks2(dir_path, data,impars, locpars, trackpars, ctrsN)
% Anders Sejr Hansen
% August 16, 2016
% UPDATE: re-wrote the file to not read in TIFF, but to instead use a 3D
% matrix already saved as a MATLAB workspace
%imstack=loadtiff([dir_path,impars.name,'.tif']);

% function buildTracks(src,event)
global tab_param ;
global tab_var ;
global tab_moy ;

% fig = gcbf;
%imstack=loadtiff([dir_path,impars.name,'.tif']);
tempWorkspace = load([dir_path,impars.name,'TIFFimgs.mat']);
imstack = tempWorkspace.imgs_3d_matrix;
settings.Width =size(imstack,2);
settings.Height = size(imstack,1);
settings.px2micron = impars.PixelSize;
settings.Delay = impars.FrameSize;

% settings.Width = getappdata(fig,'width');
% settings.Height = getappdata(fig,'height');
% settings.px2micron = getappdata(fig,'pxSize');
% settings.Delay = getappdata(fig,'frameSize')/1000;
% seuil_detec_1vue = chi2inv(1-10^getappdata(fig,'errorRate'),1);
seuil_detec_1vue = chi2inv(1-10^locpars.errorRate,1);
settings.TrackingOptions.FinalDetectionTresh = seuil_detec_1vue;

% wn = getappdata(fig,'w2d');
wn = locpars.wn;
settings.TrackingOptions.SizeDetectionBox = wn;

% r0 = getappdata(fig,'psfStd');
r0 = impars.psfStd;
settings.TrackingOptions.GaussianRadius = r0;

% seuil_alpha = getappdata(fig,'minInt');
seuil_alpha = locpars.minInt;
settings.TrackingOptions.ValidationTresh = seuil_alpha;

% nb_defl = getappdata(fig,'dfltnLoops');
nb_defl = locpars.dfltnLoops;
settings.TrackingOptions.NumberDeflationLoops = nb_defl;

% T = getappdata(fig,'statWin');
T = trackpars.statWin;
settings.TrackingOptions.AvaragingTimeWindow = T;
assignin('base', 'T', T)

% T_off = getappdata(fig,'maxOffTime')*-1;
T_off = trackpars.maxOffTime*-1;
settings.TrackingOptions.BlinkingProbability = T_off;
assignin('base', 'T_off', T_off)

% sig_free = sqrt(getappdata(fig,'Dmax')/...
%     getappdata(fig,'pxSize')^2*...
%     4*getappdata(fig,'frameSize')/1000);

sig_free = sqrt(trackpars.Dmax/...
    impars.PixelSize^2*...
    4*impars.FrameSize);

% settings.TrackingOptions.MaxDiffusionCoefficient =...
%     getappdata(fig,'Dmax');

settings.TrackingOptions.MaxDiffusionCoefficient =...
   trackpars.Dmax;

assignin('base', 'sig_free', sig_free)

% Boule_free = getappdata(fig,'searchExpFac');
Boule_free = trackpars.searchExpFac;
settings.TrackingOptions.ResearchDiameter = Boule_free;
assignin('base', 'Boule_free', Boule_free)

% Nb_combi = getappdata(fig,'maxComp');
Nb_combi = trackpars.maxComp;
settings.TrackingOptions.CombinationTresh = Nb_combi;
assignin('base', 'Nb_combi', Nb_combi)

% Poids_melange_aplha = getappdata(fig,'intLawWeight');
Poids_melange_aplha = trackpars.intLawWeight;
settings.TrackingOptions.WeightUniformGaussianLaw = Poids_melange_aplha;
assignin('base', 'Poids_melange_aplha', Poids_melange_aplha)

% Poids_melange_diff = getappdata(fig,'diffLawWeight');
Poids_melange_diff = trackpars.diffLawWeight;
settings.TrackingOptions.WeightMaxLocalDiffusion = Poids_melange_diff;
assignin('base', 'Poids_melange_diff', Poids_melange_diff)

% ctrsN = getappdata(fig,'ctrsN');
Nb_STK =  numel(ctrsN);
assignin('base', 'Nb_STK', Nb_STK)

%t == T-T_off dans les tab_x reduits
t_red = T-T_off ;
assignin('base', 't_red', t_red)

% filename = getappdata(fig,'imageName');
filename=[dir_path,impars.name,'.tif'];
info = imfinfo(filename);
im_t = double(imread(filename, 1, 'info', info)) ;
assignin('base', 'im_t', im_t)

% idx = [-1; cumsum(getappdata(fig,'ctrsN'))];
idx = [-1; cumsum(ctrsN)];

startPnt=0;
trackStart=1;
% if getappdata(fig,'trackStart') == 1
%     setappdata(fig,'startPnt',0)
% else
%     setappdata(fig,'startPnt',...
%         idx(getappdata(fig,'trackStart'))+1)
% end %if

trackEnd=numel(ctrsN);

% if isinf(getappdata(fig,'trackEnd'))
%     setappdata(fig,'trackEnd',...
%         numel(getappdata(fig,'ctrsN')))
%     setappdata(fig,'elements',inf)
% else
%     setappdata(fig,'elements',...
%         idx(getappdata(fig,'trackEnd')+1)-...
%         max(1,getappdata(fig,'startPnt'))+1)
% end %if


% settings.Frames = getappdata(fig,'trackEnd')-...
%     getappdata(fig,'trackStart')+1;
settings.Frames = trackEnd-trackStart+1;

%get ROI
% roi = getappdata(fig,'roi');
% data = preprocessData(fig,[1 1 1 1 1 1 1 0 0 0 0 0],roi);
trackID = 1:size(data.signal);

hProgressbar = waitbar(0,['Processing Frame: ' num2str(1) ':'...
    num2str(Nb_STK)],'Color', get(0,'defaultUicontrolBackgroundColor'));
% for t = getappdata(fig,'trackStart'):getappdata(fig,'trackEnd')
for t = trackStart:trackEnd
    %first iteration
%     if t == getappdata(fig,'trackStart')
    if t == trackStart
        %fake detection list
ind_valid = data.frame == 1;
par_per_frame(t) = sum(ind_valid);
lest = [(1:par_per_frame(t))' data.ctrsY(ind_valid) data.ctrsX(ind_valid)...
    data.signal(ind_valid)*sqrt(pi).*data.radius(ind_valid)...
    data.noise(ind_valid).^2 data.radius(ind_valid) ones(par_per_frame(t),1)];

%preallocate tables
tab_param = zeros(par_per_frame(t), 1+7*(t_red+1));
tab_var = tab_param;
%tab_moy = zeros(ctrsN, 1+7*(t_red+1)) ;

%% initialize parameter tables
tab_param(:,1) = (1:par_per_frame(t))' ;
tab_param(:,2+7*(t_red-1):1+7*(t_red)) = [ones(par_per_frame(t),1), ...
    lest(:,[2,3,4,6]), zeros(par_per_frame(t),1), Nb_STK*ones(par_per_frame(t),1)];
tab_param(:,2+7*(t_red)) = 2*ones(par_per_frame(t),1) ;

tab_var(:,1)   = (1:par_per_frame(t))' ;
tab_var(:,2+7*(t_red-1):1+7*(t_red)) = [ones(par_per_frame(t),1), ...
    zeros(par_per_frame(t),4), lest(:,5), Nb_STK*ones(par_per_frame(t),1)];
tab_var(:,2+7*(t_red)) = 2*ones(par_per_frame(t),1) ;
tab_moy = tab_var ;

%% set initial variance guess (20% by default) -> nested by CPR
init_tab;

%% initialize tracks
trackList = cell(1,par_per_frame(t));
for track = tab_param(:,1)'
    if tab_param(track,1+7*(t_red))>0
        trackList{trackID(track)}(1,:) =...
            [tab_param(track,7*(t_red-1)+[4 3 2])...
            trackID(track) tab_param(track,7*(t_red-1)+5)...
            tab_var(track,7*(t_red-1)+[7 3 5])];
    end %if
end %for

        continue
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  CYCLE THROUGH ACTIVE TRAJECTORIES   %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    im_t = double(imread(filename, t, 'info', info)) ;
assignin('base', 'im_t', im_t)

    ind_valid = data.frame == t;
    par_per_frame(t) = sum(ind_valid);
    lest = [(1:sum(ind_valid))' data.ctrsY(ind_valid) data.ctrsX(ind_valid)...
    data.signal(ind_valid)*sqrt(pi).*data.radius(ind_valid)...
    data.noise(ind_valid).^2 data.radius(ind_valid) ones(par_per_frame(t),1)];

    nb_traj_active = 0 ;
    nb_traj_blink = 0 ;
    
    isClosed = (tab_param(:,7*(t_red-1)+8) == T_off);
    if any(isClosed)
        trackID(find(isClosed)) = [];
        tab_param(isClosed,:) = [];
        tab_var(isClosed,:) = [];
        tab_moy(isClosed,:) = [];
    end %if

        if ~isempty(tab_param)
        tab_param(:,1) = 1:size(tab_param,1);
        tab_var(:,1) = tab_param(:,1);
        tab_moy(:,1) = tab_param(:,1);

        %from longest ON to longest OFF(blink)
    [unused, part_ordre_blk] = sort(-tab_param(:,7*(t_red-1)+8)) ;
    for traj = part_ordre_blk'
        %% reconnection test
        if (tab_param(traj, 7*(t_red-1)+8) > T_off)
            part = reconnect_part(traj, t_red-1, lest, wn) ;
            nb_traj_active = nb_traj_active + 1 ;
            if part == 0
                nb_traj_blink = nb_traj_blink + 1 ; %counts # of trajectories with BLINK status
            end%if
        else %no testing if trajectory is already terminated
            part = 0;
        end %if
        
        %% update tables
        if (part>0)
            tab_param(traj, 7*(t_red)+[3 4 5 6]) =...
                lest(part, [2 3 4 6]);
            tab_var(traj, 7*(t_red)+7) = lest(part, 5);
            if (tab_param(traj, 7*(t_red-1)+8) > 0) %trajectory was not OFF
                [LV_traj_part, flag_full_alpha] = rapport_detection(traj, t_red-1, lest, part, wn) ;
                %increase BLINK value by Nb_STK
                tab_param(traj, 7*(t_red)+8) = tab_param(traj, 7*(t_red-1)+8) + Nb_STK ;
                if (flag_full_alpha==1) %full ON
                    %increase BLINK value by 1
                    tab_param(traj, 7*(t_red)+8) = tab_param(traj, 7*(t_red)+8) + 1 ;
                else
                    tab_param(traj, 7*(t_red)+8) = ...
                        tab_param(traj, 7*(t_red)+8) - mod(tab_param(traj, 7*(t_red)+8), Nb_STK);
                end%if
            else
                %set BLINK value to initial ON value
                tab_param(traj, 7*(t_red)+8) = Nb_STK ;
            end %if
        else
            tab_param(traj, 7*(t_red)+[3 4 5 6]) =...
                [tab_param(traj, 7*(t_red-1)+[3 4]) 0 0];
            tab_var(traj, 7*(t_red)+7) = 0;
            
            %decrease BLINK value
            if (tab_param(traj, 7*(t_red-1)+8) < 0)
                tab_param(traj, 7*(t_red)+8) = tab_param(traj, 7*(t_red-1)+8)-1; %blink -1
            else
                %set BLINK value to initial OFF value
                tab_param(traj, 7*(t_red)+8) = -1 ;
            end %if
            
            %% 11/07/06
            %% test for ephemerid detection
            if (t>3)
                if (tab_param(traj, 7*(t_red-2)+8) == 0)
                    tab_param(traj, 7*(t_red)+8) = T_off ;
                end %if
            end %if
            
        end %if
        %take reconnected particle out of game
        if (part>0)
            lest(part, 2) = -lest(part, 2) ;
            lest(part, 3) = -lest(part, 3) ;
        end %if
    end %for
        end %if
    
%     nb_traj_on = sum(tab_param(:, 7*(t_red)+8) > 0) ;
%     set(h.activeTracksInfo,'String', sprintf('# elongated Trajectories: %g',nb_traj_on))
    
%     nb_traj_off = sum(tab_param(:, 7*(t_red)+8) <= T_off);
%     set(h.terminatedTracksInfo,'String', sprintf('# terminated Trajectories: %g',nb_traj_off))
    
%     set(h.blinkingTracksInfo,'String', sprintf('# blinking Trajectories: %g',...
%         sum(tab_param(:, 7*(t_red)+8) < 0)-nb_traj_off))
    
    %nb_non_affectees = sum(lest(:,2) > 0) ; % # particles not belonging to a trajectory
    nb_traj_avant_new = size(tab_param, 1) ;
    
    %check on particles not assigned to an active trajectory
    %and in case initiate a new one
    nb_non_aff_detect = false(par_per_frame(t),1);
    for p=1:par_per_frame(t)
        if (lest(p, 2) > 0)
            glrt_1vue = rapport_detection(0, 0, lest, p, wn) ;
            if ((glrt_1vue > seuil_detec_1vue) && (lest(p,4)/(sqrt(pi)*r0) > seuil_alpha))
                nb_non_aff_detect(p) = true;
            end %if
        end %if
    end %for
    new_traj = sum(nb_non_aff_detect) ;
%     set(h.newTracksInfo,'String', sprintf('# initiated Trajectories: %g',new_traj))
    
    tab_param_new = [(1:new_traj)'+nb_traj_avant_new, zeros(new_traj,7*(t_red)),...
        [ones(new_traj,1)*t, lest(nb_non_aff_detect, [2 3 4 6]),...
        zeros(new_traj,1) ones(new_traj,1)*Nb_STK]]; %by CPR
    
    tab_param = [tab_param; tab_param_new];
    tab_var = [tab_var; zeros(new_traj,7*(t_red+1)+1)];
    tab_moy = [tab_moy; zeros(new_traj,7*(t_red+1)+1)];
    
    tab_var((1:new_traj)+nb_traj_avant_new, 7*(t_red)+7) =...
        lest(nb_non_aff_detect, 5) ; %sig2_b
    
    %% shift tables one step to the left
    new_nb_traj = size(tab_param, 1) ;
    tab_param = [tab_param(:,1), ...
        tab_param(:,2+7*(1):1+7*(t_red+1)), ...
        (t+1)*ones(new_nb_traj,1), zeros(new_nb_traj,6)] ;%correction arnauld
    
    tab_var = [tab_var(:,1), ...
        tab_var(:,2+7*(1):1+7*(t_red+1)), ...
        (t+1)*ones(new_nb_traj,1), zeros(new_nb_traj,6)] ;
    
    tab_moy = [tab_moy(:,1), ...
        tab_moy(:,2+7*(1):1+7*(t_red+1)), ...
        (t+1)*ones(new_nb_traj,1), zeros(new_nb_traj,6)] ;
    
    init_tab((1+nb_traj_avant_new):new_nb_traj) ; %nested by CPR;
    mise_a_jour_tab %nested by CPR;
    
    %% update tracks
    trackList = [trackList cell(1,new_traj)];
for track = tab_param(:,1)'
    if tab_param(track,1+7*(t_red))>0
        trackList{trackID(track)}(end+1,:) =...
            [tab_param(track,7*(t_red-1)+[4 3 2])...
            trackID(track) tab_param(track,7*(t_red-1)+5)...
            tab_var(track,7*(t_red-1)+[7 3 5])];
    end %if
end %for

    waitbar(t/Nb_STK,hProgressbar,['Processing Frame: ' num2str(t) ':'...
        num2str(Nb_STK)],'Color',get(0,'defaultUicontrolBackgroundColor'));
        
end %%for
delete(hProgressbar)
   
% [filename,pathname,isOK] =...
%             uiputfile('.mat' ,'Save Tracking Data to',...
%             [getappdata(0,'searchPath')...
%             getappdata(fig,'filename') '_tracked']);
%         settings.Filename = [pathname filename];
%         
% if isOK
%     setappdata(0,'searchPath',pathname)
%     clear('data')
%     data.tr = trackList;
%     par_per_frame = ctrsN;
%         save ([pathname filename],...
%             'data', 'settings', 'par_per_frame')
% end %if

%   clear('data')
  par_per_frame = ctrsN;
        data.tr = trackList;
%         save ([dir_path impars.name,'_tracked'],...
%             'data', 'settings', 'par_per_frame')  

    function init_tab(new_traj)
        % EN/ initialisation of tables of values
        % mean of parameters and variances (std)
        %
        % if input new_traj non null
        % then only this traj is init
        % otherwise all trajectories are (at the beginning)
        if (nargin < 1)
            tab_traj = 1:par_per_frame(t) ;
            new = 0 ;
        else
            tab_traj = new_traj ;
            new = 1 ;
        end%if
        
        %% boucle sur les particules
        for iTraj = tab_traj ;
            
            %% alpha
            local_param = tab_param(iTraj, 7*(t_red-1)+5) ; % alpha
            tab_moy(iTraj, 7*(t_red-1)+5) = local_param + sqrt(-1)*local_param ;% moyenne,max
            tab_var(iTraj, 7*(t_red-1)+5) = 0.2*local_param ; % std
            
            %% r
            local_param = tab_param(iTraj, 7*(t_red-1)+6) ;
            tab_moy(iTraj, 7*(t_red-1)+6) = local_param ;
            tab_var(iTraj, 7*(t_red-1)+6) = 0.2*local_param ;
            
            %% i,j
            tab_var(iTraj, 7*(t_red-1)+3) = sig_free ;
            tab_var(iTraj, 7*(t_red-1)+4) = sig_free ;
            
            %% blink pour info
            tab_moy(iTraj, 7*(t_red-1)+8) = tab_param(iTraj, 7*(t_red-1)+8) ;
            tab_var(iTraj, 7*(t_red-1)+8) = tab_param(iTraj, 7*(t_red-1)+8) ;
            
            %% affection identique a (t_red-1)-1
            %% pour compat avec mise_a_jour_tab
            if (new)
                
                %% alpha
                local_param = tab_param(iTraj, 7*(t_red-1)+5) ; % alpha
                tab_moy(iTraj, 7*((t_red-1)-1)+5) = local_param + sqrt(-1)*local_param ;% moyenne,max
                tab_var(iTraj, 7*((t_red-1)-1)+5) = 0.2*local_param ; % std
                
                %% r
                local_param = tab_param(iTraj, 7*(t_red-1)+6) ;
                tab_moy(iTraj, 7*((t_red-1)-1)+6) = local_param ;
                tab_var(iTraj, 7*((t_red-1)-1)+6) = 0.2*local_param ;
                
                %% i,j
                tab_var(iTraj, 7*((t_red-1)-1)+3) = sig_free ;
                tab_var(iTraj, 7*((t_red-1)-1)+4) = sig_free ;
                
                %% blink pour info
                tab_moy(iTraj, 7*((t_red-1)-1)+8) = tab_param(iTraj, 7*(t_red-1)+8) ;
                tab_var(iTraj, 7*((t_red-1)-1)+8) = tab_param(iTraj, 7*(t_red-1)+8) ;
                
            end %if
            
            
        end %for
        
    end %function
    function mise_a_jour_tab
        % EN/ update of the tables of values
        % mean of parameters and variances (std)
        
        %fprintf(stderr,"in maj\n");
        %% boucle sur les particules
        for iTraj=1:new_nb_traj
            if (tab_param(iTraj, 7*(t_red-1)+8)>T_off)
                %% alpha
                %% modif le 12-11-07
                %% compatibilite avec rapport_detection
                %% suite a la prise en compte de la loi
                %% uniforme + gaussien pour alpha
                %% si modif verifer rapport_detection.m
                %%
                %%param = 5 ;
                %%[moy, sig] = calcul_reference(iTraj, (t_red-1), param, T) ;
                %%tab_moy(iTraj, 7*(t_red-1)+param) = moy ;%% test modif 160307
                %%tab_var(iTraj, 7*(t_red-1)+param) = sig ;
                [moy, sig_alpha] = calcul_reference(5) ;
                alpha_moy = real(moy) ;
                alpha_max = imag(moy) ;
                %% on ne met a jour des stats mean var
                %% que si on est en hypothese gaussienne
                %% sinon on bloque les stats
                %% determination du mode par vraisemblance
                LV_uni = -T*log(alpha_max) ;
                LV_gauss = -T/2*(1+log(2*pi*sig_alpha^2)) ;
                
                if (LV_gauss > LV_uni)
                    %% gaussienne (1)
                    tab_moy(iTraj, 7*(t_red-1)+5) = alpha_moy + sqrt(-1)*alpha_max ;
                    tab_var(iTraj, 7*(t_red-1)+5) = sig_alpha ;
                else
                    %% uniforme (2)
                    tab_moy(iTraj, 7*(t_red-1)+5) = tab_moy(iTraj, 7*((t_red-1)-1)+5) ;
                    tab_var(iTraj, 7*(t_red-1)+5) = tab_var(iTraj, 7*((t_red-1)-1)+5) ;
                end%if
                
                
                %% r
                [moy, sig] = calcul_reference(6) ;
                tab_moy(iTraj, 7*(t_red-1)+6) = moy ;
                tab_var(iTraj, 7*(t_red-1)+6) = sig ;
                
                %% i,j
                [moy, sig_i] = calcul_reference(3) ;
                [moy, sig_j] = calcul_reference(4) ;
                %%tab_moy(iTraj, 7*(t_red-1)+4) = moy ;  %% inutile
                sig_ij = sqrt(0.5*(sig_i^2+sig_j^2)) ;
                if (sig_free < sig_ij)
                    %% borne a diff libre
                    sig_ij = sig_free ;
                end%if
                tab_var(iTraj, 7*(t_red-1)+3) = sig_ij ;
                tab_var(iTraj, 7*(t_red-1)+4) = sig_ij ;
                
                %% blink pour info
                tab_moy(iTraj, 7*(t_red-1)+8) = tab_param(iTraj, 7*(t_red-1)+8) ;
                tab_var(iTraj, 7*(t_red-1)+8) = tab_param(iTraj, 7*(t_red-1)+8) ;
                
            end %if
        end %for
        function [param_ref, sig_param] = calcul_reference(param)
            %% determine la reference (parametre moyen)
            %% et ecart type du param
            %% determine sur la derniere zone de non blink
            %% et limite a une longueur T
            %% moy_alpha et sig_alpha (resp r) gardent leur valeur pendant un blink
            %% moy_i/j ne sert pas
            %% sig_i/j
            %% sig_i/j voient leur valeur augmenter pendant le blink
            %% en suivant la variation sqrt(nb_blink)*sig_i_avant_blink
            %% pris en compte dans sigij_blink
            %% param = 5 : alpha
            %% param = 6 : r
            %% param = 3 : i
            %% param = 4 : j
            
            %% offset de zone de blink nb_blink==(-offset)
            if (tab_param(iTraj, 7*(t_red-1)+8) < 0)
                offset = tab_param(iTraj, 7*(t_red-1)+8)  ;
            else
                offset = 0 ;
            end %if
            
            %% duree de la derniere partie ON de la iTraj
            nb_on = floor(tab_param(iTraj, 7*((t_red-1)+offset)+8)  / Nb_STK) ; %% correct bug suite modif
            if (nb_on > T)
                nb_on = T ;
            end %if
            
            seuil = 3+1 ; %T/2
            
            if (nb_on >= seuil)
                
                n=0:(nb_on-1) ;
                local_param = tab_param(iTraj, 7*((t_red-1)+offset-n)+param) ;
                sum_param = sum(local_param) ;
                sum_param2 = sum(local_param.^2) ;
                param_max = max(local_param) ; %% 160307
                param_ref = sum_param / nb_on ;
                sig_param = sqrt( sum_param2 / nb_on - param_ref^2) ;
                
                %% si alpha, il faut aussi la valeur max
                %% en plus de la valeur moyenne
                %% on le met sur l'axe imaginaire! 160307
                if (param == 5)
                    param_ref = param_ref + sqrt(-1)*param_max ;
                end%if
                
            else
                %% On bloque la valeur a la derniere valeur avant zone de blink
                %% la derniere info valable dans le passe
                if (offset == 0)
                    pos_info = 1 ;% la valeur precedente
                else
                    pos_info = -offset ; % la derniere valeur avant blink
                end%if
                
                param_ref = tab_moy(iTraj, 7*((t_red-1)-pos_info)+param) ;
                sig_param = tab_var(iTraj, 7*((t_red-1)-pos_info)+param) ;
                
            end %if
            
            
        end %function
        
    end %function
end

function part = reconnect_part(traj, t, lest, wn)
% EN/ function that search/detect the particle
% among those pre-detected, which best corresponds
% to the given trajectory
% returns the number of the particle in lest

%% evite les allocations sur des constantes
% global tab_param ;
% global tab_var ;
Nb_combi = evalin('base', 'Nb_combi');

%%% Pre-detection
%%% liste_param = [num, i, j, alpha, sig^2, rayon, ok]

%%% Estimation/Reconnexion
%%%              1    2  3     4       5          6          7      8
%%% tab_param = [num, t, i,    j,      alpha,     rayon,     m0,   ,blink] 
%%% tab_var =   [num, t, sig_i,sig_jj, sig_alpha, sig_rayon, sig_b ,blink] 

%% reconnexion de la particule num part

%search for particles inside search radius of trajectory
ind_boule = liste_part_boule([], traj, lest, t) ;
nb_part_boule = size(ind_boule, 1) ;


if (nb_part_boule == 0)
  %% set trajectory status to BLINK
  part = 0 ;
else
  %% plusieurs particule candidate
  %% on prend celle la plus probable

  %look up if other trajectory are in competition for one of the particles
  vec_traj_inter = liste_traj_inter(ind_boule, traj, lest, t) ;
  vec_traj = [traj; vec_traj_inter] ;
  nb_traj = size(vec_traj,1) ;

  %% limitation du nb de trajectoire
  %% en competition
  if (nb_traj > Nb_combi)
    fprintf('--> limitation combi for traj : traj %d\n', traj) ;
    vec_traj = limite_combi_traj_blk(vec_traj, t) ;
    %%vec_traj = limite_combi_traj_dst(vec_traj, t) ;
    nb_traj = Nb_combi ;
  end %if

  %% prise en compte des particules
  %% qui seraient dans les boules de recherche
  %% des trajectoires en competition
  %% "On travail ici a l'ordre 1"
  ind_boule_O1 = ind_boule ;
  for ntraj = 2:nb_traj
    traj_inter = vec_traj(ntraj) ;
    ind_boule_O1 =  liste_part_boule(ind_boule_O1, traj_inter, lest, t) ;
  end %for
  nb_part_boule_O1 = size(ind_boule_O1, 1) ;

  %% passage a l_ordre 1
  ind_boule = ind_boule_O1 ;
  nb_part_boule = nb_part_boule_O1 ;

  %% limite du nb de particules
  %% en competition
  if (nb_part_boule > Nb_combi)
    fprintf('--> limitation combi for part : traj %d\n', traj) ;
     ind_boule = limite_combi_part_dst(traj,ind_boule,lest,t) ;
     nb_part_boule = Nb_combi ;
  end %if

  %% recherche de la meilleur config par 
  %% maximum de vraisemblance
  if nb_traj <= nb_part_boule
    %% pas le blink
    %% mais possiblilite de nouvelle particule (<)
    vec_part = ind_boule ;
  else
    %% nb_traj > nb_part_boule
    %% des particules ont blinkees
    vec_part = [ind_boule; zeros(nb_traj-nb_part_boule,1)] ;
  end %if

  part = best_config_reconnex(vec_traj, vec_part, t, lest, wn);


end %if

end %function
function [indice, dist2] = N_plus_proche(ic, jc, liste_i, liste_j, N)
% renvoie les indices des N point les plus proche 
% de C(ic,jc)
% dans l'ordre d'eloignement
  
dim_liste = size(liste_i(:),1) ;
  %% distances au point C
  sq_dist = (liste_i-ic).^2 + (liste_j-jc).^2 ;
  %% classement
  [sq_dist_classe, ind_classe] = sort(sq_dist) ;
  if (dim_liste > N)
    indice = ind_classe(1:N) ;
    dist2 = sq_dist_classe(1:N) ;
  else
    indice = ind_classe ;
    dist2 = sq_dist_classe ;
  end%if
end%function
function vec_part_out = limite_combi_part_dst(traj, vec_part_in, lest, t)
% limite le nombre de part
% a celle les plus proche de la ref traj
% au nombre Nb_combi (global)
  
global tab_param ;
  Nb_combi = evalin('base', 'Nb_combi');
  
  ic = tab_param(traj, 7*t+3) ;
  jc = tab_param(traj, 7*t+4) ;
  tabi = lest(vec_part_in, 2) ;
  tabj = lest(vec_part_in, 3) ;
  indice = N_plus_proche(ic, jc, tabi, tabj, Nb_combi) ;
  vec_part_out = vec_part_in(indice) ;
end%function
function vec_traj_out = limite_combi_traj_blk(vec_traj_in, t)
% limite le nombre de traj 
% a celle les plus anciennes (en blink)
% au nombre Nb_combi (global)
% la premiere reste : ref
  
global tab_param ;
  Nb_combi = evalin('base', 'Nb_combi');
  
  tab_blk = tab_param(vec_traj_in(2:end), 7*t+8) ;
  [blk,indice] = sort(tab_blk, 'descend') ; 
  vec_traj_out = [vec_traj_in(1); vec_traj_in(indice(1:(Nb_combi-1))+1)] ;
end%function
function liste_traj = liste_traj_inter(liste_part, traj_ref, lest, t)
% function qui renvoie les trajectoires (non reconnectees)
% dont les boules (espace libre) de recherche intersecte
% au moins une des particules de la liste

global tab_param ;
Boule_free = evalin('base', 'Boule_free');

%% init des trajectoires a tester
traj_boule = zeros(size(tab_param,1), 1) ;

nb_traj = size(tab_param, 1) ;
boules = Boule_free * sigij_free_blink(1:nb_traj, t) ;


for p = liste_part'

  ic = lest(p,2) ;
  jc = lest(p,3) ;

  %% fenetre de recherche des trajectoires
  %% boule de recherche en ecartype
  icm = max(ic - boules, 0) ; 
  icM = ic + boules ; 
  jcm = max(jc - boules, 0) ; 
  jcM = jc + boules ;
  
  traj_boule = traj_boule | ...
      ((tab_param(:, 7*t+3) < icM) & (tab_param(:, 7*t+3) > icm) & ...
      (tab_param(:, 7*t+4) < jcM) & (tab_param(:, 7*t+4) > jcm)) ;

%    traj_boule = traj_boule | ...
%        (sqrt((tab_param(:, 7*t+3)-ic).^2+...
%        (tab_param(:, 7*t+4)-jc).^2)-boules) <= 0; %CPR
 
end %for

%% trajectoires a tester
%% celles non encore reconnectees
traj_boule = traj_boule & (tab_param(:, 7*(t+1)+8) == 0)  ;

%% test 22 11 07 : celles qui ne sont pas blinkee
traj_boule = traj_boule & (tab_param(:, 7*t+8) > 0)  ;

%% on enleve la ref
traj_boule(traj_ref) = 0 ;

%% les trajectoires en question
liste_traj = find(traj_boule) ;

end %function
function liste_part = liste_part_boule(liste_part_ref, traj, lest, t) 
%finds particles inside search radius of trajectory
% si liste_par_ref == [] alors pas de ref

%% evite les allocations sur des constantes
global tab_param ;
Boule_free = evalin('base', 'Boule_free');
% global tab_var ;

nb_part = size(lest, 1) ;
dim_liste = size(liste_part_ref,1) ;

if (dim_liste ~= 0)
  %% generation d_un masque
  masque_part_ref = ones(nb_part, 1) ;
  masque_part_ref(liste_part_ref) = 0 ;
end %if

%last spacecoordinates for trajectory
ic = tab_param(traj, 7*t+3) ;
jc = tab_param(traj, 7*t+4) ;
%calc search radius
boule = Boule_free * sigij_free_blink(traj, t) ; 

icm = max(ic - boule, 0) ; % en ecart type sur i
icM = ic + boule ; % en ecart type
jcm = max(jc - boule, 0) ; % en ecart type sur j
jcM = jc + boule ; % en ecart type
% 
% %% liste locale a la boule (carree!!) <<<====================================!!!
part_boule = ...
    (lest(:,2) < icM) & (lest(:,2) > icm) & ...
    (lest(:,3) < jcM) & (lest(:,3) > jcm) ;

% part_boule = sqrt((lest(:,2)-ic).^2+(lest(:,3)-jc).^2) <= boule; %CPR

%remove the ones already in ref list
if (dim_liste ~= 0)
  part_boule = part_boule & masque_part_ref ;
end %if

liste_new_part = find(part_boule) ;
liste_part = [liste_part_ref; liste_new_part] ;
end %function
function [out, flag_full_alpha] = rapport_detection(traj, t, lest, part, wn)%, T)
% EN/ returns the likelihood for reconnection between 
% the particle num_test (in list lest) and the trajectory traj
%
% flag_full_alpha indicates if the particle
% is ON (FULL, belongs to the Gaussian)


%% evite les allocations sur des constantes
global tab_param ;
global tab_moy ;
global tab_var ;
Poids_melange_aplha = evalin('base', 'Poids_melange_aplha');
Poids_melange_diff = evalin('base', 'Poids_melange_diff');
T_off = evalin('base', 'T_off');
im_t = evalin('base', 'im_t');

N = wn*wn ;% carree

%% ==============================================
%% test glrt avec parametre estime pour new traj
%% ==============================================
%%
%% glrt_1vue : le meme que dans carte_H0H1
%% mais ici calcule pour les parametres estimes
%% pour les particules nouvelles

if (traj<=0)

  %% P(x|H1)
  %% deja calcule lors de l'estimation 1 vue
  sig2_H1 = lest(part, 5 ) ;
  LxH1 = -N/2*log(sig2_H1) ; % -N/2

  %% P(x|H0)
  %% probleme lors des deflations!!!
  Pi = round(lest(part, 2)) ;
  Pj = round(lest(part, 3)) ;
  di = (1:wn)+Pi-floor(wn/2) ;
  dj = (1:wn)+Pj-floor(wn/2) ;
  im_part = im_t(di, dj) ;
  sig2_H0 = var(im_part(:)) ;
  LxH0 = -N/2*log(sig2_H0) ; % -N/2

  % glrt = -2*( LxH0 - LxH1 ) ;
  out = -2*( LxH0 - LxH1 ) ;
  return ;

end%if 


%% ==============================================
%% vraixemblance de la reconnexion traj <-> part
%% ==============================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% proba de reapparition pendant un blink (blinch)
%% gaussienne > 0
%% nb_blink
if (tab_param(traj, 7*t+8) < 0)
  nb_blink = -tab_param(traj, 7*t+8)  ;
  sig_blink = -T_off/3 ;
  Pblink = 2*inv(sqrt(2*pi)*sig_blink) * exp(-inv(2*sig_blink^2)*nb_blink^2) ;
  Lblink = log(Pblink) ;
else
  % nb_blink = 0 ;
  Lblink = 0 ;
end %if

%%%%%%%%%%%%%%%%%%%%%
%% intensite des pics
%% P(alpha|H1)
%% c'est un melange de loi uniforme et gaussienne
%% on travail a tres faible nombre d'echantillons
%% estimer la proportion uni/gauss est tres difficile

%% ancienne version _old
%% on fait plutot un test de vraisemblance uni/gauss
%% on est don, soit gaussienne, soit uniforme

%% nouvelle version : la loi est une combinaison
%% d'une loi uniforme et gaussienne
%% en effet, l'estimation conjointe des parametres
%% avec melange n'est possible qu'a grand nombre d echantillons
%% ici : a nombre d echantillons reduits on test si 
%% le comportement et plutot gaussien ou uniforme (MV)
%% si uniforme, on garde les anciens parametres
%% si gaussien, on met a jour moyenne et variance
%%
%% Attention, les para metres des lois (les stats m, var)
%% sont mis a jour par la fonction mise_a_jour_tab.m
%% dans les tableaux tab_moy et tab_var
%%
%% si modif verifer mise_a_jour_tab.m

alpha =  lest(part, 4 ) ;
alpha_moy = real(tab_moy(traj, 7*t+5)) ; %% sur tout l'echantillon
sig_alpha = tab_var(traj, 7*t+5) ; %% sur tout l'echantillon
%%alpha_max = imag(tab_moy(traj, 7*t+5)) ;
alpha_max = alpha_moy ;

%% gaussienne (1)
Palpha_gaus = inv(sqrt(2*pi)*sig_alpha) * exp(-inv(2*sig_alpha^2)*(alpha-alpha_moy)^2) ;
%% uniforme (2)
if (alpha < alpha_max)
  Palpha_univ = 1/alpha_max ;
else
  Palpha_univ = 0.0 ;
end%if

poids = Poids_melange_aplha ;
Lalpha = log(poids*Palpha_gaus + (1-poids)*Palpha_univ) ;

if (Palpha_gaus > Palpha_univ)
  flag_full_alpha = 1 ;
else
  flag_full_alpha = 0 ;
end%if


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% vraisemblance de traj a intensitee full
%% nb_alpha_full = mod(tab_param(traj,7*t+8), Nb_STK);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% vraisemblance position / mvt brownien (libre/confine)
%% P(n0|H1)
i0 = lest(part, 2) ;
j0 = lest(part, 3) ;
ic = tab_param(traj, 7*t+3) ; % derniere position
jc = tab_param(traj, 7*t+4) ;
% sig_ij_ref = tab_var(traj, 7*t+3);
sig_ij_ref = sigij_blink(traj, t) ;%% avec blk
sig_free_blk = sigij_free_blink(traj, t) ;%% avec blk  !!! 

poids = Poids_melange_diff ; %% entre gaussienne ref et gaussienne libre
Pn_ref =  inv(2*pi*sig_ij_ref^2) * exp(- inv(2*sig_ij_ref^2) * ((i0-ic)^2 + (j0-jc)^2)) ;
Pn_free = inv(2*pi*sig_free_blk^2) * exp(- inv(2*sig_free_blk^2) * ((i0-ic)^2 + (j0-jc)^2)) ;
Ln0 = log(poids*Pn_ref + (1-poids)*Pn_free);

%%%%%%%%%%
%% P(r|H1)
r =  lest(part, 6) ;
r_ref = tab_moy(traj, 7*t+6) ;
sig_r_ref = tab_var(traj, 7*t+6) ;
if (sig_r_ref ~= 0)
  Lr = -0.5*log(sig_r_ref) - inv(2*sig_r_ref^2) * (r-r_ref)^2;
else
  Lr = 0 ;
end%if

%% vraisemblance
out = Lalpha + Ln0 + Lblink + 0*Lr;


end %function
function sig_blk = sigij_blink(traj, t)
% EN/ if blink, increase of the std
    
global tab_param ;
global tab_var ;

%% offset de zone de blink nb_blink==(-offset)
if (tab_param(traj, 7*t+8) < 0)
  offset = tab_param(traj, 7*t+8)  ;
else
  offset = 0 ;
end %if

%% sigi = sigj
sig_blk = tab_var(traj, 7*t+3)  ;  %% sur i 

%% prise en compte du blink pour sig_i/j
if (offset < 0)
    sig_blk = sig_blk * sqrt(1-offset) ;
end %if

end%function
function sig_free_blk = sigij_free_blink(traj, t, sig_free)
% EN/ if blink, increase of the std
% traj scalar or vector of trajectories

global tab_param ;
sig_free = evalin('base', 'sig_free');

traj = traj(:) ;
nb_traj = size(traj, 1) ;

%% offset
offset = tab_param(traj, 7*t+8) ;

%% offset de zone de blink nb_blink==(-offset)
%% offset = 0 si non_blink (>0)
%% idem sinon ;
nb_blink = - (offset .* (offset < 0))  ;

%% sigi = sigj
sig_free_blk = sig_free*ones(nb_traj, 1) ; 

%% prise en compte du blink pour sig_i/j
sig_free_blk = sig_free_blk .* sqrt(1+nb_blink) ;

end%function
function part = best_config_reconnex(vec_traj, vec_part, t, lest, wn)%,T)
% EN/ This function looks for the best config
% according to the ML and sends back 
% the most probable particle (O if blinked)
% The refering trace IS the first one
% of the list in vect_traj 
%
% Caution with combinatory tests beyond nb_part = 4

% Exemple de calcul de Log-vraisemblance
% de reconnexion a 3 trajectoires/Particules
% reprenant les notations de la figure 3
% 
% 
% - T_domain = P_domain
% 3 trajectoires (a,k,b) pour 3 particules (1,2,3)
% on cherche la meilleure combinaison en comparant leur vraisemblance
% respective :
% L(a,1)  +  L(k,2)  +  L(b,3)  <>
% L(a,1)  +  L(k,3)  +  L(b,2)  <>
% L(a,2)  +  L(k,1)  +  L(b,3)  <>
%   etc.
% 
% - T_domain > P_domain
% 3 trajectoires (a,k,b) pour 2 particules : On en cree une 3eme OFF
% (1,2,OFF).
% Alors les tests deviennent :
% L(a,1) + L(k,2)   + L(b,OFF)  <>
% L(a,1) + L(k,OFF) + L(b,2)    <>
% L(a,2) + L(k,1)   + L(b,OFF)  <>
%   etc.
% Dans ce cas, seulement 2 termes de vraisemblance sont
% presents car le troisieme L(T,OFF), probabilite de disparition d'une 
% trajectoire, est identique pour toute trajectoires T.
% 
% - T_domain < P_domain
% 2 trajectoires (a,k) pour 3 particules (1,2,3) : On cree une nouvelle
% trajectoire (a,k,NEW)
% Alors les tests deviennent :
% L(a,1) + L(k,2)  + L(NEW,3)  <>
% L(a,1) + L(k,3)  + L(NEW,2)  <>
% L(a,2) + L(k,1)  + L(NEW,3)  <>
%   etc.
% La encore, dans ce cas, seulement 2 termes de vraisemblance sont
% presents car le troisieme terme L(NEW,P), probabilite d'apparition
% d'une nouvelle trajectoire dans l'image, est suppose constant.
% Elle ne depend ni de la position, ni de l'intensite.

  %% permutation circulaire sur vec_part
  %% limite a la taille nb_traj
  % nb_part = size(vec_part(:), 1) ;
  nb_traj = size(vec_traj(:), 1) ;
  best_part = vec_part(1) ;
  vec_part_ref = vec_part(1:nb_traj) ;
  vrais =  vrais_config_reconnex(vec_traj, vec_part_ref, t, lest, wn);%,T)


  tab_perms_vec_part = perms(vec_part)' ;
  nb_perms = size(tab_perms_vec_part, 2) ;

  for p=2:nb_perms
    vec_part_perm = tab_perms_vec_part(:,p) ;
    %% si plus de particules que de traj
    %% cas de nouvelle traj
    %% on test les nb_traj premiere
    vec_part_perm = vec_part_perm(1:nb_traj) ;
    vrais_tmp =  vrais_config_reconnex(vec_traj, vec_part_perm, t, ...
				       lest, wn);%, T) ;

    if (vrais_tmp > vrais)
      vrais = vrais_tmp ;
      best_part = vec_part_perm(1) ;
    end %if
  end %for

part = best_part ;


end %function
function vrais = vrais_config_reconnex(vec_traj, vec_part, t, lest, wn)%,T)
% function qui renvoie la vraisemblance
% d'une configuration de reconnexion/blink
% pour plusieurs trajectoires et particules
%
% les cardinaux des deux vecteurs d'entrees 
% sont forcement egaux

  % vec_part peut avoir des valeurs nulles
  % correspondant aux particules blinkees
  % la proba de blink est sans a priori
  % et c'est la meme pour tout traj
  % toute comparaison ce fera a nombre de
  % blink egal, donc on fait rien

  vrais = 0 ;
  nb_part = size(vec_part(:), 1) ;
  for p = 1:nb_part
    part = vec_part(p) ;
    traj = vec_traj(p) ;
    if part ~= 0
      vrais_p = rapport_detection(traj, t, lest, part, wn) ;
      vrais = vrais + vrais_p ;
    end %if
  end %for

end %function