function dataRecords = rmeoutToDataRecord(varargin)
%RMEOUTTODATARECORD Convert an rmeout struct into an array of DataRecords.
%
%Usage:
%   import bose.cnc.meas.*;
%   dataRecords = DataRecord.rmeoutToDataRecord(rmeout);
%   dataRecords = DataRecord.rmeoutToDataRecord(rmeout, 'datetime', datetime('yesterday'));
%   dataRecords = DataRecord.rmeoutToDataRecord(rmeout, 'environment', myTestEnvironment);
%   dataRecords = DataRecord.rmeoutToDataRecord(rmeout, 'headphone', myTestHeadphone);
%   dataRecords = DataRecord.rmeoutToDataRecord(rmeout, 'operator', myTestOperator);
%   dataRecords = DataRecord.rmeoutToDataRecord(rmeout, 'quiet', true);
%
%   This (static) method converts legacy rmeout structs exported from getxspec
%   into an array of DataRecords.
%
%Conventions assumed about the rmeout struct contents:
%   - The fields names of the rmeout struct correspond to a valid StepType
%   - The fields contain xDuts whose map is:
%       {'Sample'}{'Output'}{'Input'}{'subject'}{'group'}{'fit'}
%     If any of these dimensions are missing, or in a different order, the
%     DataRecord created will have these default values:
%       No subject dim = default to a "Missing" subject
%       No group dim = default to "None" for the side property of all Signal objects
%       No fit dim = specifies a single fit
%   - Values of the Input dimension of xDuts are valid SignalTypes
%   - xDuts contain linearly spaced frequency data
%
%Required Arguments:
%   rmeout (struct): Struct containing data exported from getxspec, with fields for every measurement type (i.e. sdvr, sopen, etc.).
%
%Parameter Arguments:
%   datetime (datetime): The datetime to use for the MissingHeadphone and DateRecord datetimes. (Default: datetime)
%   environment (bose.cnc.meas.Environment): Environment object reflecting measurement environment. (Default: bose.cnc.meas.Environment.empty)
%   headphone (bose.cnc.meas.Headphone): Headphone object reflecting measurement headphone. (Default: bose.cnc.meas.Headphone.empty)
%   operator (bose.cnc.meas.Person): Person object reflecting measurement operator. (Default: bose.cnc.meas.Person.empty)
%   quiet (logical): If true, suppress log messages. (Default: false)
%
%Returns:
%   dataRecords (DataRecord): Array of DataRecords
%
%See also: bose.cnc.meas.DataRecord, bose.cnc.meas.StepType,
%   bose.cnc.meas.SignalType, bose.cnc.meas.Headphone,
%   bose.cnc.meas.Environment, bose.cnc.meas.Person

% Author: Michael DuCott
% $Id$

% To Do:
%   - Validation function
%   - Dos command to look up subject emails

idHeader = 'bose:cnc:meas:DataRecord:rmeoutToDataRecord:';
logger = bose.cnc.logging.getLogger;

% Import packages
import('bose.cnc.meas.*');

% Parse input
parser = inputParser;
parser.addRequired('rmeout', @isstruct); %TODO: Add validation functions
parser.addParameter('datetime', datetime);
parser.addParameter('environment', Environment.empty, @(x) isa(x, 'bose.cnc.meas.Environment'));
parser.addParameter('headphone', Headphone.empty, @(x) isa(x, 'bose.cnc.meas.Headphone'));
parser.addParameter('operator', Person.empty, @(x) isa(x, 'bose.cnc.meas.Person'));
parser.addParameter('quiet', false, @(x) islogical(x));
parser.parse(varargin{:});

rmeout = parser.Results.rmeout;
currentDatetime = parser.Results.datetime;
currentEnvironment = parser.Results.environment;
currentHeadphone = parser.Results.headphone;
currentOperator = parser.Results.operator;
quietFlag = parser.Results.quiet;

%TODO(ALEX): Be able to specify Date, ExcitationFilters, ExcitationGain, ExcitationType, Fit, Hardware, SignalParameters, Subject

% Get the current toolbox version
toolboxVersion = bose.cnc.version;

% If Headphone is not provided, create a "Missing" Headphone
if isempty(currentHeadphone)
    tHeadphoneType = HeadphoneType.template;
    tHeadphoneType.Name = "MissingType"; %HACK(ALEX): Had to reduce the number of characters here so that we could upload to the HeadphoneTypes table in Headphones DB.
    tHeadphoneType.Project = "MissingProject";
    headphoneType = HeadphoneType(tHeadphoneType);

    tHeadphone = Headphone.template;
    tHeadphone.Name = "MissingName";
    tHeadphone.SerialNumber = "MissingSerialNumber";
    tHeadphone.ManufactureDate = currentDatetime;
    tHeadphone.Type = headphoneType;
    currentHeadphone = Headphone(tHeadphone);
end

% If Operator is not provided, create a "Missing" Operator
if isempty(currentOperator)
    tOperator = Person.template;
    tOperator.FirstName = "MissingOperatorFirstName";
    tOperator.LastName = "MissingOperatorLastName";
    currentOperator = Person(tOperator);
