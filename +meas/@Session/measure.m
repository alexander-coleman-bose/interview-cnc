function measuredDut = measure(obj, saveDataRecord)
    %MEASURE Create a DataRecord by making a measurement.
    %
    %Usage:
    %   session.measure;
    %   measuredDut = session.measure(false);
    %
    %Optional Positional Arguments:
    %   saveDataRecord (logical): If false, do not add a DataRecord to the Session.
    %       (Default: true)
    %
    %Returns:
    %   measuredDut (dut): A time domain DUT of the measurement.
    %
    %See also: bose.cnc.meas.Session

    % $Id$

    narginchk(1, 2);

    if nargin < 2
        saveDataRecord = true;
    end

    logger = bose.cnc.logging.getLogger;
    logger.debug('bose.cnc.meas.Session.measure function');

    % Find any timers
    timerHandle = [ ...
        bose.cnc.meters.SealQualityMeter.getTimer; ...
        bose.cnc.meters.NxsMeter.getTimer ...
    ];

    % Check if we are ready to measure and get the mappings for this CurrentStep
    [selectedInputMappings, selectedOutputMappings] = assertReadiness(obj);

    % Get the selected input channels
    selectedInputSignals = [selectedInputMappings.Signal]';
    selectedInputChannelNames = cellstr([selectedInputSignals.Name]');

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

    % Notify "PreMeasurement" event
    notify(obj, 'PreMeasurement');

    % Take measurement using LDAQ
    measuredDut = obj.DeviceHandle.measure(); % .measure here returns a DUT.

    % Select only the channels with signals included in this step.
    measuredDut = measuredDut.Channel{selectedInputChannelNames{:}};

    % Exclude ramp up, prerun and ramp down regions of data
    measuredDut = measuredDut.sample(indStart:indEnd);

    % Notify "PostMeasurement" event
    notify(obj, 'PostMeasurement');

    % Resume any timers
    if ~isempty(timerHandle) && resumeTimer
        start(timerHandle);
    end

    nHalf = floor(sigParams.Nfft / 2) + 1;
    nSignals = length(selectedInputMappings);
    correctionFactorMatrix = ones(nHalf, nSignals);

    for sig = 1:nSignals
        if strcmp(selectedInputMappings(sig).Signal.Type, 'AsrcSignal') % if the signal is from an ASRC
            correctionFactorMatrix(:, sig) = bose.cnc.math.createAsrcCorrection(sigParams.Fs, nHalf);
        end
    end

    % Convert to freq. domain
    xsData = bose.cnc.math.time2cpsd( ...
        data(measuredDut), ...
        sigParams.Fs, ...
        bose.cnc.math.getWindow(sigParams.Window, sigParams.Nfft), ...
        sigParams.Nfft, ...
        sigParams.NOverlap, ...
        'single', ...
        correctionFactorMatrix ...
    );

    % Create a DataRecord
    tDataRecord = bose.cnc.meas.DataRecord.template;
    tDataRecord.Date = datetime;
    tDataRecord.Environment = obj.Environment;
    tDataRecord.ExcitationFilters = obj.CurrentStep.ExcitationFilters;
    tDataRecord.ExcitationGain = obj.CurrentStep.ExcitationGain;
    tDataRecord.ExcitationType = obj.CurrentStep.ExcitationType;
    tDataRecord.Fit = obj.CurrentFit;
    tDataRecord.Hardware = obj.Hardware;
    tDataRecord.Headphone = obj.Headphone;
    tDataRecord.InputMapping = selectedInputMappings;
    tDataRecord.Operator = obj.Operator;
    tDataRecord.OutputMapping = selectedOutputMappings;
    tDataRecord.SignalParameters = obj.CurrentStep.SignalParameters;
    tDataRecord.StepName = obj.CurrentStep.Name;
    tDataRecord.StepType = obj.CurrentStep.Type;
    tDataRecord.Subject = obj.Subject;
    tDataRecord.ToolboxVersion = bose.cnc.version;
    tDataRecord.XsData = xsData;
    tDataRecord.TimeData = single(data(measuredDut));
    dataRecord = bose.cnc.meas.DataRecord(tDataRecord);
    
    % Store DataRecord in the Session
    obj.DataRecords = [obj.DataRecords; dataRecord];

    logger.info(sprintf( ...
        'Finished %s (F%.0f)', ...
        tDataRecord.StepName, ...
        tDataRecord.Fit ...
    ));
    sessionDataFolder = obj.SessionDataFolder;
    if(saveDataRecord) %This should always be true when a user is running
        %If there isn't a session data folder go and make one.
        if(isempty(sessionDataFolder))
            obj.createSessionDataFolder();
            sessionDataFolder = obj.SessionDataFolder;
        end
        dataRecord.saveToFile(sessionDataFolder);
    end

    % Notify "PostMeasurementSave" event
    notify(obj, 'PostMeasurementSave');
    
    %If we got here we can assume the measurement was successful. So if
    %there isn't a backup of the sesssion, but one in the session data
    %folder
    
    sessionMatBackup = fullfile(sessionDataFolder,'BackupSession.mat');
    if(~isfile(sessionMatBackup))
        obj.toFile(sessionMatBackup);
        logger.info(sprintf('Generated Session Backup at %s',sessionMatBackup ));
    end
    
end % measure