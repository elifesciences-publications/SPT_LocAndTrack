function evalSPT
%written by BSc. C.P.Richter
%University of Osnabrueck
%Department of Biophysics / Group Piehler

%FRONTPAGE
h.homeFig =...
    figure(...
    'Tag', 'home',...
    'Units','normalized',...
    'Position', [0.2 0.2 0.5 0.7],...
    'Color', get(0,'defaultUicontrolBackgroundColor'),...
    'Name', 'SPTeval Build 1.103c',...
    'NumberTitle', 'off',...
    'MenuBar', 'none',...
    'ToolBar', 'none',...
    'Resize', 'off');

h.fileList =...
    uicontrol(...
    'Style', 'listbox',...
    'Units','normalized',...
    'Position', [0.05 0.87 0.85 0.1],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1]);

h.addFile =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Units','normalized',...
    'Position', [0.9 0.936 0.05 0.033],...
    'FontSize', 25,...
    'FontUnits', 'normalized',...
    'String', '+',...
    'Callback', {@addFile, h.fileList});

h.delFile =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Units','normalized',...
    'Position', [0.9 0.903 0.05 0.033],...
    'FontSize', 30,...
    'FontUnits', 'normalized',...
    'String', '-',...
    'Callback', {@delFile, h.fileList});

uicontrol(...
    'Style', 'togglebutton',...
    'Units','normalized',...
    'Position', [0.9 0.87 0.05 0.033],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'String', 'OK',...
    'Callback', @loadData)

%% TRACK LENGTH PAGE
h.cutDataPanel =...
    uipanel(...
    'Units','normalized',...
    'Position', [0.05 0.65 0.45 0.2],...
    'Title','Specify Data Subset',...
    'FontSize',12,...
    'FontUnits', 'normalized');

uicontrol(...
    'Style', 'text',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.05 0.7 0.45 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Track Lifetime [Frames]:',...
    'HorizontalAlignment', 'left');

% min
h.minTrackLength =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.5 0.7 0.2 0.2],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'Callback', @setMinTrackLength);

uicontrol(...
    'Style', 'text',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.5 0.94 0.2 0.08],...
    'FontSize', 7,...
    'FontUnits', 'normalized',...
    'String', 'min');

% max
h.maxTrackLength =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.75 0.7 0.2 0.2],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'Callback', @setMaxTrackLength);

uicontrol(...
    'Style', 'text',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.75 0.94 0.2 0.08],...
    'FontSize', 7,...
    'FontUnits', 'normalized',...
    'String', 'max');

% excluded data
h.percentExcluded =...
    uicontrol(...
    'Style', 'text',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.5 0.4 0.2 0.2],...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'FontUnits', 'normalized');

uicontrol(...
    'Style', 'text',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.05 0.4 0.4 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Data Excluded [%]:',...
    'HorizontalAlignment', 'left');

% exclude by hand (trajectory map)
h.discardTrackPush =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.05 0.1 0.6 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'REMOVE TRACK MANUALLY',...
    'Callback', @removeTrack,...
    'Enable', 'off');

% show track length histogram
h.trackLengthHistPush =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.7 0.1 0.25 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'HISTOGRAM',...
    'Callback', @trackLengthHist,...
    'Enable', 'off');

h.trackDataExport =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.cutDataPanel,...
    'Units','normalized',...
    'Position', [0.7 0.4 0.25 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'EXPORT DATA',...
    'Callback', @exportTracks,...
    'Enable', 'off');

%% VISUALISATION PAGE
h.visModeOneToggle =...
    uicontrol(...
    'Style', 'togglebutton',...
    'Units','normalized',...
    'Position', [0.951 0.795 0.04 0.04],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'String', '1',...
    'Callback', @changeVisMode);
h.visModeTwoToggle =...
    uicontrol(...
    'Style', 'togglebutton',...
    'Units','normalized',...
    'Position', [0.951 0.751 0.04 0.04],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'String', '2',...
    'Value', 1,...
    'Callback', @changeVisMode);
    function changeVisMode(src, event)
        h = getappdata(1, 'handles');
        
        switch get(src, 'String')
            case '1'
                if get(src, 'Value')
                    set(h.visualisationPanelOne, 'Visible', 'on')
                    set(h.visualisationPanelTwo, 'Visible', 'off')
                    set(h.visModeTwoToggle, 'Value', 0)
                else
                    set(h.visModeOneToggle, 'Value', 1)
                end %if
            case '2'
                if get(src, 'Value')
                    set(h.visualisationPanelOne, 'Visible', 'off')
                    set(h.visualisationPanelTwo, 'Visible', 'on')
                    set(h.visModeOneToggle, 'Value', 0)
                else
                    set(h.visModeTwoToggle, 'Value', 1)
                end %if
        end %switch
    end

%% VISUALISATION PAGE ONE
h.visualisationPanelOne =...
    uipanel(...
    'Units','normalized',...
    'Position', [0.5 0.65 0.45 0.2],...
    'Title','Visualize Trajectory Ensemble',...
    'FontSize',12,...
    'FontUnits', 'normalized',...
    'Visible', 'off');

uicontrol(...
    'Style', 'text',...
    'Parent', h.visualisationPanelOne,...
    'Units','normalized',...
    'Position', [0.05 0.7 0.45 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Colorcoding:',...
    'HorizontalAlignment', 'left');

h.colorcodingPopup =...
    uicontrol(...
    'Style', 'popupmenu',...
    'Parent', h.visualisationPanelOne,...
    'Units', 'normalized',...
    'Position', [0.4 0.7 0.55 0.2],...
    'String', {'Detection Time', 'Track ID',...
    'Track Length', 'Detection Density', 'Local Diff. Coeff.'},...
    'Value', 1,...
    'BackgroundColor', [1 1 1],...
    'FontSize', 8,...
    'FontUnits', 'normalized');

% set pixelbinning factor
uicontrol(...
    'Style', 'text',...
    'Parent', h.visualisationPanelOne,...
    'Units','normalized',...
    'Position', [0.05 0.4 0.4 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Binning [px^2]:',...
    'HorizontalAlignment', 'left');

h.pixelBinning =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.visualisationPanelOne,...
    'Units','normalized',...
    'Position', [0.4 0.4 0.2 0.2],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 1);

% visualise data
h.showDataPush =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.visualisationPanelOne,...
    'Units','normalized',...
    'Position', [0.05 0.1 0.4 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'SHOW ENSEMBLE',...
    'Callback', @showData,...
    'Enable', 'off');

%% VISUALISATION PAGE TWO
h.visualisationPanelTwo =...
    uipanel(...
    'Units','normalized',...
    'Position', [0.5 0.65 0.45 0.2],...
    'Title','Visualize Single Trajectories',...
    'FontSize',12,...
    'FontUnits', 'normalized');

uicontrol(...
    'Style', 'text',...
    'Parent', h.visualisationPanelTwo,...
    'Units','normalized',...
    'Position', [0.05 0.7 0.45 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Select Trajectory by ID:',...
    'HorizontalAlignment', 'left');

h.selectedTrackPopup =...
    uicontrol(...
    'Style', 'popupmenu',...
    'Parent', h.visualisationPanelTwo,...
    'Units', 'normalized',...
    'Position', [0.5 0.7 0.45 0.2],...
    'String', 'empty',...
    'Value', 1,...
    'BackgroundColor', [1 1 1],...
    'FontSize', 8,...
    'FontUnits', 'normalized');

h.selectTrackFromMap =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.visualisationPanelTwo,...
    'Units','normalized',...
    'Position', [0.05 0.4 0.4 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'CHOOSE FROM MAP',...
    'Callback', @selectTrackFromMap,...
    'Enable', 'off');

h.selectTrackFromList =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.visualisationPanelTwo,...
    'Units','normalized',...
    'Position', [0.05 0.1 0.4 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'CHOOSE FROM LIST',...
    'Callback', @selectTrackFromList,...
    'Enable', 'off');

h.trajectoryOverview =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.visualisationPanelTwo,...
    'Units','normalized',...
    'Position', [0.5 0.1 0.45 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'SHOW TRACK DETAILS',...
    'Callback', @showOverview,...
    'Enable', 'off');

%% DIFFUSION PAGE
h.diffModeOneToggle =...
    uicontrol(...
    'Style', 'togglebutton',...
    'Units','normalized',...
    'Position', [0.01 0.595 0.04 0.04],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', '1',...
    'Value', 1,...
    'Callback', @changeDiffMode);
h.diffModeTwoToggle =...
    uicontrol(...
    'Style', 'togglebutton',...
    'Units','normalized',...
    'Position', [0.01 0.555 0.04 0.04],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', '2',...
    'Callback', @changeDiffMode);
    function changeDiffMode(src, event)
        h = getappdata(1, 'handles');
        
        switch get(src, 'String')
            case '1'
                if get(src, 'Value')
                    set(h.diffusionPanelOne, 'Visible', 'on')
                    set(h.diffusionPanelTwo, 'Visible', 'off')
                    set(h.diffModeTwoToggle, 'Value', 0)
                else
                    set(h.diffModeOneToggle, 'Value', 1)
                end %if
            case '2'
                if get(src, 'Value')
                    set(h.diffusionPanelOne, 'Visible', 'off')
                    set(h.diffusionPanelTwo, 'Visible', 'on')
                    set(h.diffModeOneToggle, 'Value', 0)
                else
                    set(h.diffModeTwoToggle, 'Value', 1)
                end %if
        end %switch
    end

h.diffusionPanelOne =...
    uipanel(...
    'Units','normalized',...
    'Position', [0.05 0.3 0.45 0.35],...
    'Title','Two Fractions (Sch?tz et al.)',...
    'FontSize',12,...
    'FontUnits', 'normalized');

%% DIFFUSION PAGE ONE
%short range
h.shortRange =...
    uicontrol(...
    'Style', 'checkbox',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.05 0.8 0.4 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Short Range:',...
    'Value', 1);

% start
h.shortRangeStart =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.5 0.8 0.2 0.11],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 2);

% stop
h.shortRangeStop =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.75 0.8 0.2 0.11],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 6);

%long range
h.longRange =...
    uicontrol(...
    'Style', 'checkbox',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.05 0.6 0.35 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Long Range:',...
    'Value', 1);

% start
h.longRangeStart =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.5 0.6 0.2 0.11],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 2);

% stop
h.longRangeStop =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.75 0.6 0.2 0.11],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 26);

%Dmax
h.estimateDmax =...
    uicontrol(...
    'Style', 'checkbox',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.05 0.4 0.7 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Estimate upper Diffusion Limit',...
    'Value', 1);

%diffusion model
uicontrol(...
    'Style', 'text',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.05 0.22 0.45 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Diffusion Model:',...
    'HorizontalAlignment', 'left');

h.diffusionModel =...
    uicontrol(...
    'Style', 'popupmenu',...
    'Parent', h.diffusionPanelOne,...
    'Units', 'normalized',...
    'Position', [0.5 0.24 0.45 0.11],...
    'String', {'Brownian', 'Anomalous', 'Transport'},...
    'Value', 1,...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'FontUnits', 'normalized');

h.analyseDiffOnePush =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.diffusionPanelOne,...
    'Units','normalized',...
    'Position', [0.05 0.05 0.65 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'ANALYZE DIFFUSION',...
    'Callback', @analyseDiffusionOne,...
    'Enable', 'off');

%% DIFFUSION PAGE TWO
h.diffusionPanelTwo =...
    uipanel(...
    'Units','normalized',...
    'Position', [0.05 0.3 0.45 0.35],...
    'Title','Multiple Fractions',...
    'FontSize',12,...
    'FontUnits', 'normalized',...
    'Visible', 'off');

h.timeDpndncy =...
    uicontrol(...
    'Style', 'popupmenu',...
    'Parent', h.diffusionPanelTwo,...
    'Units', 'normalized',...
    'Position', [0.05 0.8 0.65 0.11],...
    'String', {'Analyze Time Step [Frame]',...
    'Analyze Time Series [Frames]'},...
    'Value', 1,...
    'BackgroundColor', [1 1 1],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'Callback',@changeTimeDpndncy);
    function changeTimeDpndncy(src, event)
        h = getappdata(1, 'handles');
        
        switch get(src, 'Value')
            case 1
                set(h.timeStepDiffusion, 'Visible', 'on')
                set(h.timeSeriesStart, 'Visible', 'off')
                set(h.timeSeriesStop, 'Visible', 'off')
            case 2
                set(h.timeStepDiffusion, 'Visible', 'off')
                set(h.timeSeriesStart, 'Visible', 'on')
                set(h.timeSeriesStop, 'Visible', 'on')
        end %if
    end

h.timeStepDiffusion(1) =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.75 0.8 0.2 0.11],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 5);

% h.timeStepDiffusion(2) =...
%     uicontrol(...
%     'Style', 'text',...
%     'Parent', h.diffusionPanelTwo,...
%     'Units','normalized',...
%     'Position', [0.75 0.7 0.2 0.2],...
%     'FontSize', 8,...
%     'FontUnits', 'normalized',...
%     'String', 'Frames',...
%     'HorizontalAlignment', 'left');

h.timeSeriesStart =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.75 0.8 0.1 0.11],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'String', 2,...
    'BackgroundColor', [1 1 1],...
    'Visible', 'off');

h.timeSeriesStop =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.85 0.8 0.1 0.11],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'String', 26,...
    'BackgroundColor', [1 1 1],...
    'Visible', 'off');

uicontrol(...
    'Style', 'text',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.05 0.6 0.35 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', '# of Subpopulations:',...
    'HorizontalAlignment', 'left');

h.populations =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.5 0.6 0.2 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 2);

uicontrol(...
    'Style', 'text',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.05 0.4 0.35 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', '# Bins (Samplingrate):',...
    'HorizontalAlignment', 'left');

h.mffPdfBins =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.5 0.4 0.2 0.11],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 100);

h.analyseDiffTwoPush =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.05 0.05 0.5 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'ANALYZE DIFFUSION',...
    'Callback', @analyseDiffusionTwo,...
    'Enable', 'off');

h.analyseDiffHist =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.6 0.17 0.35 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'D HISTOGRAM',...
    'Callback', @diffCoeffHist,...
    'Enable', 'off');

h.analyseDiffHist =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.diffusionPanelTwo,...
    'Units','normalized',...
    'Position', [0.6 0.05 0.35 0.11],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'ALPHA HISTOGRAM',...
    'Callback', @diffCoeffHist,...
    'Enable', 'off');

%% CONFINEMENT

h.confinementPanel =...
    uipanel(...
    'Units','normalized',...
    'Position', [0.5 0.45 0.45 0.2],...
    'Title','Confinement Analysis',...
    'FontSize',12,...
    'FontUnits', 'normalized');

uicontrol(...
    'Style', 'text',...
    'Parent', h.confinementPanel,...
    'Units','normalized',...
    'Position', [0.05 0.7 0.34 0.22],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Upper Diffusion Limit [?m^2\s]:',...
    'HorizontalAlignment', 'left');

% max. diffusion coefficient
h.confDmax =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', h.confinementPanel,...
    'Units','normalized',...
    'Position', [0.4 0.7 0.2 0.2],...
    'BackgroundColor', [1 1 1],...
    'FontSize', 10,...
    'FontUnits', 'normalized');