end

% Create "Missing" Hardware object
%TODO(ALEX): Should we generate a unique missing hardware here, or should all legacy DataRecords share the same missing Hardware?
tHardware = Hardware.template;
tHardware.Name = "MissingHardware";
tHardware.DeviceModel = "MissingHardwareDeviceModel";
tHardware.DeviceName = "MissingHardwareDeviceName";
tHardware.CalibrationMode = bose.cnc.meas.CalibrationMode.None;
tHardware.Type = bose.cnc.meas.HardwareType.rme;
currentHardware = Hardware(tHardware);

% Get Steps (fields) from input rmeout struct
steps = fieldnames(rmeout);

% Compute total number of DataRecords
drCount = ones(numel(steps),1);
for kdr = 1:numel(steps)
    drCount(kdr) = prod(size(rmeout.(steps{kdr}), [4 5 6]));
end
drCount = sum(drCount);
logger.debug(sprintf( ...
    'bose.cnc.meas.DataRecord.rmeoutToDataRecord method (%.0f DataRecords)', ...
    drCount ...
));

% Create the class templates outside of the loop to save time.
signalParametersTemplate = SignalParameters.template;
personTemplate = Person.template;
dataRecordTemplate = DataRecord.template;
blankSignal = Signal(Signal.template);
blankMapping = Mapping(Mapping.template);

% Loop over Steps
if ~quietFlag
    fprintf(newline);
