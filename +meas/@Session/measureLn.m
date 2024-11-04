function measureLn(obj, varargin)
    %MEASURELN Make a linearity error measurement.
    %
    %   Only works for LDAQ measurement Hardware.
    %
    %Usage:
    %   session = bose.cnc.meas.Session.start;
    %   session.measureLn(doLinearity, doNoise, gainChange, smoothing);
    %
    %Required Arguments:
    %   doLinearity (logical): Flag to perform linearity measurement
    %   doNoise (logical): Flag to perform noise measurement
    %
    %Optional Arguments:
    %   gainChange (double): dB Gain change for linearity measurement (Default: -6)
    %   smoothing (double): Octaves to smooth data by before calculating metrics (Default: 0.1)
    %
    %Throws:
    %   InvalidHardware - When the HardwareType is not LDAQ.
    %   InvalidInput - When both doLinearity and doNoise are false.
    %
    %See also: bose.cnc.meas.Session

    % Alex Coleman & Mike DuCott
    % $Id$

    idHeader = 'bose:cnc:meas:Session:measureLn:';

    % Parse inputs
    parser = inputParser;
    addRequired(parser, 'doLinearity', @islogical);
    addRequired(parser, 'doNoise', @islogical);
    addOptional(parser, 'gainChange', -6, @(x) isscalar(x) && isnumeric(x));
    addOptional(parser, 'smoothing', 0.1, @(x) (x > 0) && isscalar(x) && isnumeric(x));
    parse(parser, varargin{:});
    doLinearity = parser.Results.doLinearity;
    doNoise = parser.Results.doNoise;
    gainChange = parser.Results.gainChange;
    smoothing = parser.Results.smoothing;

    % Get logger and send debug message
    logger = bose.cnc.logging.getLogger;
    logger.debug('bose.cnc.meas.Session.measureLn function');

    % Error if neither linearity or noise measurement is selected
    if doLinearity == false && doNoise == false
        mError = MException( ...
            [idHeader 'InvalidInput'], ...
            'Must perform either a Linearity or a Noise measurement' ...
        );
        logger.error('Invalid Measurement: Must perform either a Linearity or a Noise measurement', mError);
    end

    % Find any timers
    timerHandle = [ ...
        bose.cnc.meters.SealQualityMeter.getTimer; ...
        bose.cnc.meters.NxsMeter.getTimer ...
    ];

    % Check if we are ready to measure and get the mappings for this CurrentStep
    [selectedInputMappings, selectedOutputMappings] = assertReadiness(obj);

    % Get the selected input channels
    selectedInputSignals = [selectedInputMappings.Signal]';
    selectedInputSignalNames = cellstr([selectedInputSignals.Name]');
    selectedInputChannels = cellstr([selectedInputMappings.Channel]');
    selectedOutputChannels = cellstr([selectedOutputMappings.Channel]');

    % Set the Excitation Signals
    obj.configureHardwareSignals;

    % Get Signal params for current step
    sigParams = obj.CurrentStep.SignalParameters;
    indPrerunLast = floor((sigParams.TUp + sigParams.TPrerun) * sigParams.Fs);
    indStart = indPrerunLast + 1;
    indEnd = indPrerunLast + floor(sigParams.TRecord * sigParams.Fs);

    % Pause any timers
    resumeTimer = false;
    if ~isempty(timerHandle) && strcmp(timerHandle.Running, 'on')
        resumeTimer = true;
        stop(timerHandle);
    end

    % Create correction Factor Matrix
    nHalf = floor(sigParams.Nfft / 2) + 1;
    nSignals = length(selectedInputMappings);
    correctionFactorMatrix = ones(nHalf, nSignals);

    for sig = 1:nSignals
        if strcmp(selectedInputMappings(sig).Signal.Type, 'AsrcSignal') % if the signal is from an ASRC
            correctionFactorMatrix(:, sig) = bose.cnc.math.createAsrcCorrection(sigParams.Fs, nHalf);
        end
    end

    % Only for LDAQ
    if obj.Hardware.Type == bose.cnc.meas.HardwareType.ldaq
        % Temporarily set AutoPlot to false for measuring raw signals
        origAutoPlot = obj.DeviceHandle.AutoPlot;
        obj.DeviceHandle.AutoPlot = false;

        % Get current output channel gains
        currentGains = zeros(size(selectedOutputChannels));

        for chan = 1:numel(selectedOutputChannels)
            currentGains(chan) = obj.DeviceHandle.(selectedOutputChannels{chan}).Gain;
        end

        % Notify "PreMeasurement" event
        notify(obj, 'PreMeasurement');

        % Measure current input signals
        logger.info('Measuring signal');
        sigMeas = obj.DeviceHandle.measure(); % .measure here returns a DUT.

        % Select only the channels with signals included in this step.
        sigMeas = sigMeas.Channel{selectedInputSignalNames{:}};

        % Exclude ramp up, prerun and ramp down regions of data
        sigMeas = sigMeas.sample(indStart:indEnd);

        % Notify "PostMeasurement" event
        notify(obj, 'PostMeasurement');

        % Calculate auto-spectra of inputs
        sigPsd = bose.cnc.math.time2cpsd( ...
            data(sigMeas), ...
            sigParams.Fs, ...
            bose.cnc.math.getWindow(sigParams.Window, sigParams.Nfft), ...
            sigParams.Nfft, ...
            sigParams.NOverlap, ...
            'single', ...
            correctionFactorMatrix ...
        );
        sigPsd = sigPsd(:, logical(eye(numel(selectedInputSignalNames))));

        % Initialize an array for all PSD & error data
        allPsd = zeros(size(sigPsd, 1), size(sigPsd, 2), 3); % sig, lin, noise = 3
        allErrors = zeros(size(sigPsd, 1), size(sigPsd, 2), 3); % lin, noiseMax, noiseMin = 3

        % Smooth Data
        sigPsd = smooth2(sigPsd, smoothing);
        allPsd(:, :, 1) = sigPsd;

        % If doing a linearity measurement ...
        if doLinearity
            % Apply gain change to each output channel
            logger.debug(sprintf('Applying %ddB gain to output channels', gainChange));

            for chan = 1:numel(selectedOutputChannels)
                obj.DeviceHandle.(selectedOutputChannels{chan}).Gain = currentGains(chan) + gainChange;
            end

            % Notify "PreMeasurement" event
            notify(obj, 'PreMeasurement');

            % Measure gain adjusted input signals
            logger.info(sprintf('Measuring signal with %ddB gain change', gainChange));
            linMeas = obj.DeviceHandle.measure();

            % Select only the channels with signals included in this step.
            linMeas = linMeas.Channel{selectedInputSignalNames{:}};

            % Exclude ramp up, prerun and ramp down regions of data
            linMeas = linMeas.sample(indStart:indEnd);

            % Notify "PostMeasurement" event
            notify(obj, 'PostMeasurement');

            % Calculate auto-spectra of inputs
            linPsd = bose.cnc.math.time2cpsd( ...
                data(linMeas), ...
                sigParams.Fs, ...
                bose.cnc.math.getWindow(sigParams.Window, sigParams.Nfft), ...
                sigParams.Nfft, ...
                sigParams.NOverlap, ...
                'single', ...
                correctionFactorMatrix ...
            );
            linPsd = linPsd(:, logical(eye(numel(selectedInputSignalNames))));

            % Smooth data
            linPsd = smooth2(linPsd, smoothing);
            allPsd(:, :, 2) = linPsd;

            % Calculate linearity + noise error
            allErrors(:, :, 1) = 10 * log10(sigPsd) - 10 * log10(linPsd) + gainChange;
        end

        % If doing a noise measurement ...
        if doNoise
            % Mute the output channels
            logger.debug('Muting outputs');
            
            for chan = 1:numel(selectedOutputChannels)
                minGain = obj.DeviceHandle.(selectedOutputChannels{chan}).PossibleGains(1);
                obj.DeviceHandle.(selectedOutputChannels{chan}).Gain = minGain;
            end

            % Notify "PreMeasurement" event
            notify(obj, 'PreMeasurement');

            % Measure noise
            logger.info('Measuring Noise with muted outputs');
            noiseMeas = obj.DeviceHandle.measure();

            % Select only the channels with signals included in this step.
            noiseMeas = noiseMeas.Channel{selectedInputSignalNames{:}};

            % Exclude ramp up, prerun and ramp down regions of data
            noiseMeas = noiseMeas.sample(indStart:indEnd);

            % Notify "PostMeasurement" event
            notify(obj, 'PostMeasurement');

            % Calculate auto-spectra of inputs
            noisePsd = bose.cnc.math.time2cpsd( ...
                data(noiseMeas), ...
                sigParams.Fs, ...
                bose.cnc.math.getWindow(sigParams.Window, sigParams.Nfft), ...
                sigParams.Nfft, ...
                sigParams.NOverlap, ...
                'single', ...
                correctionFactorMatrix ...
            );
            noisePsd = noisePsd(:, logical(eye(numel(selectedInputSignalNames))));

            % Smooth data
            noisePsd = smooth2(noisePsd, smoothing);
            allPsd(:, :, 3) = noisePsd;

            % Calculate noise error
            allErrors(:, :, 2) = 20 * log10(abs(sqrt(sigPsd) + sqrt(noisePsd)) ./ sqrt(sigPsd));
            allErrors(:, :, 3) = 20 * log10(abs(sqrt(sigPsd) - sqrt(noisePsd)) ./ sqrt(sigPsd));
        end

        % Restore gains to initial values
        logger.info('Restoring output gains');

        for chan = 1:numel(selectedOutputChannels)
            obj.DeviceHandle.(selectedOutputChannels{chan}).Gain = currentGains(chan);
        end

        % Graph results
        local_graphLinearityData(obj, allPsd, allErrors, selectedInputChannels, obj.CurrentStep, gainChange, smoothing);

        % Restore the original AutoPlot value
        obj.DeviceHandle.AutoPlot = origAutoPlot;

        % Resume any stopped timers
        if ~isempty(timerHandle) && resumeTimer
            start(timerHandle);
        end
    else
        % Resume any stopped timers
        if ~isempty(timerHandle) && resumeTimer
            start(timerHandle);
        end

        error( ...
            [idHeader 'InvalidHardware'], ...
            'Session.measureLn only supports LDAQ devices.' ...
        );
    end % if LDAQ
end % function

function local_graphLinearityData(obj, allPsd, allErrors, selectedInputChannels, currentStep, gainChange, smoothing)
    % Local function to graph results of linearity + noise measurements

    % Get Signal params from current Step
    sigParams = currentStep.SignalParameters;

    % Uifigures for plotting
    respFig = findall(0, 'Tag', 'DiagnosticResponseFig');
    errorFig = findall(0, 'Tag', 'DiagnosticErrorFig');

    if isempty(respFig)
        % If it doesn't already exist, create response uifigure
        respFig = uifigure('Name', 'Signal & Noise PSD Responses', 'Tag', 'DiagnosticResponseFig');
    else
        % Clear existing figure and appdata
        respFig = clf(respFig);
        cellfun(@(x) rmappdata(respFig, x), fieldnames(getappdata(respFig)));
    end

    if isempty(errorFig)
        % If it doesn't already exist, create error uifigure
        errorFig = uifigure('Name', 'Linearity & Noise Error Estimates', 'Tag', 'DiagnosticErrorFig');
    else
        % Clear existing figure and appdata
        errorFig = clf(errorFig);
        cellfun(@(x) rmappdata(errorFig, x), fieldnames(getappdata(errorFig)));
    end

    % Determine whether we ran linearity, noise, or both
    doLinearity = any([allPsd(:, :, 2)] > 0);
    doNoise = any([allPsd(:, :, 3)] > 0);

    % Build cell arrays of signal names
    % Subselect the data and convert to dB and adjust for gain change
    respSigNames = {'Signal'};
    errorSigNames = {};
    exportPsd = 10 * log10(allPsd(:, :, 1));
    exportErrors = double.empty(size(exportPsd, 1), size(exportPsd, 2), 0);

    if doLinearity
        respSigNames = [respSigNames sprintf('%ddB Gain Change', gainChange)];
        errorSigNames = [errorSigNames 'Linearity Error'];
        exportPsd = cat(3, exportPsd, 10 * log10(allPsd(:, :, 2)) - gainChange);
        exportErrors = cat(3, exportErrors, allErrors(:, :, 1));
    end

    if doNoise
        respSigNames = [respSigNames 'Noise'];
        errorSigNames = [errorSigNames 'Max Noise Error' 'Min Noise Error'];
        exportPsd = cat(3, exportPsd, 10 * log10(allPsd(:, :, 3)));
        exportErrors = cat(3, exportErrors, allErrors(:, :, 2:3));
    end

    % Embed data in figures to allow export
    respDut = freqdut( ...
    exportPsd, ...
        sigParams.Frequencies, ...
        'volts', ...
        'db' ...
    );
    respDut.MapNames(2) = 'Channel';
    respDut.MapNames(3) = 'Signal';
    respDut.value(3) = respSigNames;
    respDut.Label = 'CncMeasure Linearity Measurement Data';
    set(respDut, 'FromF', 1);
    setappdata(respFig, 'CncMeasureResponseData', respDut);
    setappdata(respFig, 'currentStep', currentStep);
    setappdata(respFig, 'gainChange', gainChange);
    setappdata(respFig, 'smoothing', smoothing);

    errorDut = freqdut( ...
        exportErrors, ...
        sigParams.Frequencies, ...
        'volts', ...
        'db' ...
    );
    errorDut.MapNames(2) = 'Channel';

    if ndims(errorDut) == 3
        errorDut.MapNames(3) = 'ErrorType';
        errorDut.value(3) = errorSigNames;
    end

    errorDut.Label = 'CncMeasure Linearity Error Data';
    set(errorDut, 'FromF', 1);
    setappdata(errorFig, 'CncMeasureLinearityData', errorDut);
    setappdata(errorFig, 'currentStep', currentStep);
    setappdata(errorFig, 'gainChange', gainChange);
    setappdata(errorFig, 'smoothing', smoothing);

    % Create tab groups
    respTabGroup = uitabgroup(respFig, 'Position', [0 0 respFig.Position(3) + 1 respFig.Position(4) + 1]);
    errorTabGroup = uitabgroup(errorFig, 'Position', [0 0 errorFig.Position(3) + 1 errorFig.Position(4) + 1]);

    % Plot results
    numResps = size(allPsd, 2);
    axesRightMargin = 20;
    axesTopMargin = 40;
    plotLowFreq = 10;
    plotHighFreq = sigParams.Fs / 2;
    exportButtonPosition = [507 5 50 22];

    for dataSet = 1:numResps
        % Create response tab and axes
        respTab(dataSet) = uitab(respTabGroup, 'Title', obj.DeviceHandle.(selectedInputChannels{dataSet}).ChannelName);
        respAxes(dataSet) = uiaxes( ...
            respTab(dataSet), ...
            'Position', [ ...
                10, ...
                10, ...
                respTab(dataSet).Position(3) - axesRightMargin, ...
                respTab(dataSet).Position(4) - axesTopMargin ...
            ] ...
        );

        % Plot response data and set plot attributes
        semilogx(respAxes(dataSet), sigParams.Frequencies, squeeze(exportPsd(:, dataSet, :)));
        legend(respAxes(dataSet), respSigNames); %'Current Level', sprintf('%ddB Gain Change', gainChange), 'Noise');
        grid(respAxes(dataSet), 'on');
        respAxes(dataSet).XLim = [plotLowFreq plotHighFreq];
        respAxes(dataSet).Title.String = obj.DeviceHandle.(selectedInputChannels{dataSet}).ChannelName;
        respAxes(dataSet).XLabel.String = sprintf('Frequency (Hz)');
        respAxes(dataSet).YLabel.String = sprintf(sprintf('dB%s', obj.CurrentStep.InputSignals(1).Units));

        % Create Export button
        respExportBtn(dataSet) = uibutton( ...
        respTab(dataSet), ...
            'Position', exportButtonPosition, ...
            'Text', 'Export', ...
            'ButtonPushedFcn', {@local_exportDataFromFig, respFig} ...
        );

        % Create error tab and axes
        errorTab(dataSet) = uitab(errorTabGroup, 'Title', obj.DeviceHandle.(selectedInputChannels{dataSet}).ChannelName);
        errorAxes(dataSet) = uiaxes( ...
            errorTab(dataSet), ...
            'Position', [ ...
                10, ...
                10, ...
                errorTab(dataSet).Position(3) - axesRightMargin, ...
                errorTab(dataSet).Position(4) - axesTopMargin ...
            ] ...
        );

        % Plot error data, error bounds, and set plot attributes
        hold(errorAxes(dataSet), 'on');

        if doLinearity
            semilogx(errorAxes(dataSet), sigParams.Frequencies, squeeze(allErrors(:, dataSet, 1)));
        end

        if doNoise
            semilogx( ...
                errorAxes(dataSet), ...
                sigParams.Frequencies, ...
                squeeze(allErrors(:, dataSet, 2:3)), 'r' ...
            );
        end

        % hold(errorAxes(dataSet), 'on');
        line(errorAxes(dataSet), [plotLowFreq plotHighFreq], [.5 .5], 'Color', [0 1 0], 'LineStyle', '--', 'LineWidth', 3);
        line(errorAxes(dataSet), [plotLowFreq plotHighFreq], - [.5 .5], 'Color', [0 1 0], 'LineStyle', '--', 'LineWidth', 3);
        errorAxes(dataSet).XScale = 'log';
        hold(errorAxes(dataSet), 'off');
        grid(errorAxes(dataSet), 'on');
        legend(errorAxes(dataSet), errorSigNames);
        errorAxes(dataSet).XLim = [plotLowFreq plotHighFreq];
        errorAxes(dataSet).YLim = [-1.5 1.5];
        errorAxes(dataSet).Title.String = obj.DeviceHandle.(selectedInputChannels{dataSet}).ChannelName;
        errorAxes(dataSet).XLabel.String = sprintf('Frequency (Hz)');
        errorAxes(dataSet).YLabel.String = sprintf(sprintf('dB%s', obj.CurrentStep.InputSignals(1).Units));

        % Create Export button
        errorExportBtn(dataSet) = uibutton( ...
        errorTab(dataSet), ...
            'Position', exportButtonPosition, ...
            'Text', 'Export', ...
            'ButtonPushedFcn', {@local_exportDataFromFig, errorFig} ...
        );
    end
end % local_graphLinearityData

function local_exportDataFromFig(~, ~, parentFig)
    % Local helper function to export data from figures generated from this method

    % Get logger
    logger = bose.cnc.logging.getLogger;

    % Get file name and path
    [filename, pathname] = uiputfile('*.mat', 'Data Export');

    if isempty(filename) || isequal(filename, 0)
        logger.debug('Export: No file selected');
        return
    end

    % Get appdata from uifigure
    CncMeasureDiagnosticData = getappdata(parentFig);

    % Save data
    fullPath = fullfile(pathname, filename);
    save(fullPath, 'CncMeasureDiagnosticData');
    logger.info(sprintf('Saved Linearity/Noise data to %s', fullPath));
end % local_exportDataFromFig