h.confEstimateDmax =...
    uicontrol(...
    'Style', 'checkbox',...
    'Parent', h.confinementPanel,...
    'Units','normalized',...
    'Position', [0.7 0.7 0.3 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'estimate',...
    'Value', 1);

uicontrol(...
    'Style', 'text',...
    'Parent', h.confinementPanel,...
    'Units','normalized',...
    'Position', [0.05 0.4 0.35 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Algorithm:',...
    'HorizontalAlignment', 'left');

h.confAlgorithm =...
    uicontrol(...
    'Style', 'popupmenu',...
    'Parent', h.confinementPanel,...
    'Units', 'normalized',...
    'Position', [0.4 0.43 0.55 0.2],...
    'String', {'Meilhac et al.', 'Saxton et al.'},...
    'Value', 1,...
    'BackgroundColor', [1 1 1],...
    'FontSize', 8,...
    'FontUnits', 'normalized');

h.confinementAnalysisPush =...
    uicontrol(...
    'Style', 'pushbutton',...
    'Parent', h.confinementPanel,...
    'Units','normalized',...
    'Position', [0.05 0.1 0.6 0.2],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'ANALYZE CONFINEMENT',...
    'Callback', @confinementAnalysis,...
    'Enable', 'off');

%% track movie
uipanel(...
    'Tag','trackMoviePanel',...
    'Units','normalized',...
    'Position', [0.5 0.3 0.45 0.15],...
    'Title','Trajectory Movie',...
    'FontSize',12,...
    'FontUnits', 'normalized');

uicontrol(...
    'Style', 'togglebutton',...
    'Parent', findobj(h.homeFig,'Tag','trackMoviePanel'),...
    'Tag','buttonSetTrackMovie',...
    'Units','normalized',...
    'Position', [0.55 0.4 0.4 0.3],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'SETTINGS',...
    'CreateFcn',{@initializeVarList,'Track Movie'},...
    'Callback', @settingsTrackMovie);

uicontrol(...
    'Style', 'pushbutton',...
    'Parent', findobj(h.homeFig,'Tag','trackMoviePanel'),...
    'Units','normalized',...
    'Position', [0.05 0.4 0.4 0.3],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'START MOVIE',...
    'Callback', @buildTrackMovie,...
    'Enable', 'off');

%% Kinetics
uipanel(...
    'Tag','trackKineticsPanel',...
    'Units','normalized',...
    'Position', [0.05 0.05 0.45 0.25],...
    'Title','Kinetics Analysis',...
    'FontSize',12,...
    'FontUnits', 'normalized');

uicontrol(...
    'Style', 'text',...
    'Parent', findobj(h.homeFig,'Tag','trackKineticsPanel'),...
    'Units','normalized',...
    'Position', [0.05 0.7 0.35 0.16],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Analysis Window:',...
    'HorizontalAlignment', 'left');

h.transitionAnalysisWin =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', findobj(h.homeFig,'Tag','trackKineticsPanel'),...
    'Units','normalized',...
    'Position', [0.5 0.75 0.2 0.16],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', 16);

uicontrol(...
    'Style', 'text',...
    'Parent', findobj(h.homeFig,'Tag','trackKineticsPanel'),...
    'Units','normalized',...
    'Position', [0.05 0.4 0.35 0.16],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'Transition Threshold:',...
    'HorizontalAlignment', 'left');

h.transitionThresh =...
    uicontrol(...
    'Style', 'edit',...
    'Parent', findobj(h.homeFig,'Tag','trackKineticsPanel'),...
    'Units','normalized',...
    'Position', [0.5 0.45 0.2 0.16],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'BackgroundColor', [1 1 1],...
    'String', -2);

uicontrol(...
    'Style', 'pushbutton',...
    'Parent', findobj(h.homeFig,'Tag','trackKineticsPanel'),...
    'Units','normalized',...
    'Position', [0.05 0.08 0.4 0.17],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'STATE HISTOGRAM',...
    'Callback', @ensembleStateAnalysis,...
    'Enable', 'off');

%%
setappdata(1, 'handles', h)
setappdata(1, 'searchPath', cd)

end
function addFile(src, event, hList)
[stackname, stackpath, isOK] = uigetfile('*.mat',...
    'Select Tracking Data', getappdata(1,'searchPath'), 'MultiSelect', 'on');
if isOK
    setappdata(1, 'searchPath', stackpath)
    content = get(hList, 'String');
    content = [content',...
        cellstr(strcat(stackpath, stackname))];
    set(hList, 'String', content, 'Value', 1)
else
    return
end %if
end
function delFile(src, event, hList)
bad = get(hList, 'Value');
content = get(hList, 'String');
if isempty(content)
    return
else
    content(bad) = [];
    set(hList, 'String', content, 'Value', 1)
end %if
end
function loadData(src, event)
h = getappdata(1, 'handles');

switch get(src, 'Value')
    case 1
        set(findobj(h.homeFig, 'Style',...
            'pushbutton'), 'Enable', 'on')
        set(h.addFile, 'Enable', 'off')
        set(h.delFile, 'Enable', 'off')
        
        contents = get(h.fileList, 'String');
        if isempty(contents)
            set(findobj(h.homeFig, 'Style',...
                'pushbutton'), 'Enable', 'off')
            set(h.addFile, 'Enable', 'on')
            set(h.delFile, 'Enable', 'on')
            set(src, 'Value', 0)
            return
        elseif numel(contents) == 1
            load(contents{1})
            v.data = data.tr;
            v.settings = settings;
            v.detectionsPerFrame = par_per_frame;
        else
            setNr = 0;
            temp = [];
            for N = 1:numel(contents)
                load(contents{N});
                for n = 1:numel(data.tr)
                    data.tr{n}(:,4) = data.tr{n}(:,4)+setNr;
                end
                setNr = data.tr{n}(1,4);
                setData{N} = data.tr;
                
                %setSettingsTrackingAlgorithm{N} = settings.TrackingAlgorithm;
                setSettingsFrames(N) = settings.Frames;
                setSettingsWidth(N) = settings.Width;
                setSettingsHeigth(N) = settings.Height;
                setSettingsDelay(N) = settings.Delay;
                if isfield(settings,'Magnification') %for backward compatibility
                    setSettingsMagnification{N} = settings.Magnification;
                else
                    setSettingsPx2Micron(N) = settings.px2micron;
                end
                
                setPPF{N} = par_per_frame;
                
                if exist('trackActiv','var')
                    temp = [temp trackActiv];
                else
                    temp = [temp true(1,numel(data.tr))];
                end %if
            end
            trackActiv = temp;
            
            v.data = horzcat(setData{:});
            
            v.settings = settings;
            v.settings.Frames = max(setSettingsFrames);
            v.settings.Width = max(setSettingsWidth);
            v.settings.Height = max(setSettingsHeigth);
            if all(setSettingsDelay == setSettingsDelay)
                v.settings.Delay = setSettingsDelay(1);
            else
                errordlg('Timelag not equal', 'Error', 'modal');
            end
            if isfield(settings,'Magnification') %for backward compatibility
                if all(strcmp(cellstr(setSettingsMagnification),...
                        cellstr(setSettingsMagnification)))
                    v.settings.Magnification = setSettingsMagnification{1};
                else
                    errordlg('Magnification not equal', 'Error', 'modal');
                end
                
            else
                if all(setSettingsPx2Micron == setSettingsPx2Micron)
                    v.settings.px2micron = setSettingsPx2Micron(1);
                else
                    errordlg('Magnification not equal', 'Error', 'modal');
                end
            end %if
            v.detectionsPerFrame = nansum(padcat(setPPF{:}));
        end
        if isfield(settings,'Magnification') %for backward compatibility
            % conversion [px] to [?m]
            switch v.settings.Magnification
                case '60, 1x'
                    v.px2micron = 0.267;
                case '60, 1.6x'
                    v.px2micron = 0.180;
                case '150, 1x'
                    v.px2micron = 0.105;
                case '150, 1.6x'
                    v.px2micron = 0.071;
                case 'Simulation'
                    v.px2micron = 0.099;
            end %switch
        else
            v.px2micron = v.settings.px2micron;
        end %if
        
        v.tracksTotal = numel(v.data);
        v.trackIndex = 1:v.tracksTotal;
        v.trackLength = cellfun('size', v.data, 1);
        v.trackLifeTime = cell2mat(cellfun(@(x) (x(end,3)-x(1,3))+1,...
            v.data, 'Un',0));
        
%         v.track = v.trackLength >= 3;
%         v.trackList = vertcat(v.data{v.track});
%         if exist('trackActiv','var')
%             v.trackActiv = trackActiv;
%         else
%             v.trackActiv = true(1,v.tracksTotal);
%         end %if
%         
%         %     set(h.openFilenameText, 'String', [pathname file],...
%         %         'ToolTipString', '', 'UserData', [])
%         set(h.minTrackLength, 'String', 3)
%         set(h.maxTrackLength, 'String', 100)
%         set(h.percentExcluded, 'String', ...
%             round(sum(v.trackLength(~v.track))/sum(v.trackLength)*100))
%         set(h.selectedTrackPopup, 'String',...
%             cellstr(num2str(transpose(find(v.track)))),...
%             'Value', 1)
        
        v.track = v.trackLength >= 3 &...
            v.trackLength <= 100;
        
        if exist('trackActiv','var')
            v.trackActiv = trackActiv;
        else
            v.trackActiv = true(1,v.tracksTotal);
        end %if
        
        v.trackList = vertcat(v.data{v.track & v.trackActiv});

        set(h.minTrackLength, 'String', 3)
        set(h.maxTrackLength, 'String', 100)
        set(h.percentExcluded, 'String', ...
            round(sum(v.trackLength(~(v.trackActiv & v.track)))/...
            sum(v.trackLength)*100))
        set(h.selectedTrackPopup, 'String',...
            cellstr(num2str(transpose(find(v.track & v.trackActiv)))))

        %icon grafics
        v.xlsExportIcon = repmat(...
            [NaN,0,NaN,NaN,0,NaN,0,0,0,0,NaN,0,0,0,NaN,NaN;
            NaN,0,NaN,NaN,0,NaN,0,NaN,NaN,0,NaN,0,NaN,NaN,0,NaN;
            NaN,0,NaN,NaN,0,NaN,0,0,0,0,NaN,0,0,0,NaN,NaN;
            NaN,NaN,0,0,NaN,NaN,0,NaN,NaN,0,NaN,0,NaN,NaN,0,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,0,NaN,0,NaN,NaN,0,NaN,NaN,NaN,NaN,0,0,0,0,NaN;
            NaN,NaN,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN;
            NaN,NaN,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,0,0,0,0,NaN;
            NaN,0,NaN,0,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,NaN;
            0,NaN,NaN,NaN,0,NaN,0,0,0,0,NaN,0,0,0,0,NaN;], [1 1 3]);
        
        setappdata(1, 'values', v)
    case 0
        set(findobj(h.homeFig, 'Style',...
            'pushbutton'), 'Enable', 'off')
        set(h.addFile, 'Enable', 'on')
        set(h.delFile, 'Enable', 'on')
        
        set(h.minTrackLength, 'String', '')
        set(h.maxTrackLength, 'String', '')
        set(h.percentExcluded, 'String', '')
        set(h.selectedTrackPopup, 'String','empty', 'Value', 1)
        
        v = [];
        
        %icon grafics
        v.xlsExportIcon = repmat(...
            [NaN,0,NaN,NaN,0,NaN,0,0,0,0,NaN,0,0,0,NaN,NaN;
            NaN,0,NaN,NaN,0,NaN,0,NaN,NaN,0,NaN,0,NaN,NaN,0,NaN;
            NaN,0,NaN,NaN,0,NaN,0,0,0,0,NaN,0,0,0,NaN,NaN;
            NaN,NaN,0,0,NaN,NaN,0,NaN,NaN,0,NaN,0,NaN,NaN,0,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,0,NaN,0,NaN,NaN,0,NaN,NaN,NaN,NaN,0,0,0,0,NaN;
            NaN,NaN,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN;
            NaN,NaN,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,0,0,0,0,NaN;
            NaN,0,NaN,0,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,NaN;
            0,NaN,NaN,NaN,0,NaN,0,0,0,0,NaN,0,0,0,0,NaN;], [1 1 3]);
        
        setappdata(1, 'values', v)
end %switch
end

function setMinTrackLength(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

minLength = str2double(get(h.minTrackLength, 'String'));
maxLength = str2double(get(h.maxTrackLength, 'String'));
if minLength < 1
    warndlg('min. track length must be 6', 'Warning', 'modal');
    minLength = 6;
elseif maxLength < minLength
    warndlg('max. track length must be >= min. track length',...
        'Warning', 'modal');
    maxLength = minLength;
end %if

v.track = v.trackLength >= minLength &...
    v.trackLength <= maxLength;
v.trackList = vertcat(v.data{v.track & v.trackActiv});

set(h.minTrackLength, 'String', minLength)
set(h.maxTrackLength, 'String', maxLength)
set(h.percentExcluded, 'String', ...
    round(sum(v.trackLength(~(v.trackActiv & v.track)))/...
    sum(v.trackLength)*100))
set(h.selectedTrackPopup, 'String',...
    cellstr(num2str(transpose(find(v.track & v.trackActiv)))))

setappdata(1, 'values', v)
end
function setMaxTrackLength(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

minLength = str2double(get(h.minTrackLength, 'String'));
maxLength = str2double(get(h.maxTrackLength, 'String'));

if maxLength > max(v.trackLength)
    maxLength = max(v.trackLength);
elseif maxLength < minLength
    warndlg('max. track length must be >= min. track length', 'Warning', 'modal');
    maxLength = minLength;
end %if

v.track = v.trackLength >= minLength &...
    v.trackLength <= maxLength;
v.trackList = vertcat(v.data{v.track & v.trackActiv});

set(h.maxTrackLength, 'String', maxLength)
set(h.percentExcluded, 'String', ...
    round(sum(v.trackLength(~(v.trackActiv & v.track)))/...
    sum(v.trackLength)*100))
set(h.selectedTrackPopup, 'String',...
    cellstr(num2str(transpose(find(v.track & v.trackActiv)))))

setappdata(1, 'values', v)
end
function removeTrack(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

fig =...
    figure(...
    'Units', 'normalized',...
    'Position', figPos(1),...
    'Toolbar', 'figure',...
    'MenuBar', 'none',...
    'NumberTitle', 'off',...
    'Color', get(0,'defaultUicontrolBackgroundColor'),...
    'Name', 'remove Track from further Analysis');
ax =...
    axes(...
    'Parent', fig,...
    'FontSize', 15);

hToolBar = findall(fig,'Type','uitoolbar');
hToggleList = findall(hToolBar);
delete(hToggleList([2 3 4 5 6 7 8 9 10 13 14 16 17 18]))

%plot tracks ensemble at once
line(cell2mat(cellfun(@(x) [x(:,1);nan],...
    v.data(v.track)', 'Un',0)),...
    cell2mat(cellfun(@(x) [x(:,2);nan],...
    v.data(v.track)', 'Un',0)), 'Color', 'b',...
    'Parent', ax);

line(cell2mat(cellfun(@(x) [x(:,1);nan],...
    v.data(~v.trackActiv)', 'Un',0)),...
    cell2mat(cellfun(@(x) [x(:,2);nan],...
    v.data(~v.trackActiv)', 'Un',0)), 'Color', 'r',...
    'LineWidth', 2, 'Parent', ax);

axis('equal', 'ij',...
    [0 v.settings.Width 0 v.settings.Height])
xlabel('x-coordinate [px]'); ylabel('y-coordinate [px]');

hcmenu = uicontextmenu;
uimenu(hcmenu, 'Label', 'activate all',...
    'Callback', @selectEnsemble);
uimenu(hcmenu, 'Label', 'remove all',...
    'Callback', @selectEnsemble);

set(fig, 'UIContextMenu', hcmenu)
set(ax, 'ButtonDownFcn', @selectTrack)

    function selectTrack(src, event)
        
        [x,y] = ginput(1);
        neighbor = (v.trackList(:,1) - x).^2 +...
            (v.trackList(:,2) - y).^2;
        trackID = v.trackList(neighbor == min(neighbor),4);
        
        %             v = getappdata(1, 'values');
        v.trackActiv(trackID) = false;
        save(char(get(h.fileList, 'String')),...
            '-struct', 'v', 'trackActiv', '-append')
        
        v.trackList(v.trackList(:,4) == trackID,:) = [];
        
        set(h.percentExcluded, 'String', ...
            round(sum(v.trackLength(~(v.trackActiv & v.track)))/...
            sum(v.trackLength)*100))
        set(h.selectedTrackPopup, 'String',...
            cellstr(num2str(transpose(find(v.track & v.trackActiv)))),...
            'Value', 1)
        
        line(v.data{trackID}(:,1),v.data{trackID}(:,2),...
            'Color', 'g', 'LineWidth', 2, 'Parent', ax)
        
        setappdata(1, 'values', v)
    end
    function selectEnsemble(src,event)
        switch get(src,'Label')
            case 'activate all'
                v.trackActiv(:) = true;
                v.trackList = vertcat(v.data{v.track});
                
            case 'remove all'
                v.trackActiv(:) = false;
                v.trackList = [];
        end %switch
        save(char(get(h.fileList, 'String')),...
            '-struct', 'v', 'trackActiv', '-append')
        
        set(h.percentExcluded, 'String', ...
            round(sum(v.trackLength(~(v.trackActiv & v.track)))/...
            sum(v.trackLength)*100))
        set(h.selectedTrackPopup, 'String',...
            cellstr(num2str(transpose(find(v.track & v.trackActiv)))),...
            'Value', 1)
        
        setappdata(1, 'values', v)
    end
end
function trackLengthHist(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');
varList = {'Track Lengths', 'Bin Centers',...
    'Frequency Counts'};

fig =...
    figure(...
    'Units', 'normalized',...
    'Position', figPos(1),...
    'Name', 'Track Lifetime Histogram',...
    'NumberTitle', 'off',...
    'Color', get(0,'defaultUicontrolBackgroundColor'),...
    'MenuBar', 'none',...
    'ToolBar', 'figure');

hToolBar = findall(fig,'Type','uitoolbar');
hToggleList = findall(hToolBar);
% delete(hToggleList([2 3 5 6 7 9 10 11 12 16 17]))

uipushtool(hToolBar,...
    'CData', v.xlsExportIcon,...
    'ClickedCallback', {@varExport, fig, varList})

ax =...
    axes(...
    'Parent', fig,...
    'FontSize', 15,...
    'NextPlot','add');

minLength = str2double(get(h.minTrackLength, 'String'));
maxLength = str2double(get(h.maxTrackLength, 'String'));

if 1
    %based on lifetime (includes blinking)
    selection = v.trackLifeTime >= minLength...
        & v.trackLifeTime <= maxLength;
    tracksAnalysed = sum(selection);
    data = v.trackLifeTime(selection);
else
    %based on number of detection (excludes blinking)
    selection = v.trackLength >= minLength...
        & v.trackLength <= maxLength;
    tracksAnalysed = sum(selection);
    data = v.trackLength(selection);
end
if 0
[freq bin] = hist(data, calcnbins(data,'fd'));
else
[freq bin] = ksdensity(data,'function','survivor');
end
%calculate track half-life time
fitHalfLife = fit(bin',freq','exp2');
yhat = feval(fitHalfLife,bin);

bar(ax,bin,freq,'hist');
plot(bin,yhat,'color','r','linewidth',2)
legend(sprintf('Average Lifetime ~ %.0f Frames',...
    -1/fitHalfLife.b))

axis tight
title(['Analyzing ' num2str(tracksAnalysed) ' out of ' ...
    num2str(v.tracksTotal) ' Trajectories']);
xlabel('Trajectory Lifetime [Frames]'); ylabel('Frequency');
end
function exportTracks(src,event)
v = getappdata(1, 'values');
h = getappdata(1, 'handles');
    contents = get(h.fileList, 'String');
        [filename,pathname,isOK] =...
            uiputfile('.txt' ,...
            'Save Tracking Tables to',...
            contents{1}(1:end-4));
if isOK
data = vertcat(v.data{v.track & v.trackActiv});
dlmwrite([pathname filename], data,...
    'delimiter', '\t','precision',8, 'newline', 'pc')
msgbox('Done!');

end
end

function showData(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

% plot track map
fig =...
    figure(...
    'Units', 'normalized',...
    'Position', figPos(1),...
    'Name', 'Ensemble Data Overview',...
    'NumberTitle', 'off',...
    'Color', get(0,'defaultUicontrolBackgroundColor'),...
    'MenuBar', 'none',...
    'ToolBar', 'figure');

hToolBar = findall(fig,'Type','uitoolbar');
hToggleList = findall(hToolBar);
uitoggletool(...
        'Parent', hToolBar,...
        'CData', repmat(rand(16), [1 1 3]),...
        'ClickedCallback', @putBackground)
delete(hToggleList([2 3 6 7 8 9 10 13 16 17]))

ax =...
    axes(...
    'Parent', fig,...
    'FontSize', 15,...
    'NextPlot','add');

binFactor = str2double(get(h.pixelBinning, 'String'));
switch get(h.colorcodingPopup, 'Value')
    case 1
        % colorcode by frame
        cmap = jet(v.settings.Frames);
        endPoints = [cumsum(v.trackLength(v.track & v.trackActiv))...
            size(v.trackList,1)];
        for frame = 1:v.settings.Frames-1
            iStart = find(v.trackList(:,3) == frame);
            iStart = iStart(~ismember(iStart,endPoints));
            iEnd = find(v.trackList(:,3) == frame+1 & ...
                ismember(v.trackList(:,4),v.trackList(iStart,4)));
            good = ismember(iStart,iEnd-1);
            x = [v.trackList(iStart(good),1),v.trackList(iEnd,1), nan(sum(good),1)]';
            y = [v.trackList(iStart(good),2),v.trackList(iEnd,2), nan(sum(good),1)]';
            line(1+ x(:)/binFactor, 1+ y(:)/binFactor,...
                'Color', cmap(frame,:), 'Parent', ax);
            if ~all(good)
                iBlink = iStart(good == 0);
                iBlink = iBlink(ismember(v.trackList(iBlink,4),v.trackList(1+iBlink,4)));
                x = [v.trackList(iBlink,1),v.trackList(1+iBlink,1), nan(size(iBlink))]';
                y = [v.trackList(iBlink,2),v.trackList(1+iBlink,2), nan(size(iBlink))]';
                line(1+ x(:)/binFactor, 1+ y(:)/binFactor,...
                    'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5, 'Parent', ax);
            end %if
        end %for
        
        hCbar = colorbar;
        set(hCbar,'YTick', 0:5:65)
        set(hCbar,'YTickLabel', round(v.settings.Frames/14:...
            v.settings.Frames/14:v.settings.Frames))
        label = 'Frame';
    case 2
        % colorcode by track
        cmap = lines(sum(v.track & v.trackActiv));
        xCoords = nan(v.settings.Frames,numel(v.track & v.trackActiv));
        yCoords = nan(v.settings.Frames,numel(v.track & v.trackActiv));
        n = 1;
        for N = find(v.track & v.trackActiv)
            xCoords(v.data{N}(:,3),n) = v.data{N}(:,1);
            yCoords(v.data{N}(:,3),n) = v.data{N}(:,2);
            n = n +1;
        end %for
        for N = 2:v.settings.Frames
            xCoords(N,isnan(xCoords(N,:))) = xCoords(N-1,isnan(xCoords(N,:)));
            yCoords(N,isnan(yCoords(N,:))) = yCoords(N-1,isnan(yCoords(N,:)));
        end %for
        line(xCoords/binFactor +1,yCoords/binFactor +1, 'Parent', ax);
        
        hCbar = colorbar;
        colormap(cmap)
        label = 'Track [id]';
    case 3
        % colorcode by track length
        cmap = jet(max(v.trackLength(v.track & v.trackActiv)));
        xCoords = nan(v.settings.Frames,numel(v.track & v.trackActiv));
        yCoords = nan(v.settings.Frames,numel(v.track & v.trackActiv));
        n = 1;
        for N = find(v.track & v.trackActiv)
            xCoords(v.data{N}(:,3),n) = v.data{N}(:,1);
            yCoords(v.data{N}(:,3),n) = v.data{N}(:,2);
            n = n +1;
        end %for
        for N = 2:v.settings.Frames
            xCoords(N,isnan(xCoords(N,:))) = xCoords(N-1,isnan(xCoords(N,:)));
            yCoords(N,isnan(yCoords(N,:))) = yCoords(N-1,isnan(yCoords(N,:)));
        end %for
        for N = 1:max(v.trackLength(v.track & v.trackActiv))
            good = ismember(v.trackLength(v.track & v.trackActiv), N);
            line(xCoords(:,good)/binFactor +1, yCoords(:,good)/binFactor +1,...
                'Color', cmap(N,:), 'Parent', ax);
        end %for
        
        hCbar = colorbar;
        colormap(jet)
        set(hCbar,'YTick', 0:5:65)
        set(hCbar,'YTickLabel', round(max(v.trackLength)/14:...
            max(v.trackLength)/14:max(v.trackLength)))
        label = 'Length [frames]';
    case 4
        %detection density map
        ctrs{1} = 0.5*binFactor:1*binFactor:v.settings.Height;
        ctrs{2} = 0.5*binFactor:1*binFactor:v.settings.Width;
        frequency_matrix = hist3([v.trackList(:,2) v.trackList(:,1)],ctrs);
        imagesc(log(frequency_matrix+1));
        
        hCbar = colorbar;
        colormap(flipud(gray(256)))
        set(hCbar,'YTickLabel', round(exp(get(hCbar, 'YTick')) -1))
        label = 'Detectiondensity';
    case 5
        %Local Diff Coeff
        ensembleWinAnalysis(ax)
        label = 'Local Diff. Coeff.';
end %switch

xlabel('x-coordinate [px]'); ylabel('y-coordinate [px]');
axis equal ij
xlim ([0 v.settings.Width/binFactor]);
ylim([0 v.settings.Height/binFactor])

cbar = cbfreeze;
cblabel(cbar,label)
    function putBackground(src,event)
[filename, pathname, isOK] = uigetfile(...
    '*.tif', 'Select Background Images',...
    getappdata(1,'searchPath'));
if isOK
    setappdata(1, 'searchPath', pathname)
    im = imread([pathname filename],1);
    imshow(im, [min(min(im)) max(max(im))],'Parent',ax);
    set(ax,'Children', flipud(get(ax,'Children')))
end %if
    end
end
function selectTrackFromMap(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

% plot track map
fig =...
    figure(...
    'Units', 'normalized',...
    'Position', figPos(1),...
    'Toolbar', 'figure',...
    'MenuBar', 'none',...
    'NumberTitle', 'off',...
    'Color', get(0,'defaultUicontrolBackgroundColor'),...
    'Name', 'select Track for further Analysis');
ax =...
    axes(...
    'Parent', fig,...
    'FontSize', 15);

hToolBar = findall(fig,'Type','uitoolbar');
hToggleList = findall(hToolBar);
delete(hToggleList([2 3 4 5 6 7 8 9 10 13 14 16 17 18]))

xCoords = nan(v.settings.Frames,numel(v.track & v.trackActiv));
yCoords = nan(v.settings.Frames,numel(v.track & v.trackActiv));
n = 1;
for N = find(v.track & v.trackActiv)
    xCoords(v.data{N}(:,3),n) = v.data{N}(:,1);
    yCoords(v.data{N}(:,3),n) = v.data{N}(:,2);
    n = n +1;
end %for
for N = 2:v.settings.Frames
    xCoords(N,isnan(xCoords(N,:))) = xCoords(N-1,isnan(xCoords(N,:)));
    yCoords(N,isnan(yCoords(N,:))) = yCoords(N-1,isnan(yCoords(N,:)));
end %for
line(xCoords +1,yCoords +1, 'Parent', ax);

axis equal ij
xlim ([0 v.settings.Width]); ylim([0 v.settings.Height])
xlabel('x-coordinate [px]'); ylabel('y-coordinate [px]');

set(gca, 'ButtonDownFcn', @selectTrack)

    function selectTrack(src, event)
        [x,y] = ginput(1);
        neighbor = (v.trackList(:,1) - x).^2 + (v.trackList(:,2) - y).^2;
        trackID = v.trackList(neighbor == min(neighbor),4);
        
        contents = get(h.selectedTrackPopup, 'String');
        set(h.selectedTrackPopup, 'Value',...
            find(str2num(vertcat(contents{:})) == trackID))
    end
end
function selectTrackFromList(src, event)
v = getappdata(1, 'values');

figure(...
    'Units', 'normalized',...
    'Position', [0 0 1 1],...
    'MenuBar', 'none',...
    'Toolbar', 'none',...
    'NextPlot', 'add',...
    'Color', get(0,'defaultUicontrolBackgroundColor'),...
    'Name', 'Trajectory List',...
    'NumberTitle', 'off')

stepSize = 1/floor(sum(v.track)/20);
if isinf(stepSize)
    stepSize = 0;
end %if

uicontrol(...
    'Style', 'slider',...
    'Units', 'normalized',...
    'Position', [0.98 0 0.01 1],...
    'Min', 0,...
    'Max', ceil(sum(v.track)/20)-1,...
    'Value', ceil(sum(v.track)/20)-1,....
    'SliderStep', [stepSize stepSize],...
    'CreateFcn', @showList,...
    'Callback', @showList);

    function showList(src, event)
        h = getappdata(1, 'handles');
        v = getappdata(1, 'values');
        
        delete(findobj(gcf, 'Type', 'axes',...
            '-or', 'Style', 'popupmenu'))
        count = 1+(ceil(sum(v.track)/20)-...
            round(get(src, 'Value'))-1)*20;
        idx = find(v.track);
        for n = 0.8:-0.25:0
            for m = 0:0.2:0.8
                if count > numel(idx)
                    return
                end %if
                axes(...
                    'Position', [0 0 1 1],...
                    'OuterPosition', [m n 0.2 0.2],...
                    'NextPlot', 'replace',...
                    'DataAspectRatio', [1 1 1]);
                
                hold on
                plot(v.data{idx(count)}(:,1)-min(v.data{idx(count)}(:,1)),...
                    v.data{idx(count)}(:,2)-min(v.data{idx(count)}(:,2)),...
                    'LineWidth', 1)
                title(['Track Nr: ' num2str(idx(count))],...
                    'userdata', idx(count),...
                    'ButtonDownFcn', @showOverview)
                axis ij tight off
                ax = axis;
                line([ax(1),ax(1)+1], [ax(3),ax(3)], 'Color', 'r',...
                    'LineWidth', 4)
                
                switch v.trackActiv(idx(count))
                    case 1
                        status = 1;
                        color = [0 1 0];
                    case 0
                        status = 2;
                        color = [1 0 0];
                end %switch
                uicontrol(...
                    'Style', 'popupmenu',...
                    'Units', 'normalized',...
                    'Position', [m+0.05 n 0.1 0.02],...
                    'String', {'active', 'excluded'},...
                    'FontSize', 9,...
                    'Value', status,...
                    'UserData', idx(count),...
                    'BackgroundColor', color,...
                    'Callback', {@setTraceStatus, h});
                
                count = count +1;
            end %for
        end %for
    end
    function setTraceStatus(src, event, h)
        v = getappdata(1, 'values');
        
        trackID = get(src, 'UserData');
        switch get(src, 'Value')
            case 1
                set(src, 'BackgroundColor', [0 1 0])
                v.trackActiv(trackID) = true;
                v.trackList = vertcat(v.data{v.track & v.trackActiv});
            case 2
                set(src, 'BackgroundColor', [1 0 0])
                v.trackActiv(trackID) = false;
                v.trackList(v.trackList(:,4) == trackID,:) = [];
        end %switch
        save(char(get(h.fileList, 'String')),...
            '-struct', 'v', 'trackActiv', '-append')
        
        set(h.percentExcluded, 'String', ...
            round(sum(v.trackLength(~(v.trackActiv & v.track)))/...
            sum(v.trackLength)*100))
        set(h.selectedTrackPopup, 'String',...
            cellstr(num2str(transpose(find(v.track & v.trackActiv)))),...
            'Value', 1)
        
        %             setappdata(1, 'handles', h)
        setappdata(1, 'values', v)
    end
end
function showOverview(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

if strcmp(get(src,'type'),'text')
    selection = ...
        str2double(get(h.selectedTrackPopup,'String')) ==...
        get(src,'userdata');
    set(h.selectedTrackPopup,'value',find(selection))
end %if

trackID = get(h.selectedTrackPopup, {'String', 'Value'});
switch get(src, 'Tag')
    case 'previous'
        if trackID{2} > 1
            trackID{2} = trackID{2} -1;
            set(h.selectedTrackPopup, 'Value', trackID{2})
            clf
        end %if
    case 'next'
        if trackID{2} < numel(trackID{1})
            trackID{2} = trackID{2} +1;
            set(h.selectedTrackPopup, 'Value', trackID{2})
            clf
        end %if
    otherwise
        figure(...
            'Units', 'normalized',...
            'Position', [0 0 1 1],...
            'Color', get(0,'defaultUicontrolBackgroundColor'),...
            'ToolBar', 'none',...
            'MenuBar', 'none',...
            'Name', 'Trajectory Overview',...
            'NumberTitle', 'off');
end %switch
trackID = str2double(cell2mat(trackID{1}(trackID{2})));

x = repmat(v.data{trackID}(:,1),1,v.trackLength(trackID));
y = repmat(v.data{trackID}(:,2),1,v.trackLength(trackID));
frame = repmat(v.data{trackID}(:,3),1,v.trackLength(trackID));

good = tril(true(v.trackLength(trackID)),-1);
dxPos = (x(good)-x(flipud(good))).*v.px2micron;
dyPos = (y(good)-y(flipud(good))).*v.px2micron;

singleTrackSD = dxPos.^2 + dyPos.^2;
stepLength = frame(good)-frame(flipud(good));

singleTrackMSD = nonzeros(accumarray(stepLength,...
    singleTrackSD,[],@nanmean));

nObs = nonzeros(accumarray(stepLength,1));
n = unique(stepLength);
if 1
%Quian et al.
take = nObs >= max(nObs)/2;
errMSD(take,1) = sqrt((4*n(take).^2.*nObs(take)+2.*nObs(take)+n(take)-n(take).^3)./(6.*n(take).*nObs(take).^2));
errMSD(~take,1) = sqrt(1+(nObs(~take).^3-4.*n(~take).*nObs(~take).^2+4.*n(~take)-nObs(~take))./(6.*n(~take).^2.*nObs(~take)));
errMSD = singleTrackMSD.*errMSD;
else
    errMSD = accumarray(stepLength,...
    singleTrackSD,[],@nanstd);    
errMSD = errMSD(n)./nObs;
end
%preallocate space
moment = mat2cell(zeros(v.trackLength(trackID),6),...
    v.trackLength(trackID),ones(1,6));

% mean moment displacements (mmd)
moment{1} = log(nonzeros(accumarray(stepLength,abs(dxPos)...
    + abs(dyPos),[],@mean)));
moment{2} = log(singleTrackMSD);
moment{3} = log(nonzeros(accumarray(stepLength,abs(dxPos.^3)...
    + abs(dyPos.^3),[],@mean)));
moment{4} = log(nonzeros(accumarray(stepLength,dxPos.^4 ...
    + dyPos.^4,[],@mean)));
moment{5} = log(nonzeros(accumarray(stepLength,abs(dxPos.^5)...
    + abs(dyPos.^5),[],@mean)));
moment{6} = log(nonzeros(accumarray(stepLength,dxPos.^6 ...
    + dyPos.^6,[],@mean)));

logTime = log(unique(stepLength)*v.settings.Delay);

% calculate a robust fit (log(mmd) vs log(t)) for 1/3 (max 10 steps) of track
trackCutOff = 5;
fitMoments = cell2mat(cellfun(@(x) robustfit(logTime(1:trackCutOff),...
    x(1:trackCutOff)),moment,'Un',0));

% theoretical diffuison constant (considering a free diffusion model)
singleTrackD = 0.25*exp(fitMoments(3));

% fitting mean scaling spectrum vs. moments
s = fitoptions('Method', 'LinearLeastSquares',...
    'Lower',[-1,-Inf],...
    'Upper', [1,Inf],...
    'Robust', 'on');

f = fittype({'moment','1'},...
    'coefficients', {'slope','intercept'},...
    'options', s,...
    'independent', 'moment');

[fitMSS, statsMSS] = fit ((1:6)',fitMoments(2,1:6)',f);

singleTrackMSS = fitMSS.slope;
singleTrackMSSadjrsquare = statsMSS.adjrsquare;

% angle between steps (theta(n+1) - theta(n), neg. deg. = left turn)
singleTrackStepAngle = [nan; diff(atan2(dyPos(1:v.trackLength(trackID)),...
    dxPos(1:v.trackLength(trackID))))*180/pi];
singleTrackStepAngle(singleTrackStepAngle < -180) = ...
    singleTrackStepAngle(singleTrackStepAngle < -180) + 360;
singleTrackStepAngle(singleTrackStepAngle > 180) = ...
    singleTrackStepAngle(singleTrackStepAngle > 180) - 360;

singleTrackStepAngleMedians = ...
    [median(singleTrackStepAngle(singleTrackStepAngle < 0)),...
    median(singleTrackStepAngle(singleTrackStepAngle > 0))];

trackIndex = 1:v.trackLength(trackID);
blinkIndex = [stepLength(1:v.trackLength(trackID)-1) > 1; false];

%MSS Plot
hSub{2} = subplot(...
    'Position', [0.050, 0.11, 0.2368, 0.34]);
plot(fitMSS,'r',(1:6),fitMoments(2,1:6), 'o')
axis tight
title(['MSS: ' num2str(fitMSS.slope,'%.3f') ' (R^2: ' ...
    num2str(statsMSS.adjrsquare,'%.3f') ')'])
xlabel('Moment'); ylabel('Gamma')
ylim([0 5])
legend off

%Trajectory Plot
hSub{1} = subplot('Position', [0.050, 0.5682, 0.2368, 0.34]);
minX = min(v.data{trackID}(:,1));
minY = min(v.data{trackID}(:,2));
hold on
plot(1000*v.px2micron*(v.data{trackID}(:,1)-minX),...
    1000*v.px2micron*(v.data{trackID}(:,2)-minY))
h = plot(1000*v.px2micron*([v.data{trackID}(blinkIndex,1)';...
    v.data{trackID}([false; blinkIndex(1:end-1)],1)']-minX),...
    1000*v.px2micron*([v.data{trackID}(blinkIndex,2)';...
    v.data{trackID}([false; blinkIndex(1:end-1)],2)']-minY), 'r');
trackPlotBlink = hggroup;
set(h,'Parent',trackPlotBlink)
set(get(get(trackPlotBlink,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','on');
plot(1000*v.px2micron*(v.data{trackID}(1,1)-minX),...
    1000*v.px2micron*(v.data{trackID}(1,2)-minY),'ro')
hold off
% legend('Track', 'Blink', 'Start', 'Orientation', 'horizontal')
axis equal tight ij
title(['Track Nr: ' num2str(trackID)])
xlabel('x Position [nm]'); ylabel('y Position [nm]')

%MSD vs. Time Plot
hSub{3} = subplot('Position', [0.3491, 0.7673, 0.6109, 0.1577]);
hold on
errorbar(unique(stepLength)*v.settings.Delay,...
    singleTrackMSD,errMSD, 'o:')
plot(unique(stepLength)*v.settings.Delay,...
    smooth(singleTrackMSD), 'r')
plot([trackCutOff*v.settings.Delay ...
    trackCutOff*v.settings.Delay],...
    [min(singleTrackMSD-errMSD)...
    max(singleTrackMSD+errMSD)], 'r:')
text(trackCutOff*v.settings.Delay , ...
    max(singleTrackMSD+errMSD),...
    sprintf('\n  cut off'), 'Color', 'r', 'FontSize', 13)
hold off
axis tight
title(['Diffusion Coefficient: ' num2str(singleTrackD,'%.3f') ' ?m^2/s; ' ...
    'alpha = ' num2str(fitMoments(4),'%.2f')])
xlabel('Time [s]'); ylabel('MSD [?m^2]')

%OneStep Displacement vs. Position Plot
hSub{4} = subplot('Position', [0.3491, 0.5482, 0.35, 0.1577]);
data = [sqrt(singleTrackSD(1:v.trackLength(trackID)-1))*1000; nan];
hold on
plot(trackIndex, data, 'bo:')
plot(trackIndex(blinkIndex), data(blinkIndex), 'rx')
plot(trackIndex, smooth(data),'r')
% legend ('Displacement', 'Blink', 'Smooth', 'Orientation', 'horizontal')
axis tight
xlabel('Vector Position'); ylabel('Displacement [nm]')

hSub{5} = subplot('Position', [0.76, 0.5482, 0.2, 0.1577]);
hist(sqrt(singleTrackSD(1:v.trackLength(trackID)))*1000,...
    calcnbins(sqrt(singleTrackSD(1:v.trackLength(trackID)))*1000, 'fd'))
xlabel('Displacement [nm]'); ylabel('Frequency')
axis tight

%Intensity vs. Position Plot
hSub{8} = subplot('Position', [0.3491, 0.1100, 0.35, 0.1577]);
%         photons = (v.data{trackID}(:,5)/(sqrt(pi)*imageBin.psf))*...
%             2*pi*imageBin.psf^2*imageBin.cnts2photon;
volume = v.data{trackID}(:,5)/...
    (sqrt(pi)*v.settings.TrackingOptions.GaussianRadius)*...
    2*pi.*v.settings.TrackingOptions.GaussianRadius.^2; %counts
hold on
plot(trackIndex, volume, 'bo:')
plot(trackIndex, smooth(volume), 'r')
hold off
axis tight
xlim([0 v.trackLength(trackID)])
xlabel('Track Position'); ylabel('Signal [counts]')
% legend('Intensity', 'Offset', 'Orientation', 'horizontal')

hSub{9} = subplot('Position', [0.76, 0.1100, 0.2, 0.1577]);
precision =...
    calcLocPrecision(v.settings.TrackingOptions.GaussianRadius,...
    v.px2micron, volume, sqrt(v.data{trackID}(:,6)));

hist(precision*1000, calcnbins(precision, 'fd'))
xlabel('Localization Precision [nm]'); ylabel('Frequency')
axis tight

%Angle vs. Position Plot
hSub{6} = subplot('Position', [0.3491, 0.3291, 0.35, 0.1577]);
hold on
plot(trackIndex, singleTrackStepAngle, 'bo:')
% line([0, 0; v.trackLength(trackID), v.trackLength(trackID)],...
%     repmat(singleTrackStepAngleMedians,2,1), 'Color', 'r')
plot(trackIndex(singleTrackStepAngle > 0), ...
    smooth(singleTrackStepAngle(singleTrackStepAngle > 0)), 'r')
plot(trackIndex(singleTrackStepAngle < 0), ...
    smooth(singleTrackStepAngle(singleTrackStepAngle < 0)), 'r')
hold off
axis tight
xlim([0 v.trackLength(trackID)]); ylim([-180 180])
xlabel('Track Position'); ylabel('Vectors Angle [deg]')
set(gca, 'YTick', [-180 -90 0 90 180])

hLabel = cell2mat(get([hSub{:}], {'YLabel', 'XLabel', 'Title'}));
set(hLabel(:), 'FontSize', 13)

hSub{7} = subplot('Position', [0.76, 0.3291, 0.2, 0.1577]);
bar(-180:45:180, histc(singleTrackStepAngle, -180:45:180), 'histc')
xlabel('Vectors Angle [deg]'); ylabel('Frequency')
xlim([-180 180])

linkaxes([hSub{[4,6,8]}], 'x')
set([hSub{:}],'ButtonDownFcn', @increaseAx)

uicontrol(...
    'Style', 'pushbutton',...
    'Tag', 'previous',...
    'Units', 'normalized',...
    'Position', [0.048 0.475 0.025 0.05],...
    'String', '<',...
    'FontSize', 10,...
    'Callback', @showOverview)

uicontrol(...
    'Style', 'pushbutton',...
    'Tag', 'next',...
    'Units', 'normalized',...
    'Position', [0.262 0.475 0.025 0.05],...
    'String', '>',...
    'FontSize', 10,...
    'Callback', @showOverview)

uicontrol(...
    'Style', 'pushbutton',...
    'Tag', 'localizeTrackOnMap',...
    'Units', 'normalized',...
    'Position', [0.012 0.95 0.075 0.03],...
    'String', 'show position',...
    'FontSize', 10,...
    'Callback', {@localizeTrackOnMap, trackID})

uicontrol(...
    'Style', 'pushbutton',...
    'Tag', 'subTrackAnalysis',...
    'Units', 'normalized',...
    'Position', [0.097 0.95 0.075 0.03],...
    'String', 'Window Analysis',...
    'FontSize', 10,...
    'Callback', {@trackWinAnalysis, v.data{trackID}(:,1),...
    v.data{trackID}(:,2),v.data{trackID}(:,3),...
    16,v.settings.Delay,v.settings.px2micron,...
    v.data{trackID}(:,8)})

movieFilter =...
    uicontrol(...
    'Style', 'checkbox',...
    'Units','normalized',...
    'Position', [0.262 0.95 0.05 0.03],...
    'FontSize', 8,...
    'FontUnits', 'normalized',...
    'String', 'apply filter',...
    'Value', 0);

uicontrol(...
    'Style', 'pushbutton',...
    'Units','normalized',...
    'Position', [0.182 0.95 0.075 0.03],...
    'FontSize', 10,...
    'FontUnits', 'normalized',...
    'String', 'Track Movie',...
    'Callback', {@buildSingleTrackMovie,...
    trackID, movieFilter, v, h});

% uicontrol(...
%     'Style', 'pushbutton',...
%     'Tag', 'subTrackAnalysis',...
%     'Units', 'normalized',...
%     'Position', [0.167 0.95 0.075 0.03],...
%     'String', 'Window Analysis',...
%     'FontSize', 10,...
%     'Callback', @ensembleWinAnalysis)


    function localizeTrackOnMap(src, event, trackID)
        
        fig =...
            figure(...
            'Units', 'normalized',...
            'Position', figPos(1),...
            'Toolbar', 'none',...
            'MenuBar', 'none',...
            'NextPlot', 'add',...
            'Color', get(0,'defaultUicontrolBackgroundColor'),...
            'Name', 'Localization Map',...
            'NumberTitle', 'off');
        
        ax =....
            axes('Parent', fig,...
            'FontSize', 15);
        
        %plot tracks ensemble at once
        line(cell2mat(cellfun(@(x) [x(:,1);nan],...
            v.data(v.track)', 'Un',0)),...
            cell2mat(cellfun(@(x) [x(:,2);nan],...
            v.data(v.track)', 'Un',0)));
        
        line(v.data{trackID}(:,1), v.data{trackID}(:,2),...
            'Color', 'r', 'LineWidth', 2.5)
        
        axis('equal', 'ij',...
            [0 v.settings.Width 0 v.settings.Height])
        xlabel('x-coordinate [px]'); ylabel('y-coordinate [px]');
    end
    function increaseAx(src, event)
        fig =...
            figure(...
            'Units','normalized',...
            'Position', [0 0 1 1],...
            'NumberTitle', 'off',...
            'Color', get(0,'defaultUicontrolBackgroundColor'),...
            'MenuBar', 'none',...
            'ToolBar', 'figure');
        hToolBar = findall(fig,'Type','uitoolbar');
        hToggleList = findall(hToolBar);
        delete(hToggleList([2 3 4 5 6 7 8 9 10 16 17]))
        
        hObj = copyobj(src,fig);
        set(hObj, 'OuterPosition', [0 0 1 1],...
            'Position', [0.13 0.11 0.775 0.815])
    end
    function precision =...
            calcLocPrecision(psfStd, pxSize, photons, noise)
        %calculates the localization uncertainty based on
        %   psfStd, pxSize, photons, noise. (Thompson and Webb)
        
        psfStd = psfStd*pxSize; % px -> ?m
        precision = sqrt((psfStd.^2+pxSize^2/12)./photons+...
            8*pi.*psfStd.^4.*noise.^2/pxSize^2./photons.^2); %[?m]
    end
end
function ensembleStateAnalysis(src,event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

w = str2double(get(h.transitionAnalysisWin,'string'));
yThresh = str2double(get(h.transitionThresh,'string'));

good = find(v.track & v.trackActiv);
for N = good
    [nrSeg idxSeg ptsSeg lifeTime w] =...
        segmentTrack(v.data{N}(:,3),w);
    
    x = accumarray(1+v.data{N}(:,3)-v.data{N}(1,3),...
        v.data{N}(:,1),[lifeTime 1],[],nan);
    y = accumarray(1+v.data{N}(:,3)-v.data{N}(1,3),...
        v.data{N}(:,2),[lifeTime 1],[],nan);
    frame = (1:lifeTime)';
    
    [data take] =...
        evalLocalDiff(...
        x,...
        y,...
        frame,...
        w,...
        nrSeg,...
        idxSeg,...
        v.settings.Delay,...
        v.px2micron);
    
    [beginEvent endEvent lengthEvent{N}...
        beginGround endGround lengthGround{N}] =...
        getConfBounds(data(take)',...
        yThresh, 1);
    
    %filter eventstate
    if ~isempty(lengthEvent{N})
        if lengthEvent{N} == numel(data(take))
            %discard if no transition
            lengthEvent{N} = [];
        else
            if any(beginEvent == 1)
                %discard if beginn of event is not observed
                lengthEvent{N}(1) = [];
            end %if
            if any(endEvent == numel(data(take)))
                %discard if end of event is not observed
                lengthEvent{N}(end) = [];
            end %if
        end %if
    end %if
    %filter groundstate
    if ~isempty(lengthGround{N})
        if lengthGround{N} == numel(data(take))
            %discard if no transition
            lengthGround{N} = [];
        else
            if any(beginGround == 1)
                %discard if beginn of event is not observed
                lengthGround{N}(1) = [];
            end %if
            if any(endGround == numel(data(take)))
                %discard if end of event is not observed
                lengthGround{N}(end) = [];
            end %if
        end %if
    end %if
    
    %ROC Curve
%     measureBinary = data(take)' <= yThresh;
%     simBinary = v.data{N}(take,8) > 1.5;
%     TP{N} = sum(measureBinary & simBinary);
%     TN{N} = sum(~measureBinary & ~simBinary);
%     FN{N} = sum(~measureBinary & simBinary);
%     FP{N} = sum(measureBinary & ~simBinary);
        
        %count # missed detections
%     [beginEventSim endEventSim lengthEventSim...
%         beginGroundSim endGroundSim lengthGroundSim] =...
%         getConfBounds(v.data{N}(take,8),...
%         1.5, 1);

%     errCnt{N} = [0 0];
%     detectCnt{N} = 0;
%     if isempty(lengthGround{N})
%         errCnt{N}(2) = 10;
%     else
%             detections = numel(lengthGround{N});
%             isFalseDetected = true(1,detections);
% 
%         for pulse = 1:10
%             pulseDetected = false;
%             coveredFramesSim = beginEventSim(pulse):endEventSim(pulse);
%             
%             for detection = 1:detections
%                 coveredFrames = beginGround(detection):endGround(detection);
%                 good = ismember(coveredFramesSim,coveredFrames);
%                 if any(good)
%                     detectCnt{N} = detectCnt{N} + 1;
%                     
%                     %simulated pulse has been detected
%                     pulseDetected = true;
%                     
%                     %current detection is true detection
%                     isFalseDetected(detection) = false;
%                     
%                     %calculate ratio of measured tau to simulated tau
%                     detectionAcc{N}(detectCnt{N}) =...
%                         lengthGround{N}(detection)/lengthEventSim(5);
%                 end
%             end
%             
%             % # pulses not detected
%             if ~pulseDetected
%                errCnt{N}(2) = errCnt{N}(2) + 1;
%             end
%             
%         end
%         % # of false detection
%         errCnt{N}(1) = sum(isFalseDetected);
%     end

end %for
lengthEvent = vertcat(lengthEvent{:});
lengthGround = vertcat(lengthGround{:});

% Save the Ground and Free states for the building transitions histograms
if 1
           [filename,pathname,isOK] =...
            uiputfile('' ,'Save Data',getappdata(1,'searchPath'));
        fid = fopen([pathname, filename '_lengthEvent.txt'],'w+');
        fprintf(fid,'%g \t\n', lengthEvent)
        fclose(fid)
        fid = fopen([pathname, filename 'lengthGround.txt'],'w+');
        fprintf(fid,'%g \t\n', lengthGround)
fclose(fid)
end

% End of save the Ground and Free states for the building transitions histograms

% if 1
%     errCnt = sum(vertcat(errCnt{:}))./[1 1000];
%     horzcat(detectionAcc{:})
% end

figure;
hold on
% [f(:,1) xi(:,1)] = ksdensity(lengthGround,'function',@exppdf);
% [f(:,2) xi(:,2)] = ksdensity(lengthEvent*...
%     v.settings.Delay,'kernel','epanechnikov','support','positive','function','survivor');
% h = bar(xi, f);

ctrs = (1:max(max(lengthGround),max(lengthEvent)));
% ctrs = linspace(v.settings.Delay,...
%     max(max(lengthGround),max(lengthEvent))*v.settings.Delay,100)
h = bar(ctrs, [hist(lengthGround,ctrs);...
    hist(lengthEvent,ctrs)]','hist');

[fitGround ciGround] = expfit(lengthGround*v.settings.Delay)
[fitEvent ciEvent] = expfit(lengthEvent*v.settings.Delay)

try
fitGround = fit(ctrs',hist(lengthGround,ctrs)','exp1');
plot(ctrs,feval(fitGround,ctrs),'b-',...
    'DisplayName', sprintf('A0 = %.1f; tau = %.1f sec',...
    fitGround.a,-1/fitGround.b),'LineWidth', 2)
catch
    sprintf('fitting ground state failed')
end
try
fitEvent = fit(ctrs',hist(lengthEvent,ctrs)','exp1');
plot(ctrs,feval(fitEvent,ctrs),'r-',...
    'DisplayName', sprintf('A0 = %.1f; tau = %.1f sec',...
    fitEvent.a,-1/fitEvent.b),'LineWidth', 2)
catch
    sprintf('fitting event state failed')
end
set(h(1), 'EdgeColor', 'b', 'DisplayName', 'Ground')
set(h(2), 'EdgeColor', 'r', 'DisplayName', 'Event')

legend('Location', 'NorthEast')
axis tight
xlabel('Time [s]'); ylabel('Frequency');

end
function ensembleWinAnalysis(ax)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

w = str2double(get(h.transitionAnalysisWin,'string'));

ymin = inf; ymax = -inf;
good = find(v.track & v.trackActiv);
for N = good
    [nrSeg idxSeg ptsSeg lifeTime] =...
        segmentTrack(v.data{N}(:,3),w);
    
    x{N,1} = accumarray(1+v.data{N}(:,3)-v.data{N}(1,3),...
        v.data{N}(:,1),[lifeTime 1],[],nan);
    y{N,1} = accumarray(1+v.data{N}(:,3)-v.data{N}(1,3),...
        v.data{N}(:,2),[lifeTime 1],[],nan);
    frame = (1:lifeTime)';
    
    [data{N} take{N}] =...
        evalLocalDiff(...
        x{N},...
        y{N},...
        frame,...
        w,...
        nrSeg,...
        idxSeg,...
        v.settings.Delay,...
        v.px2micron);
    ymin = min(min(data{N}(take{N})),ymin);
    ymax = max(max(data{N}(take{N})),ymax);
    
end %for

cmap = jet(256);
set(ax,...
    'CLim', [ymin ymax],...
    'Fontsize', 15);

for N = good
    take{N} = find(take{N});
    
    [unused cIdx{N}] = histc(data{N}(take{N}),...
        linspace(ymin,ymax,256));
    
    %plot trajectory            
    hLine{N} = plot([x{N}(take{N}),x{N}([take{N}(2:end) take{N}(end)+1])]',...
        [y{N}(take{N}),y{N}([take{N}(2:end) take{N}(end)+1])]',...
        'Parent', ax(1));
end
hLine = vertcat(hLine{:});
    set(hLine,{'Color'},mat2cell(cmap(horzcat(cIdx{:}),:),...
        ones(numel(horzcat(take{:})),1),3))
end

function trackWinAnalysis(src,event,x,y,frame,w,lagTime,px2micron,trueBinary)
h = getappdata(1, 'handles');

w = str2double(get(h.transitionAnalysisWin,'string'));
yThresh = str2double(get(h.transitionThresh,'string'));

[nrSeg idxSeg ptsSeg lifeTime w] = segmentTrack(frame,w);

x = accumarray(1+frame-frame(1),x,[lifeTime 1],[],nan);
y = accumarray(1+frame-frame(1),y,[lifeTime 1],[],nan);
frame = (1:lifeTime)';

[data take] =...
    evalLocalDiff(...
    x,...
    y,...
    frame,...
    w,...
    nrSeg,...
    idxSeg,...
    lagTime,...
    px2micron);

%         plot(x,y,'k')
%     [unused cIdx] = histc(log(Dlocal(2,:)),...
%         linspace(min(log(Dlocal(2,:))),...
%         max(log(Dlocal(2,:))),256));
%     seg = 1;
%                hSeg = plot(x(idxSeg(:,seg)),y(idxSeg(:,seg)),...
%                'Color', cmap(cIdx(seg),:),...
%                'LineWidth', 2);
%     while ishandle(hfig)
%            seg = seg+1;
%            set(hSeg,...
%                'XData', x(idxSeg(:,seg)),...
%                'YData', y(idxSeg(:,seg)),...
%                'Color', cmap(cIdx(seg),:))
%            pause(0.01)
%            if seg == nrSeg
%                seg = 0;
%            end
%     end %for

% data = [data{:}];
% take = logical([take{:}]);
take = find(take);
ymin = min(data(take));
ymax = max(data(take));

cmap = jet(256);
[unused cIdx] = histc(data(take),...
    linspace(ymin,ymax,256));

figure(...
    'Color', get(0,'defaultUicontrolBackgroundColor'));
ax(1) = axes(...
    'OuterPosition', [0 0.3 1 0.7],...
    'CLim', [ymin ymax],...
    'Fontsize', 15);

ax(2) = axes(...
    'OuterPosition', [0 0 1 0.3],...
    'NextPlot', 'add',...
    'Fontsize', 15);

%plot trajectory
hLine = line(px2micron*[x(take),x([take(2:end) take(end)+1])]',...
    px2micron*[y(take),y([take(2:end) take(end)+1])]',...
    'Parent', ax(1));
set(hLine,{'Color'},mat2cell(cmap(cIdx,:),...
    ones(numel(take),1),3))
axis(ax(1),'image', 'ij')
xlabel(ax(1), 'x Position [?m]')
ylabel(ax(1), 'y Position [?m]')

%generate colorbar
x = [zeros(1,256); ones(1,256)*lifeTime-2];
y = repmat(linspace(min(data(take)),...
    max(data(take)),256),2,1);
vertices = [x(:) y(:) zeros(512,1)];
face = repmat([1 3 4 2],255,1)+...
    repmat((0:2:508)',1,4);

patch('Faces',face,'Vertices',vertices,...
    'FaceVertexCData', jet(255),...
    'FaceColor', 'flat',...
    'FaceAlpha', 0.5,...
    'EdgeColor', 'none',...
    'Parent', ax(2));

%plot running window analysis
plot(take,data(take),...
    'Color', [0 0 0],...
    'LineWidth', 2,...
    'Parent', ax(2))

dataBinary(data(take) >= yThresh) = ymax;
dataBinary(data(take) < yThresh) = ymin;
stairs(take,dataBinary,...
    'Color', [0.75 0 0.75],...
    'LineWidth', 2,...
    'LineStyle', '-',...
    'Parent', ax(2))

%show simulated state sequence
% trueBinary = trueBinary(take);
% trueBinary(trueBinary == 1) = ymax;
% trueBinary(trueBinary == 2) = ymin;
% stairs(take,trueBinary,...
%     'Color', [1 1 0],...
%     'LineWidth', 3,...
%     'LineStyle', '--',...
%     'Parent', ax(2))

axis(ax(2),'tight')
xlabel(ax(2), 'Position')
ylabel(ax(2), 'D(local) [?m^2/s]')

%Dlocal(ptsSeg < w/2) = nan; %discard if less than w/2 ponts inside w
end
function [output, take] =...
    evalLocalDiff(x,y,frame,w,nrSeg,idxSeg,lagTime,px2micron)
%Calculates the local Diffusion inside moving timewindow
%
%
% INPUT:
%           x (Vector; x-coordinates [px])
%           y (Vector; y-coordinates [px])
%           lagTime(scalar; [s])
%           w (scalar; calculation Window [Frames])
%
% OUTPUT:
%           D (Vector of Diffusion Coefficients)
%
% written by C.P.Richter
% version 10.06.12

iMat = repmat(idxSeg(:,1),1,w);
good = tril(true(w),-1);
ii = iMat(good);
iii = iMat(flipud(good));

iSeg = repmat(0:nrSeg-1,sum(idxSeg(1:end-1,1)),1);
ii = repmat(ii,1,nrSeg)+iSeg;
iii = repmat(iii,1,nrSeg)+iSeg;

for moment = 2
    sd = ((x(ii)-x(iii)).^moment +...
        (y(ii)-y(iii)).^moment)*px2micron^moment;
    stepLength = frame(ii)-frame(iii);
    
    stepLength = stepLength(w:6*w-21,:); %analyse 2:6 steps
    sd = sd(w:6*w-21,:);
    
    subs = bsxfun(@plus,stepLength,0:5:(nrSeg-1)*5)-1;
    mmd = reshape(accumarray(subs(:),...
        sqrt(sd(:).^2),[],@nanmean), 5, nrSeg);
    %     t = 4*(2:6)'*lagTime;
    
    t = [ones(5,1) log(4*(2:6)*lagTime)'];
    % mean moment displacement = Dlocal*4t^AnomalousCoeff
    yHat = t\log(mmd);
    Dlocal(moment,:) = exp(yHat(1,:));
    AnomalousCoeff(moment,:) = yHat(2,:);
    
    %     for seg = 1:nrSeg
    %     result = fit(4*(2:6)'*lagTime,mmd(:,seg),'power2');
    %     fitPower2(:,seg) = coeffvalues(result);
    %     result = fit(4*(2:6)'*lagTime,mmd(:,seg),'poly1');
    %     fitLin(:,seg) = coeffvalues(result);
    %
    %     fig = figure;
    %     hold on
    %     title(num2str(seg))
    %     plot(4*(2:6)'*lagTime,mmd(:,seg),'ko')
    %     plot(4*(2:6)'*lagTime,...
    %         4*fitLin(1,seg)*(2:6)'*lagTime+fitLin(2,seg),'g-')
    %     plot(4*(2:6)'*lagTime,...
    %         Dlocal(moment,seg)*(4*(2:6)'*lagTime).^AnomalousCoeff(moment,seg),'b-')
    %     plot(4*(2:6)'*lagTime,...
    %         fitPower2(1,seg)*(4*(2:6)'*lagTime).^fitPower2(2,seg)+fitPower2(3,seg),'r-')
    %     waitforbuttonpress
    %     delete(fig)
    %     end %for
    
    %     SST = sum(bsxfun(@minus,log(mmd),...
    %         mean(log(mmd))).^2);
    %     SSR = sum((log(mmd)-...
    %         t*yHat).^2);
    %     Rsquare = 1-SSR./SST;
    %     Dlocal(moment,Rsquare < 0.9) = nan;
    
end

%calculate degree of self similarity
%     mss = [ones(5,1) (1:5)']\AnomalousCoeff;
%
%     SST = sum(bsxfun(@minus,AnomalousCoeff,...
%         mean(AnomalousCoeff)).^2);
%     SSR = sum((AnomalousCoeff-...
%         [ones(5,1) (1:5)']*mss).^2);
%     Rsquare = 1-SSR./SST;

mode = 'Local Diff. Coeff.';
switch mode
    case 'Local Diff. Coeff.'
        datasrc = log10(Dlocal(moment,:));
    case 'AnomalousCoeff'
        datasrc = AnomalousCoeff(2,:);
    case 'Rsquare Statistics'
        datasrc = Rsquare;
end

jump = idxSeg(w/2,1);
while isnan(x(jump))
    jump = jump -1;
end
jumpEnd = 1;
while jump < idxSeg(w/2,end)+1
    while isnan(x(jump+jumpEnd)-x(jump))
        jumpEnd = jumpEnd+1;
    end
    [unused good] = find(any(ismember(idxSeg,...
        jump:jump+jumpEnd-1)));
    output(jump) = nanmedian(datasrc(good));
    
    jump = jump+jumpEnd;
    jumpEnd = 1;
end %for
output = [output zeros(1,w/2)];
take = output ~= 0;
end
function buildSingleTrackMovie(src,event,trackID,filter,v,h)
[filename, pathname, isOK] = uigetfile(...
    '*.tif', 'Select Background Images',...
    getappdata(1,'searchPath'));
if isOK
    setappdata(1,'searchPath',pathname)
    
    fig =...
        figure(...
        'Tag', 'figBuildTrackMovie',...
        'Units','normalized',...
        'Position', [0.25 0.25 0.5 0.5],...
        'Color', get(0,'defaultUicontrolBackgroundColor'),...
        'Name', 'Track Movie',...
        'NumberTitle', 'off',...
        'MenuBar', 'none',...
        'ToolBar', 'none');
    ax =...
        axes(...
        'Tag', 'axBuildTrackMovie',...
        'Units','normalized',...
        'Position', [0 0 1 1],...
        'NextPlot','add');
    
    xmin = max(floor(min(v.data{trackID}(:,1)))-10,1);
    xmax = ceil(max(v.data{trackID}(:,1)))+10;
    ymin = max(floor(min(v.data{trackID}(:,2)))-10,1);
    ymax = ceil(max(v.data{trackID}(:,2)))+10;
    startPnt = v.data{trackID}(1,3);
    endPnt = v.data{trackID}(end,3);
    
    %initialize movie
    raw = double(imread([pathname filename],startPnt,...
        'PixelRegion', {[ymin ymax],[xmin xmax]}));
    if get(filter,'Value')
        raw = wiener2(raw);
    end %if
    
    hIm = imshow(raw,[min(raw(:)) max(raw(:))],...
        'Parent',ax);
    
    hLine = line(v.data{trackID}(v.data{trackID}(:,3)<=startPnt,1)-xmin+2,...
        v.data{trackID}(v.data{trackID}(:,3)<=startPnt,2)-ymin+2,...
        'Parent', ax, 'Color', [1 0 0], 'LineWidth', 3);
    
    colormap gray
    axis image
    drawnow
    mov(1) = getframe(ax);
    
    for frame = startPnt+1:endPnt
        raw = double(imread([pathname filename],frame,...
            'PixelRegion', {[ymin ymax],[xmin xmax]}));
        if get(filter,'Value')
            raw = wiener2(raw);
        end %if
        
        set(hIm,'CData',raw)
        set(hLine,'XData',v.data{trackID}(v.data{trackID}(:,3)<=frame,1)-xmin+2,...
            'YData',v.data{trackID}(v.data{trackID}(:,3)<=frame,2)-ymin+2)
        drawnow
        
        mov(frame-startPnt+1) = getframe(ax);
    end %for
    
    fps = 20;
    while ishandle(fig)
        cla
        movie(ax,mov,3,fps)
        fps = abs(fps - 6);
    end
    
    answer = questdlg('Save to Disk?','','Yes','No','No');
    if strcmp(answer,'Yes')
        [filename,pathname,isOK] =...
            uiputfile('.tif' ,'Save Track Movie',...
            [pathname filename(1:end-4)...
            '_track_' num2str(trackID) '.tif']);
        if isOK
            for frame = 1:numel(mov)
                imwrite(mov(frame).cdata,[pathname filename],...
                    'compression','none','writemode','append')
            end %for
        end %if
    end %if
end %if

end

function analyseDiffusionOne(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

varList = {...
    'CDF(radius^2)',...
    'CDF(probability)',...
    'fitted CDF(radius^2)',...
    'fitted CDF(probability)',...
    'mobile Fractions + Err',...
    'Timevector',...
    'max MSDs + Err',...
    'fit D(upper limit)',...
    'D(upper limit) + Err',...
    'D(upper limit) Residuals',...
    'mobile MSDs + Err',...
    'fit D(short range)',...
    'D(short range) + Err',...
    'D(short range) Residuals',...
    'fit D(long range)',...
    'D(long range) + Err',...
    'D(long range) Residuals',...
    'immobile MSDs + Err',...
    'fit D(immobile)',...
    'D(immobile) + Err',...
    'D(immobile) Residuals'};

shortRange = str2double(get(h.shortRangeStart, 'String')):...
    str2double(get(h.shortRangeStop, 'String'));
longRange = str2double(get(h.longRangeStart, 'String')):...
    str2double(get(h.longRangeStop, 'String'));

if get(h.longRange, 'Value') %long range diffusion checked
    steps2analyse = longRange;
else
    steps2analyse = shortRange;
end %if

[singleTrackSD maxSD unused stepLength] =...
    calcSD(find(v.track & v.trackActiv), 1, 0);

stepLength = vertcat(stepLength{:});
singleTrackSD = vertcat(singleTrackSD{:});

%preallocate space
P = cell(1,max(steps2analyse));
rsquare = cell(1,max(steps2analyse));
fitPar = zeros(max(steps2analyse),3);
fitParErr = zeros(max(steps2analyse),3);

hProgressbar = waitbar(0,'Calculating  Diffusion Constant','Color',...
    get(0,'defaultUicontrolBackgroundColor'));
for step = steps2analyse
    
    % calculating probability for increasing square displacements
    [P{step},rsquare{step}] = ecdf(singleTrackSD(stepLength == step));
    
    % fitting P vs. rsquare (Sch?tz et al. 1997, Biophys. J. 73:1073-1080)
    %     s = fitoptions('Method', 'NonlinearLeastSquares',...
    %         'Lower',[0,0,0],...
    %         'Upper', [1,Inf,Inf],...
    %         'StartPoint', [0.5 0.01 0.001],...
    %         'Robust', 'on');
    
    %     f = fittype('1-(a*exp(-x/b)+(1-a)*exp(-x/c))',...
    %         'options', s,...
    %         'independent', 'x');
    %
    %     fitMSD = fit (rsquare{step},P{step},f);
    %     fitPar(step,1:3) = coeffvalues(fitMSD);
    %     fitParErr(step,1:3) = diff(confint(fitMSD,0.68))/2;
    
    s = fitoptions('Method', 'NonlinearLeastSquares',...
        'Lower',[0],...
        'Upper', [inf],...
        'StartPoint', [5],...
        'Robust', 'on');
    
    f = fittype('1-(exp(-x/b))',...
        'options', s,...
        'independent', 'x');
    
    fitMSD = fit (rsquare{step},P{step},f);
    fitPar(step,2) = coeffvalues(fitMSD);
    fitParErr(step,2) = diff(confint(fitMSD,0.68))/2;
    
    fitSampling{step,1} = linspace(min(rsquare{step}),max(rsquare{step}),1000);
    yCumFit{step} = feval(fitMSD,fitSampling{step,1});
    
    %     modelfun = @(x,a,b,c) 1-(a*exp(-x/b)+...
    %         (1-a)*exp(-x/c));
    %     [hypo(step),prob(step),stats] = chi2gof(...
    %         singleTrackSD(stepLength == step),...
    %         'cdf', {modelfun,fitMSD.a,fitMSD.b,fitMSD.c},...
    %         'nparams', 3, 'nbins', 100);
    
    waitbar(step/max(steps2analyse),hProgressbar,...
        'Calculating Diffusion Constant','Color',...
        get(0,'defaultUicontrolBackgroundColor'));
end %for
delete(hProgressbar)

dt = (1:step)'*v.settings.Delay;

fig =...
    figure(...
    'Units', 'normalized',...
    'Position', [0 0 1 1],...
    'MenuBar', 'none',...
    'ToolBar', 'figure',...
    'Color', get(0,'defaultUicontrolBackgroundColor'),...
    'Name', 'Two Fraction Diffusion Fit',...
    'NumberTitle', 'off');

hToolBar = findall(fig,'Type','uitoolbar');
hToggleList = findall(hToolBar);
delete(hToggleList([2 3 5 6 7 9 10 16 17]))

hSub(1) =...
    subplot(...
    'position',[0.1 0.4 0.8 0.5],...
    'FontSize', 15,...
    'NextPlot', 'add',...
    'XTickLabel', '');

% calculating diffusion constant with mean maximum excursion model
maxSD = padcat(maxSD{v.track & v.trackActiv});
meanMaxSD = nanmean(maxSD,2);
stdMaxSD = nanstd(maxSD,[],2);
[Dmax DmaxStats] = robustfit(4*dt(shortRange),meanMaxSD(shortRange));
yDmaxFit = 4*Dmax(2)*dt+Dmax(1);
if get(h.estimateDmax, 'Value')
    %     hPlot = errorbar(dt(shortRange),meanMaxSD(shortRange),...
    %             stdMaxSD(shortRange),'ko');
    hPlot = plot(dt,yDmaxFit,'m--');
    set(hPlot, 'DisplayName', ['upper diffusion limit: D = ' num2str(Dmax(2),'%.3f')...
        ' \pm ' num2str(DmaxStats.se(2),'%.3f') '?m^2/s; c = '...
        num2str(Dmax(1),'%.3f') '?m^2'])
end

% calculating max diffusion constant
[fitShortRange shortRangeStats] = robustfit(4*dt(shortRange),...
    fitPar(shortRange,2));
DiffCoeffResiduals = shortRangeStats.resid;
yDshortFit = 4*fitShortRange(2)*dt+fitShortRange(1);

if get(h.shortRange, 'Value') %short range diffusion checked
    if ~get(h.longRange, 'Value')
        hPlot = errorbar(dt(shortRange),fitPar(shortRange,2),...
            fitParErr(shortRange,2),'ko');
        set(hPlot, 'DisplayName', [num2str(mean(fitPar(shortRange))*100,...
            '%.1f') ' \pm ' num2str(std(fitPar(shortRange))*100,'%.1f') '% mobile'])
    end %if
    hPlot = plot(dt,yDshortFit,'b');
    set(hPlot, 'DisplayName', ['short range diffusion: D = '...
        num2str(fitShortRange(2),'%.3f')...
        ' \pm ' num2str(shortRangeStats.se(2),'%.3f') '?m^2/s; c = '...
        num2str(fitShortRange(1),'%.3f') '?m^2'])
end %if

switch get(h.diffusionModel, 'Value')
    case 1
        % calculating diffusion constant with normal diffusion model
        s = fitoptions('Method', 'LinearLeastSquares',...
            'Lower', [0,0],...
            'Robust', 'on');
        
        f = fittype({'4*t','1'},...
            'coefficients', {'D','c'},...
            'options', s,...
            'independent', 't');
        
        [fitDiffusion, statsDiffusion, outputDiffusion] = ...
            fit(dt(steps2analyse),fitPar(steps2analyse,2),f);
        DiffCoeffStd = diff(confint(fitDiffusion,0.68))/2;
        yDlongFit = 4*fitDiffusion.D*dt+fitDiffusion.c;
        
        if get(h.longRange, 'Value') %long range diffusion checked
            DiffCoeffResiduals = outputDiffusion.residuals;
            
            hPlot(1) = errorbar(dt(longRange),fitPar(longRange,2),...
                fitParErr(longRange,2),'ko');
            hPlot(2) = plot(dt,yDlongFit,'r');
            set(hPlot(1), 'DisplayName', [num2str(mean(fitPar(longRange,1)*100),'%.1f')...
                ' \pm ' num2str(std(fitPar(longRange))*100,'%.1f') '% mobile'])
            set(hPlot(2), 'DisplayName', ['long range diffusion: D = ' num2str(fitDiffusion.D,'%.3f') ' \pm '...
                num2str(DiffCoeffStd(1),'%.3f') '?m^2/s; c = ' num2str(fitDiffusion.c,'%.3f')...
                '?m^2'])
        end
    case 2
        % calculating diffusion constant with anonmalous diffusion model
        s = fitoptions('Method', 'NonlinearLeastSquares',...
            'Lower', [0,0,-Inf],...
            'Upper', [Inf,1,Inf],...
            'StartPoint', [1, 0.5, 0],...
            'Robust', 'on');
        
        f = fittype('4*D*t^a+c',...
            'options', s,...
            'independent', 't');
        
        [fitDiffusion, statsDiffusion, outputDiffusion] = ...
            fit(dt(steps2analyse),fitPar(steps2analyse,2),f);
        
        DiffCoeffStd = diff(confint(fitDiffusion,0.68))/2;
        yDlongFit = 4*fitDiffusion.D*dt.^fitDiffusion.a+fitDiffusion.c;
        
        if get(h.longRange, 'Value') %long range diffusion checked
            DiffCoeffResiduals = outputDiffusion.residuals;
            
            hPlot(1) = errorbar(dt(longRange),fitPar(longRange,2),...
                fitParErr(longRange,2),'ko');
            hPlot(2) = plot(dt,yDlongFit,'r');
            set(hPlot(1), 'DisplayName', [num2str(mean(fitPar(longRange,1)*100),'%.1f') '% mobile'])
            set(hPlot(2), 'DisplayName', ['long range diffusion: D = ' num2str(fitDiffusion.D,'%.3f') ' \pm '...
                num2str(DiffCoeffStd(1),'%.3f') '?m^2/s; ' '\alpha = ' num2str(fitDiffusion.a,'%.3f')...
                '; c = ' num2str(fitDiffusion.c,'%.3f') '?m^2'])
        end
    case 3
        % calculating diffusion constant with Transport model
        s = fitoptions('Method', 'NonlinearLeastSquares',...
            'Lower', [0,0],...
            'Upper', [Inf,1],...
            'StartPoint', [1 .5],...
            'Robust', 'on');
        
        f = fittype('4*D*t+(V*t)^2',...
            'options', s,...
            'independent', 't');
        
        [fitDiffusion, statsDiffusion, outputDiffusion] = ...
            fit(dt(steps2analyse),fitPar(steps2analyse,2),f);
        
        DiffCoeffStd = diff(confint(fitDiffusion,0.68))/2;
        DiffCoeffV = fitDiffusion.V;
        yDlongFit = 4*fitDiffusion.D*dt+(fitDiffusion.V*dt)^2;
        
        if get(h.longRange, 'Value') %long range diffusion checked
            DiffCoeffResiduals = outputDiffusion.residuals;
            
            hPlot(1) = errorbar(dt(longRange),fitPar(longRange,2),...
                fitParErr(longRange,2),'ko');
            hPlot(2) = plot(dt,yDlongFit,'r-');
            set(hPlot(1), 'DisplayName', [num2str(mean(fitPar(longRange,1)*100),'%.1f') '% mobile'])
            set(hPlot(2), 'DisplayName', ['long range diffusion: D = ' num2str(fitDiffusion.D,'%.3f') ' \pm '...
                num2str(DiffCoeffStd(1),'%.3f') '?m^2/s; V = ' num2str(DiffCoeffV,'%.3f')...
                '?m/s'])
        end
        
    otherwise
end %switch

% calculating diffusion constant with normal diffusion model
[immobileD immobileDstats] = robustfit(4*dt(steps2analyse),fitPar(steps2analyse,3));

hPlot = errorbar(dt(steps2analyse),fitPar(steps2analyse,3),...
    fitParErr(steps2analyse,3),'ko');
set(hPlot, 'DisplayName', [num2str(100-mean(fitPar(steps2analyse,1)*100),'%.1f') '% immobile'])
yDimmFit = 4*immobileD(2)*dt+immobileD(1);
hPlot = plot(dt,yDimmFit,'g');
set(hPlot, 'DisplayName', ['immobile: D = ' num2str(immobileD(2),'%.3f')...
    ' \pm ' num2str(immobileDstats.se(2),'%.3f') '?m^2/s; c = ' num2str(immobileD(1),'%.3f') '?m^2'])

hold off
ylabel('MSD [?m^2]');
% axis(axis.*[0 1 1 1])

legend('Location', 'NorthWest');

% plot residues of mobile
hSub(2) =...
    subplot(...
    'position',[0.1 0.1 0.8 0.2],...
    'FontSize', 15);

stem(hSub(2),dt(steps2analyse), DiffCoeffResiduals)

% [ax, h1, h2] = plotyy(dt(steps2analyse), DiffCoeffResiduals,...
%     dt(steps2analyse), prob(steps2analyse), 'stem', 'plot');
% set(ax, 'FontSize', 15)
% ylabel(ax(1), 'Residuals'); ylabel(ax(2), 'p-value (X^2 test)')
% set(h2, 'LineStyle', ':', 'Marker', 'o')

xlabel('Time [s]'); ylabel('Residuals')
linkaxes(hSub, 'x')

% temp = accumarray(stepLength,singleTrackSD,[],@(x){x});
toExport = {...
    padcat(rsquare{:}),...
    padcat(P{:}),...
    padcat(fitSampling{:})',...
    padcat(yCumFit{:}),...
    [fitPar(:,1) fitParErr(:,1)],...
    dt,...
    [meanMaxSD stdMaxSD],...
    yDmaxFit,...
    [Dmax(2) DmaxStats.se(2); Dmax(1) DmaxStats.se(1)],...
    DmaxStats.resid,...
    [fitPar(:,2) fitParErr(:,2)],...
    yDshortFit,...
    [fitShortRange(2) shortRangeStats.se(2); fitShortRange(1) shortRangeStats.se(1)],...
    shortRangeStats.resid,...
    yDlongFit,...
    [fitDiffusion.D DiffCoeffStd(1); fitDiffusion.c DiffCoeffStd(2)],...
    DiffCoeffResiduals,...
    [fitPar(:,3) fitParErr(:,3)],...
    yDimmFit,...
    [immobileD(2) immobileDstats.se(2); immobileD(1) immobileDstats.se(1)],...
    immobileDstats.resid};
bad = [];
if ~get(h.estimateDmax, 'Value')
    bad = [bad 7 8 9 10];
end
if ~get(h.shortRange, 'Value')
    bad = [bad 12 13 14];
end
if ~get(h.longRange, 'Value')
    bad = [bad 15 16 17];
end
if ~isempty(bad)
    varList(bad) = [];
    toExport(bad) = [];
end
uipushtool(hToolBar,...
    'CData', v.xlsExportIcon,...
    'ClickedCallback', {@varExport, fig, varList})

setappdata(fig, 'variables', toExport)
%     function fx = schuetzModel(x,a,b,c)
%         fx = 1-(a*exp(-x/b)+(1-a)*exp(-x/c));
%     end
end
function analyseDiffusionTwo(src, event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

[singleTrackSD unused unused stepLength] =...
    calcSD(find(v.track & v.trackActiv), 0, 0);
stepLength = vertcat(stepLength{:});
singleTrackSD = sqrt(vertcat(singleTrackSD{:}));

switch get(h.timeDpndncy, 'Value')
    case 1
        steps2analyse = str2double(get(h.timeStepDiffusion(1), 'String'));
        varList = {...
            'Diff. Constants + Err',...
            'Fractions + Err',...
            'Timestep',...
            'PDF(radius)',...
            'PDF(probability)',...
            'fitted Curve(radius)',...
            'fitted SumCurve(probability)'};
    case 2
        steps2analyse = str2double(get(h.timeSeriesStart, 'String')):...
            str2double(get(h.timeSeriesStop, 'String'));
        varList = {...
            'Diff. Constants + Err',...
            'Fractions + Err',...
            'Timevector',...
            'PDF(radius)',...
            'PDF(probability)',...
            'fitted Curve(radius)',...
            'fitted SumCurve(probability)'};
end %switch
fractions = str2double(get(h.populations, 'String'));
for n = 1:fractions
    varList = [varList cellstr(['fitted Curve(fraction' num2str(n) ')'])];
end %for

fig =...
    figure(...
    'Units', 'normalized',...
    'Position', figPos(1),...
    'ToolBar', 'figure',...
    'MenuBar', 'none',...
    'Color', get(0,'defaultUicontrolBackgroundColor'),...
    'Name', 'Multiple Fraction Diffusion Fit',...
    'NumberTitle', 'off');

hToolBar = findall(fig,'Type','uitoolbar');
hToggleList = findall(hToolBar);
delete(hToggleList([2 3 5 6 7 8 9 10 13 14 16 17]))

uipushtool(hToolBar,...
    'CData', v.xlsExportIcon,...
    'ClickedCallback', {@varExport, fig, varList})

bins = str2double(get(h.mffPdfBins, 'String'));
cmap = lines(fractions);

%preallocate
[x,y] = deal(cell(steps2analyse(end),1));
fitPar = zeros(steps2analyse(end),2*fractions);
fitParErr = zeros(steps2analyse(end),2*fractions);
% hypo = zeros(steps2analyse(end),1);
% prob = zeros(steps2analyse(end),1);

for step = steps2analyse
    %     [P{step},r{step}] = ecdf(singleTrackSD(stepLength == step));
    %     [y{step}, x{step}] = ecdfhist(P{step},r{step},bins);
    %     [y{step}, x{step}] = hist(singleTrackSD(stepLength == step),...
    %         linspace(0,max(singleTrackSD(stepLength == step)),bins));
    %     y{step} = y{step}/sum(y{step}*(x{step}(2)-x{step}(1)));
    %
    [y{step}, x{step}] = ksdensity(singleTrackSD(stepLength == step),...
        linspace(0,max(singleTrackSD(stepLength == step)),bins));
    
    equation = ['((N1/(4*pi*D1*' num2str(v.settings.Delay*step)...
        '))*exp(-x.^2/(4*D1*' num2str(v.settings.Delay*step) '))*2*pi.*x)'];
    
    if fractions > 1
        for n = 2:fractions
            equation = [equation '+((N' num2str(n) '/(4*pi*D' num2str(n) ...
                '*' num2str(v.settings.Delay*step) '))*exp(-x.^2/(4*D' num2str(n)...
                '*' num2str(v.settings.Delay*step) '))*2*pi.*x)'];
        end %for
    end %if
    
    %     startPnt = [0.4 1 0.8 0.2];
    %     lb = [0.25 0.9 0 0];
    %     ub = [0.45 1.5 1 1];
    %     s = fitoptions('Method', 'NonlinearLeastSquares',...
    %         'Lower', lb,...
    %         'Upper', ub,...
    %         'StartPoint', startPnt);
    
    s = fitoptions('Method', 'NonlinearLeastSquares',...
        'Lower', zeros(1, fractions*2),...
        'Upper', [repmat(inf, 1, fractions), repmat(1, 1, fractions)],...
        'StartPoint', [10.^-(1:fractions), repmat(1/fractions, 1, fractions)]);
    
    f = fittype(equation,...
        'options', s,...
        'independent', 'x');
    
    %plot results
    
    switch get(h.timeDpndncy, 'Value')
        case 1
            [fitStepLength statsStepLength outputStepLength] =...
                fit(x{step}',y{step}',f);
            fitPar = coeffvalues(fitStepLength);
            fitParErr = diff(confint(fitStepLength,0.68))/2;
            
            %chisquare test
            %             [hypo,prob,stats] = chi2gof(x{step},...
            %                 'ctrs', x{step}, 'frequency', y{step},...
            %                 'expected', feval(fitStepLength,x{step}),...
            %                 'nparams', fractions*2, 'emin', 0);
            
            hSub(1) =...
                subplot(...
                'position',[0.1 0.4 0.8 0.5],...
                'FontSize', 15,...
                'NextPlot', 'add');
            
            
            bar(x{step},y{step},'hist');
            
            fitSampling{step,1} = linspace(min(x{step}),max(x{step}),bins*10);
            ySumFit{step} = feval(fitStepLength,fitSampling{step,1});
            hPlot = plot(fitSampling{step,1}, ySumFit{step},...
                'color', 'm', 'linewidth', 2);
            
            %             if hypo
            %                 chiTestResult = 'H0 rejected';
            %             else
            %                 chiTestResult = ['H0 accepted, p-Value = ' num2str(prob,'%.1f')];
            %             end %if
            
            set(hPlot, 'DisplayName',...
                sprintf('%s', [num2str(sum(fitPar(fractions+1:2*fractions))*100,...
                '%.1f') '% Sum Function']));
            
            for n = 1:fractions
                yFractionFit{n}{step} = ((fitPar(n+fractions)/(4*pi*fitPar(n)*v.settings.Delay*...
                    step)))*exp(-fitSampling{step,1}.^2/(4*fitPar(n)*v.settings.Delay*...
                    step))*2*pi.*fitSampling{step,1};
                plot(fitSampling{step,1},yFractionFit{n}{step}, 'Color', cmap(n,:),...
                    'linewidth', 2, 'DisplayName',...
                    [num2str(fitPar(n+fractions)*100','%.1f') ' \pm '...
                    num2str(fitParErr(n+fractions)*100','%.1f') '%; D = '...
                    num2str(fitPar(n),'%.3f') ' \pm ' num2str(fitParErr(n),'%.3f') '?m^2/s']);
            end %for
            
            legend('Location', 'NorthEast')
            ylabel('Probability Density'); xlabel('Step Length [?m]');
            
            % plot residues
            hSub(2) =...
                subplot(...
                'position',[0.1 0.1 0.8 0.2],...
                'FontSize', 15);
            stem (x{step},outputStepLength.residuals,'Color','r',...
                'DisplayName', ['RMSE = ' num2str(statsStepLength.rmse, '%.3f')])
            legend('Location', 'NorthEast')
            ylabel('Residuals'); xlabel('Step Length [?m]');
            
            linkaxes(hSub,'x')
        case 2
            
            [fitStepLength statsStepLength outputStepLength] = fit(x{step}',y{step}',f);
            fitPar(step,:) = coeffvalues(fitStepLength);
            fitParErr(step,:) = diff(confint(fitStepLength,0.68))/2;
            
            fitSampling{step,1} = linspace(min(x{step}),max(x{step}),bins*10);
            ySumFit{step} = feval(fitStepLength,fitSampling{step,1});
            
            %chisquare test
            %             [hypo(step),prob(step),stats] = chi2gof(x{step},...
            %                 'ctrs', x{step}, 'frequency', y{step},...
            %                 'expected', feval(fitStepLength,x{step}),...
            %                 'nparams', fractions*2, 'emin', 0);
            
            if step == steps2analyse(1)
                ax(1) =...
                    subplot(2,1,1);
                ax(2) =...
                    subplot(2,1,2);
                set(ax, 'NextPlot', 'add',...
                    'FontSize', 15)
            end %if
            
            for n = 1:fractions
                yFractionFit{n}{step} = ((fitPar(step,n+fractions)/(4*pi*fitPar(step,n)*v.settings.Delay*...
                    step)))*exp(-fitSampling{step,1}.^2/(4*fitPar(step,n)*v.settings.Delay*...
                    step))*2*pi.*fitSampling{step,1};
                
                %                 if hypo(step)
                %                     errorbar(ax(1), step*v.settings.Delay,...
                %                         fitPar(step,n), fitParErr(step,n), 'Color', cmap(n,:),...
                %                         'LineStyle', 'none', 'Marker', '*', 'MarkerSize', 15)
                %                     errorbar(ax(2), step*v.settings.Delay, fitPar(step,n+fractions),...
                %                         fitParErr(step,n+fractions), 'Color', cmap(n,:), 'LineStyle', 'none',...
                %                         'Marker', '*', 'MarkerSize', 15)
                %                 else
                errorbar(ax(1), step*v.settings.Delay,...
                    fitPar(step,n), fitParErr(step,n),'Color', cmap(n,:),...
                    'LineStyle', 'none', 'Marker', 'o')
                errorbar(ax(2),step*v.settings.Delay, fitPar(step,n+fractions),...
                    fitParErr(step,n+fractions), 'Color', cmap(n,:), 'LineStyle', 'none',...
                    'Marker', 'o')
                %                 end %if
            end %for
            
            if step == steps2analyse(end)
                ylim([0 1])
                %                 plot(ax(2), steps2analyse*v.settings.Delay, prob(steps2analyse),...
                %                     'Color', 'k', 'Marker', 'x', 'MarkerSize', 15, 'LineStyle', ':')
                plot(ax(2), steps2analyse*v.settings.Delay,...
                    sum(fitPar(steps2analyse,fractions+1:2*fractions),2), 'mo')
                
                ylabel(ax(1), 'D [?m^2/s]'); xlabel(ax(1), 'Time [s]');
                ylabel(ax(2), 'Fraction'); xlabel(ax(2), 'Time [s]');
                linkaxes(ax,'x');
                set(ax, 'YMinorGrid','on')
            end %if
    end %if
    axis tight
end %for
% toExport = {...
%     [fitPar(:,1:fractions) fitParErr(:,1:fractions)],...
%     [fitPar(:,1+fractions:end) fitParErr(:,1+fractions:end)],...
%     steps2analyse'*v.settings.Delay,...
%     padcat(x{:})',...
%     padcat(y{:})',...
%     padcat(fitSampling{:})',...
%     padcat(ySumFit{:})};
% for n = 1:fractions
%     toExport = [toExport padcat(yFractionFit{n}{:})'];
% end %for
% setappdata(fig, 'variables', toExport)
end
function diffCoeffHist(src,event)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

winSize = str2double(...
    inputdlg(...
    'Window Size [frames]',...
    '',1));

good = find(v.track & v.trackActiv);
[Dlocal AnomalousCoeff] = deal(cell(1,max(good)));
for N = good
    [Dlocal{N} AnomalousCoeff{N}] =...
        calcDlocal(v.data{N}(:,1),...
        v.data{N}(:,2),...
        v.data{N}(:,3),...
        winSize,...
        v.settings.Delay,...
        v.px2micron);
end %for

fig =...
    figure(...
    'Units','normalized',...
    'Position', [0.2 0.2 0.6 0.6],...
    'Name', 'Diffusion Coefficient Distribution',...
    'NumberTitle', 'off',...
    'MenuBar', 'figure',...
    'ToolBar', 'figure');

hToolBar = findall(fig,'Type','uitoolbar');
    uipushtool(...
        'Parent', hToolBar,...
        'CData', repmat(rand(16), [1 1 3]),...
        'ClickedCallback', @excludeByPosteriori)

hToggleList = findall(hToolBar);
delete(hToggleList([2 3 4 5 6 7 8 9 10 13 14 16 17 18]))

ax =...
    axes(...
    'Parent', fig,...
    'Units','normalized',...
    'FontSize', 20,...
    'NextPlot', 'add');

switch get(src, 'String')
    case 'D HISTOGRAM'
        data =  log10(horzcat(Dlocal{:}))';
    otherwise
        data =  horzcat(AnomalousCoeff);
end %switch

[freq, ctrs] = hist(data,...
    linspace(min(data),max(data),150));
% [freq, ctrs] = hist(data,...
%     linspace(min(data),max(data),100));

bar(ctrs,freq,'hist');

options = statset('MaxIter',1000);
fractions = str2double(get(h.populations, 'String'));
mixComponents = gmdistribution.fit(data,fractions,...
    'Options', options);

%                                     AIC = zeros(1,fractions);
%                             mixComponents = cell(1,fractions);
%                             for k = 1:fractions
%                                 mixComponents{k} = ...
%                                     gmdistribution.fit(log10(Dlocal),k,...
%                                     'Options', options);
%                                 AIC(k)= mixComponents{k}.AIC;
%                             end
%                             [minAIC,fractions] = min(AIC);
%                             mixComponents = mixComponents{fractions};

%calculate 0.05 alpha threshold for each population
% [prob dD]  = ecdf(data);
% alpha(1) = interp1(prob,dD,0.01)
% alpha(2) = interp1(prob,dD,0.05)
% for fraction = 1:fractions
%     alpha(fraction) = min(norminv(0.05,...
%         mixComponents.mu(fraction),...
%         sqrt(mixComponents.Sigma(fraction))))
% end %for

results = [trapz(ctrs,freq)*mixComponents.PComponents'./...
    sqrt(2*pi*mixComponents.Sigma(:)),...
    mixComponents.mu,...
    sqrt(mixComponents.Sigma(:))];

gauss = @(x,a,b,c) a*exp(-((x-b).^2/(2*c^2)));
ctrsInterp = linspace(min(ctrs),max(ctrs),10*numel(ctrs))';
freqSub = zeros(fractions,numel(ctrsInterp));
for N = 1:fractions
    freqSub(N,:) = gauss(ctrsInterp,...
        results(N,1),results(N,2),results(N,3));
    plot(ax, ctrsInterp, freqSub(N,:), 'r', 'Tag', 'fit',...
        'Displayname', sprintf('%.0f%%; ? = %.2f',...
        mixComponents.PComponents(N)*100,mixComponents.mu(N)))
end %for
plot(ax, ctrsInterp, sum(freqSub,1), 'm', 'Tag', 'fit',...
    'Displayname', 'gaussian mixture model')

% hThresh = line([alpha;alpha],...
%     [zeros(1,fractions); repmat(max(freq),1,fractions)],...
%     'Color', 'k', 'LineWidth', 2);
% hGroup = hggroup;
% set(hThresh, 'Parent', hGroup)
% set(get(get(hGroup,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','on');
% set(hGroup,'Displayname', 'threshold (alpha 0.05)')

legend(ax,'show')
axis tight
ylabel('Frequency');

hToolBar = findall(fig,'Type','uitoolbar');
    uipushtool(...
        'Parent', hToolBar,...
        'CData', repmat(rand(16), [1 1 3]),...
        'ClickedCallback',@excludeByPosteriori)

    function excludeByPosteriori(src,event)
        h = getappdata(1, 'handles');
        v = getappdata(1, 'values');

        [prob loglike] = posterior(mixComponents,data);
        
        [unused, popIdx] = min(mixComponents.mu);
        v.trackActiv(good(prob(:,popIdx) > 0.05)) = false;
        v.trackList = [];
        
        set(h.percentExcluded, 'String', ...
            round(sum(v.trackLength(~(v.trackActiv & v.track)))/...
            sum(v.trackLength)*100))
        set(h.selectedTrackPopup, 'String',...
            cellstr(num2str(transpose(find(v.track & v.trackActiv)))),...
            'Value', 1)
        
        setappdata(1, 'values', v)
    end
end

function confinementAnalysis(src, event)
h = getappdata(1, 'handles');

hConf.type = 'group';
figure(...
    'Units', 'normalized',...
    'Position', [0 0 1 1],...
    'Toolbar', 'figure',...
    'Color', get(0,'defaultUicontrolBackgroundColor'));

hConf.SettingsPanel =...
    uipanel(...
    'Position', [0 0 0.3 1]);
% hConf.AxesPanel = uipanel('Position', [0.3 0 0.7 1]);
hConf.Axes =...
    axes(...
    'Parent', gcf,...
    'Position', [0.4 0.1 0.5 0.8]);

setappdata(hConf.Axes, 'showBackground', 0)
setappdata(hConf.Axes, 'showControl', 1)
setappdata(hConf.Axes, 'backgroundType', 'none')

setappdata(hConf.Axes, 'calcWindowVal',7)
setappdata(hConf.Axes, 'confThreshVal',50)
setappdata(hConf.Axes, 'minTimeVal',8)

switch get(h.confAlgorithm, 'Value');
    case 1
        method = 'varM';
    case 2
        method = 'conf';
    otherwise
end %switch
setappdata(hConf.Axes, 'method', method)

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.15 0.85 0.7 0.05],...
    'String', 'Settings:',...
    'FontSize', 25)

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.15 0.7 0.7 0.05],...
    'String', 'Type:',...
    'FontSize', 15)

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.15 0.38 0.2 0.05],...
    'String', 'Window',...
    'FontSize', 15)

hConf.calcWindowLabel =...
    uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'edit',...
    'Tag' , 'calcWindowLabel',...
    'Units', 'normalized',...
    'Position', [0.2 0.05 0.1 0.05],...
    'String', 7,...
    'FontSize', 10,...
    'Callback', {@setCalcWindowVal, hConf});

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.4 0.38 0.2 0.05],...
    'String', 'Thresh',...
    'FontSize', 15)

hConf.confThreshLabel =...
    uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'edit',...
    'Tag' , 'confThreshLabel',...
    'Units', 'normalized',...
    'Position', [0.45 0.05 0.1 0.05],...
    'String', 50,...
    'FontSize', 10,...
    'Callback', {@setConfThreshVal, hConf});

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'text',...
    'Units', 'normalized',...
    'Position', [0.65 0.38 0.2 0.05],...
    'String', 'Time',...
    'FontSize', 15)

hConf.minTimeLabel =...
    uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'edit',...
    'Tag' , 'minTimeLabel',...
    'Units', 'normalized',...
    'Position', [0.7 0.05 0.1 0.05],...
    'String', 8,...
    'FontSize', 10,...
    'Callback', {@setMinTimeVal, hConf});

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'slider',...
    'Tag' , 'calcWindow',...
    'Units', 'normalized',...
    'Position', [0.2 0.1 0.1 0.3],...
    'Max', 100,...
    'Min', 7,...
    'SliderStep', [0.01 0.1],...
    'Value', 7,...
    'Callback', {@setCalcWindowVal, hConf});

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'slider',...
    'Tag' , 'confThresh',...
    'Units', 'normalized',...
    'Position', [0.45 0.1 0.1 0.3],...
    'Max', 1000,...
    'Min', 1,...
    'SliderStep', [0.001 0.01],...
    'Value', 50,...
    'Callback', {@setConfThreshVal, hConf});

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'slider',...
    'Tag' , 'minTime',...
    'Units', 'normalized',...
    'Position', [0.7 0.1 0.1 0.3],...
    'Max', 100,...
    'Min', 1,...
    'SliderStep', [0.01 0.1],...
    'Value', 8,...
    'Callback', {@setMinTimeVal, hConf});

uicontrol(...
    'Parent', hConf.SettingsPanel,...
    'Style', 'popupmenu',...
    'Tag', 'groupConfMapPlotType',...
    'Units', 'normalized',...
    'Position', [0.15 0.5 0.7 0.2],...
    'String', {'Index', 'Trajectory Map', 'Conf. Distribution', 'Diffusion', 'Conf. Lifetime'},...
    'Value', 1,...
    'FontSize', 10,...
    'CreateFcn', {@ConfMapCalc, hConf},...
    'Callback', {@ConfChangePlot, hConf});
end
function setCalcWindowVal(src, event, hConf)
if strcmp(get(src, 'Style'),'edit')
    x = round(str2double(get(src, 'String')));
    if x < 7
        x = 7;
        uiwait(warndlg('Calculation Window must be > 7','Warning','modal'));
    end %if
    set(src, 'String', x)
    setappdata(hConf.Axes, 'calcWindowVal', x)
    set(findobj('Tag', 'calcWindow'), 'Value', x)
else
    x = round(get(src, 'Value'));
    set(src, 'Value', x)
    setappdata(hConf.Axes, 'calcWindowVal', x)
    set(findobj('Tag', 'calcWindowLabel'), 'String', x)
end %if
ConfMapCalc(src, event, hConf)
end
function setConfThreshVal(src, event, hConf)
if strcmp(get(src, 'Style'),'edit')
    x =  str2double(get(src, 'String'));
    setappdata(hConf.Axes, 'confThreshVal', x)
    set(findobj('Tag', 'confThresh'), 'Value', x)
else
    x = round(get(src, 'Value'));
    set(src, 'Value', x)
    setappdata(hConf.Axes, 'confThreshVal', x)
    set(findobj('Tag', 'confThreshLabel'), 'String', x)
end %if
ConfMapUpdate(src, event, hConf)
end
function setMinTimeVal(src, event, hConf)
if strcmp(get(src, 'Style'),'edit')
    x =  str2double(get(src, 'String'));
    setappdata(hConf.Axes, 'minTimeVal', x)
    set(findobj('Tag', 'minTime'), 'Value', x)
else
    x = round(get(src, 'Value'));
    set(src, 'Value', x)
    setappdata(hConf.Axes, 'minTimeVal', x)
    set(findobj('Tag', 'minTimeLabel'), 'String', x)
end %if
ConfMapUpdate(src, event, hConf)
end
function ConfMapCalc(src, event, hConf)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

switch hConf.type
    case 'group'
        tracks2analyse = find(v.track & v.trackActiv);
        [singleTrackSD  SDmax unused stepLength] = calcSD(tracks2analyse, 1, 0);
        if get(h.confEstimateDmax, 'Value')
            ensembleMME = nanmean(padcat(SDmax{tracks2analyse}),2);
            Dmax = 4*(2:6)'*v.settings.Delay\ensembleMME(2:6);
        else
            Dmax = str2double(get(h.confDmax, 'String'));
        end %if
    case 'single'
        %         trackID = get(handles.singleTrackSelected, {'String', 'Value'});
        %         trackID = str2double(cell2mat(trackID{1}(trackID{2})));
        %         tracks2analyse = trackID;
        %         [singleTrackSD  SDmax unused stepLength] = calcSD(tracks2analyse, 1, 0);
        %         ensembleMME = SDmax{tracks2analyse};
end %switch

%preallocate space
[Dlocal iConf refPoint displacement beginConf endConf lengthConf...
    beginFree endFree lengthFree trackListFree trackListConf pntConf pntFree] =...
    deal(cell(numel(tracks2analyse),1));

nrFree = 0; nrConf = 0;
hProgressbar = waitbar(0,'Calculating...','Color',...
    get(0,'defaultUicontrolBackgroundColor'));
for N = tracks2analyse
    Dlocal{N} = calcDlocal(v.data{N}(:,1),...
        v.data{N}(:,2),...
        v.data{N}(:,3),getappdata(hConf.Axes, 'calcWindowVal'),...
        v.settings.Delay, v.px2micron);
    
    [iConf{N} refPoint{N} displacement{N}] = calcConf(Dmax,...
        v.data{N}(:,1), v.data{N}(:,2), v.data{N}(:,3),...
        v.settings.Delay, getappdata(hConf.Axes, 'calcWindowVal'),...
        getappdata(hConf.Axes, 'method'),v.px2micron);
    [beginConf{N} endConf{N} lengthConf{N}...
        beginFree{N} endFree{N} lengthFree{N}] =...
        getConfBounds(iConf{N},getappdata(hConf.Axes, 'confThreshVal'),...
        getappdata(hConf.Axes, 'minTimeVal'));
    
    [trackListFree{N} trackListConf{N} pntFree{N} pntConf{N}] = getConfPeriods(v.data{N},...
        beginConf{N},endConf{N},lengthConf{N},beginFree{N},...
        endFree{N},lengthFree{N},getappdata(hConf.Axes, 'calcWindowVal'),...
        nrFree, nrConf);
    
    nrFree = max(nrFree, trackListFree{N}(end,9));
    nrConf = max(nrConf, trackListConf{N}(end,9));
    
    waitbar(N/numel(tracks2analyse),hProgressbar,...
        'Calculating...','Color',...
        get(0,'defaultUicontrolBackgroundColor'));
end %for
delete(hProgressbar)

control = simBrown(0,0,numel(vertcat(iConf{:})),1,...
    Dmax,v.settings.Delay, v.px2micron);
iConfControl = calcConf(Dmax,...
    control(:,1), control(:,2),...
    control(:,3),v.settings.Delay,...
    getappdata(hConf.Axes, 'calcWindowVal'),...
    getappdata(hConf.Axes, 'method'),v.px2micron);

setappdata(hConf.Axes, 'Dmax', Dmax)
setappdata(hConf.Axes, 'confIndex', iConf)
setappdata(hConf.Axes, 'localD', Dlocal)
setappdata(hConf.Axes, 'refPoint', refPoint)
setappdata(hConf.Axes, 'displacement', displacement)
setappdata(hConf.Axes, 'confControl', iConfControl)
setappdata(hConf.Axes, 'beginConf', beginConf)
setappdata(hConf.Axes, 'endConf', endConf)
setappdata(hConf.Axes, 'lengthConf', lengthConf)
setappdata(hConf.Axes, 'lengthFree', lengthFree)
setappdata(hConf.Axes, 'trackListConf', trackListConf)
setappdata(hConf.Axes, 'trackListFree', trackListFree)
setappdata(hConf.Axes, 'pntConf', pntConf)
setappdata(hConf.Axes, 'pntFree', pntFree)


ConfChangePlot(src, event, hConf)
end
function ConfMapUpdate(src, event, hConf)
v = getappdata(1, 'values');

switch hConf.type
    case 'group'
        tracks2analyse = find(v.track & v.trackActiv);
    case 'single'
        trackID = get(handles.singleTrackSelected, {'String', 'Value'});
        trackID = str2double(cell2mat(trackID{1}(trackID{2})));
        tracks2analyse = trackID;
end %switch

%preallocate space
[beginConf endConf lengthConf beginFree endFree lengthFree...
    trackListFree trackListConf pntConf pntFree] =...
    deal(cell(numel(tracks2analyse),1));

nrFree = 0; nrConf = 0;
iConf = getappdata(hConf.Axes, 'confIndex');
for N = tracks2analyse
    [beginConf{N} endConf{N} lengthConf{N}...
        beginFree{N} endFree{N} lengthFree{N}] =...
        getConfBounds(iConf{N},...
        getappdata(hConf.Axes, 'confThreshVal'),...
        getappdata(hConf.Axes, 'minTimeVal'));
    
    [trackListFree{N} trackListConf{N} pntFree{N} pntConf{N}] = getConfPeriods(v.data{N},...
        beginConf{N},endConf{N},lengthConf{N},beginFree{N},...
        endFree{N},lengthFree{N},getappdata(hConf.Axes, 'calcWindowVal'),...
        nrFree, nrConf);
    
    nrFree = sum(cellfun('size',beginFree,1));
    nrConf = sum(cellfun('size',beginConf,1));
end

setappdata(hConf.Axes, 'beginConf', beginConf)
setappdata(hConf.Axes, 'endConf', endConf)
setappdata(hConf.Axes, 'trackListConf', trackListConf)
setappdata(hConf.Axes, 'trackListFree', trackListFree)
setappdata(hConf.Axes, 'pntConf', pntConf)
setappdata(hConf.Axes, 'pntFree', pntFree)

ConfChangePlot(src, event, hConf)
end
function ConfChangePlot(src, event, hConf)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

delete([findobj('Tag', 'groupConf');...
    findobj('Tag', 'axesLocalD')])
cla(hConf.Axes, 'reset')
set(hConf.Axes, 'Position', [0.4 0.1 0.5 0.8])

switch get(findobj('-regexp', 'Tag', 'ConfMapPlotType'), 'Value')
    case 1
        switch hConf.type
            case 'group'
                
                uicontrol(...
                    'Parent', hConf.SettingsPanel,...
                    'Style', 'popupmenu',...
                    'Tag', 'groupConf',...
                    'Units', 'normalized',...
                    'Position', [0.15 0.4 0.7 0.2],...
                    'String', ['all'; get(h.selectedTrackPopup, 'String')],...
                    'Value', 1,...
                    'FontSize', 10,...
                    'CreateFcn', {@ConfMapIndex, hConf},...
                    'Callback', {@ConfMapIndex, hConf});
                
            case 'single'
                
                Lc = getappdata(hConf.Axes, 'confIndex');
                localD = getappdata(hConf.Axes, 'localD');
                beginConf = getappdata(hConf.Axes, 'beginConf');
                endConf = getappdata(hConf.Axes, 'endConf');
                track = get(handles.singleTrackSelected, {'String', 'Value'});
                track = str2double(track{1}(track{2}));
                
                set(hConf.Axes, 'Position', [0.4 0.1 0.5 0.39])
                set(hConf.Axes, 'ButtonDownFcn', {@selectData, track, hConf})
                hold on
                if ~isempty(beginConf{track})
                    patch([beginConf{track} beginConf{track} endConf{track} endConf{track}]',...
                        repmat([0; max(Lc{track}); max(Lc{track}); 0],1,numel(beginConf{track})),...
                        [0.85 0.85 0.85], 'EdgeColor', [1 1 1], 'DisplayName', 'confinement');
                end %if
                if getappdata(hConf.Axes, 'showControl')
                    control = simBrown(0,0,v.trackLifeTime(track),1,...
                        getappdata(hConf.Axes, 'Dmax'),v.settings.Delay,...
                        v.px2micron);
                    iConfControl = calcConf(getappdata(hConf.Axes, 'Dmax'),...
                        control(:,1), control(:,2), control(:,3),v.settings.Delay,...
                        getappdata(hConf.Axes, 'calcWindowVal'), getappdata(hConf.Axes, 'method'),...
                        v.px2micron);
                    area(iConfControl,'FaceColor', 'b',...
                        'EdgeColor', 'b', 'DisplayName', 'control')
                end %if
                plot(Lc{track},'Color', 'r', 'LineWidth', 0.5, 'DisplayName', 'data')
                plot(smooth(Lc{track},100),'g','LineWidth',3, 'DisplayName', 'smoothed data')
                line([0 numel(Lc{track})], [getappdata(hConf.Axes, 'confThreshVal')...
                    getappdata(hConf.Axes, 'confThreshVal')], 'Color', 'k',...
                    'LineWidth', 3, 'DisplayName', 'threshhold')
                axis tight
                legend(hConf.Axes,'show')
                xlabel('Window Position'); ylabel('Confinement Index');
                
                axes('Tag', 'axesLocalD', 'Position', [0.4 0.51 0.5 0.39],...
                    'ButtonDownFcn', {@selectData, track, hConf})
                hold on
                if ~isempty(beginConf{track})
                    patch([beginConf{track} beginConf{track} endConf{track} endConf{track}]',...
                        repmat([0; max(localD{track}); max(localD{track}); 0],1,numel(beginConf{track})),...
                        [0.85 0.85 0.85], 'EdgeColor', [0.85 0.85 0.85], 'DisplayName', 'confinement');
                end %if
                plot(localD{track},'Color', 'r', 'LineWidth', 0.5, 'DisplayName', 'data')
                plot(smooth(localD{track},100),'g','LineWidth',3, 'DisplayName', 'smoothed data')
                axis tight
                ylabel('Local Diffusion [?m^2/s]');
                set(gca, 'XTick', [])
                
                linkaxes([gca, hConf.Axes],'x');
        end
        
        uicontrol(...
            'Parent', hConf.SettingsPanel,...
            'Style', 'checkbox',...
            'Tag', 'groupConf',...
            'Units', 'normalized',...
            'Position', [0.35 0.5 0.3 0.05],...
            'String', 'show Control',...
            'FontSize', 10,...
            'Value', getappdata(hConf.Axes, 'showControl'),...
            'Callback', {@ConfMapControl, hConf})
        
        zoom reset
    case 2
        
        if getappdata(hConf.Axes, 'showBackground')
            cla(hConf.Axes, 'reset')
            imagesc(getappdata(hConf.Axes, 'background'))
            colormap(gray(256))
            hold on
        end %if
        
        switch hConf.type
            case 'single'
                
                track = get(h.selectedTrackPopup, {'String', 'Value'});
                track = str2double(track{1}(track{2}));
                
                x = v.data{track}(:,1);
                y = v.data{track}(:,2);
                plot(x +1,y +1,'b', 'LineWidth', 1,...
                    'DisplayName', 'free');
                
            case 'group'
                
                x = cellfun(@(x) [x(:,1); nan],v.data(v.track & v.trackActiv),'Un',0);
                y = cellfun(@(x) [x(:,2); nan],v.data(v.track & v.trackActiv),'Un',0);
                
                switch getappdata(hConf.Axes, 'backgroundType')
                    case 'palm'
                        if getappdata(hConf.Axes, 'showBackground')
                            exf = getappdata(hConf.Axes, 'expansionFactor');
                            plot(vertcat(x{:}).*exf+exf*.5,vertcat(y{:}).*exf+exf*.5,'b',...
                                'LineWidth', 1, 'DisplayName', 'free');
                        else
                            plot(vertcat(x{:}) +1,vertcat(y{:}) +1,'b', 'LineWidth', 1,...
                                'DisplayName', 'free');
                            xlim([0 v.settings.Width]); ylim([0 v.settings.Height])
                        end %if
                    otherwise
                        plot(vertcat(x{:}) +1,vertcat(y{:}) +1,'b', 'LineWidth', 1,...
                            'DisplayName', 'free');
                        xlim([0 v.settings.Width]); ylim([0 v.settings.Height])
                end %switch
        end %switch
        
        hold on
        trackListConf = cell2mat(getappdata(hConf.Axes, 'trackListConf'));
        trackListConf(isnan(trackListConf(:,9)),:) = [];
        if ~isempty(trackListConf)
            xConf = accumarray(trackListConf(:,9), trackListConf(:,1),...
                [max(trackListConf(:,9)) 1], @(x) {x});
            yConf = accumarray(trackListConf(:,9), trackListConf(:,2),...
                [max(trackListConf(:,9)) 1], @(x) {x});
            if numel(xConf) == 1
                xConf = xConf{:};
                yConf = yConf{:};
            else
                xConf = padcat(xConf{:});
                yConf = padcat(yConf{:});
            end %if
            
            switch getappdata(hConf.Axes, 'backgroundType')
                case 'palm'
                    if getappdata(hConf.Axes, 'showBackground')
                        h = plot(xConf.*exf+exf*.5,yConf.*exf+exf*.5,'r', 'LineWidth', 2);
                    else
                        h = plot(xConf +1,yConf +1,'r', 'LineWidth', 2);
                    end %if
                otherwise
                    h = plot(xConf +1,yConf +1,'r', 'LineWidth', 2);
            end %switch
            handleGroup(1) = hggroup;
            set(h,'Parent',handleGroup(1))
            set(get(get(handleGroup(1),'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','on');
            set(handleGroup(1), 'DisplayName', 'confinement')
        end
        
        legend(hConf.Axes, 'show')
        xlabel('x-coordinate [px]'); ylabel('y-coordinate [px]');
        axis equal ij
        
        uicontrol(...
            'Parent', hConf.SettingsPanel,...
            'Style', 'checkbox',...
            'Tag', 'groupConf',...
            'Units', 'normalized',...
            'Position', [0.3 0.6 0.4 0.05],...
            'String', 'show Background',...
            'FontSize', 10,...
            'Value', getappdata(hConf.Axes, 'showBackground'),...
            'Callback', {@ConfMapBackground, hConf})
        
        zoom reset
    case 3
        
        colormap('default')
        Lc = getappdata(hConf.Axes, 'confIndex');
        Lc = vertcat(Lc{:});
        Lc(isnan(Lc) | isinf(Lc)) = [];
        Lcontrol = getappdata(hConf.Axes, 'confControl');
        
        bins = calcnbins(nonzeros(Lc), 'fd');
        binWidth = max(nonzeros(Lc))/bins;
        binCtrs = linspace(binWidth, max(nonzeros(Lc)),bins);
        histLc = histc(nonzeros(Lc), binCtrs);
        histLcontrol = histc(nonzeros(Lcontrol), binCtrs);
        
        hold on
        %         h = bar(binCtrs,log([histLcontrol histLc]), 'BarWidth', 1);
        %         colormap([0 0 1; 1 0 0])
        %         set(h(1), 'EdgeColor', 'b', 'DisplayName', 'control')
        %         set(h(2), 'EdgeColor', 'r', 'DisplayName', 'data')
        stem(binCtrs,log(histLc),'r', 'DisplayName', 'data')
        stem(binCtrs,log(histLcontrol),'b', 'DisplayName', 'control')
        
        yLim = get(gca, 'YLim');
        line([getappdata(hConf.Axes, 'confThreshVal'),...
            getappdata(hConf.Axes, 'confThreshVal')],...
            [0 yLim(2)], 'Color', 'k', 'LineWidth', 3, 'DisplayName', 'threshhold')
        text(getappdata(hConf.Axes, 'confThreshVal'), yLim(2),...
            sprintf('\n  min confinement'), 'Color', 'k', 'FontSize', 13)
        axis tight
        legend(hConf.Axes, 'show')
        xlabel('Confinement Index'); ylabel('ln Frequency');
        
        zoom reset
    case 4
        
        trackListConf = cell2mat(getappdata(hConf.Axes, 'trackListConf'));
        trackListConf(isnan(trackListConf(:,9)),:) = [];
        if ~isempty(trackListConf)
            indexVector = 1:size(trackListConf,1);
            iMatrix = accumarray(trackListConf(:,9), indexVector, [],...
                @(x) {repmat(x,1,numel(x))});
            ii = cellfun(@(x) x(tril(true(size(x)),-1)), iMatrix, 'Un', 0);
            iii = cellfun(@(x) x(flipud(tril(true(size(x)),-1))), iMatrix, 'Un', 0);
            confDisplacement = trackListConf(vertcat(ii{:}),1:3) - trackListConf(vertcat(iii{:}),1:3);
            confDisplacement(:,4) = sqrt(sum(confDisplacement(:,1:2).^2,2))*v.px2micron;
            setappdata(hConf.Axes, 'confDisplacement', confDisplacement)
        end %if
        
        trackListFree = cell2mat(getappdata(hConf.Axes, 'trackListFree'));
        trackListFree(isnan(trackListFree(:,9)),:) = [];
        if ~isempty(trackListFree)
            indexVector = 1:size(trackListFree,1);
            iMatrix = accumarray(trackListFree(:,9), indexVector, [],...
                @(x) {repmat(x,1,numel(x))});
            ii = cellfun(@(x) x(tril(true(size(x)),-1)), iMatrix, 'Un', 0);
            iii = cellfun(@(x) x(flipud(tril(true(size(x)),-1))), iMatrix, 'Un', 0);
            freeDisplacement = trackListFree(vertcat(ii{:}),1:3) - trackListFree(vertcat(iii{:}),1:3);
            freeDisplacement(:,4) = sqrt(sum(freeDisplacement(:,1:2).^2,2))*v.px2micron;
            setappdata(hConf.Axes, 'freeDisplacement', freeDisplacement)
        end %if
        
        uicontrol(...
            'Parent', hConf.SettingsPanel,...
            'Style', 'text',...
            'Tag', 'groupConf',...
            'Units', 'normalized',...
            'Position', [0.15 0.53 0.4 0.05],...
            'String', 'Time Step:',...
            'FontSize', 15);
        
        hConf.deltaT =...
            uicontrol(...
            'Parent', hConf.SettingsPanel,...
            'Style', 'edit',...
            'Tag', 'groupConf',...
            'Units', 'normalized',...
            'Position', [0.6 0.53 0.2 0.05],...
            'String', '5',...
            'FontSize', 15);
        
        uicontrol(...
            'Parent', hConf.SettingsPanel,...
            'Style', 'text',...
            'Tag', 'groupConf',...
            'Units', 'normalized',...
            'Position', [0.15 0.58 0.4 0.05],...
            'String', 'Subfractions:',...
            'FontSize', 15);
        
        hConf.fractions =...
            uicontrol(...
            'Parent', hConf.SettingsPanel,...
            'Style', 'edit',...
            'Tag', 'groupConf',...
            'Units', 'normalized',...
            'Position', [0.6 0.58 0.2 0.05],...
            'String', '1',...
            'FontSize', 15);
        
        uicontrol(...
            'Parent', hConf.SettingsPanel,...
            'Style', 'pushbutton',...
            'Tag', 'groupConf',...
            'Units', 'normalized',...
            'Position', [0.15 0.45 0.7 0.05],...
            'String', 'Diffusion Constant',...
            'FontSize', 10,...
            'CreateFcn', {@ConfMapDiffusion, hConf},...
            'Callback', {@ConfMapDiffusion, hConf})
        
        zoom reset
        
    case 5
        
        lengthFree = cell2mat(getappdata(hConf.Axes, 'lengthFree'));
        lengthConf = cell2mat(getappdata(hConf.Axes, 'lengthConf'));
        
        ctrs = linspace(1,max([lengthFree;lengthConf]),...
            calcnbins(lengthFree, 'fd'));
        h = bar(ctrs, [hist(lengthFree,ctrs); hist(lengthConf,ctrs)]');
        set(h(1), 'EdgeColor', 'b', 'DisplayName', 'Free')
        set(h(2), 'EdgeColor', 'r', 'DisplayName', 'Confined')
        
        legend('Location', 'NorthEast')
        axis tight
        xlabel('Time [s]'); ylabel('Frequency');
        
        zoom reset
        
    otherwise
end %switch
end
function ConfMapDiffusion(src, event, hConf)
v = getappdata(1, 'values');

cla (hConf.Axes, 'reset')

deltaT = str2double(get(hConf.deltaT, 'String'));
subfractions = str2double(get(hConf.fractions, 'String'));

dFree = getappdata(hConf.Axes, 'freeDisplacement');
if ~isempty(dFree)
    [pFree,rFree] = ecdf(dFree(dFree(:,3) == deltaT,4));
    [yFree, xFree] = ecdfhist(pFree,rFree,100);
end %if

dConf = getappdata(hConf.Axes, 'confDisplacement');
if ~isempty(dConf)
    [pConf,rConf] = ecdf(dConf(dConf(:,3) == deltaT,4));
    if isempty(dFree)
        [yConf, xConf] = ecdfhist(pConf,rConf,100);
    else
        [yConf, xConf] = ecdfhist(pConf,rConf,xFree);
    end %if
end %if

hold on
if ~isempty(dFree) && ~isempty(dConf)
    h = bar(xFree,[yFree' yConf'], 'BarWidth', 1);
    colormap([0 0 1; 1 0 0])
    set(h(1), 'EdgeColor', 'b', 'DisplayName', 'Free')
    set(h(2), 'EdgeColor', 'r', 'DisplayName', 'Confined')
elseif ~isempty(dFree)
    h = bar(xFree,yFree', 'BarWidth', 1);
    colormap([0 0 1])
    set(h, 'EdgeColor', 'b', 'DisplayName', 'Free')
elseif ~isempty(dConf)
    h = bar(xConf,yConf', 'BarWidth', 1);
    colormap([1 0 0])
    set(h, 'EdgeColor', 'r', 'DisplayName', 'Confined')
end %if


lower = repmat([0 0], 1, subfractions);
upper = repmat([1 1], subfractions, 1);
upper = upper(:);
start = [(1:subfractions)/1000, repmat(1/subfractions, 1, subfractions)];

s = fitoptions('Method', 'NonlinearLeastSquares',...
    'Lower', lower,...
    'Upper', upper,...
    'StartPoint', start);

equation = ['((N1/(4*pi*D1*' num2str(v.settings.Delay*deltaT)...
    '))*exp(-x^2/(4*D1*' num2str(v.settings.Delay*deltaT) '))*2*pi*x)'];

if subfractions > 1
    for n = 2:subfractions
        equation = [equation '+((N' num2str(n) '/(4*pi*D' num2str(n) ...
            '*' num2str(v.settings.Delay*deltaT) '))*exp(-x^2/(4*D' num2str(n)...
            '*' num2str(v.settings.Delay*deltaT) '))*2*pi*x)'];
    end %for
end %if

f = fittype(equation,...
    'options', s,...
    'independent', 'x');

if subfractions == 1
    if ~isempty(dFree)
        [fitDfree statsDfree outputDfree] = fit(xFree',yFree',f);
        h = plot(fitDfree, 'b');
        set(h, 'DisplayName', ['D = ' num2str(fitDfree.D1, '%.3f')...
            ' (adjR^2 = ' num2str(statsDfree.adjrsquare, '%.3f') ')'])
    end %if
    
    if ~isempty(dConf)
        [fitDconf statsDconf outputDconf] = fit(xConf',yConf',f);
        h = plot(fitDconf, 'r');
        set(h, 'DisplayName', ['D = ' num2str(fitDconf.D1, '%.3f')...
            ' (adjR^2 = ' num2str(statsDconf.adjrsquare, '%.3f') ')'])
    end %if
else
    if ~isempty(dFree)
        [fitDfree statsDfree outputDfree] = fit(xFree',yFree',f);
        h = plot(fitDfree, 'b');
        set(h, 'DisplayName', ['Sum Function (adjR^2 = ' num2str(statsDfree.adjrsquare, '%.3f') ')'])
    end %if
    
    if ~isempty(dConf)
        [fitDconf statsDconf outputDconf] = fit(xConf',yConf',f);
        h = plot(fitDconf, 'r');
        set(h, 'DisplayName', ['Sum Function (adjR^2 = ' num2str(statsDconf.adjrsquare, '%.3f') ')'])
    end %if
    for n = 1:subfractions
        if ~isempty(dFree)
            freeD(n) = eval(['fitDfree.D' num2str(n)]);
            freeN(n) = eval(['fitDfree.N' num2str(n)]);
            h = plot(xFree,((freeN(n)/(4*pi*freeD(n)*v.settings.Delay*...
                deltaT)))*exp(-xFree.^2/(4*freeD(n)*v.settings.Delay*...
                deltaT))*2*pi.*xFree, 'b:');
            
            set(h, 'DisplayName', [num2str(freeN(n)*100','%.1f')...
                '% D = ' num2str(freeD(n),'%.3f') ' ?m^2/s'])
        end %if
        
        if ~isempty(dConf)
            confD(n) = eval(['fitDconf.D' num2str(n)]);
            confN(n) = eval(['fitDconf.N' num2str(n)]);
            h = plot(xFree,((confN(n)/(4*pi*confD(n)*v.settings.Delay*...
                deltaT)))*exp(-xFree.^2/(4*confD(n)*v.settings.Delay*...
                deltaT))*2*pi.*xFree, 'r:');
            
            set(h, 'DisplayName', [num2str(confN(n)*100','%.1f')...
                '% D = ' num2str(confD(n),'%.3f') ' ?m^2/s'])
        end %if
    end %for
end %if

legend('Location', 'NorthEast')
axis tight
xlabel('Step Length [?m]'); ylabel('Probability Density');
end
function ConfMapIndex(src, event, hConf)

cla(hConf.Axes, 'reset')
legend(hConf.Axes,'off')
delete(findobj('Tag', 'axesLocalD'))

track = get(src, {'String', 'Value'});
track = str2double(track{1}(track{2}));
Lc = getappdata(hConf.Axes, 'confIndex');
localD = getappdata(hConf.Axes, 'localD');
beginConf = getappdata(hConf.Axes, 'beginConf');
endConf = getappdata(hConf.Axes, 'endConf');

set(hConf.Axes, 'Position', [0.4 0.1 0.5 0.39])
if isnan(track)
    Lc = vertcat(Lc{:});
    localD = horzcat(localD{:})';
    %     beginConf = vertcat(beginConf{:});
    %     endConf = vertcat(endConf{:});
    hold on
    %     patch([beginConf beginConf endConf endConf]',...
    %         repmat([0; max(Lc); max(Lc); 0],1,numel(beginConf)),...
    %         [0.85 0.85 0.85], 'EdgeColor', [0.85 0.85 0.85], 'DisplayName', 'confinement');
    if getappdata(hConf.Axes, 'showControl')
        area(getappdata(hConf.Axes, 'confControl'),'FaceColor', 'b',...
            'EdgeColor', 'b', 'DisplayName', 'control')
    end %if
    plot(Lc,'Color', 'r', 'LineWidth', 0.5, 'DisplayName', 'data')
    plot(smooth(Lc,100),'g','LineWidth',3, 'DisplayName', 'smoothed data')
    line([0 numel(Lc)], [getappdata(hConf.Axes, 'confThreshVal')...
        getappdata(hConf.Axes, 'confThreshVal')], 'Color', 'k',...
        'LineWidth', 3, 'DisplayName', 'threshhold')
    axis tight
    legend(hConf.Axes,'show')
    xlabel('Track'); ylabel('Confinement Index');
    set(gca, 'XTick', [])
    
    axes('Tag', 'axesLocalD', 'Position', [0.4 0.51 0.5 0.39])
    hold on
    %     patch([beginConf beginConf endConf endConf]',...
    %         repmat([0; max(localD); max(localD); 0],1,numel(beginConf)),...
    %         [0.85 0.85 0.85], 'EdgeColor', [0.85 0.85 0.85], 'DisplayName', 'confinement');
    plot(localD,'Color', 'r', 'LineWidth', 0.5, 'DisplayName', 'data')
    plot(smooth(localD,100),'g','LineWidth',3, 'DisplayName', 'smoothed data')
    axis tight
    ylabel('Local Diffusion [?m^2/s]');
    set(gca, 'XTick', [])
    
    linkaxes([gca, hConf.Axes],'x');
else
    v = getappdata(1, 'values');
    
    %trackList =
    %vertcat(v.data{str2num(cell2mat(get(v.singleTrackSelected, 'String')))});
    beginConf = beginConf{track};
    endConf = endConf{track};
    
    axes(hConf.Axes)
    set(hConf.Axes, 'ButtonDownFcn', {@selectData, track, hConf})
    hold on
    if ~isempty(beginConf)
        patch([beginConf beginConf endConf endConf]',...
            repmat([0; max(Lc{track}); max(Lc{track}); 0],1,numel(beginConf)),...
            [0.85 0.85 0.85], 'EdgeColor', [1 1 1], 'DisplayName', 'confinement');
    end %if
    if getappdata(hConf.Axes, 'showControl')
        control = simBrown(0,0,v.trackLifeTime(track),1,...
            getappdata(hConf.Axes, 'Dmax'),v.settings.Delay,...
            v.px2micron);
        iConfControl = calcConf(getappdata(hConf.Axes, 'Dmax'),...
            control(:,1), control(:,2), control(:,3),v.settings.Delay,...
            getappdata(hConf.Axes, 'calcWindowVal'), getappdata(hConf.Axes, 'method'),...
            v.px2micron);
        area(iConfControl,'FaceColor', 'b',...
            'EdgeColor', 'b', 'DisplayName', 'control')
    end %if
    plot(Lc{track},'Color', 'r', 'LineWidth', 0.5, 'DisplayName', 'data')
    plot(smooth(Lc{track},100),'g','LineWidth',3, 'DisplayName', 'smoothed data')
    line([0 numel(Lc{track})], [getappdata(hConf.Axes, 'confThreshVal')...
        getappdata(hConf.Axes, 'confThreshVal')], 'Color', 'k',...
        'LineWidth', 3, 'DisplayName', 'threshhold')
    axis tight
    legend(hConf.Axes,'show')
    xlabel('Window Position'); ylabel('Confinement Index');
    
    axes('Tag', 'axesLocalD', 'Position', [0.4 0.51 0.5 0.39],...
        'ButtonDownFcn', {@selectData, track, hConf})
    hold on
    patch([beginConf beginConf endConf endConf]',...
        repmat([0; max(localD{track}); max(localD{track}); 0],1,numel(beginConf)),...
        [0.85 0.85 0.85], 'EdgeColor', [0.85 0.85 0.85], 'DisplayName', 'confinement');
    plot(localD{track},'Color', 'r', 'LineWidth', 0.5, 'DisplayName', 'data')
    plot(smooth(localD{track},100),'g','LineWidth',3, 'DisplayName', 'smoothed data')
    axis tight
    ylabel('Local Diffusion [?m^2/s]');
    set(gca, 'XTick', [])
    
    linkaxes([gca, hConf.Axes],'x');
end

zoom reset
end
function ConfMapBackground(src, event, hConf)
h = getappdata(1, 'handles');
v = getappdata(1, 'values');

if get(src, 'Value')
    setappdata(hConf.Axes, 'showBackground', 1)
    if isempty(getappdata(hConf.Axes, 'background'))
        answer = questdlg('Type of Background Image:','',...
            'Single Image', 'Image Stack', 'Palm Image', 'Single Image');
        
        [filename, pathname] =...
            uigetfile('*.tif', 'Select Image',getappdata(1,'searchPath'));
        
        switch answer
            case 'Single Image'
                
                I = imread([pathname filename],1);
                
                answer = questdlg('Visualisation Style:','',...
                    'gray scale', 'pseudo colored', 'gray scale');
                switch answer
                    case 'gray scale'
                        colormap('gray')
                        
                        answer = questdlg('Gray Scale Order:','',...
                            'normal', 'inverted', 'normal');
                        switch answer
                            case 'normal'
                                imagesc(I)
                            case 'inverted'
                                imagesc(imcomplement(I))
                        end %switch
                    case 'pseudo colored'
                end %switch
                
                graphOrderList = allchild(gca);
                set(gca, 'Children',...
                    [graphOrderList(2:end); graphOrderList(1)])
                
            case 'Image Stack'
                
                I = zeros(v.settings.Height,...
                    v.settings.Width,...
                    v.settings.Frames, 'uint16');
                
                info = imfinfo([pathname filename]);
                
                hProgressbar = waitbar(0,'Loading Stack','Color',...
                    get(0,'defaultUicontrolBackgroundColor'));
                for N = 1:v.settings.Frames
                    I(:,:,N) = imread([pathname filename],N, 'Info', info);
                    waitbar(N/v.settings.Frames,hProgressbar,...
                        'Loading Stack','Color',...
                        get(0,'defaultUicontrolBackgroundColor'));
                end %for
                delete(hProgressbar)
                
                answer = questdlg('Visualisation Style:','',...
                    'gray scale', 'pseudo colored', 'gray scale');
                switch answer
                    case 'gray scale'
                        colormap('gray')
                        
                        answer = questdlg('Stack Unification Method:','',...
                            'max', 'average', 'variance', 'average');
                        
                        switch answer
                            case 'max'
                                I = max(I,[],3);
                            case 'average'
                                I = mean(I,3);
                            case 'variance'
                                I = var(single(I),[],3);
                        end %switch
                        
                        answer = questdlg('Gray Scale Order:','',...
                            'normal', 'inverted', 'normal');
                        switch answer
                            case 'normal'
                                imagesc(I)
                            case 'inverted'
                                imagesc(imcomplement(I))
                        end %switch
                        
                    case 'pseudo colored'
                end %switch
                
                graphOrderList = allchild(gca);
                set(gca, 'Children',...
                    [graphOrderList(2:end); graphOrderList(1)])
                
            case 'Palm Image'
                
                cla reset
                I = imread([pathname filename],1);
                imagesc(I);
                colormap('gray')
                
                exf = str2double(cell2mat(inputdlg('Set PALM Expansion Factor:','',...
                    1,{'12'})));
                
                x = cellfun(@(x) [x(:,1); nan],v.data(v.track & v.trackActiv),'Un',0);
                y = cellfun(@(x) [x(:,2); nan],v.data(v.track & v.trackActiv),'Un',0);
                hold on
                plot(vertcat(x{:}).*exf+exf*.5,vertcat(y{:}).*exf+exf*.5,'b', 'LineWidth', 1,...
                    'DisplayName', 'free');
                axis equal ij
                
                trackListConf = cell2mat(getappdata(hConf.Axes, 'trackListConf'));
                trackListConf(isnan(trackListConf(:,10)),:) = [];
                if ~isempty(trackListConf)
                    xConf = accumarray(trackListConf(:,10), trackListConf(:,1),...
                        [max(trackListConf(:,10)) 1], @(x) {x});
                    yConf = accumarray(trackListConf(:,10), trackListConf(:,2),...
                        [max(trackListConf(:,10)) 1], @(x) {x});
                    if numel(xConf) == 1
                        xConf = xConf{:};
                        yConf = yConf{:};
                    else
                        xConf = padcat(xConf{:});
                        yConf = padcat(yConf{:});
                    end %if
                    
                    
                    h = plot(xConf.*exf+exf*.5,yConf.*exf+exf*.5,'r', 'LineWidth', 2);
                    handleGroup(1) = hggroup;
                    set(h,'Parent',handleGroup(1))
                    set(get(get(handleGroup(1),'Annotation'),'LegendInformation'),...
                        'IconDisplayStyle','on');
                    set(handleGroup(1), 'DisplayName', 'confinement')
                end
                zoom reset
                setappdata(hConf.Axes, 'backgroundType', 'palm')
                setappdata(hConf.Axes, 'expansionFactor', exf)
        end
        
        setappdata(hConf.Axes, 'background', I)
        
    else
        ConfChangePlot(src, event, hConf)
    end %if
else
    setappdata(hConf.Axes, 'showBackground', 0)
    ConfChangePlot(src, event, hConf)
end %if
end
function ConfMapControl(src, event, hConf)
if get(src, 'Value')
    setappdata(hConf.Axes, 'showControl', 1)
    ConfChangePlot(src, event,  hConf)
else
    setappdata(hConf.Axes, 'showControl', 0)
    ConfChangePlot(src, event,  hConf)
end %if
end

function [Dlocal AnomalousCoeff] = calcDlocal(x,y,frame,w,lagTime,px2micron)
%Calculates the local Diffusion inside moving timewindow
%
%
% INPUT:
%           x (Vector; x-coordinates [px])
%           y (Vector; y-coordinates [px])
%           lagTime(scalar; [s])
%           w (scalar; calculation Window [Frames])
%
% OUTPUT:
%           D (Vector of Diffusion Coefficients)
%
% written by C.P.Richter
% version 10.06.12
[nrSeg idxSeg ptsSeg lifeTime w] = segmentTrack(frame,w);

% Dlocal = zeros(nrSeg,1);
if nrSeg > 0
    x = accumarray(1+frame-frame(1),x,[lifeTime 1],[],nan);
    y = accumarray(1+frame-frame(1),y,[lifeTime 1],[],nan);
    frame = (1:lifeTime)';
    
    iMat = repmat(idxSeg(:,1),1,w);
    good = tril(true(w),-1);
    ii = iMat(good);
    iii = iMat(flipud(good));
        
    iSeg = repmat(0:nrSeg-1,sum(idxSeg(1:end-1,1)),1);
    ii = repmat(ii,1,nrSeg)+iSeg;
    iii = repmat(iii,1,nrSeg)+iSeg;
        
    sd = ((x(ii)-x(iii)).^2 +...
        (y(ii)-y(iii)).^2)*px2micron^2;
    stepLength = frame(ii)-frame(iii);
        
    stepLength = stepLength(w:6*w-21,:); %analyse 2:6 steps
    sd = sd(w:6*w-21,:);
        
    subs = bsxfun(@plus,stepLength,0:5:(nrSeg-1)*5)-1;
        
    msd = reshape(accumarray(subs(:),...
        sd(:),[],@nanmean), 5, nrSeg);
    t = [ones(5,1) log(4*(2:6)*lagTime)'];
    
    % mean moment displacement = Dlocal*4t^AnomalousCoeff
    yHat = t\log(msd);
    Dlocal = exp(yHat(1,:));
    AnomalousCoeff = yHat(2,:);
    
    %Dlocal(ptsSeg < w/2) = nan; %discard if less than w/2 ponts inside w
end
end
function [iConf refPoint displacement] =...
    calcConf(D, x ,y, frame, lagTime, w, method,px2micron)
%Calculates the Confinement Index inside moving time-window
%
%
% INPUT:
%           D (Scalar; Dmax [?m^2/s])
%           x (Vector; x-coordinates [px])
%           y (Vector; y-coordinates [px])
%           lagTime(scalar; [s])
%           w (scalar; calculation Window [Frames])
%           method (scalar, defines Algorithm)
%
% OUTPUT:
%           iConf (Vector of Confinement Indizes)
%
% written by C.P.Richter
% version 10.05.04

[nrSeg idxSeg ptsSeg lifeTime] = segmentTrack(frame,w);
iConf = zeros(nrSeg,1);
refPoint = zeros(nrSeg,1);
displacement = zeros(nrSeg,1);

if nrSeg > 0
    x = accumarray(1+frame-frame(1),x,[lifeTime 1],[],nan);
    y = accumarray(1+frame-frame(1),y,[lifeTime 1],[],nan);
    
    switch method
        
        case 'varM' %Meilhac
            
            refPoint = idxSeg(ceil(w/2),:);
            segMiddle = repmat(refPoint,w,1);
            displacement = nanvar(reshape(sqrt(((x(idxSeg)-x(segMiddle))*px2micron).^2 +...
                ((y(idxSeg)-y(segMiddle))*px2micron).^2),w,nrSeg),[],1);
            
            iConf(:) = D * w * lagTime ./ displacement;
            
        case 'conf' %Saxton
            
            refPoint = idxSeg(1,:);
            segStart = repmat(refPoint,w,1);
            displacement = max(reshape(sqrt(((x(idxSeg)-x(segStart))*px2micron).^2 +...
                ((y(idxSeg)-y(segStart))*px2micron).^2),w,nrSeg));
            psi = exp(0.2048 - (2.5117 * D * (w - 1 * lagTime))./...
                displacement);
            iConf(psi < 0.1) = -1*log(psi(psi < 0.1)) -1;
            
    end %switch
end %if
end

function [nrSeg idxSeg ptsSeg lifeTime w] = segmentTrack(frame,w)
%Segmentises a track using a constant moving time-window
%
% INPUT:
%           frame (Vector; Frames the particle was detected)
%           w (Scalar; Size of time-window [frames])
%
% OUTPUT:
%           nrSeg (Scalar; Number of segments)
%           idxSeg (Matrix; Indizes of segments as columnvectors)
%           ptsSeg (Vector; Number of detections in each segment)
%           lifeTime (Scalar; Time the particle was observed [frames])
%
% written by C.P.Richter
% version 10.06.18

lifeTime = 1+frame(end)-frame(1);

nrSeg = lifeTime-w+1;
if nrSeg < 1
    nrSeg = 1;
    w = lifeTime;
end %if

[segMat,wMat] = meshgrid(1:nrSeg ,0:w-1);
idxSeg = segMat + wMat;

frame = accumarray(1+frame-frame(1),frame,[lifeTime 1],[],nan);
ptsSeg = w-sum(isnan(frame(idxSeg)));
end
function [beginEvent endEvent lengthEvent...
    beginGround endGround lengthGround] =...
    getConfBounds(data, yThresh, xThresh)
%Quantifies Events in two State Trajectory
%
%
% INPUT:
%
% OUTPUT:
%
% written by C.P.Richter
% version 10.06.01

if isempty(data)
    
    beginEvent = [];
    endEvent = [];
    lengthEvent = [];
    beginGround = [];
    endGround = [];
    lengthGround = [];
    
else
    
    nrW = numel(data); %nr of calculated time-windows
    
    endEvent = find(diff(data >= yThresh) == -1); %transition 0 -> 1
    beginGround = endEvent + 1;
    
    endGround = find(diff(data >= yThresh) == +1); %transition 1 -> 0
    beginEvent = endGround + 1;
    
    %evaluate trajectory bounds
    if data(1) > yThresh %event starts
        beginEvent = [1; beginEvent];
    else
        beginGround = [1; beginGround];
    end
    
    if data(end) > yThresh %event ends
        endEvent = [endEvent; nrW];
    else
        endGround = [endGround; nrW];
    end
    
    lengthEvent = (endEvent-beginEvent)+1;
    %check if event is long enough
    goodEvent = lengthEvent >= xThresh;
    
    beginEvent = beginEvent(goodEvent);
    endEvent = endEvent(goodEvent);
    lengthEvent = lengthEvent(goodEvent);
    
    lengthGround = (endGround-beginGround)+1;
end
end
function [trackListGround trackListEvent pntGround pntEvent] = getConfPeriods(...
    track,beginEvent,endEvent,lengthEvent,beginGround,endGround,lengthGround,w,nrGround,nrEvent)
%Seperates Traces into two States
%
%
% INPUT:
%
% OUTPUT:
%
% written by C.P.Richter
% version 10.06.01

if isempty(beginEvent) %no events
    
    trackListGround = [track ones(size(track,1),1)+nrGround];
    trackListEvent = nan(1,9);
    pntEvent = zeros(size(track,1));
    pntGround = w-pntEvent;
    
elseif isempty(beginGround)
    
    trackListEvent = [track ones(size(track,1),1)+nrEvent];
    trackListGround = nan(1,9);
    pntEvent = ones(size(track,1))*w;
    pntGround = w-pntEvent;
    
else %both
    
    [nrSeg idxSeg unused unused] = segmentTrack(track(:,3),w);
    good = arrayfun(@(x) ge(x,beginEvent') &...
        le(x,endEvent'), idxSeg(1,:), 'Un',0);
    [good unused] = find(vertcat(good{:}));
    [pntEvent cnt] = hist(reshape(idxSeg(:,good),[],1),1:track(end,3));
    pntEvent = pntEvent(ismember(cnt,track(:,3)));
    pntGround = w-pntEvent;
    
    idxSeg = idxSeg+track(1,3)-1; %idx2frame transform
    EventBounds = [idxSeg(1,beginEvent); idxSeg(end,endEvent)];
    good = arrayfun(@(x) ge(x,EventBounds(1,:)) &...
        le(x,EventBounds(2,:)), track(:,3), 'Un',0);
    [good segment] = find(vertcat(good{:}));
    trackListEvent = [track(good,:) segment+nrEvent];
    
    GroundBounds = [idxSeg(1,beginGround); idxSeg(end,endGround)];
    good = arrayfun(@(x) ge(x,GroundBounds(1,:)) &...
        le(x,GroundBounds(2,:)), track(:,3), 'Un',0);
    [good segment] = find(vertcat(good{:}));
    trackListGround = [track(good,:) segment+nrGround];    
end
end
function data = simBrown(x0, y0, length, N, D, lagTime,px2micron)
%Simulates a set of brownian Diffuser
%
%
% INPUT:
%
% OUTPUT:
%
% written by C.P.Richter
% version 10.05.20

data = ones(length, 4, N);
data(:,3,:) = (1:length)'*ones(1,N);
data(:,4,:) = ones(length,1)*(1:N);

sigma = sqrt(2*(D/px2micron^2)*lagTime);
data(:,1:2,:) = cumsum([randn([length 1 N])...
    randn([length 1 N])]*sigma,1);

data(:,1,:) = data(:,1,:)+x0;
data(:,2,:) = data(:,2,:)+y0;

if N > 1
    data = squeeze(mat2cell(data, length, 4, ones(1,N)))';
end
end

%%global functions
function [SD maxSD minSD stepLength] = calcSD(track, calcMax, calcMin)
%Calculates the Square Displacement, max and min Square Displacement and
%timedifference between jumps
%
%
% INPUT:
%
% OUTPUT:
%
% written by C.P.Richter
% version 10.05.04
v = getappdata(1, 'values');

%preallocate space
[stepLength SD maxSD minSD] = deal(cell(1,v.tracksTotal));

for N = track
    x = repmat(v.data{N}(:,1),1,v.trackLength(N));
    y = repmat(v.data{N}(:,2),1,v.trackLength(N));
    f = repmat(v.data{N}(:,3),1,v.trackLength(N));
    
    good = tril(true(v.trackLength(N)),-1);
    
    SD{N} = ((x(good)-x(flipud(good))).^2 +...
        (y(good)-y(flipud(good))).^2)*v.px2micron^2;
    stepLength{N} = f(good)-f(flipud(good));
    
    if calcMax
        maxSD{N} = nonzeros(accumarray(stepLength{N}, SD{N},[],@max));
    end %if
    
    if calcMin
        minSD{N} = nonzeros(accumarray(stepLength{N}, SD{N},[],@min));
    end %if
    
end %for
end
function [hLine hText] = scalebar(px2micronFactor,...
    micronBarLength, barPos,...
    barColor, borderDistance, axesHandle)
%Plots a scalebar into specified axes showing microns as the distance
%metric using a defined transformationfactor for the data.
%
% INPUT:
%           px2micronFactor
%           micronBarLength (in micron)
%           barPos ('NW' for upper left and 'SW' for lower left)
%           barColor (1x3 Vektor or Matlab-specific Colorstring)
%           borderDistance (Percentage of Axisrange)
%           axesHandle
% OUTPUT:
%           hLine (handle to line object)
%           hText (handle to text object)
%
% written by C.P.Richter
% version 10.03.21

if nargin < 6
    axisLimits = get(gca,{'XLim','YLim'});
else
    axisLimits = get(axesHandle,{'XLim','YLim'});
end %if
if nargin < 5; borderDistance = 20; end %if
if nargin < 4; barColor = 'k'; end %if
if nargin < 3; barPos = 'SW'; end %if
if nargin < 2; micronBarLength = 5; end %if

switch px2micronFactor
    case '60, 1x'
        pxBarLength = micronBarLength/0.267;
    case '60, 1.6x'
        pxBarLength = micronBarLength/0.180;
    case '150, 1x'
        pxBarLength = micronBarLength/0.105;
    case '150, 1.6x'
        pxBarLength = micronBarLength/0.071;
end %switch

switch barPos
    case 'NW'
        hLine = line([axisLimits{1}(1) + (axisLimits{1}(2) - axisLimits{1}(1))/borderDistance ...
            axisLimits{1}(1) + (axisLimits{1}(2) - axisLimits{1}(1))/borderDistance + pxBarLength],...
            [axisLimits{2}(1) + (axisLimits{2}(2) - axisLimits{2}(1))/borderDistance ...
            axisLimits{2}(1) + (axisLimits{2}(2) - axisLimits{2}(1))/borderDistance]);
        
        hText = text(axisLimits{1}(1) + (axisLimits{1}(2) - axisLimits{1}(1))/borderDistance + pxBarLength/2,...
            axisLimits{2}(1) + (axisLimits{2}(2) - axisLimits{2}(1))/borderDistance, [num2str(micronBarLength),'?m']);
    case 'SW'
        hLine = line([axisLimits{1}(1) + (axisLimits{1}(2) - axisLimits{1}(1))/borderDistance ...
            axisLimits{1}(1) + (axisLimits{1}(2) - axisLimits{1}(1))/borderDistance + pxBarLength],...
            [axisLimits{2}(2) - (axisLimits{2}(2) - axisLimits{2}(1))/borderDistance ...
            axisLimits{2}(2) - (axisLimits{2}(2) - axisLimits{2}(1))/borderDistance]);
        
        hText = text(axisLimits{1}(1) + (axisLimits{1}(2) - axisLimits{1}(1))/borderDistance + pxBarLength/2,...
            axisLimits{2}(2) - (axisLimits{2}(2) - axisLimits{2}(1))/borderDistance, [num2str(micronBarLength),'?m']);
end %switch

set(hLine, 'Color', barColor, 'LineWidth', 3, 'LineStyle', '-')
set(hText, 'Color', barColor, 'FontSize', 10, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'Top')
end
function nbins = calcnbins(x, method, minimum, maximum)
% Calculate the "ideal" number of bins to use in a histogram, using a
% choice of methods.
%
% NBINS = CALCNBINS(X, METHOD) calculates the "ideal" number of bins to use
% in a histogram, using a choice of methods.  The type of return value
% depends upon the method chosen.  Possible values for METHOD are:
% 'fd': A single integer is returned, and CALCNBINS uses the
% Freedman-Diaconis method,
% based upon the inter-quartile range and number of data.
% See Freedman, David; Diaconis, P. (1981). "On the histogram as a density
% estimator: L2 theory". Zeitschrift f?r Wahrscheinlichkeitstheorie und
% verwandte Gebiete 57 (4): 453-476.

% 'scott': A single integer is returned, and CALCNBINS uses Scott's method,
% based upon the sample standard deviation and number of data.
% See Scott, David W. (1979). "On optimal and data-based histograms".
% Biometrika 66 (3): 605-610.
%
% 'sturges': A single integer is returned, and CALCNBINS uses Sturges'
% method, based upon the number of data.
% See Sturges, H. A. (1926). "The choice of a class interval". J. American
% Statistical Association: 65-66.
%
% 'middle': A single integer is returned.  CALCNBINS uses all three
% methods, then picks the middle (median) value.
%
% 'all': A structure is returned with fields 'fd', 'scott' and 'sturges',
% each containing the calculation from the respective method.
%
% NBINS = CALCNBINS(X) works as NBINS = CALCNBINS(X, 'MIDDLE').
%
% NBINS = CALCNBINS(X, [], MINIMUM), where MINIMUM is a numeric scalar,
% defines the smallest acceptable number of bins.
%
% NBINS = CALCNBINS(X, [], MAXIMUM), where MAXIMUM is a numeric scalar,
% defines the largest acceptable number of bins.
%
% Notes:
% 1. If X is complex, any imaginary components will be ignored, with a
% warning.
%
% 2. If X is an matrix or multidimensional array, it will be coerced to a
% vector, with a warning.
%
% 3. Partial name matching is used on the method name, so 'st' matches
% sturges, etc.
%
% 4. This function is inspired by code from the free software package R
% (http://www.r-project.org).  See 'Modern Applied Statistics with S' by
% Venables & Ripley (Springer, 2002, p112) for more information.
%
% 5. The "ideal" number of depends on what you want to show, and none of
% the methods included are as good as the human eye.  It is recommended
% that you use this function as a starting point rather than a definitive
% guide.
%
% 6. The wikipedia page on histograms currently gives a reasonable
% description of the algorithms used.
% See http://en.wikipedia.org/w/index.php?title=Histogram&oldid=232222820
%
% Examples:
% y = randn(10000,1);
% nb = calcnbins(y, 'all')
%    nb =
%             fd: 66
%          scott: 51
%        sturges: 15
% calcnbins(y)
%    ans =
%        51
% subplot(3, 1, 1); hist(y, nb.fd);
% subplot(3, 1, 2); hist(y, nb.scott);
% subplot(3, 1, 3); hist(y, nb.sturges);
% y2 = rand(100,1);
% nb2 = calcnbins(y2, 'all')
%    nb2 =
%             fd: 5
%          scott: 5
%        sturges: 8
% hist(y2, calcnbins(y2))
%
% See also: HIST, HISTX
%
% $ Author: Richard Cotton $		$ Date: 2008/10/24 $    $ Version 1.5 $

% Input checking
error(nargchk(1, 4, nargin));

if ~isnumeric(x) && ~islogical(x)
    error('calcnbins:invalidX', 'The X argument must be numeric or logical.')
end

if ~isreal(x)
    x = real(x);
    warning('calcnbins:complexX', 'Imaginary parts of X will be ignored.');
end

% Ignore dimensions of x.
if ~isvector(x)
    x = x(:);
    warning('calcnbins:nonvectorX', 'X will be coerced to a vector.');
end

nanx = isnan(x);
if any(nanx)
    x = x(~nanx);
    warning('calcnbins:nanX', 'Values of X equal to NaN will be ignored.');
end

if nargin < 2 || isempty(method)
    method = 'middle';
end

if ~ischar(method)
    error('calcnbins:invalidMethod', 'The method argument must be a char array.');
end

validmethods = {'fd'; 'scott'; 'sturges'; 'all'; 'middle'};
methodmatches = strmatch(lower(method), validmethods);
nmatches = length(methodmatches);
if nmatches~=1
    error('calnbins:unknownMethod', 'The method specified is unknown or ambiguous.');
end
method = validmethods{methodmatches};

if nargin < 3 || isempty(minimum)
    minimum = 1;
end

if nargin < 4 || isempty(maximum)
    maximum = Inf;
end

% Perform the calculation
switch(method)
    case 'fd'
        nbins = calcfd(x);
    case 'scott'
        nbins = calcscott(x);
    case 'sturges'
        nbins = calcsturges(x);
    case 'all'
        nbins.fd = calcfd(x);
        nbins.scott = calcscott(x);
        nbins.sturges = calcsturges(x);
    case 'middle'
        nbins = median([calcfd(x) calcscott(x) calcsturges(x)]);
end

% Calculation details
    function nbins = calcfd(x)
        h = diff(prctile0(x, [25; 75])); %inter-quartile range
        if h == 0
            h = 2*median(abs(x-median(x))); %twice median absolute deviation
        end
        if h > 0
            nbins = ceil((max(x)-min(x))/(2*h*length(x)^(-1/3)));
        else
            nbins = 1;
        end
        nbins = confine2range(nbins, minimum, maximum);
    end

    function nbins = calcscott(x)
        h = 3.5*std(x)*length(x)^(-1/3);
        if h > 0
            nbins = ceil((max(x)-min(x))/h);
        else
            nbins = 1;
        end
        nbins = confine2range(nbins, minimum, maximum);
    end

    function nbins = calcsturges(x)
        nbins = ceil(log2(length(x)) + 1);
        nbins = confine2range(nbins, minimum, maximum);
    end

    function y = confine2range(x, lower, upper)
        y = ceil(max(x, lower));
        y = floor(min(y, upper));
    end

    function y = prctile0(x, prc)
        % Simple version of prctile that only operates on vectors, and skips
        % the input checking (In particluar, NaN values are now assumed to
        % have been removed.)
        lenx = length(x);
        if lenx == 0
            y = [];
            return
        end
        if lenx == 1
            y = x;
            return
        end
        
        function foo = makecolumnvector(foo)
            if size(foo, 2) > 1
                foo = foo';
            end
        end
        
        sortx = makecolumnvector(sort(x));
        posn = prc.*lenx/100 + 0.5;
        posn = makecolumnvector(posn);
        posn = confine2range(posn, 1, lenx);
        y = interp1q((1:lenx)', sortx, posn);
    end
end
function [M, TF] = padcat(varargin)
% PADCAT - concatenate vectors with different lengths by padding with NaN
%
%   M = PADCAT(V1, V2, V3, ..., VN) concatenates the vectors V1 through VN
%   into one large matrix. All vectors should have the same orientation,
%   that is, they are all row or column vectors. The vectors do not need to
%   have the same lengths, and shorter vectors are padded with NaNs.
%   The size of M is determined by the length of the longest vector. For
%   row vectors, M will be a N-by-MaxL matrix and for column vectors, M
%   will be a MaxL-by-N matrix, where MaxL is the length of the longest
%   vector.
%
%   Examples:
%      a = 1:5 ; b = 1:3 ; c = [] ; d = 1:4 ;
%      padcat(a,b,c,d) % row vectors
%         % ->   1     2     3     4     5
%         %      1     2     3   NaN   NaN
%         %    NaN   NaN   NaN   NaN   NaN
%         %      1     2     3     4   NaN
%      CC = {d.' a.' c.' b.' d.'} ;
%      padcat(CC{:}) % column vectors
%         %      1     1   NaN     1     1
%         %      2     2   NaN     2     2
%         %      3     3   NaN     3     3
%         %      4     4   NaN   NaN     4
%         %    NaN     5   NaN   NaN   NaN
%
%   [M, TF] = PADCAT(..) will also return a logical matrix TF with the same
%   size as R having true values for those positions that originate from an
%   input vector. This may be useful if any of the vectors contain NaNs.
%
%   Example:
%       a = 1:3 ; b = [] ; c = [1 NaN] ;
%       [M,tf] = padcat(a,b,c)
%       % find the original NaN
%       [Vev,Pos] = find(tf & isnan(M))
%       % -> Vec = 3 , Pos = 2
%
%   Scalars will be concatenated into a single column vector.
%
%   See also CAT, RESHAPE, STRVCAT, CHAR, HORZCAT, VERTCAT, ISEMPTY
%            NONES, GROUP2CELL (Matlab File Exchange)

% for Matlab 2008
% version 1.0 (feb 2009)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History
% 1.0 (feb 2009) -

% Acknowledgements:
% Inspired by padadd.m (feb 2000) Fex ID 209 by Dave Johnson

error(nargchk(1,Inf,nargin)) ;

% check the inputs
SZ = cellfun(@size,varargin,'UniformOutput',false) ; % sizes
Ndim = cellfun(@ndims,varargin) ; %

if ~all(Ndim==2)
    error([mfilename ':WrongInputDimension'], ...
        'Input should be vectors.') ;
end

TF = [] ; % default second output so we do not have to check all the time

% for 2D matrices (including vectors) the size is a 1-by-2 vector
SZ = cat(1,SZ{:}) ;
maxSZ = max(SZ) ;    % probable size of the longest vector

if ~any(maxSZ == 1),  % hmm, not all elements are 1-by-N or N-by-1
    % 2 options ...
    if any(maxSZ==0),
        % 1) all inputs are empty
        M  = [] ;
        return
    else
        % 2) wrong input
        % Either not all vectors have the same orientation (row and column
        % vectors are being mixed) or an input is a matrix.
        error([mfilename ':WrongInputSize'], ...
            'Inputs should be all row vectors or all column vectors.') ;
    end
end

if nargin == 1,
    % single input, nothing to concatenate ..
    M = varargin{1} ;
else
    % If the input were row vectors stack them into one large column, for
    % column vectors stack them into one large row
    
    dim = (maxSZ(1)==1) + 1 ;      % Find out the dimension to work on
    X = cat(dim, varargin{:}) ;    % make one big list
    
    % we will use linear indexing, which operates along columns. We apply a
    % transpose at the end if the input were row vectors.
    
    if maxSZ(dim) == 1,
        % if all inputs are scalars, ...
        M = X ;   % copy the list
    elseif all(SZ(:,dim)==SZ(1,dim)),
        % all vectors have the same length
        M = reshape(X,SZ(1,dim),[]) ;% copy the list and reshape
    else
        % We do have vectors of different lengths.
        % Pre-allocate the final output array as a column oriented array. We
        % make it one larger to accommodate the largest vector as well.
        M = zeros([maxSZ(dim)+1 nargin]) ;
        % where do the fillers begin in each column
        M(sub2ind(size(M), SZ(:,dim).'+1, 1:nargin)) = 1 ;
        % Fillers should be put in after that position as well, so applying
        % cumsum on the columns
        % Note that we remove the last row; the largest vector will fill an
        % entire column.
        M = cumsum(M(1:end-1,:),1) ; % remove last row
        
        % If we need to return position of the non-fillers we will get them
        % now. We cannot do it afterwards, since NaNs may be present in the
        % inputs.
        if nargout>1,
            TF = ~M ;
            % and make use of this logical array
            M(~TF) = NaN ; % put the fillers in
            M(TF)  = X ;   % put the values in
        else
            M(M==1) = NaN ; % put the fillers in
            M(M==0) = X ;   % put the values in
        end
    end
    
    if dim == 2,
        % the inputs were row vectors, so transpose
        M = M.' ;
        TF = TF.' ; % was initialized as empty if not requested
    end
end % nargin == 1

if nargout > 1 && isempty(TF),
    % in this case, the inputs were all empty, all scalars, or all had the
    % same size.
    TF = true(size(M)) ;
end
end
function pos = figPos(ratio)

scrSize = get(0, 'ScreenSize');

if ratio > 1
    
    pos = [0.3 0.09...
        0.65*scrSize(4)/scrSize(3) 0.65/ratio];
    
elseif ratio < 1
    
    pos = [0.3 0.09...
        0.65*scrSize(4)/scrSize(3)*ratio 0.65];
    
else
    
    pos = [0.3 0.09...
        0.65*scrSize(4)/scrSize(3) 0.65];
    
end %if
end
function varExport(src, event, hFig, varList)
[selection, isSelected] =...
    listdlg(...
    'Name', 'Data 2 Excel',...
    'PromptString','Select a Variable:',...
    'OKString', 'Export',...
    'ListString',varList);
variables = getappdata(hFig, 'variables');

if isSelected
    [filename,pathname,isFile] =...
        uiputfile('.xls' ,'Save Variables to',...
        [getappdata(1,'searchPath') 'Variables.xls']);
    if isFile
        hProgressbar = waitbar(0,'Exporting...','Color',...
            get(0,'defaultUicontrolBackgroundColor'));
        warning off MATLAB:xlswrite:AddSheet
        for N = selection
            if iscell(variables{N})
                for M = 1:numel(variables{N})
                    xlswrite([pathname filename], variables{N}{M},...
                        [varList{N} num2str(M)])
                end %for
            else
                xlswrite([pathname filename], variables{N}, varList{N})
            end %if
            waitbar(N/numel(selection),hProgressbar,...
                'Exporting... ' ,'Color',...
                get(0,'defaultUicontrolBackgroundColor'));
        end %for
        delete(hProgressbar)
    end %if
end %if
end

function initializeVarList(src,event,id)
switch id
    case 'Track Movie'
        varList.saveas = 1;
        varList.visMode = false;
        varList.isScalebar = false;
        varList.valScalebar = 1000; %[nm]
        varList.isColormap = false;
        varList.isTimestamp = false;
        varList.valTimestamp = 0.032; %[s]
        varList.isRoi = false;
        varList.isShowDetect = false;
end %switch
setappdata(src,'varList',varList')
end
function settingsTrackMovie(src,event)
switch get(src,'Value')
    case 1
        varList = getappdata(src,'varList');
        
        fig =...
            figure(...
            'Tag', 'figSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.7 0.3 0.2 0.4],...
            'Color', get(0,'defaultUicontrolBackgroundColor'),...
            'Name', 'Settings Track Movie',...
            'NumberTitle', 'off',...
            'MenuBar', 'none',...
            'ToolBar', 'none',...
            'Resize', 'off',...
            'DeleteFcn', {@updateVarList,src,varList});
        
        uicontrol(...
            'Style', 'text',...
            'Parent', fig,...
            'Units','normalized',...
            'Position', [0.05 0.8 0.25 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', 'Save as:',...
            'HorizontalAlignment', 'left');
        
        uicontrol(...
            'Style', 'popupmenu',...
            'Parent', fig,...
            'Tag', 'saveasVarSetTrackMovie',...
            'Units', 'normalized',...
            'Position', [0.4 0.8 0.3 0.1],...
            'String', {'TIFF','AVI'},...
            'Value', varList.saveas,...
            'FontSize', 12,...
            'FontUnits', 'normalized');
        
        uicontrol(...
            'Style', 'checkbox',...
            'Parent', fig,...
            'Tag', 'visStyleVarSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.05 0.7 0.9 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', 'Trajactories are only visible',...
            'Value', varList.visMode);
        uicontrol(...
            'Style', 'text',...
            'Parent', fig,...
            'Units','normalized',...
            'Position', [0.15 0.6 0.8 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', 'during Particles ON-Time',...
            'HorizontalAlignment', 'left');
        
        uicontrol(...
            'Style', 'checkbox',...
            'Parent', fig,...
            'Tag', 'isShowDetectVarSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.05 0.5 0.9 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', 'Show Particle Detections',...
            'Value', varList.isShowDetect);
        
        uicontrol(...
            'Style', 'checkbox',...
            'Parent', fig,...
            'Tag', 'isRoiVarSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.05 0.4 0.9 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', 'Set Region of Interest',...
            'Value', varList.isRoi);
        
        uicontrol(...
            'Style', 'checkbox',...
            'Parent', fig,...
            'Tag', 'isScalebarVarSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.05 0.25 0.7 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', 'show Scalebar [nm]:',...
            'HorizontalAlignment', 'left',...
            'Value', varList.isScalebar);
        
        uicontrol(...
            'Style', 'edit',...
            'Parent', fig,...
            'Tag', 'valScalebarVarSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.75 0.25 0.2 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', varList.valScalebar);
        
        uicontrol(...
            'Style', 'checkbox',...
            'Parent', fig,...
            'Tag', 'isColormapVarSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.05 0.15 0.7 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', 'show Colormap',...
            'HorizontalAlignment', 'left',...
            'Value', varList.isColormap);
        
        uicontrol(...
            'Style', 'checkbox',...
            'Parent', fig,...
            'Tag', 'isTimestampVarSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.05 0.05 0.7 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', 'show Timestamp [s]:',...
            'HorizontalAlignment', 'left',...
            'Value', varList.isTimestamp);
        
        uicontrol(...
            'Style', 'edit',...
            'Parent', fig,...
            'Tag', 'valTimestampVarSetTrackMovie',...
            'Units','normalized',...
            'Position', [0.75 0.05 0.2 0.1],...
            'FontSize', 12,...
            'FontUnits', 'normalized',...
            'String', varList.valTimestamp);
    case 0
        delete(findobj(0,'Tag', 'figSetTrackMovie'))
end %switch

    function updateVarList(src,event,object,varList)
        varList.saveas = ...
            get(findobj(src,'Tag','saveasVarSetTrackMovie'),'Value');
        varList.visMode = ...
            get(findobj(src,'Tag','visStyleVarSetTrackMovie'),'Value');
        varList.isScalebar = ...
            get(findobj(src,'Tag','isScalebarVarSetTrackMovie'),'Value');
        varList.valScalebar = str2double(...
            get(findobj(src,'Tag','valScalebarVarSetTrackMovie'),'String'));
        varList.isColormap = ...
            get(findobj(src,'Tag','isColormapVarSetTrackMovie'),'Value');
        varList.isTimestamp = ...
            get(findobj(src,'Tag','isTimestampVarSetTrackMovie'),'Value');
        varList.valTimestamp = str2double(...
            get(findobj(src,'Tag','valTimestampVarSetTrackMovie'),'String'));
        varList.isRoi = ...
            get(findobj(src,'Tag','isRoiVarSetTrackMovie'),'Value');
        varList.isShowDetect = ...
            get(findobj(src,'Tag','isShowDetectVarSetTrackMovie'),'Value');
        
        setappdata(object,'varList', varList)
    end
end
function buildTrackMovie(src,event)
v = getappdata(1, 'values');
varList = ...
    getappdata(findobj(get(src,'Parent'),...
    'Tag','buttonSetTrackMovie'),'varList');

[filename, pathname, isOK] = uigetfile(...
    '*.tif', 'Select Background Images',getappdata(1,'searchPath'));
if isOK
    setappdata(1,'searchPath',pathname)
    info = imfinfo([pathname filename]);    
    [moviename,moviepath,isOK] =...
        uiputfile('' ,'Save Movie to',getappdata(1,'searchPath'));
    if isOK
        setappdata(1,'searchPath',moviepath)
        
        % colorcode by track
        cmap = rand(sum(v.track & v.trackActiv),3);
        
        fig =...
            figure(...
            'Tag', 'figBuildTrackMovie',...
            'Units','normalized',...
            'Position', [0.1 0.1 0.8 0.8],...
            'Color', get(0,'defaultUicontrolBackgroundColor'),...
            'Name', 'Track Movie',...
            'NumberTitle', 'off',...
            'MenuBar', 'none',...
            'ToolBar', 'none');
        ax =...
            axes(...
            'Tag', 'axBuildTrackMovie',...
            'Units','normalized',...
            'Position', [0 0 1 1],...
            'XTickLabel','',...
            'YTickLabel','',...
            'ColorOrder', cmap);
        axis image
        
        raw = double(imread([pathname filename],1,'info',info));
        imshow(raw,[min(raw(:)) max(raw(:))]);
        hImTool = imcontrast(ax);
        hAdjImButton = findobj(hImTool, 'String', 'Adjust Data');
        set(hAdjImButton, 'Callback', @getMinMax)
        uiwait(hImTool);
        minmax = evalin('base', 'imMinMax');
        
        cla(ax,'reset')
        I = uint8((raw-minmax(1))/(minmax(2)-minmax(1))*255);
        hI = imshow(I,[0 255]);
        drawnow
        
        if varList.isRoi
            setROI(fig,ax);
            roiElements = get(ax,'UserData');
            roi = get(roiElements{2},'UserData');
            delete(roiElements{1}); delete(roiElements{2})
        else
            roi = [1 1 v.settings.Width v.settings.Height];
        end %if
        I = I(roi(2):roi(2)+roi(4)-1,roi(1):roi(1)+roi(3)-1);
        
        if varList.isColormap
            I = imprintColormap([],[],I,size(I,2),5,1);
        end
        if varList.isScalebar
            I = imprintScalebar([], [], I,size(I,2),...
                size(I,1),1,varList.valScalebar,...
                v.px2micron, 1, 1);
        end %if
        if varList.isTimestamp
            I = imprintTimestamp([], [], I,...
                size(I,2),size(I,1),0, 1, 1);
        end %if
        
        set(hI,'CData',I)
        axis image
        
        trackIdx = v.track & v.trackActiv;
        activeTracks = sum(trackIdx);
        startPnt = 0;
        xCoords = nan(activeTracks,v.settings.Frames-startPnt);
        yCoords = nan(activeTracks,v.settings.Frames-startPnt);
        n = 1;
        for N = find(trackIdx)
            %check if whole trajectory is inside the roi
            if all(v.data{N}(:,1)+1 > roi(1) &...
                    v.data{N}(:,1)+1 < roi(1)+roi(3)-1 &...
                    v.data{N}(:,2)+1 > roi(2) &...
                    v.data{N}(:,2)+1 < roi(2)+roi(4)-1)
                xCoords(n,v.data{N}(:,3)-startPnt) = v.data{N}(:,1)+1;
                yCoords(n,v.data{N}(:,3)-startPnt) = v.data{N}(:,2)+1;
                n = n +1;
            else
                %discard track
                trackIdx(N) = false;
            end %if
        end %for
        %cut nan
        xCoords(n+1:end,:) = []; yCoords(n+1:end,:) = [];
        
        onState = ~isnan(xCoords);
        for N = 2:v.settings.Frames-startPnt
            xCoords(isnan(xCoords(:,N)),N)  = xCoords(isnan(xCoords(:,N)),N-1);
            yCoords(isnan(yCoords(:,N)),N) = yCoords(isnan(yCoords(:,N)),N-1);
        end %for
        lastFrame = cell2mat(...
            cellfun(@(x) x(end,3),v.data(trackIdx),'Un',0))-startPnt;
        xCoords(sub2ind(size(xCoords),1:n-1,lastFrame)) = nan;
        
        %adjust coordinates for Roi
        xCoords = xCoords-roi(1)+1; yCoords = yCoords-roi(2)+1;
        
        if varList.isShowDetect
            rho = [0;0.69;1.39;2.09;2.79;3.49;4.18;4.88;5.58;6.28];
            hDots = patch(repmat(xCoords(onState(:,1),1)',10,1)+...
                cos(rho)*repmat(2,sum(onState(:,1)),1)',...
                repmat(yCoords(onState(:,1),1)',10,1)+...
                sin(rho)*repmat(2,sum(onState(:,1)),1)',...
                repmat(shiftdim([1 0 0],-1),1,sum(onState(:,1))),...
                'EdgeColor', 'none', 'FaceAlpha', 0.3,...
                'Parent', ax);
        end %if
        
        htrack = line([xCoords(:,1),xCoords(:,1)]',[yCoords(:,1),yCoords(:,1)]',...
            'Parent', ax,'LineWidth',2);
        drawnow
        
        exportMovie([moviepath moviename],ax,'initialize',varList,1)
        
        for frame = 2:v.settings.Frames-startPnt
            raw = double(imread([pathname filename],frame,'info',info,...
                'PixelRegion',{[roi(2) roi(2)+roi(4)-1],...
                [roi(1) roi(1)+roi(3)-1]}));
            I = uint8((raw-minmax(1))/(minmax(2)-minmax(1))*255);
            
            if varList.isColormap
                I = imprintColormap([],[],I,size(I,2),5,1);
            end
            if varList.isScalebar
                I = imprintScalebar([], [], I,size(I,2),...
                    size(I,1),1,varList.valScalebar,...
                    v.px2micron, 1, 1);
            end %if
            if varList.isTimestamp
                I = imprintTimestamp([], [], I,...
                    size(I,2),size(I,1),v.settings.Delay*(frame-1), 1, 1);
            end %if
            set(hI,'CData',I)
            
            if varList.isShowDetect
                set(hDots, 'XData', repmat(xCoords(onState(:,frame),frame)',10,1)+...
                    cos(rho)*repmat(2,sum(onState(:,frame)),1)',...
                    'YData', repmat(yCoords(onState(:,frame),frame)',10,1)+...
                    sin(rho)*repmat(2,sum(onState(:,frame)),1)',...
                    'CData', repmat(shiftdim([1 0 0],-1),1,sum(onState(:,frame))))
            end %if
            
            if varList.visMode
                good = ~isnan(xCoords(:,frame));
                set(htrack(good),{'XData',},num2cell(xCoords(good,1:frame),2),...
                    {'YData',},num2cell(yCoords(good,1:frame),2))
                set(htrack(~isnan(xCoords(:,frame-1)) & ~good),'Visible','off');
            else
                set(htrack,{'XData',},num2cell(xCoords(:,1:frame),2),...
                    {'YData',},num2cell(yCoords(:,1:frame),2))
            end %if
            drawnow
            
            exportMovie([moviepath moviename],ax,'append',varList,frame)
        end %for
        exportMovie([moviepath moviename],ax,'finalize',varList,frame)
    end %if
    delete(fig)
    msgbox('Movie Export Done!')
end %if

    function getMinMax(src, event)
        hList = findobj(hImTool, 'Style', 'edit');
        imMinMax = [str2double(get(hList(7), 'String'))...
            str2double(get(hList(6), 'String'))];
        assignin('base', 'imMinMax', imMinMax)
        close(gcbf)
    end
end
function exportMovie(filename,ax,mode,varList,frame)
persistent hMovie

v = getappdata(1, 'values');
format = {'tif','avi'};
format = format{varList.saveas};

I = getframe(ax);

switch format
    case 'tif'
        imwrite(I.cdata,[filename '.tif'],...
            'compression', 'none', 'WriteMode', 'append')
    case 'gif'
        I.cdata = rgb2ind(I.cdata,gray(256));
        imwrite(I.cdata,[filename '.gif'],...
            'WriteMode', 'append')
    case 'avi'
        switch mode
            case 'initialize'
                hMovie = avifile(filename,...
                    'Colormap', gray(256),...
                    'Compression', 'none',...
                    'fps', 32);
                hMovie = addframe(hMovie, I.cdata);
            case 'append'
                hMovie = addframe(hMovie, I.cdata);
            case 'finalize'
                hMovie = close(hMovie);
        end %switch
end %switch
end %function

function I = imprintColormap(src, event, I, width, mapHeight, mode)
if mode == 1
    colorRamp = repmat(round(linspace(0, 255, width)),...
        mapHeight,1);
    I(end-mapHeight+1:end,:) = colorRamp;
else
    cmapWidth = floor(width/4);
    colorRamp = round(linspace(0, 255, cmapWidth));
    colorRamp = repmat([colorRamp,...
        ones(1,cmapWidth)*255, fliplr(colorRamp),...
        zeros(1,width-3*cmapWidth)],mapHeight,1);
    if mode == 3
        colorRamp3D = repmat(round(linspace(0, 255,...
            mapHeight))',1,width);
        I(end-mapHeight+1:end,:,:) =...
            cat(3,colorRamp, fliplr(colorRamp), colorRamp3D);
    else
        I(end-mapHeight+1:end,:,:) =...
            cat(3,colorRamp, fliplr(colorRamp), colorRamp*0);
    end %if
end %if
end
function I = imprintScalebar(src, event, I, width, height,...
    exf, barLength, pxSize, sizeFac, mode)
barUnit = pxChars(height,width,...
    [num2str(barLength) 'nm'],sizeFac);

pxBarLength = round(barLength/(1000*pxSize/exf));
pxBarHeight = ceil(max(exf/3,pxBarLength/20));
bar = ones(pxBarHeight,pxBarLength);

tmp = size(bar,2)-size(barUnit,2);
if tmp > 0
    bar = [[zeros(size(barUnit,1),floor(tmp/2)),...
        barUnit, zeros(size(barUnit,1),ceil(tmp/2))];...
        zeros(2,size(bar,2)); bar];
elseif tmp < 0
    bar = [barUnit;zeros(2,size(barUnit,2));...
        [zeros(pxBarHeight,floor(-tmp/2)),bar,...
        zeros(pxBarHeight,ceil(-tmp/2))]];
else
    bar = [barUnit;zeros(2,size(bar,2));bar];
end %sif

barOffsetX = 4*pxBarHeight;
barOffsetY = 4*pxBarHeight;
offset = height*(width-(size(bar,2)+barOffsetX))+barOffsetY;
idx = find([bar;zeros(height-size(bar,1),...
    size(bar,2))])+offset;

if mode == 1
    I(idx) = 255;
else
    I([idx;idx+height*width;idx+2*height*width]) = 255;
end %if
end
function I = imprintTimestamp(src, event, I, width, height,...
    time, sizeFac, mode)
stamp = pxChars(height,width,...
    [strrep(num2str(time, '%.3f'),'.','p') '_S'],...
    sizeFac);

barOffsetX = ceil(max(sizeFac*2,size(stamp,2)/5));
barOffsetY = barOffsetX;

idx = find([stamp;zeros(height-size(stamp,1),size(stamp,2))])+...
    barOffsetX*height+barOffsetY;
if mode == 1
    I(idx) = 255;
else
    I([idx;idx+height*width;idx+2*height*width]) = 255;
end %if
end
function string = pxChars(N,M,num,scaleFactor) %#ok
n_ = [...
    0 0;...
    0 0;...
    0 0;...
    0 0;...
    0 0] ;%#ok

np = [...
    0;...
    0;...
    0;...
    0;...
    1] ;%#ok

n0 = [...
    1 1 1;...
    1 0 1;...
    1 0 1;...
    1 0 1;...
    1 1 1] ;%#ok
n1 = [...
    0 1 0;...
    0 1 0;...
    0 1 0;...
    0 1 0;...
    0 1 0] ;%#ok
n2= [...
    1 1 1;...
    0 0 1 ;...
    1 1 1;...
    1 0 0;...
    1 1 1] ;%#ok
n3= [...
    1 1 1;...
    0 0 1 ;...
    0 1 1;...
    0 0 1;...
    1 1 1] ;%#ok
n4= [...
    1 0 1;...
    1 0 1 ;...
    1 1 1;...
    0 0 1;...
    0 0 1] ;%#ok
n5 = [...
    1 1 1;...
    1 0 0;...
    1 1 1;...
    0 0 1;...
    1 1 1] ;%#ok
n6= [...
    1 1 1;...
    1 0 0 ;...
    1 1 1;...
    1 0 1;...
    1 1 1] ;%#ok
n7 = [...
    1 1 1;...
    0 0 1;...
    0 1 0;...
    0 1 0;...
    0 1 0] ;%#ok
n8 = [...
    1 1 1;...
    1 0 1;...
    1 1 1;...
    1 0 1;...
    1 1 1] ;%#ok
n9 = [...
    1 1 1;...
    1 0 1;...
    1 1 1;...
    0 0 1;...
    1 1 1] ;%#ok

nA = [...
    0 1 1 1 0;...
    1 0 0 0 1;...
    1 1 1 1 1;...
    1 0 0 0 1;...
    1 0 0 0 1] ;%#ok

nB = [...
    1 1 1 1 0;...
    1 0 0 0 1;...
    1 1 1 1 0;...
    1 0 0 0 1;...
    1 1 1 1 0] ;%#ok

nC = [...
    1 1 1 1 1;...
    1 0 0 0 0;...
    1 0 0 0 0;...
    1 0 0 0 0;...
    1 1 1 1 1] ;%#ok

nD = [...
    1 1 1 1 0;...
    1 0 0 0 1;...
    1 0 0 0 1;...
    1 0 0 0 1;...
    1 1 1 1 0] ;%#ok

nE = [...
    1 1 1 1 1;...
    1 0 0 0 0;...
    1 1 1 1 1;...
    1 0 0 0 0;...
    1 1 1 1 1] ;%#ok

nF = [...
    1 1 1 1 1;...
    1 0 0 0 0;...
    1 1 1 1 1;...
    1 0 0 0 0;...
    1 0 0 0 0] ;%#ok

nG = [...
    1 1 1 1 1;...
    1 0 0 0 0;...
    1 0 1 1 1;...
    1 0 0 0 1;...
    1 1 1 1 1] ;%#ok

nH = [...
    1 0 0 0 1;...
    1 0 0 0 1;...
    1 1 1 1 1;...
    1 0 0 0 1;...
    1 0 0 0 1] ;%#ok

nI = [...
    0 1 1 1 0;...
    0 0 1 0 0;...
    0 0 1 0 0;...
    0 0 1 0 0;...
    0 1 1 1 0] ;%#ok

nJ = [...
    1 1 1 1 1;...
    0 0 0 0 1;...
    0 0 0 0 1;...
    1 0 0 0 1;...
    0 1 1 1 0] ;%#ok

nK = [...
    1 0 0 0 1;...
    1 0 0 1 0;...
    1 1 1 0 0;...
    1 0 0 1 0;...
    1 0 0 0 1] ;%#ok

nL = [...
    1 0 0 0 0;...
    1 0 0 0 0;...
    1 0 0 0 0;...
    1 0 0 0 0;...
    1 1 1 1 1] ;%#ok

nM = [...
    1 1 0 1 1;...
    1 0 1 0 1;...
    1 0 1 0 1;...
    1 0 0 0 1;...
    1 0 0 0 1] ;%#ok

nN = [...
    1 0 0 0 1;...
    1 1 0 0 1;...
    1 0 1 0 1;...
    1 0 0 1 1;...
    1 0 0 0 1] ;%#ok

nO = [...
    0 1 1 1 0;...
    1 0 0 0 1;...
    1 0 0 0 1;...
    1 0 0 0 1;...
    0 1 1 1 0] ;%#ok

nP = [...
    1 1 1 1 0;...
    1 0 0 0 1;...
    1 1 1 1 0;...
    1 0 0 0 0;...
    1 0 0 0 0] ;%#ok

nQ = [...
    0 1 1 1 0;...
    1 0 0 0 1;...
    1 0 1 0 1;...
    1 0 0 1 0;...
    0 1 1 0 1] ;%#ok

nR = [...
    1 1 1 1 0;...
    1 0 0 0 1;...
    1 1 1 1 0;...
    1 0 0 1 0;...
    1 0 0 0 1] ;%#ok

nS = [...
    1 1 1 1 1;...
    1 0 0 0 0;...
    1 1 1 1 1;...
    0 0 0 0 1;...
    1 1 1 1 1] ;%#ok

nT = [...
    1 1 1 1 1;...
    0 0 1 0 0;...
    0 0 1 0 0;...
    0 0 1 0 0;...
    0 0 1 0 0] ;%#ok

nU = [...
    1 0 0 0 1;...
    1 0 0 0 1;...
    1 0 0 0 1;...
    1 0 0 0 1;...
    0 1 1 1 0] ;%#ok

nV = [...
    1 0 0 0 1;...
    1 0 0 0 1;...
    1 0 0 0 1;...
    0 1 0 1 0;...
    0 0 1 0 0] ;%#ok

nW = [...
    1 0 0 0 1;...
    1 0 0 0 1;...
    1 0 1 0 1;...
    1 0 1 0 1;...
    0 1 0 1 0] ;%#ok

nX = [...
    1 0 0 0 1;...
    0 1 0 1 0;...
    0 0 1 0 0;...
    0 1 0 1 0;...
    1 0 0 0 1] ;%#ok

nY = [...
    1 0 0 0 1;...
    0 1 0 1 0;...
    0 0 1 0 0;...
    0 0 1 0 0;...
    0 0 1 0 0] ;%#ok

nZ = [...
    1 1 1 1 1;...
    0 0 0 1 0;...
    0 0 1 0 0;...
    0 1 0 0 0;...
    1 1 1 1 1] ;%#ok

nm = [...
    0 0 0 0 0;...
    0 0 0 0 0;...
    0 1 0 1 0;...
    1 0 1 0 1;...
    1 0 1 0 1] ;%#ok

nn = [...
    0 0 0;...
    0 0 0;...
    0 1 0;...
    1 0 1;...
    1 0 1] ;%#ok

strnum = num2str(num) ;


string = eval(sprintf('imresize(n%s,scaleFactor)>0.5;', strnum(1)));
for c=2:size(strnum, 2)
    string = [string, zeros(5*scaleFactor,1),...
        eval(sprintf('imresize(n%s,scaleFactor)>0.5;', strnum(c)))];
end%for
end%function
function setROI(hFig,hAx)
hRoi = imrect(hAx);
hPatch = findobj(hRoi,'Type','patch');
set(hPatch,'FaceColor', [1 1 1],...
    'FaceAlpha', 0.3)

pos = ceil(getPosition(hRoi)-0.5);
hText = text(pos(1), pos(2),...
    sprintf([' x = ' num2str(round(pos(1))) '\n',...
    ' y = ' num2str(round(pos(2))) '\n',...
    ' width = ' num2str(ceil(pos(3)+(pos(1)-0.5-floor(pos(1)-0.5)))) '\n',...
    ' height = ' num2str(ceil(pos(4)+(pos(2)-0.5-floor(pos(2)-0.5))))]),...
    'FontSize', 8,...
    'FontWeight', 'bold',...
    'Color', [0 1 0],...
    'VerticalAlignment', 'top',...
    'Tag', 'roi',...
    'UserData', [round(pos(1)) round(pos(2))...
    ceil(pos(3)+(pos(1)-0.5-floor(pos(1)-0.5)))...
    ceil(pos(4)+(pos(2)-0.5-floor(pos(2)-0.5)))]);
addNewPositionCallback(hRoi,@posInfo);
cnstrnts = get(hAx,{'XLim','YLim'});
fcn = makeConstrainToRectFcn('imrect',...
    cnstrnts{1}+[eps -eps], cnstrnts{2}+[eps -eps]);
setPositionConstraintFcn(hRoi,fcn);
set(hAx,'UserData',{hRoi,hText})
%         h = getappdata(src,'handles');
%         delete(h{1}); delete(h{2})
    function posInfo(pos)
        set(hText, 'Position', [round(pos(1)) round(pos(2)) 0],...
            'String', sprintf([...
            ' x = ' num2str(round(pos(1))) '\n',...
            ' y = ' num2str(round(pos(2))) '\n',...
            ' width = ' num2str(ceil(pos(3)+(pos(1)-0.5-floor(pos(1)-0.5)))) '\n',...
            ' height = ' num2str(ceil(pos(4)+(pos(2)-0.5-floor(pos(2)-0.5))))]),...
            'UserData', [round(pos(1)) round(pos(2))...
            ceil(pos(3)+(pos(1)-0.5-floor(pos(1)-0.5)))...
            ceil(pos(4)+(pos(2)-0.5-floor(pos(2)-0.5)))])
    end
end

function CBH = cbfreeze(varargin)
%CBFREEZE   Freezes the colormap of a colorbar.
%
%   SYNTAX:
%           cbfreeze
%           cbfreeze('off')
%           cbfreeze(H,...)
%     CBH = cbfreeze(...);
%
%   INPUT:
%     H     - Handles of colorbars to be freezed, or from figures to search
%             for them or from peer axes (see COLORBAR).
%             DEFAULT: gcf (freezes all colorbars from the current figure)
%     'off' - Unfreezes the colorbars, other options are:
%               'on'    Freezes
%               'un'    same as 'off'
%               'del'   Deletes the colormap(s).
%             DEFAULT: 'on' (of course)
%
%   OUTPUT (all optional):
%     CBH - Color bar handle(s).
%
%   DESCRIPTION:
%     MATLAB works with a unique COLORMAP by figure which is a big
%     limitation. Function FREEZECOLORS by John Iversen allows to use
%     different COLORMAPs in a single figure, but it fails freezing the
%     COLORBAR. This program handles this problem.
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%     * If no colorbar is found, one is created.
%     * The new frozen colorbar is an axes object and does not behaves
%       as normally colorbars when resizing the peer axes. Although, some
%       time the normal behavior is not that good.
%     * Besides, it does not have the 'Location' property anymore.
%     * But, it does acts normally: no ZOOM, no PAN, no ROTATE3D and no
%       mouse selectable.
%     * No need to say that CAXIS and COLORMAP must be defined before using
%       this function. Besides, the colorbar location. Anyway, 'off' or
%       'del' may help.
%     * The 'del' functionality may be used whether or not the colorbar(s)
%       is(are) froozen. The peer axes are resized back. Try: 
%        >> colorbar, cbfreeze del
%
%   EXAMPLE:
%     surf(peaks(30))
%     colormap jet
%     cbfreeze
%     colormap gray
%     title('What...?')
%
%   SEE ALSO:
%     COLORMAP, COLORBAR, CAXIS
%     and
%     FREEZECOLORS by John Iversen
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cbfreeze.m
%   VERSION: 1.1 (Sep 02, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released. (Jun 08, 2009)
%   1.1      Fixed BUG with image handle on MATLAB R2009a. Thanks to Sergio
%            Muniz. (Sep 02, 2009)

%   DISCLAIMER:
%   cbfreeze.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2009 Carlos Adrian Vargas Aguilera


% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Parameters:
cbappname = 'Frozen';         % Colorbar application data with fields:
                              % 'Location' from colorbar
                              % 'Position' from peer axes befor colorbar
                              % 'pax'      handle from peer axes.
axappname = 'FrozenColorbar'; % Peer axes application data with frozen
                              % colorbar handle.
 
% Set defaults:
S = 'on';                   Sopt = {'on','un','off','del'};
H = get(0,'CurrentFig');

% Check inputs:
if nargin==2 && (~isempty(varargin{1}) && all(ishandle(varargin{1})) && ...
  isempty(varargin{2}))
 
 % Check for CallBacks functionalities:
 % ------------------------------------
 
 varargin{1} = double(varargin{1});
 
 if strcmp(get(varargin{1},'BeingDelete'),'on') 
  % Working as DeletFcn:

  if (ishandle(get(varargin{1},'Parent')) && ...
      ~strcmpi(get(get(varargin{1},'Parent'),'BeingDeleted'),'on'))
    % The handle input is being deleted so do the colorbar:
    S = 'del'; 
    
   if ~isempty(getappdata(varargin{1},cbappname))
    % The frozen colorbar is being deleted:
    H = varargin{1};
   else
    % The peer axes is being deleted:
    H = ancestor(varargin{1},{'figure','uipanel'}); 
   end
   
  else
   % The figure is getting close:
   return
  end
  
 elseif (gca==varargin{1} && ...
                     gcf==ancestor(varargin{1},{'figure','uipanel'}))
  % Working as ButtonDownFcn:
  
  cbfreezedata = getappdata(varargin{1},cbappname);
  if ~isempty(cbfreezedata) 
   if ishandle(cbfreezedata.ax)
    % Turns the peer axes as current (ignores mouse click-over):
    set(gcf,'CurrentAxes',cbfreezedata.ax);
    return
   end
  else
   % Clears application data:
   rmappdata(varargin{1},cbappname) 
  end
  H = varargin{1};
 end
 
else
 
 % Checks for normal calling:
 % --------------------------
 
 % Looks for H:
 if nargin && ~isempty(varargin{1}) && all(ishandle(varargin{1}))
  H = varargin{1};
  varargin(1) = [];
 end

 % Looks for S:
 if ~isempty(varargin) && (isempty(varargin{1}) || ischar(varargin{1}))
  S = varargin{1};
 end
end

% Checks S:
if isempty(S)
 S = 'on';
end
S = lower(S);
iS = strmatch(S,Sopt);
if isempty(iS)
 error('CVARGAS:cbfreeze:IncorrectStringOption',...
  ['Unrecognized ''' S ''' argument.' ])
else
 S = Sopt{iS};
end

% Looks for CBH:
CBH = cbhandle(H);

if ~strcmp(S,'del') && isempty(CBH)
 % Creates a colorbar and peer axes:
 pax = gca;
 CBH = colorbar('peer',pax);
else
 pax = [];
end


% -------------------------------------------------------------------------
% MAIN 
% -------------------------------------------------------------------------
% Note: only CBH and S are necesary, but I use pax to avoid the use of the
%       "hidden" 'Axes' COLORBAR's property. Why... ??

% Saves current position:
fig = get(  0,'CurrentFigure');
cax = get(fig,'CurrentAxes');

% Works on every colorbar:
for icb = 1:length(CBH)
 
 % Colorbar axes handle:
 h  = double(CBH(icb));
 
 % This application data:
 cbfreezedata = getappdata(h,cbappname);
 
 % Gets peer axes:
 if ~isempty(cbfreezedata)
  pax = cbfreezedata.pax;
  if ~ishandle(pax) % just in case
   rmappdata(h,cbappname)
   continue
  end
 elseif isempty(pax) % not generated
  try
   pax = double(get(h,'Axes'));  % NEW feature in COLORBARs
  catch
   continue
  end
 end
 
 % Choose functionality:
 switch S
  
  case 'del'
   % Deletes:
   if ~isempty(cbfreezedata)
    % Returns axes to previous size:
    oldunits = get(pax,'Units');
    set(pax,'Units','Normalized');
    set(pax,'Position',cbfreezedata.Position)
    set(pax,'Units',oldunits)
    set(pax,'DeleteFcn','')
    if isappdata(pax,axappname)
     rmappdata(pax,axappname)
    end
   end
   if strcmp(get(h,'BeingDelete'),'off') 
    delete(h)
   end
   
  case {'un','off'}
   % Unfrozes:
   if ~isempty(cbfreezedata)
    delete(h);
    set(pax,'DeleteFcn','')
    if isappdata(pax,axappname)
     rmappdata(pax,axappname)
    end
    oldunits = get(pax,'Units');
    set(pax,'Units','Normalized')
    set(pax,'Position',cbfreezedata.Position)
    set(pax,'Units',oldunits)
    CBH(icb) = colorbar(...
     'peer'    ,pax,...
     'Location',cbfreezedata.Location);
   end
 
  otherwise % 'on'
   % Freezes:
 
   % Gets colorbar axes properties:
   cb_prop  = get(h);
   
   % Gets colorbar image handle. Fixed BUG, Sep 2009
   hi = findobj(h,'Type','image');
    
   % Gets image data and transform it in a RGB:
   CData = get(hi,'CData'); 
   if size(CData,3)~=1
    % It's already frozen:
    continue
   end
  
   % Gets image tag:
   Tag = get(hi,'Tag');
  
   % Deletes previous colorbar preserving peer axes position:
   oldunits = get(pax,'Units');
              set(pax,'Units','Normalized')
   Position = get(pax,'Position');
   delete(h)
   cbfreezedata.Position = get(pax,'Position');
              set(pax,'Position',Position)
              set(pax,'Units',oldunits)
  
   % Generates new colorbar axes:
   % NOTE: this is needed because each time COLORMAP or CAXIS is used,
   %       MATLAB generates a new COLORBAR! This eliminates that behaviour
   %       and is the central point on this function.
   h = axes(...
    'Parent'  ,cb_prop.Parent,...
    'Units'   ,'Normalized',...
    'Position',cb_prop.Position...
   );
  
   % Save location for future call:
   cbfreezedata.Location = cb_prop.Location;
  
   % Move ticks because IMAGE draws centered pixels:
   XLim = cb_prop.XLim;
   YLim = cb_prop.YLim;
   if     isempty(cb_prop.XTick)
    % Vertical:
    X = XLim(1) + diff(XLim)/2;
    Y = YLim    + diff(YLim)/(2*length(CData))*[+1 -1];
   else % isempty(YTick)
    % Horizontal:
    Y = YLim(1) + diff(YLim)/2;
    X = XLim    + diff(XLim)/(2*length(CData))*[+1 -1];
   end
  
   % Draws a new RGB image:
   image(X,Y,ind2rgb(CData,colormap),...
    'Parent'            ,h,...
    'HitTest'           ,'off',...
    'Interruptible'     ,'off',...
    'SelectionHighlight','off',...
    'Tag'               ,Tag...
   )  

   % Removes all   '...Mode'   properties:
   cb_fields = fieldnames(cb_prop);
   indmode   = strfind(cb_fields,'Mode');
   for k=1:length(indmode)
    if ~isempty(indmode{k})
     cb_prop = rmfield(cb_prop,cb_fields{k});
    end
   end
   
   % Removes special COLORBARs properties:
   cb_prop = rmfield(cb_prop,{...
    'CurrentPoint','TightInset','BeingDeleted','Type',...       % read-only
    'Title','XLabel','YLabel','ZLabel','Parent','Children',...  % handles
    'UIContextMenu','Location',...                              % colorbars
    'ButtonDownFcn','DeleteFcn',...                             % callbacks
    'CameraPosition','CameraTarget','CameraUpVector','CameraViewAngle',...
    'PlotBoxAspectRatio','DataAspectRatio','Position',... 
    'XLim','YLim','ZLim'});
   
   % And now, set new axes properties almost equal to the unfrozen
   % colorbar:
   set(h,cb_prop)

   % CallBack features:
   set(h,...
    'ActivePositionProperty','position',...
    'ButtonDownFcn'         ,@cbfreeze,...  % mhh...
    'DeleteFcn'             ,@cbfreeze)     % again
   set(pax,'DeleteFcn'      ,@cbfreeze)     % and again!  
  
   % Do not zoom or pan or rotate:
   setAllowAxesZoom  (zoom    ,h,false)
   setAllowAxesPan   (pan     ,h,false)
   setAllowAxesRotate(rotate3d,h,false)
   
   % Updates data:
   CBH(icb) = h;   

   % Saves data for future undo:
   cbfreezedata.pax       = pax;
   setappdata(  h,cbappname,cbfreezedata);
   setappdata(pax,axappname,h);
   
 end % switch functionality   

end  % MAIN loop


% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------

% Output?:
if ~nargout
 clear CBH
else
 CBH(~ishandle(CBH)) = [];
end

% Returns current axes:
if ishandle(cax) 
 set(fig,'CurrentAxes',cax)
end
end
function CBH = cbfit(varargin)
%CBFIT   Draws a colorbar with specific color bands between its ticks.
% 
%   SYNTAX:
%           cbfit
%           cbfit(NBANDS)               % May be LBANDS instead of NBANDS
%           cbfit(NBANDS,CENTER)
%           cbfit(...,MODE)
%           cbfit(...,OPT)
%           cbfit(CBH,...)
%     CBH = cbfit(...);
%
%   INPUT:
%     NBANDS - Draws a colorbar with NBANDS bands colors between each tick
%      or      mark or a colorband between the specifies level bands
%     LBANDS   (LBANDS=NBANDS).
%              DEFAULT: 5     
%     CENTER - Center the colormap to this CENTER reference.
%              DEFAULT: [] (do not centers)
%     MODE   - Specifies the ticks mode (should be before AP,AV). One of:
%                'manual' - Forces color ticks on the new bands. 
%                'auto'   - Do not forces
%              DEFAULT: 'auto'
%     OPT    - Normal optional arguments of the COLORBAR function (should
%              be the last arguments).
%              DEFAULT: none.
%     CBH    - Uses this colorbar handle instead of current one.
%
%   OUTPUT (all optional):
%     CBH  - Returns the colorbar axes handle.
%
%   DESCRIPTION:
%     Draws a colorbar with specified number of color bands between its
%     ticks by modifying the current colormap and caxis.
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%     * Sets the color limits, CAXIS, and color map, COLORMAP, before using
%       this function. Use them after this function to get the
%       modifications.
%
%   EXAMPLE:
%     figure, surf(peaks+2), colormap(jet(14)), colorbar
%      title('Normal colorbar.m')
%     figure, surf(peaks+2),                    cbfit(2,0)
%      title('Fitted 2 color bands and centered on zero')
%     figure, surf(peaks+2), caxis([0 10]),     cbfit(4,8)
%      title('Fitted 4 color bands and centered at 8')
%
%   SEE ALSO:
%     COLORBAR
%     and
%     CBFREEZE, CMFIT by Carlos Vargas
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cbfit.m
%   VERSION: 2.1 (Sep 30, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released as COLORBARFIT.M. (Mar 11, 2008)
%   1.1      Fixed bug when CAXIS is used before this function. (Jul 01,
%            2008)
%   1.2      Works properly when CAXIS is used before this function. Bug
%            fixed on subfunction and rewritten code. (Aug 21, 2008)
%   2.0      Rewritten code. Instead of the COLORBAND subfunction, now uses
%            the CMFIT function. Changed its name from COLORBARFIT to
%            CBFIT. (Jun 08, 2008)
%   2.1      Fixed bug and help with CBH input. (Sep 30, 2009)

%   DISCLAIMER:
%   cbfit.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2008,2009 Carlos Adrian Vargas Aguilera


% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Sets defaults:
NBANDS = 5;
CENTER = [];
MODE   = 'auto';            
CBH    = [];
pax    = [];        % Peer axes

% Checks if first argument is a handle: Fixed bug Sep 2009
if (~isempty(varargin) && (length(varargin{1})==1) && ...
  ishandle(varargin{1})) && strcmp(get(varargin{1},'Type'),'axes')
 if strcmp(get(varargin{1},'Tag'),'Colorbar')
  CBH = varargin{1};
 else
  warning('CVARGAS:cbfit:incorrectHInput',...
   'Unrecognized first input handle.')
 end
 varargin(1) = [];
end
 
% Reads NBANDS and CENTER:
if ~isempty(varargin) && isnumeric(varargin{1})
 if ~isempty(varargin{1})
  NBANDS = varargin{1};
 end
 if (length(varargin)>1) && isnumeric(varargin{2})
  CENTER = varargin{2};
  varargin(2) = [];
 end
 varargin(1) = [];
end

% Reads MODE:
if (~isempty(varargin) && (rem(length(varargin),2)==1))
 if (~isempty(varargin{1}) && ischar(varargin{1}))
  switch lower(varargin{1})
   case 'auto'  , MODE = 'auto';
   case 'manual', MODE = 'manual';
   otherwise % 'off', 'hide' and 'delete'
    warning('CVARGAS:cbfit:incorrectStringInput',...
     'No pair string input must be one of ''auto'' or ''manual''.')
  end
 end
 varargin(1) = [];
end

% Reads peer axes:
for k = 1:2:length(varargin)
 if ~isempty(varargin{k})
  switch lower(varargin{k})
   case 'peer', pax = varargin{k+1}; break
  end
 end
end
if isempty(pax)
 pax = gca;
end

% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------

% Generates a preliminary colorbar:
if isempty(CBH)
 CBH = colorbar(varargin{:});
end

% Gets limits and orientation:
s     = 'Y';
ticks = get(CBH,[s 'Tick']);
if isempty(ticks)             
 s     = 'X';
 ticks = get(CBH,[s 'Tick']);
end
zlim = get(CBH,[s 'Lim']);

% Gets width and ref:
if ~isempty(NBANDS)

 NL = length(NBANDS);
 
 if (NL==1)
  
  % Force positive integers:
  NBANDS = round(abs(NBANDS));
 
  % Ignores ticks outside the limits:
  if zlim(1)>ticks(1)
   ticks(1) = [];
  end
  if zlim(2)<ticks(end)
   ticks(end) = [];
  end

  % Get the ticks step and colorband:
  tstep = ticks(2)-ticks(1);
  WIDTH = tstep/NBANDS;
  
  % Sets color limits
  if strcmp(get(pax,'CLimMode'),'auto')
   caxis(zlim);
  end
  
  % Forces old colorbar ticks: 
  set(CBH,[s 'Lim'],zlim,[s 'Tick'],ticks)
  
  % Levels:
  if strcmp(MODE,'manual')
   LBANDS = [fliplr(ticks(1)-WIDTH:-WIDTH:zlim(1)) ticks(1):WIDTH:zlim(2)];
  end
  
 else
  
  % Nonlinear colorbar:
  ticks = NBANDS;
  WIDTH = ticks;
  
  % Scales to CLIM:
  if strcmp(get(pax,'CLimMode'),'manual')
   ticks = ticks-ticks(1);
   ticks = ticks/ticks(end);
   ticks = ticks*diff(zlim) + zlim(1);
  end
  zlim = [ticks(1) ticks(end)];
  caxis(pax,zlim)
  CBIH = get(CBH,'Children');
  
  % Change ticks:
  set(CBIH,[s 'Data'],ticks)
  
  % Sets limits:
  set(CBH,[s 'Lim'],zlim)
  
  % Levels:
  if strcmp(MODE,'manual')
   LBANDS = NBANDS;
  end
  
 end
 
 % Get reference mark
 if ~isempty(CENTER)
  REF    = CENTER;
  CENTER = true;
 else
  REF    = ticks(1);
  CENTER = false;
 end
  
end

% Fits the colormap and limits:
cmfit(get(get(pax,'Parent'),'Colormap'),zlim,WIDTH,REF,CENTER)

% Sets ticks:
if strcmp(MODE,'manual')
 set(CBH,[s 'Tick'],LBANDS)
end

% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------

if ~nargout
 clear CBH
end
end
function CBH = cbhandle(varargin)
%CBHANDLE   Handle of current colorbar axes.
%
%   SYNTAX:
%     CBH = cbhandle;
%     CBH = cbhandle(H);
%
%   INPUT:
%     H - Handles axes, figures or uipanels to look for colorbars.
%         DEFAULT: gca (current axes)
%
%   OUTPUT:
%     CBH - Color bar handle(s).
%
%   DESCRIPTION:
%     By default, color bars are hidden objects. This function searches for
%     them by its 'axes' type and 'Colorbar' tag.
%    
%   SEE ALSO:
%     COLORBAR
%     and
%     CBUNITS, CBLABEL, CBFREEZE by Carlos Vargas
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cbhandle.m
%   VERSION: 1.1 (Aug 20, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released. (Jun 08, 2009)
%   1.1      Fixed bug with colorbar handle input. (Aug 20, 2009)

%   DISCLAIMER:
%   cbhandle.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2009 Carlos Adrian Vargas Aguilera


% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Parameters:
axappname = 'FrozenColorbar'; % Peer axes application data with frozen
                              % colorbar handle.

% Sets default:
H = get(get(0,'CurrentFigure'),'CurrentAxes');

if nargin && ~isempty(varargin{1}) && all(ishandle(varargin{1}))
 H = varargin{1};
end

% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------

% Looks for CBH:
CBH = [];
% set(0,'ShowHiddenHandles','on')
for k = 1:length(H)
 switch get(H(k),'type')
  case {'figure','uipanel'}
   % Parents axes?:
   CBH = [CBH; ...
    findobj(H(k),'-depth',1,'Tag','Colorbar','-and','Type','axes')];
  case 'axes'
   % Peer axes?:
   hin  = double(getappdata(H(k),'LegendColorbarInnerList'));
   hout = double(getappdata(H(k),'LegendColorbarOuterList'));
   if     (~isempty(hin)  && ishandle(hin))
    CBH = [CBH; hin];
   elseif (~isempty(hout) && ishandle(hout))
    CBH = [CBH; hout];
   elseif isappdata(H(k),axappname)
    % Peer from frozen axes?:
    CBH = [CBH; double(getappdata(H(k),axappname))];
   elseif strcmp(get(H(k),'Tag'),'Colorbar') % Fixed BUG Aug 2009
    % Colorbar axes?
    CBH = [CBH; H(k)];
   end
  otherwise
   % continue
 end
end
end
function CBLH = cblabel(varargin)
%CBLABEL   Adds a label to the colorbar.
%
%   SYNTAX:
%            cblabel(LABEL)
%            cblabel(LABEL,..,TP,TV);
%            cblabel(H,...)
%     CBLH = cblabel(...);
%
%   INPUT:
%     LABEL - String (or cell of strings) specifying the colorbar label.
%     TP,TV - Optional text property/property value arguments (in pairs).
%             DEFAULT:  (none)
%     H     - Color bar or peer axes (see COLORBAR) or figure handle(s) to
%             search for a single color bar handle.
%             DEFAULT: gca (current axes color bar)
%
%   OUTPUT (all optional):
%     CBLH  - Returns the colorbar label handle(s).
%           - Labels modified on the colorbar of the current figure or
%             the one(s) specified by CBH.
%
%   DESCRIPTION:
%     This function sets the label of the colorbar(s) in the current
%     figure.
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%
%   EXAMPLE:
%     figure, colorbar, cblabel(['           T, ?C'],'Rotation',0)
%     figure
%      subplot(211), h1 = colorbar;
%      subplot(212), h2 = colorbar('Location','south');
%      cblabel([h1 h2],{'$1-\alpha$','$\beta^3$'},'Interpreter','latex')   
%
%   SEE ALSO: 
%     COLORBAR
%     and 
%     CBUNITS, CBHANDLE, CBFREEZE by Carlos Vargas
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cblabel.m
%   VERSION: 2.0 (Jun 08, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released. (Aug 21, 2008)
%   2.0      Minor changes. Added CBHANDLE dependency. (Jun 08, 2009)

%   DISCLAIMER:
%   cblabel.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2008,2009 Carlos Adrian Vargas Aguilera


% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Parameters:
cbappname = 'Frozen';         % Colorbar application data with fields:
                              % 'Location' from colorbar
                              % 'Position' from peer axes befor colorbar
                              % 'pax'      handle from peer axes.

% Sets defaults:
H     = get(get(0,'CurrentFigure'),'CurrentAxes');
LABEL = '';
TOPT  = {};
CBLH  = [];

% Number of inputs:
if nargin<1
 error('CVARGAS:cblabel:incorrectNumberOfInputs',...
        'At least one input is required.')
end

% Looks for H:
if nargin && ~isempty(varargin{1}) && all(ishandle(varargin{1}))
 H = varargin{1};
 varargin(1) = [];
end

% Looks for CBH:
CBH = cbhandle(H);
if isempty(CBH), if ~nargout, clear CBLH, end, return, end

% Looks for LABEL:
if ~isempty(varargin) && (ischar(varargin{1}) || iscellstr(varargin{1}))  
 LABEL = varargin{1};
 varargin(1) = [];
end

% Forces cell of strings:
if ischar(LABEL)
 % Same label to all the color bars:
 LABEL = repmat({LABEL},length(CBH),1);
elseif iscellstr(LABEL) && (length(LABEL)==length(CBH))
  % Continue...
else
 error('CVARGAS:cblabel:incorrectInputLabel',...
        ['LABEL must be a string or cell of strings of equal size as ' ...
         'the color bar handles: ' int2str(length(CBH)) '.'])
end

% OPTIONAL arguments:
if ~isempty(varargin)
 TOPT = varargin;
end
if length(TOPT)==1
 TOPT = repmat({TOPT},size(CBH));
end

% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------
% NOTE: Only CBH, LABEL and TOPT are needed.

% Applies to each colorbar:
CBLH = repmat(NaN,size(CBH));
for icb = 1:length(CBH)
 
 % Searches for label location:
 try 
  % Normal colorbar:
  location = get(CBH(icb),'Location');
 catch
  % Frozen colorbar:
  location = getappdata(CBH(icb),cbappname);
  location = location.Location;
 end
 switch location(1)
  case 'E', as  = 'Y';
  case 'W', as  = 'Y';
  case 'N', as  = 'X';
  case 'S', as  = 'X';
 end
 % Gets label handle:
 CBLH(icb) = get(CBH(icb),[as 'Label']);
 % Updates label:
 set(CBLH(icb),'String',LABEL{icb},TOPT{:});
 
end

% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------

% Sets output:
if ~nargout
 clear CBLH
end
end
function CBH = cbunits(varargin)
%CBUNITS   Adds units to the colorbar ticklabels.
%
%   SYNTAX:
%           cbunits(UNITS)
%           cbunits(UNITS,SPACE)
%           cbunits -clear
%           cbunits(H,...)
%     CBH = cbunits(...);
%
%   INPUT:
%     UNITS - String (or cell of strings) with the colorbar(s) units or
%             '-clear' to eliminate any unit. 
%     SPACE - Logical indicating whether an space should be put between
%             quantity and units. Useful when using '3?C', for example.
%             DEFAULT: true (use an space)
%     H     - Colorbar, or peer axes (see COLORBAR) or figure handle(s) to
%             search for color bars. 
%             DEFAULT: gca (current axes color bar)
%
%   OUTPUT (all optional):
%     CBH   - Returns the colorbar handle(s).
%             DEFAULT: Not returned if not required.
%           - Ticklabels modified on the colorbar of the current axes or
%             the one(s) specified by CBH.
%
%   DESCRIPTION:
%     This function adds units to the current colorbar, by writting them
%     after the biggest ticklabel.
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%     * Scientific notation is included in the units (if any).
%     * When more than one colorbar handle is given or founded and a single
%       UNITS string is given, it is applied to all of them.
%     * Use a cell of strings for UNITS when more than one colorbar handles
%       are given in order to give to each one their proper units. This
%       also works when the handlesare founded but the units order is
%       confusing and not recommended.
%     * Once applied, CAXIS shouldn't be used.
%     * To undo sets the ticklabelmode to 'auto'.
%
%   EXAMPLE:
%     % Easy to use:
%       figure, caxis([1e2 1e8]), colorbar, cbunits('?F',false)
%     % Vectorized:
%       figure
%       subplot(211), h1 = colorbar;
%       subplot(212), h2 = colorbar;
%       cbunits([h1;h2],{'?C','dollars'},[false true])
%     % Handle input:
%       figure
%       subplot(211), colorbar;
%       subplot(212), colorbar('Location','North');
%       caxis([1e2 1e8])
%       cbunits(gcf,'m/s')
%
%   SEE ALSO: 
%     COLORBAR
%     and
%     CBLABEL, CBHANDLE, CBFREEZE by Carlos Vargas
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cbunits.m
%   VERSION: 3.0 (Sep 30, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released. (Aug 21, 2008)
%   2.0      Minor changes. Added 'clear' option and CBHANDLE dependency.
%            (Jun 08, 2009)
%   3.0      Fixed bug when inserting units on lower tick and ticklabel
%            justification. Added SPACE option. (Sep 30, 2009)

%   DISCLAIMER:
%   cbunits.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2008,2009 Carlos Adrian Vargas Aguilera


% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Sets defaults:
H     = get(get(0,'CurrentFigure'),'CurrentAxes');
UNITS = '';
SPACE = true;

% Checks inputs/outputs number:
if     nargin<1
 error('CVARGAS:cbunits:notEnoughInputs',...
  'At least 1 input is required.')
elseif nargin>3
 error('CVARGAS:cbunits:tooManyInputs',...
  'At most 3 inputs are allowed.')
elseif nargout>1
 error('CVARGAS:cbunits:tooManyOutputs',...
  'At most 1 output is allowed.')
end

% Looks for H:
if nargin && ~isempty(varargin{1}) && all(ishandle(varargin{1}))
 H = varargin{1};
 varargin(1) = [];
end

% Looks for CBH:
CBH = cbhandle(H);
if isempty(CBH), if ~nargout, clear CBH, end, return, end

% Looks for UNITS:
if ~isempty(varargin) && ~isempty(varargin{1}) && ...
  (ischar(varargin{1}) || iscellstr(varargin{1}))  
 UNITS = varargin{1};
 varargin(1) = [];
end
if isempty(UNITS), if ~nargout, clear CBH, end, return, end

% Forces cell of strings:
if ischar(UNITS)
 if numel(UNITS)~=size(UNITS,2)
  error('CVARGAS:cbunits:IncorrectUnitsString',...
        'UNITS string must be a row vector.')
 end
 % Same units to all the color bars:
 UNITS = repmat({UNITS},length(CBH),1);
elseif iscellstr(UNITS) && (length(UNITS)==length(CBH))
  % Continue...
else
 error('CVARGAS:cbunits:IncorrectInputUnits',...
        ['UNITS must be a string or cell of strings of equal size as ' ...
         'the color bar handles: ' int2str(length(CBH)) '.'])
end

% Looks for SPACE:
Nunits = length(UNITS);
if ~isempty(varargin) && ~isempty(varargin{1}) && ...
  ((length(varargin{1})==1) || (length(varargin{1})==Nunits))  
 SPACE = varargin{1};
end
SPACE = logical(SPACE);

% Forces equal size of SPACE and UNITS.
if (length(SPACE)==1) && (Nunits~=1)
 SPACE = repmat(SPACE,Nunits,1);
end


% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------
% Note: Only CBH and UNITS are required.

% Applies to each colorbar:
for icb = 1:length(CBH)
 
 units  = UNITS{icb};
 space  = SPACE(icb);
 cbh    = CBH(icb);
 append = [];
 
 % Gets tick labels:
 as  = 'Y';
 at  = get(cbh,[as 'Tick']);
 if isempty(at)
  as = 'X';
  at = get(cbh,[as 'Tick']);
 end
 
 % Checks for elimitation:
 if strcmpi(units,'-clear')
  set(cbh,[as 'TickLabelMode'],'auto')
  continue
 end

             set(cbh,[as 'TickLabelMode'],'manual');
 old_ticks = get(cbh,[as 'TickLabel']);

 % Adds scientific notation:
 if strcmp(get(cbh,[as 'Scale']),'linear')
  ind = 1;
  if at(ind)==0
   ind = 2;
  end
  o  = log10(abs(at(ind)/str2double(old_ticks(ind,:))));
  sg = '';
  if at(ind)<0, sg = '-'; end
  if o>0
   append = [' e' sg int2str(o) ''];
  end
 end
 
 % Updates ticklabels:
 Nu = length(units);
 Na = length(append);
 Nt = size(old_ticks,1);
 loc = Nt; % Fixed bug, Sep 2009
 if (strcmp(as,'Y') && ((abs(at(1))>abs(at(Nt))) && ...
    (length(fliplr(deblank(fliplr(old_ticks( 1,:))))) > ...
     length(fliplr(deblank(fliplr(old_ticks(Nt,:)))))))) || ...
     (strcmp(as,'X') && strcmp(get(cbh,[as 'Dir']),'reverse'))
  loc = 1; 
 end
 new_ticks  = [old_ticks repmat(' ',Nt,Nu+(Na-(Na>0))+space)];
 new_ticks(loc,end-Nu-Na-space+1:end) = [append repmat(' ',1,space) units];
 if strcmp(as,'Y') % Fixed bug, Sep 2009
  if strcmp(get(cbh,[as 'AxisLocation']),'right')
   new_ticks = strjust(new_ticks,'left');
  else
   new_ticks = strjust(new_ticks,'right');
  end
 else
  new_ticks = strjust(new_ticks,'center');
 end
 set(cbh,[as 'TickLabel'],new_ticks)
 
end % MAIN LOOP


% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------

% Sets output:
if ~nargout
 clear CBH
end
end
function RGB = cmapping(varargin)
%CMAPPING   Colormap linear mapping/interpolation.
%
%   SYNTAX:
%           cmapping
%           cmapping(U)
%           cmapping(U,CMAP)
%           cmapping(U,CMAP,...,CNAN)
%           cmapping(U,CMAP,...,TYPE)
%           cmapping(U,CMAP,...,MODE)
%           cmapping(U,CMAP,...,MAPS)
%           cmapping(U,CMAP,...,CLIM)
%           cmapping(AX,...)
%     RGB = cmapping(...);
%
%   INPUT:
%     U     - May be one of the following options:
%              a) An scalar specifying the output M number of colors.
%              b) A vector of length M specifying the values at which
%                 the function CMAP(IMAP) will be mapped.
%              c) A matrix of size M-by-N specifying intensities to be
%                 mapped to an RGB (3-dim) image. May have NaNs elements. 
%             DEFAULT: Current colormap length.
%     CMAP  - A COLORMAP defined by its name or handle-function or RGB
%             matrix (with 3 columns) or by a combination of colors chars
%             specifiers ('kbcw', for example) to be mapped. See NOTE below
%             for more options.
%             DEFAULT: Current colormap
%     CNAN  - Color for NaNs values on U, specified by a 1-by-3 RGB color
%             or a char specifier.
%             DEFAULT: Current axes background (white color: [1 1 1])
%     TYPE  - String specifying the result type. One of:
%               'colormap'  Forces a RGB colormap matrix result (3 columns)
%               'image'     Forces a RGB image result (3 dimensions)
%             DEFAULT: 'image' if U is a matrix, otherwise is 'colormap'
%     MODE  - Defines the mapping way. One of:
%               'discrete'     For discrete colors
%               'continuous'   For continuous color (interpolates)
%             DEFAULT: 'continuous' (interpolates between colors)
%     MAPS  - Specifies the mapping type. One of (see NOTES below):
%               'scaled'   Scales mapping, also by using CLIM (as IMAGESC).
%               'direct'   Do not scales the mapping (as IMAGE).
%             DEFAULT: 'scaled' (uses CLIM)
%     CLIM  - Two element vector that, if given, scales the mapping within
%             this color limits. Ignored if 'direct' is specified.
%             DEFAULT: [0 size(CMAP,1)] or [0 1].
%     AX    - Uses specified axes or figure handle to set/get the colormap.
%             If used, must be the first input.
%             DEFAULT: gca
%
%   OUTPUT (all optional):
%     RGB - If U is not a matrix, this is an M-by-3 colormap matrix with
%           RGB colors in its rows, otherwise is an RGB image: M-by-N-by-3,
%           with the color red intensities defined by RGB(:,:,1), the green
%           ones by RGB(:,:,2) and the blue ones by RGB(:,:,3).
%
%   DESCRIPTION:
%     This functions has various functionalities like: colormap generator,
%     colormap expansion/contraction, color mapping/interpolation, matrix
%     intensities convertion to RGB image, etc.
%
%     The basic idea is a linear mapping between the CMAP columns
%     [red green blue] and the U data, ignoring its NaNs.
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%     * If a single value of U is required for interpolation, use [U U].
%     * If the char '-' is used before the CMAP name, the colors will be
%       flipped. The same occurs if U is a negative integer.
%
%   EXAMPLE:
%     % Colormaps:
%       figure, cmapping( 256,'krgby')            , colorbar
%       figure, cmapping(-256,'krgby' ,'discrete'), colorbar
%       figure, cmapping(log(1:100),[],'discrete'), colorbar
%     % Images:
%       u = random('chi2',2,20,30); u(15:16,7:9) = NaN;
%       u = peaks(30);  u(15:16,7:9) = NaN;
%       v = cmapping(u,jet(64),'discrete','k');
%       w = cmapping(u,cmapping(log(0:63),'jet','discrete'),'discrete');
%       figure, imagesc(u), cmapping(64,'jet'), colorbar
%        title('u')
%       figure, imagesc(v), cmapping(64,'jet'), colorbar
%        title('u transformed to RGB (look the colored NaNs)')
%       figure, imagesc(w) ,cmapping(64,'jet'), colorbar
%        title('u mapped with log(colormap)')
%       figure, imagesc(u), cmapping(log(0:63),'jet','discrete'), colorbar
%        title('u with log(colormap)')
%    
%   SEE ALSO:
%     COLORMAP, IND2RGB
%     and
%     CMJOIN by Carlos Vargas
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cmapping.m
%   VERSION: 1.1 (Sep 02, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released. (Jun 08, 2009)
%   1.0.1    Fixed little bug with 'm' magenta color. (Jun 30, 2009)
%   1.1      Fixed BUG with empty CMAP, thanks to Andrea Rumazza. (Sep 02,
%            2009) 

%   DISCLAIMER:
%   cmapping.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2009 Carlos Adrian Vargas Aguilera


% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Sets defaults:
AX     = {};                     % Calculated inside.
U      = [];                     % Calculated inside.
CMAP   = [];                     % Calculated inside.
TYPE   = 'colormap';             % Changes to 'image' if U is a matrix.
CLIM   = [];                     % To use in scaling
CNAN   = [1 1 1];                % White 'w'
MODE   = 'continuous';           % Scaling to CLIM
MAPS   = 'scaled';               % Scaled mapping
method = 'linear';               % Interpolation method
mflip  = false;                  % Flip the colormap

% Gets figure handle and axes handle (just in case the default colormap or
% background color axes will be used.
HF     = get(0,'CurrentFigure');
HA     = [];
if ~isempty(HF)
 HA    = get(HF,'CurrentAxes');
 if ~isempty(HA)
  CNAN = get(HA,'Color');        % NaNs colors
 end
end

% Checks inputs:
if nargin>8
 error('CVARGAS:cmapping:tooManyInputs', ...
  'At most 8 inputs are allowed.')
elseif nargout>1
 error('CVARGAS:cmapping:tooManyOutputs', ...
  'At most 1 output is allowed.')
end

% Checks AX:
if (~isempty(varargin)) && ~isempty(varargin{1}) && ...
  (numel(varargin{1})==1) && ishandle(varargin{1}) && ...
  strcmp(get(varargin{1},'Type'),'axes')
 % Gets AX and moves all other inputs to the left:
 AX          = varargin(1);
 HA          = AX{1};
 CNAN        = get(HA,'Color');
 varargin(1) = [];
end

% Checks U:
Nargin = length(varargin);
if ~isempty(varargin)
 U           = varargin{1};
 varargin(1) = [];
end

% Checks CMAP:
if ~isempty(varargin)
 CMAP        = varargin{1};
 varargin(1) = []; 
end

% Checks input U, if not given uses as default colormap length:
% Note: it is not converted to a vector in case CMAP is a function and IMAP
%       was not given.
if isempty(U)
 % Gets default COLORMAP length:
 if ~isempty(HA)
  U = size(colormap(HA),1);
 else
  U = size(get(0,'DefaultFigureColormap'),1);
 end
elseif ndims(U)>2
 error('CVARGAS:cmapping:incorrectXInput', ...
  'U must be an scalar, a vector or a 2-dimensional matrix.')
end

% Checks input CMAP:
if isempty(CMAP)
 % CMAP empty, then uses default:
 if ~isempty(HA)
  CMAP = colormap(HA);
  if isempty(CMAP) % Fixed BUG, Sep 2009.
   CMAP = get(0,'DefaultFigureColormap');
   if isempty(CMAP)
    CMAP = jet(64);
   end
  end
 else
  CMAP = get(0,'DefaultFigureColormap');
  if isempty(CMAP)
   CMAP = jet(64);
  end
 end
 Ncmap = size(CMAP,1);
elseif isnumeric(CMAP)
 % CMAP as an [R G B] colormap:
 Ncmap = size(CMAP,1);
 if (size(CMAP,2)~=3) || ...
  ((min(CMAP(:))<0) || (max(CMAP(:))>1)) || any(~isfinite(CMAP(:)))
  error('CVARGAS:cmapping:incorrectCmapInput', ...
        'CMAP is an incorrect 3 columns RGB colors.')
 end
elseif ischar(CMAP)
 % String CMAP
 % Checks first character:
 switch CMAP(1)
  case '-'
   mflip = ~mflip;
   CMAP(1) = [];
   if isempty(CMAP)
    error('CVARGAS:cmapping:emptyCmapInput',...
     'CMAP function is empty.')
   end
 end
 if ~((exist(CMAP,'file')==2) || (exist(CMAP,'builtin')==5))
  % CMAP as a combination of color char specifiers:
  CMAP  = lower(CMAP);
  iy    = (CMAP=='y');
  im    = (CMAP=='m');
  ic    = (CMAP=='c');
  ir    = (CMAP=='r');
  ig    = (CMAP=='g');
  ib    = (CMAP=='b');
  iw    = (CMAP=='w');
  ik    = (CMAP=='k');
  Ncmap = length(CMAP);
  if (sum([iy im ic ir ig ib iw ik])~=Ncmap)
   error('CVARGAS:cmapping:incorrectCmapStringInput', ...
   ['String CMAP must be a valid colormap name or a combination of '...
    '''ymcrgbwk''.'])
  end
  % Convertion to [R G B]:
  CMAP       = zeros(Ncmap,3);
  CMAP(iy,:) = repmat([1 1 0],sum(iy),1);
  CMAP(im,:) = repmat([1 0 1],sum(im),1); % BUG fixed Jun 2009
  CMAP(ic,:) = repmat([0 1 1],sum(ic),1);
  CMAP(ir,:) = repmat([1 0 0],sum(ir),1);
  CMAP(ig,:) = repmat([0 1 0],sum(ig),1);
  CMAP(ib,:) = repmat([0 0 1],sum(ib),1);
  CMAP(iw,:) = repmat([1 1 1],sum(iw),1);
  CMAP(ik,:) = repmat([0 0 0],sum(ik),1);
 else
  % CMAP as a function name
  % Changes function name to handle:
  CMAP = str2func(CMAP);
  Ncmap = []; % This indicates a CMAP function input
 end
elseif isa(CMAP,'function_handle')
 Ncmap = []; % This indicates a CMAP function input
else
 % CMAP input unrecognized:
 error('CVARGAS:cmapping:incorrectCmapInput', ...
  'Not recognized CMAP input.') 
end

% Checks CMAP function handle:
if isempty(Ncmap)
 % Generates the COLORMAP from function:
 try
  temp = CMAP(2);
  if ~all(size(temp)==[2 3]) || any(~isfinite(temp(:))), error(''), end
  clear temp
 catch
  error('CVARGAS:cmapping:incorrectCmapFunction', ...
   ['CMAP function ''' func2str(CMAP) ''' must result in RGB colors.'])
 end
end

% Checks varargin:
while ~isempty(varargin)
 if     isempty(varargin{1})
  % continue
 elseif ischar(varargin{1})
  % string input
  switch lower(varargin{1})
   % CNAN:
   case 'y'         , CNAN = [1 1 0];
   case 'm'         , CNAN = [1 0 0];
   case 'c'         , CNAN = [0 1 1];
   case 'r'         , CNAN = [1 0 0];
   case 'g'         , CNAN = [0 1 0];
   case 'b'         , CNAN = [0 0 1];
   case 'w'         , CNAN = [1 1 1];
   case 'k'         , CNAN = [0 0 0];
   % MODE:
   case 'discrete'  , MODE = 'discrete';
   case 'continuous', MODE = 'continuous';
   % TYPE:
   case 'colormap'  , TYPE = 'colormap';
   case 'image'     , TYPE = 'image';
   % MAPS:
   case 'direct'    , MAPS = 'direct';
   case 'scaled'    , MAPS = 'scaled';
   % Incorrect input:
   otherwise
    error('CVARGAS:cmapping:incorrectStringInput',...
     ['Not recognized optional string input: ''' varargin{1} '''.'])
  end
 elseif isnumeric(varargin{1}) && all(isfinite(varargin{1}(:)))
  % numeric input
  nv = numel(varargin{1});
  if (nv==3) && (size(varargin{1},1)==1)
   % CNAN:
   CNAN = varargin{1}(:)';
   if (max(CNAN)>1) || (min(CNAN)<0)
    error('CVARGAS:cmapping:incorrectCnanInput',...
     'CNAN elements must be between 0 and 1.')
   end
  elseif (nv==2) && (size(varargin{1},1)==1)
   % CLIM:
   CLIM = sort(varargin{1},'ascend');
   if (diff(CLIM)==0)
    error('CVARGAS:cmapping:incorrectClimValues',...
     'CLIM must have 2 distint elements.')
   end
  else
   error('CVARGAS:cmapping:incorrectNumericInput',...
   'Not recognized numeric input.')
  end
 else
  error('CVARGAS:cmapping:incorrectInput',...
   'Not recognized input.')
 end
 % Clears current optional input:
 varargin(1) = [];
end % while


% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------

% U size:
[m,n] = size(U);
mn    = m*n;

% Checks TYPE:
if ~any([m n]==1)
 % Forces image TYPE if U is a matrix:
 TYPE = 'image';
elseif strcmp(TYPE,'colormap') && ~nargout && isempty(AX)
 % Changes the colormap on the specified or current axes if no output
 % argument:
 AX = {gca};
end

% Forces positive integer if U is an scalar, and flips CMAP if is negative:
if (mn==1)
 U = round(U);
 if (U==0)
  if ~nargout && strcmp(TYPE,'colormap')
   warning('CVARGAS:cmapping:incorrectUInput',...
    'U was zero and produces no colormap')
  else
   RGB = [];
  end
  return
 elseif (U<0)
  mflip = ~mflip;
  U     = abs(U);
 end
end

% Gets CMAP from function handle:
if isempty(Ncmap)
 if (mn==1)
  % From U:
  Ncmap = U(1);
 else
  % From default colormap:
  if ~isempty(HA)
   Ncmap = size(colormap(HA),1);
  else
   Ncmap = size(get(0,'DefaultFigureColormap'),1);
  end
 end
 CMAP = CMAP(Ncmap);
end

% Flips the colormap
if mflip
 CMAP = flipud(CMAP);
end

% Check CMAP when U is an scalar::
if (mn==1) && (U==Ncmap)
 % Finishes:
 if ~nargout && strcmp(TYPE,'colormap')
  if Nargin==0
   RGB = colormap(AX{:},CMAP);
  else
   colormap(AX{:},CMAP)
  end
 else
  RGB = CMAP;
  if strcmp(TYPE,'image')
   RGB = reshape(RGB,Ncmap,1,3);
  end
 end
 return
end

% Sets scales:
if strcmp(MAPS,'scaled')
 % Scaled mapping:
 if ~isempty(CLIM)
  if (mn==1)
   mn = U;
   U = linspace(CLIM(1),CLIM(2),mn)';
  else
   % Continue  
  end
 else
  CLIM = [0 1];
  if (mn==1)
   mn = U;
   U = linspace(CLIM(1),CLIM(2),mn)';
  else
   % Scales U to [0 1]:
   U = U-min(U(isfinite(U(:))));
   U = U/max(U(isfinite(U(:))));
   % Scales U to CLIM:
   U = U*diff(CLIM)+CLIM(1);
  end
 end
else
 % Direct mapping:
 CLIM = [1 Ncmap];
end

% Do not extrapolates:
U(U<CLIM(1)) = CLIM(1);
U(U>CLIM(2)) = CLIM(2);

% Sets CMAP argument:
umap = linspace(CLIM(1),CLIM(2),Ncmap)';

% Sets U:
if (mn==2) && (U(1)==U(2))
 % U = [Uo Uo] implicates U = Uo:
 U(2) = [];
 mn   = 1;
 m    = 1;
 n    = 1;
end

% Sets discretization:
if strcmp(MODE,'discrete')
 umap2 = linspace(umap(1),umap(end),Ncmap+1)';
 for k = 1:Ncmap
  U((U>umap2(k)) & (U<=umap2(k+1))) = umap(k);
 end
 clear umap2
end

% Forces column vector:
U = U(:);

% Gets finite data:
inan = ~isfinite(U);

% Initializes:
RGB  = repmat(reshape(CNAN,[1 1 3]),[mn 1 1]);

% Interpolates:
if (Ncmap>1) && (sum(~inan)>1)
 [Utemp,a,b]    = unique(U(~inan));
 RGBtemp = [...
  interp1(umap,CMAP(:,1),Utemp,method) ...
  interp1(umap,CMAP(:,2),Utemp,method) ...
  interp1(umap,CMAP(:,3),Utemp,method) ...
  ];
 RGB(~inan,:) = RGBtemp(b,:);
else
 % single color:
 RGB(~inan,1,:) = repmat(reshape(CMAP,[1 1 3]),[sum(~inan) 1 1]);
end

% Just in case
RGB(RGB>1) = 1; 
RGB(RGB<0) = 0;

% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------

% Output type:
if strcmp(TYPE,'colormap')
 RGB = reshape(RGB,mn,3);
 if ~isempty(AX)
  colormap(AX{:},RGB)
  if ~nargout 
   clear RGB
  end
 end
else
 RGB = reshape(RGB,[m n 3]);
end
end
function [CMAP,CLIM,WIDTH,REF,LEVELS] = ...
                                 cmfit(CMAP,CLIM,WIDTH,REF,CENTER,varargin) 
%CMFIT   Sets the COLORMAP and CAXIS to specific color bands. 
%
%   SYNTAX:
%                                      cmfit
%                                      cmfit(CMAP)
%                                      cmfit(CMAP,CLIM)
%                                      cmfit(CMAP,CLIM,WIDTH or LEVELS)
%                                      cmfit(CMAP,CLIM,WIDTH,REF)
%                                      cmfit(CMAP,CLIM,WIDTH,REF,CENTER)
%                                      cmfit(AX,...)
%     [CMAPF,CLIMF,WIDTHF,REFF,LEVF] = cmfit(...);
%
%   INPUT:
%     CMAP   - Fits the specified colormap function or RGB colors. 
%              DEFAULT: (current figure colormap)
%     CLIM   - 2 element vector spacifying the limits of CMAP. 
%              DEFAULT: (limits of a COLORBAR)
%     WIDTH  - Color band width (limits are computed with CAXIS) for each
%     or       band or a row vector specifying the LEVELS on each band (see
%     LEVELS   NOTE below).
%              DEFAULT: (fills the ticks of a COLORBAR)
%     REF    - Reference level to start any of the color bands.
%              DEFAULT: (generally the middle of CLIM)
%     CENTER - Logical specifying weather the colormap should be center in
%              the REF value or not.
%              DEFAULT: false (do not centers)
%     AX     - Uses the specified figure or axes handle.
%
%   OUTPUT (all optional):
%     CMAPF  - RGB fitted color map (with 3 columns).
%     CLIMF  - Limits of CMAPF.
%     WIDTHF - Width of fitted colorbands.
%     REFF   - Reference of fitted colorbands.
%     LEVF   - Levels for the color bands.
%
%   DESCRIPTION:
%     This program sets the current figure colormap with specified
%     band-widths of colors taking the CAXIS limits as reference. When the 
%     optional input argument CENTER is true, the colormap is moved and
%     expanded so its middle color will be right at REF. This will help for
%     distinguish between positive and negative values (REF=0).
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%     * When one of the first two inputs is missing, they are automatically
%       calculated by using a COLORBAR (created temporarly if necesary). In
%       this case CBHANDLE is necesary.
%     * When CMAP is used as output, the current figure colormap won't be
%       modificated. Use 
%         >> colormap(CMAP)
%       after this function, if necesary.
%     * When LEVELS are used instead of band WINDTH, it shoud be
%       monotonically increasing free of NaNs and of length equal to the
%       number of colors minus one, on the output colormap.
% 
%   SEE ALSO:
%     COLORMAP
%     and 
%     CMAPPING, CBFIT by Caros Vargas
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cmfit.m
%   VERSION: 1.0 (Jun 08, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released. (Jun 08, 2009)

%   DISCLAIMER:
%   cmfit.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2008,2009 Carlos Adrian Vargas Aguilera


% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Sets defaults: 
AX  = {};    % Axes input
tol = 1;     % Adds this tolerance to the decimal precision
hfig = {get(0,'CurrentFigure')};
if ~isempty(hfig)
 hax = {get(hfig{1},'CurrentAxes')};
 if isempty(hax{1}), hax = {}; end
else
 hfig = {};
 hax  = {};
end

% Checks inputs:
if nargin>6
 error('CVARGAS:cmfit:tooManyInputs', ...
  'At most 6 inputs are allowed.')
end
if nargin>5
 error('CVARGAS:cmfit:tooManyOutputs', ...
  'At most 5 outputs are allowed.')
end

% Saves number of arguments:
Nargin = nargin;

% Checks AX input:
if (Nargin>0) && ~isempty(CMAP) && (numel(CMAP)==1) && ...
  ishandle(CMAP)
 % Gets AX and moves all other inputs to the left:
 AX = {CMAP};
 switch get(AX{1},'Type')
  case 'axes'
   hax  = AX;
   hfig = {get(hax{1},'Parent')};
  case {'figure','uipanel'}
   hfig = {AX{1}};
   hax  = {get(hfig{1},'CurrentAxes')};
   if isempty(hax{1}), hax = {}; end
  otherwise
   error('CVARGAS:cmfit:incorrectAxHandle',...
    'AX must be a valid axes or figure handle.')
 end
 if (Nargin>1)
  CMAP = CLIM;
  if (Nargin>2)
   CLIM = WIDTH;
   if (Nargin>3)
    WIDTH = REF;
    if (Nargin>4)
     REF = CENTER;
     if (Nargin>5)
      CENTER = varargin{1};
     end
    end
   end
  end
 end
 Nargin = Nargin-1;
end

% Checks CMAP input:
if Nargin<1 || isempty(CMAP)
 if ~isempty(hax)
  CMAP = colormap(hax{1});
 else
  CMAP = get(0,'DefaultFigureColormap');
 end
end

% Checks CLIM input:
if Nargin<2
 CLIM = [];
end

% Checks WIDTH input:
if Nargin<3
 WIDTH = [];
end

% Checks REf input:
if Nargin<4
 REF = [];
end

% Checks CENTER input:
if Nargin<5 || isempty(CENTER)
 CENTER = false;
end

% Look for WIDTH and REF from a (temporarly) colorbar:
if isempty(WIDTH) || (length(WIDTH)==1 && (isempty(REF) || ...
  (isempty(CLIM) && (isempty(hax) || ...
  ~strcmp(get(hax{1},'CLimMode'),'manual')))))
 if ~isempty(CLIM)
  caxis(hax{:},CLIM)
 end
 if ~isempty(AX) && ~isempty(cbhandle(AX{1}))
  h = cbhandle(AX{1}); doclear = false; h = h(1);
 elseif ~isempty(hax) && ~isempty(cbhandle(hax{1}))
  h = cbhandle(hax{1}); doclear = false; h = h(1);
 elseif ~isempty(hfig) && ~isempty(cbhandle(hfig{1}))
  h = cbhandle(hfig{1}); doclear = false; h = h(1);
 else
  h = colorbar; doclear = true;
 end
 ticks = get(h,'XTick');
 lim   = get(h,'XLim');
 if isempty(ticks)
  ticks = get(h,'YTick');
  lim   = get(h,'YLim');
 end
 if isempty(WIDTH)
  WIDTH = diff(ticks(1:2));
 end
 if isempty(CLIM)
  CLIM = lim;
 end
 if isempty(REF) && ~CENTER
  REF = ticks(1);
 end
 if doclear
  delete(h)
 end
end

% Centers at the middle:
if CENTER && isempty(REF)
 REF = 0;
end 

% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------


% Gets minimum width from specified levels:
NL = length(WIDTH); 
if (NL>1)
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % NONLINEAR CASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 LEVELS = sort(WIDTH);
 
 % Gets LEVELS width:
 wLEVELS = diff(LEVELS);
 
 % Scales to CLIM:
 if ~isempty(CLIM)
  % Scales to [0 1]
  LEVELS = LEVELS-LEVELS(1);
  LEVELS = LEVELS/LEVELS(end);
  % Scales to CLIM:
  LEVELS = LEVELS*diff(CLIM)+CLIM(1);
 else
  CLIM  = [LEVELS(1) LEVELS(end)]; 
 end
 
 % Gets precision:
 if isinteger(wLEVELS) % Allows integer input: uint8, etc. 
  wLEVELS = double(wLEVELS);
 end
 temp = warning('off','MATLAB:log:logOfZero');
 precision = floor(log10(abs(wLEVELS))); % wLEVELS = Str.XXX x 10^precision.
 precision(wLEVELS==0) = 0; % M=0 if x=0.
 warning(temp.state,'MATLAB:log:logOfZero')
 precision = min(precision)-tol;
 
 % Sets levels up to precision:
 wLEVELS = round(wLEVELS*10^(-precision));
 
 % Gets COLORMAP for each LEVEL:
 if CENTER
  % Centers the colormap:
  ind = (REF==LEVELS);
  if ~any(ind)
   error('CVARGAS:cmfit:uncorrectRefLevel',...
    'When CENTER, REF level must be on of the specifyied LEVELS.')
  end
  Nl     = sum(~ind(1:find(ind)));
  [Nl,l] = max([Nl (NL-1-Nl)]);
  wCMAP  = cmapping(2*Nl,CMAP);
  if l==1
   wCMAP = wCMAP(1:NL-1,:);
  else
   wCMAP = wCMAP(end-NL+2:end,:);
  end
 else
  wCMAP  = cmapping(NL-1,CMAP);
 end
 
 % Gets minimum band width:
 WIDTH = wLEVELS(1);
 for k = 1:NL-1
  wlev    = wLEVELS;
  wlev(k) = [];
  WIDTH   = min(min(gcd(wLEVELS(k),wlev)),WIDTH);
 end
 
 % Gets number of bands:
 wLEVELS = wLEVELS/WIDTH;
 
 % Gets new CMAP:
 N = sum(wLEVELS);
 try
  CMAP = repmat(wCMAP(1,:),N,1);
 catch
  error('CVARGAS:cmfit:memoryError',...
   ['The number of colors (N=' int2str(N) ') for the new colormap ' ...
    'is extremely large. Try other LEVELS.'])
 end
 ko = wLEVELS(1);
 for k = 2:NL-1;
  CMAP(ko+(1:wLEVELS(k)),:) = repmat(wCMAP(k,:),wLEVELS(k),1);
  ko = ko+wLEVELS(k);
 end
 
else
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % LINEAR CASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 % Gets CLIM:
 if isempty(CLIM)
  CLIM = caxis(hax{:});
 end

 % Sets color limits to be a multipler of WIDTH passing through REF:
 N1   = ceil((+REF-CLIM(1))/WIDTH);
 N2   = ceil((-REF+CLIM(2))/WIDTH);
 CLIM = REF + [-N1 N2]*WIDTH;

 % Sets colormap with NC bands:
 Nc = round(diff(CLIM)/WIDTH);
 if CENTER
  % Necesary colorbands number to be centered:
  Nmin        = [N1 N2];
  [Nmax,imax] = max(Nmin);
  Nmin(imax)  = [];
  Nc2         = Nc + Nmax - Nmin;
  % Generate a colormap with this size:
  CMAP = cmapping(Nc2,CMAP);
  if imax==1
   CMAP = CMAP(1:Nc,:);
  else
   CMAP = flipud(CMAP);
   CMAP = CMAP(1:Nc,:);
   CMAP = flipud(CMAP);
  end
 else
  CMAP = cmapping(Nc,CMAP);
 end
 
 % Sets levels:
 LEVELS = linspace(CLIM(1),CLIM(2),size(CMAP,1))';
end

% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------
if ~isempty(AX)
 colormap(AX{:},CMAP)
 caxis(AX{:},CLIM)
end
if ~nargout
 if isempty(AX)
  colormap(CMAP)
  caxis(CLIM)
 end
 clear CMAP
end
end
function [CMAP,LEV,WID,CLIM] = cmjoin(varargin)
%CMJOIN   Joins colormaps at certain levels.
%
%   SYNTAX:
%                           cmjoin(CMAPS)
%                           cmjoin(CMAPS,LEV)
%                           cmjoin(CMAPS,LEV,WID)
%                           cmjoin(CMAPS,LEV,WID,CLIM)
%                           cmjoin(AX,...)
%     [CMAP,LEV,WID,CLIM] = cmjoin(...);
%
%   INPUT:
%     CMAPS - Cell with the N colormaps handles, names or RGB colors to be
%             joined. See NOTE below.
%     LEV   - One of:
%               a) N-1 scalars specifying the color levels where the
%                  colormaps will be joined (uses CAXIS). See NOTE below.
%               b) N integers specifying the number of colors for each
%                  colormap.
%               c) N+1 scalars specifying the color limits for each
%                  colormap (sets CAXIS). See NOTE below.
%             DEFAULT: Tries to generate a CMAP with default length.
%     WID   - May be one (or N) positive scalar specifying the width for
%             every (or each) color band. See NOTE below.
%             DEFAULT: uses CAXIS and LEV to estimate it.  
%     CLIM  - 2 elements row vector specifying the color limits values. May
%             be changed at the end, because of the discretization of the
%             colormaps.
%             DEFAULT: uses CAXIS or [0 1] if there are no axes.
%     AX    - Uses the specified axes handle to get/set the CMAPS. If used,
%             must be the first input.
%             DEFAULT: gca
%
%   OUTPUT (all optional):
%     CMAP - RGB colormap output matrix, M-by-3.
%     LEV  - Final levels used.
%     WID  - Final widths used.
%     CLIM - Final color limits used.
%
%   DESCRIPTION:
%     This function join two colormaps at specific level. Useful for
%     joining colormaps at zero (for example) and distinguish from positive
%     and negative values.
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%     * If no output is required or an axes handle were given, the current
%       COLORMAP and CAXIS are changed.
%     * If any of the inputs on CMAPS is a function name, 'jet', for
%       example, it can be used backwards (because CMAPPING is used) if
%       added a '-' at the beggining of its name: '-jet'.
%     * When LEV is type b) and WID is specifyed, the latter is taken as
%       relative colorbans widths between colormaps.
%
%   EXAMPLE:
%     figure(1), clf, surf(peaks)
%     cmjoin({'copper','-summer'},2.5)
%      shading interp, colorbar, axis tight, zlabel('Meters')
%      title('Union at 2.5 m')
%     %
%     figure(2), clf, surf(peaks) 
%     cmjoin({'copper','-summer'},2.5,0.5)
%      shading interp, colorbar, axis tight, zlabel('Meters')
%      title('Union at 2.5 m and different color for each 0.5 m band')
%     %
%     figure(3), clf, surf(peaks)
%     cmjoin({'copper','summer'},2.5,[2 0.5])
%      shading interp, colorbar, axis tight, zlabel('Metros')
%      title('Union at 2.5 m with lengths 2 and 0.5')
%     %
%     figure(4), clf, surf(peaks)
%     cmjoin({'copper','summer'},[-10 2.5 10],[2 0.5])
%      shading interp, colorbar, axis tight, zlabel('Metros')
%      title('Union at 2.5 m with lengths 2 and 0.5 and specified levels')
%     %
%     figure(5), clf, surf(peaks)
%     cmjoin({'copper','summer'},[10 8],[4 1])
%      shading interp, colorbar, axis tight, zlabel('Metros')
%      title('Union at 2.5 m with specified levels number of colors and widths 4:1')
%    
%   SEE ALSO:
%     COLORMAP, COLORMAPEDITOR
%     and
%     CMAPPING by Carlos Vargas
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cmjoin.m
%   VERSION: 2.0 (Jun 08, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0       Released as SETCOLORMAP. (Nov 07, 2006)
%   1.1       English translation. (Nov 11, 2006)
%   2.0       Rewritten and renamed code (from SETCOLORMAPS to CMJOIN. Now
%             joins multiple colormaps. Inputs changed. (Jun 08, 2009)

%   DISCLAIMER:
%   cmjoin.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2006,2009 Carlos Adrian Vargas Aguilera

% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Parameters:
tol  = 1;            % When rounding the levels.

% Checks inputs and outputs number:
if nargin<1
 error('CVARGAS:cmjoin:notEnoughInputs',...
  'At least 1 input is required.')
end
if nargin>5
 error('CVARGAS:cmjoin:tooManyInputs',...
  'At most 5 inputs are allowed.')
end
if nargout>4
 error('CVARGAS:cmjoin:tooManyOutputs',...
  'At most 4 outputs are allowed.')
end

% Checks AX:
AX = {get(get(0,'CurrentFigure'),'CurrentAxes')};
if isempty(AX{1})
 AX = {};
end
if (length(varargin{1})==1) && ishandle(varargin{1}) && ...
  strcmp(get(varargin{1},'Type'),'axes')
 AX = varargin(1);
 varargin(1) = [];
 if isempty(varargin)
  error('CVARGAS:cmjoin:notEnoughInputs',...
   'CMAPS input must be given.')
 end
end

% Checks CMAPS:
CMAPS  = varargin{1};
Ncmaps = length(CMAPS);
if ~iscell(CMAPS) || (Ncmaps<2)
 error('CVARGAS:cmjoin:incorrectCmapsType',...
  'CMAPS must be a cell input with at least 2 colormaps.')
end
varargin(1) = [];
Nopt        = length(varargin);

% Checks LEV and sets Ncol and Jlev:
Ncol = []; % Number of colors for each colormap.
Jlev = []; % Join levels.
LEV  = []; % Levels at which each CMAPS begins and ends.
if (Nopt<1) || isempty(varargin{1})
 % continue as empty
elseif ~all(isfinite(varargin{1}(:)))
 error('CVARGAS:cmjoin:incorrectLevValue',...
  'LEV must be integers or scalars.')
else
 Nopt1 = length(varargin{1}(:));
 if (Nopt1==Ncmaps)
  % Specifies number of colors:
  Ncol = varargin{1}(:);
  if ~all(Ncol==round(Ncol))
   error('CVARGAS:cmjoin:incorrectLevInput',...
    'LEV must be integers when defines number of colors.')
  end
 elseif ~all(sort(varargin{1})==varargin{1})
  error('CVARGAS:cmjoin:incorrectLevInput',...
   'LEV must be monotonically increasing.')
 elseif Nopt1==(Ncmaps-1) 
  Jlev = varargin{1}(:);
 elseif Nopt1==(Ncmaps+1)
  LEV = varargin{1}(:);
 else
  error('CVARGAS:cmjoin:incorrectLevLength',...
   'LEV must have any of length(CMAPS)+[-1 0 1] elements.')
 end
end

% Checks WID:
Tcol = []; % Total number of colors for output colormap.
if (Nopt<2) || isempty(varargin{2})
 % Tries to generate a colormap with default length with every colorband
 % of the same width:
 WID = [];
 if ~isempty(AX)
  Tcol = size(colormap(AX{:}),1);
 else
  Tcol = size(get(0,'DefaultFigureColormap'),1);
 end
else
 WID = varargin{2}(:);
 WID(~isfinite(WID) | (WID<0)) = 0;
 if ~any(WID>0)
  error('CVARGAS:cmjoin:incorrectWidInput',...
   'At least one WID must be positive.')
 end
 if length(WID)==1
  WID = repmat(abs(varargin{2}),Ncmaps,1);
 elseif length(WID)~=Ncmaps
  error('CVARGAS:cmjoin:incorrectWidLength',...
   'WID must have length 1 or same as CMAPS.')
 end
end

% Checks CLIM:
if (Nopt<3) || isempty(varargin{3})
 % Sets default CLIM:
 if ~isempty(LEV)
  CLIM = [LEV(1) LEV(end)];
 elseif ~isempty(AX)
  CLIM = caxis(AX{:});
 else
  CLIM = [0 1];
 end
else
 CLIM = varargin{3}(:).';
 if (length(CLIM)==2) && (diff(CLIM)>0) && isfinite(diff(CLIM))
  % continue
 else
  error('CVARGAS:cmjoin:incorrectClimInput',...
   'CLIM must be a valid color limits. See CAXIS for details.')
 end
end


% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------

% Gets rounding precision:
temp = warning('off','MATLAB:log:logOfZero');
if ~isempty(WID)
 tempp               = WID;
 precision           = floor(log10(abs(tempp)));
 precision(tempp==0) = 0;
 precision           = min(precision)-tol;
 % Rounds:
 WID   = round(WID*10^(-precision))*10^precision;
 if ~isempty(LEV)
  LEV(1)        = floor(LEV(1)       *10^(-precision))*10^precision;
  LEV(2:end-1)  = round(LEV(2:end-1) *10^(-precision))*10^precision;
  LEV(end)      = ceil(LEV(end)      *10^(-precision))*10^precision;
 elseif ~isempty(Jlev)
  Jlev(1)       = floor(Jlev(1)      *10^(-precision))*10^precision;
  Jlev(2:end-1) = round(Jlev(2:end-1)*10^(-precision))*10^precision;
  Jlev(end)     = ceil(Jlev(end)     *10^(-precision))*10^precision;
 end
elseif ~isempty(LEV)
 tempp               = diff(LEV);
 precision           = floor(log10(abs(tempp)));
 precision(tempp==0) = 0;
 precision           = min(precision)-tol;
 % Rounds:
 LEV(1)       = floor(LEV(1)      *10^(-precision))*10^precision;
 LEV(2:end-1) = round(LEV(2:end-1)*10^(-precision))*10^precision;
 LEV(end)     = ceil(LEV(end)     *10^(-precision))*10^precision;
elseif ~isempty(Jlev)
 tempp               = diff(Jlev);
 if isempty(tempp)
  tempp              = Jlev;
 end
 precision           = floor(log10(abs(tempp)));
 precision(tempp==0) = 0;
 precision           = min(precision)-tol;
 % Rounds:
 if length(Jlev)==1
  Jlev          = round(Jlev*10^(-precision))*10^precision;
 else
  Jlev(1)       = floor(Jlev(1)      *10^(-precision))*10^precision;
  Jlev(2:end-1) = round(Jlev(2:end-1)*10^(-precision))*10^precision;
  Jlev(end)     = ceil(Jlev(end)     *10^(-precision))*10^precision;
 end
else
 tempp               = CLIM;
 precision           = floor(log10(abs(tempp)));
 precision(tempp==0) = 0;
 precision           = min(precision)-tol;
end
% Rounds:
CLIM(1) = floor(CLIM(1)*10^(-precision))*10^precision;
CLIM(2) =  ceil(CLIM(2)*10^(-precision))*10^precision;
warning(temp.state,'MATLAB:log:logOfZero')

% Completes levels when only join levels are specified:
if ~isempty(Jlev)
 cedge = CLIM;
 % First limit:
 if cedge(1)<=Jlev(1)
  if ~isempty(WID)
   cedge(1) = Jlev(1);
   if WID(1)~=0
    cedge(1) = cedge(1) - WID(1)*ceil((Jlev(1)-CLIM(1))/WID(1));
   end
  else
   % continue
  end
 else
  if (Ncmaps==2)
   cedge(1) = Jlev(1);
  else
   for k = 2:length(Jlev)
    if cedge(1)<=Jlev(k)
     cedge(1) = Jlev(k-1);
     break
    else
     Jlev(k-1) = Jlev(k);
    end
   end
  end
 end
 % Last limit:
 if cedge(2)>=Jlev(end)
  if ~isempty(WID)
   cedge(2) = Jlev(end);
   if WID(end)~=0
    cedge(2) = cedge(2) + WID(end)*ceil((CLIM(2)-Jlev(end))/WID(end));
   end
  else
   % continue
  end
 else
  if (Ncmaps==2)
   cedge(2) = Jlev(end);
  else
   for k = length(Jlev)-1:-1:1
    if cedge(2)>=Jlev(k)
     cedge(2) = Jlev(k+1);
     break
    else
     Jlev(k+1) = Jlev(k);
    end
   end
  end
 end
 % New Levels:
 LEV = [cedge(1); Jlev; cedge(2)];
 
end

% Gets colorband width and sets WID:
if ~isempty(Ncol)
 if isempty(WID)
  % Treats all colorbands with equal widths:
  Cwid = diff(CLIM)/sum(abs(Ncol));
  Cwid = round(Cwid*10^(-(precision-1)))*10^(precision-1);
  WID  = repmat(Cwid,Ncmaps,1);
  LEV  = [CLIM(1); CLIM(1)+cumsum(abs(Ncol))*Cwid];
 else
  % Treats WID as colorbands withs relations:
  WID   = WID/min(WID(WID~=0));
  Ncol2 = WID.*Ncol;
  Cwid  = diff(CLIM)/sum(abs(Ncol2));
  Cwid  = round(Cwid*10^(-(precision-1)))*10^(precision-1);
  WID   = WID*Cwid;
  LEV   = [CLIM(1); CLIM(1)+cumsum(abs(Ncol2))*Cwid];
 end
elseif ~isempty(WID)
 % Gets colorband width:
 Cwid  = WID(1)*10^(-precision);
 for k = 2:Ncmaps
  Cwid = gcd(Cwid,WID(k)*10^(-precision));
 end
 Cwid  = Cwid*10^precision;
else
 % Gets relation between colomaps width:
 if isempty(LEV)
  r    = ones(Ncmaps,1);
  d    = diff(CLIM);
 else
  r         = diff(LEV);
  temp      = warning('off','MATLAB:log:logOfZero');
  precision = floor(log10(abs(r))); % r = Str.XXX x 10^precision.
  precision(r==0) = 0; % precision=0 if Ncol=0.
  warning(temp.state,'MATLAB:log:logOfZero')
  precision = min(precision)-tol;
  r  = round(r*10^(-precision));
  rgcd  = r(1);
  for k = 2:Ncmaps
   rgcd = gcd(rgcd,r(k));
  end
  r = r/rgcd;
  d = (LEV(end)-LEV(1));
 end
 % Gets colorband width:
 r    = r*ceil(Tcol/sum(r));
 Cwid = d/sum(r);
 WID  = repmat(Cwid,Ncmaps,1);
end

% Sets LEV when empty:
if isempty(LEV)
 LEV = linspace(CLIM(1),CLIM(2),Ncmaps+1)';
end

% Gets number of colors for each colormap:
Ncol2 = round(diff(LEV)/Cwid);
if ~isempty(Ncol)
 % continue
else
 Ncol = round(diff(LEV)./WID);
 Ncol(~isfinite(Ncol)) = 0;
 if ~all(Ncol==round(Ncol))
  error('CVARGAS:cmjoin:incorrectWidColor',...
   'Colorband do not match each colormap width. Modify LEV or WID.')
 end
end

% Generates the colormaps:
CMAP  = zeros(sum(abs(Ncol2)),3);
xband = zeros(sum(abs(Ncol2))+1,1);
tempr = [];
for k = 1:Ncmaps
 if Ncol(k)
  r          = sum(abs(Ncol2(1:k-1)))+(1:abs(Ncol2(k)));
  if Ncol(k)~=Ncol2(k)
   CMAP(r,:) = cmapping(Ncol2(k),cmapping(Ncol(k),CMAPS{k}),'discrete');
  else
   CMAP(r,:) = cmapping(Ncol(k),CMAPS{k});
  end
  tempr      = linspace(LEV(k),LEV(k+1),abs(Ncol2(k))+1)';
  xband(r)   = tempr(1:end-1); 
 end
end
if ~isempty(tempr)
 xband(end) = tempr(end);
end

% Cuts edges:
ind = find((xband>=CLIM(1)) & (xband<=CLIM(2)));
if (ind(1)~=1) && ~(any(xband==CLIM(1)))
 ind = [ind(1)-1; ind];
end
if (ind(end)~=length(ind)) && ~(any(xband==CLIM(2)))
 ind = [ind; ind(end)+1];
end
CMAP  = CMAP(ind(1:end-1),:);
clim2 = xband(ind([1 end]));


% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------

if ~nargout
 colormap(AX{:},CMAP)
 caxis(AX{:},clim2(:)');
 clear CMAP
else
 if ~isempty(AX)
  colormap(AX{:},CMAP)
  caxis(AX{:},clim2(:)');
 end
 CLIM = clim2;
 WID  = diff(LEV)./max([Ncol ones(Ncmaps,1)],[],2);
end
end
function [HL,CLIN] = cmlines(varargin)
% CMLINES   Change the color of plotted lines using the colormap.
%
%   SYNTAX:
%                 cmlines
%                 cmlines(CMAP)
%                 cmlines(H,...)
%     [HL,CLIN] = cmlines(...);
%   
%   INPUT:
%     CMAP - Color map name or handle to be used, or a Nx3 matrix of colors
%            to be used for each of the N lines or color char specifiers.
%            DEFAULT: jet.
%     H    - Handles of lines or from a axes to search for lines or from
%            figures to search for exes. If used, must be the first input.
%            DEFAULT: gca (sets colors for lines in current axes)
%
%   OUTPUT (all optional):
%     HL   - Returns the handles of lines. Is a cell array if several axes
%            handle were used as input.
%     CLIN - Returns the RGB colors of the lines. Is a cell array if
%            several axes handle were used as input.
%
%   DESCRIPTION:
%     Ths function colored the specified lines with the spectrum of the
%     given colormap. Ideal for lines on the same axes which means increase
%     (or decrease) monotonically.
%
%   EXAMPLE:
%     plot(reshape((1:10).^2,2,5))
%     cmlines
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%    
%   SEE ALSO:
%     PLOT and COLORMAP.
%     and
%     CMAPPING
%     at http://www.mathworks.com/matlabcentral/fileexchange
%
%
%   ---
%   MFILE:   cmlines.m
%   VERSION: 1.0 (Jun 08, 2009) (<a href="matlab:web(['www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do',char(63),'objectType',char(61),'author',char(38),'objectId=1093874'])">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released. (Jun 08, 2009)

%   DISCLAIMER:
%   cmlines.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2009 Carlos Adrian Vargas Aguilera

% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% Set defaults:
HL   = {};
Ha   = gca;
CMAP = colormap;

% Checks number of inputs:
if nargin>2
 error('CVARGAS:cmlines:tooManyInputs', ...
  'At most 2 inputs are allowed.')
end
if nargout>2
 error('CVARGAS:cmlines:tooManyOutputs', ...
  'At most 2 outputs are allowed.')
end

% Checks handles of lines, axes or figure inputs:
Hl = [];
if (nargin~=0) && ~isempty(varargin{1}) && all(ishandle(varargin{1}(:))) ...
 && ((length(varargin{1})>1) || ~isa(varargin{1},'function_handle'))
 Ha = [];
 for k = 1:length(varargin{1})
  switch get(varargin{1}(k),'Type')
   case 'line'
    Hl = [Hl varargin{1}(k)];
   case 'axes'
    Ha = [Ha varargin{1}(k)];
   case {'figure','uipanel'}
    Ha = [Ha findobj(varargin{1}(k),'-depth',1,'Type','axes',...
                      '-not',{'Tag','Colorbar','-or','Tag','legend'})];
   otherwise
     warning('CVARGAS:cmlines:unrecognizedHandleInput',...
      'Ignored handle input.')
  end
 end
 varargin(1) = [];
end

% Looks for CMAP input:
if nargin && ~isempty(varargin) && ~isempty(varargin{1})
 CMAP = varargin{1};
end

% Gets line handles:
if ~isempty(Hl)
 HL{1} = Hl;
end
if ~isempty(Ha)
 for k = 1:length(Ha)
  Hl = findobj(Ha(k),'Type','line');
  if ~isempty(Hl)
   HL{end+1} = Hl;
  end
 end
end
if isempty(HL)
 if ~nargout
  clear HL
 end
 return
end

% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------

% Sets color lines for each set of lines:
Nlines = length(HL);
CLIN   = cell(1,Nlines);
for k  = 1:length(HL)
 
 % Interpolates the color map:
 CLIN{k} = cmapping(length(HL{k}),CMAP);

 % Changes lines colors:
 set(HL{k},{'Color'},mat2cell(CLIN{k},ones(1,size(CLIN{k},1)),3))
 
end

% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------

if ~nargout
 clear HL
elseif Nlines==1
 HL   = HL{1};
 CLIN = CLIN{1};
end
end