end
dataRecords = DataRecord.empty; % Nx0 array
drNumber = 1;
for kd = 1:numel(steps)

    % Get this Step and associated xDut
    currentStepName = steps{kd};
    stepData = rmeout.(currentStepName);

    % Get Inputs, Subjects, Groups and Fits
    stepMap = stepData.mapnames;
    inputs = stepData.value('input');
    if any(strcmpi(stepMap,'subject'))
        subjects = stepData.value('subject');
    else
        % "Missing" subject
        subjects = {'MissingSubjectFirstName_MissingSubjectLastName'};
        stepData = newdim('subject', '', '', 't', stepData);
    end
    if any(strcmpi(stepMap,'group'))
        groups = stepData.value('group');
    else
        % No group (side)
        groups = {'None'};
        stepData = newdim('group', '', '', 't', stepData);
    end
    if any(strcmpi(stepMap,'fit'))
        fits = stepData.value('fit');
    else
        % No Fit dimension specifies a single fit
        fits = {'fit1'};
        stepData = newdim('fit', '', '', 't', stepData);
    end

    % Find the correct StepType
    switch(lower(currentStepName))
        case 'sdvr'
            currentStepType = StepType.Driver;
        case 'sfit'
            currentStepType = StepType.Fit;
        case 'sgod'
            currentStepType = StepType.Coupling;
        case {'sactive', 'fbonly', 'aware', 'fbff', 'cnc1', 'cnc2', 'cnc3', 'anr'} %HACK(ALEX): Double-check these names
            currentStepType = StepType.NoiseActive;
        case 'sopen'
            currentStepType = StepType.NoiseOpen;
        case 'spas'
            currentStepType = StepType.NoisePassive;
        case 'svactive'
            currentStepType = StepType.VoiceActive;
        case 'svopen'
            currentStepType = StepType.VoiceOpen;
        case 'svpas'
            currentStepType = StepType.VoicePassive;
        otherwise
            currentStepType = StepType.Generic;
            warnMsg = sprintf( ...
                '%s is not recognized, defaulting to Generic StepType', ...
                currentStepName ...
            );
            warning([idHeader 'UnknownStepName'], '%s', warnMsg);
            if ~quietFlag
                logger.warning(warnMsg);
            end
    end

    % Get Input Signal Types for the input signals
    inputSignals = Signal.empty(0, numel(inputs));
    for ki = 1:numel(inputs)
        inputSignals(ki) = blankSignal;
        inputSignals(ki).Name = inputs{ki};
        validEnums = enumeration('bose.cnc.meas.SignalType');
        validLabels = [validEnums.Label];
        switch string(inputs{ki})
            case cellstr(validLabels)
                inputSignals(ki).Type = bose.cnc.meas.SignalType.fromLabel(inputs{ki});
            case {"o1"}
                inputSignals(ki).Type = SignalType.FeedForwardMic;
            otherwise
                errMsg = sprintf( ...
                    [ ...
                        'Input signal ''%s'' in ''%s'' measurement (step) ' ...
                        'is an unrecognized SignalType' ...
                    ], ...
                    inputs{ki}, ...
                    currentStepName ...
                );
                mError = MException([idHeader 'InvalidSignalType'], '%s', errMsg);
                logger.error(errMsg, mError);
        end
    end

    % Get OutputSignals based on RequiredOutputTypes
    requiredOutputTypes = vertcat(currentStepType.RequiredOutputTypes);
    numOutputTypes = numel(requiredOutputTypes);
    outputSignals = Signal.empty(0, numOutputTypes);
    for indType = 1:numOutputTypes
        outputSignals(indType) = blankSignal;
        outputSignals(indType).Type = requiredOutputTypes(indType);
        outputSignals(indType).Name = sprintf( ...
            "MissingOutput-%s", ...
            outputSignals(indType).Type ...
        );
    end

    % Get SignalParameters that are available for this Step
    %HACK(MIKE): We are deriving/hacking Fs and Nfft assuming linear spaced freq data and even length acquisitions from getxspec()
    freqVec = stepData.Seq;
    signalParametersTemplate.Fs = freqVec(end).*2;              % Assumes last freq point is Nyquist (Fs/2)
    signalParametersTemplate.Nfft = (length(freqVec) - 1)*2;    % Assumes even length time acquisition
    currentSignalParameters = SignalParameters(signalParametersTemplate);

    % Loop over Subjects
    for ks = 1:numel(subjects)

        % Construct Person object for Subject
        subjectName = split(string(subjects{ks}),"_");
        personTemplate.FirstName = subjectName(1);
        personTemplate.LastName = join(subjectName(2:end));
        currentPerson = Person(personTemplate);
        %TODO(MIKE): Dos command to get email ?

        % Loop over Group (side)
        for kg = 1:numel(groups)

            % Current group (side)
            currentSide = string(groups{kg});

            % Set the Input Mapping & Input Channels
            currentInputMapping = Mapping.empty(0, numel(inputSignals));
            currentInputChannels = string.empty(0, numel(inputSignals));
            for km = 1:numel(inputSignals)
                currentInputChannels(km) = "MissingInputChannel-" + string(km);
                inputSignals(km).Side = currentSide;
                currentInputMapping(km) = blankMapping;
                currentInputMapping(km).Channel = "MissingInputChannel";
                currentInputMapping(km).Signal = inputSignals(km);
            end
            currentHardware.NumAnalogInputs = numel(currentInputChannels);

            % Set the Output Mapping & Output Channels
            currentOutputMapping = Mapping.empty(0, numel(outputSignals));
            currentOutputChannels = string.empty(0, numel(outputSignals));
            for km = 1:numel(outputSignals)
                currentOutputChannels(km) = "MissingOutputChannel-" + string(km);
                outputSignals(km).Side = currentSide;
                currentOutputMapping(km) = blankMapping;
                currentOutputMapping(km).Channel = "MissingOutputChannel";
                currentOutputMapping(km).Signal = outputSignals(km);
            end
            numOutputs = numel(currentOutputChannels);
            currentHardware.NumAnalogOutputs = numOutputs;

            % Loop over Fit
            for kf = 1:numel(fits)

                % Parse fit number
                currentFit = str2double(strrep(fits{kf},'fit',''));

                % Use DataRecord constructor template to set properties
                dataRecordTemplate.Date = currentDatetime;                                  % Date
                dataRecordTemplate.Environment = currentEnvironment;                        % Environment
                dataRecordTemplate.ExcitationFilters = double.empty(0, 6, numOutputs);      % ExcitationFilters
                dataRecordTemplate.ExcitationGain = 1;                                      % ExcitationGain
                dataRecordTemplate.ExcitationType = bose.cnc.meas.ExcitationType.External;  % ExcitationType
                dataRecordTemplate.Fit = currentFit;                                        % Fit
                dataRecordTemplate.Hardware = currentHardware;                              % Hardware
                dataRecordTemplate.Headphone = currentHeadphone;                            % Headphone
                dataRecordTemplate.InputMapping = currentInputMapping;                      % InputMapping
                dataRecordTemplate.Operator = currentOperator;                              % Operator
                dataRecordTemplate.OutputMapping = currentOutputMapping;                    % OutputMapping
                dataRecordTemplate.SignalParameters = currentSignalParameters;              % SignalParameters
                dataRecordTemplate.StepName = currentStepName;                              % StepName
                dataRecordTemplate.StepType = currentStepType;                              % StepType
                dataRecordTemplate.Subject = currentPerson;                                 % Subject
                dataRecordTemplate.ToolboxVersion = toolboxVersion;                         % ToolboxVersion

                % Get XsData
                currentXsData = data(squeeze(stepData.subject(ks).group(kg).fit(kf)));
                dataRecordTemplate.XsData = currentXsData;

                % Create DataRecord
                dataRecords = [dataRecords; DataRecord(dataRecordTemplate)];
                if ~quietFlag
                    logger.info(sprintf( ...
                        [ ...
                            'DataRecord [%d] created ===  StepName: %s  ' ...
                            '-|-  StepType: %s  -|-  Subject: %s  -|-  ' ...
                            'Group: %s  -|-  Fit: %s' ...
                        ], ...
                        drNumber, ...
                        currentStepName, ...
                        currentStepType, ...
                        subjects{ks}, ...
                        groups{kg}, ...
                        num2str(currentFit) ...
                    ));
                end
                drNumber = drNumber + 1;
            end % For every Fit
        end % For every Group/Side
    end % For every Subject
end % For every Step

end % function
