classdef Session < handle & bose.cnc.classes.StructInputHandle
    %SESSION Orchestration class for the Measurement framework.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.Session.start,
    %   bose.cnc.meas.Configuration, bose.cnc.meas.DataRecord,
    %   bose.cnc.meas.Environment, bose.cnc.meas.Hardware,
    %   bose.cnc.meas.Headphone, bose.cnc.meas.Mapping, bose.cnc.meas.Person,
    %   bose.cnc.metrics.StepAssociations, bose.cnc.meas.Step

    % $Id$

    %% PUBLIC PROPERTIES
    properties (Access = public, SetObservable)
        Configuration(:, 1) bose.cnc.meas.Configuration {bose.common.validators.mustBeEmptyOrScalar} = bose.cnc.meas.Configuration.empty % The "Measurement Configuration" that contains the Sequence of measurement Steps and the SignalParameters. (Default:bose.cnc.meas.Configuration.empty)
        CurrentFit(1, 1) uint8 {mustBePositive} = 1 % Keep the current fit index for when we form a DataRecord. (Default: 1)
        DataRecords(:, 1) bose.cnc.meas.DataRecord = bose.cnc.meas.DataRecord.empty % An array of previous measurements. (Default: bose.cnc.meas.DataRecord.empty)
        Environment(:, 1) bose.cnc.meas.Environment {bose.common.validators.mustBeEmptyOrScalar} = bose.cnc.meas.Environment.empty % The Environment (if any) where the measurements will take place.
        Hardware(:, 1) bose.cnc.meas.Hardware {bose.common.validators.mustBeEmptyOrScalar} = bose.cnc.meas.Hardware.empty % Configuration object for the measurement Hardware (i.e. MDAQ, LDAQ, etc.). (Default: bose.cnc.meas.Hardware.empty)
        Headphone(:, 1) bose.cnc.meas.Headphone = bose.cnc.meas.Headphone.empty % The "Device under Test" (if any) used during the measurement. (Default:bose.cnc.meas.Headphone.empty)
        InputMapping(:, 1) bose.cnc.meas.Mapping = bose.cnc.meas.Mapping.empty % Maps columns of the recorded signals to physical channels on the measurement Hardware. (Default: bose.cnc.meas.Mapping.empty)
        Operator(:, 1) bose.cnc.meas.Person {bose.common.validators.mustBeEmptyOrScalar} = bose.cnc.meas.Person.empty % The Operator of the measurement, e.g., "Dr. Bose". (Default: bose.cnc.meas.Person.empty)
        OutputMapping(:, 1) bose.cnc.meas.Mapping = bose.cnc.meas.Mapping.empty % Maps columns of the excitation signals to physical channels on the measurement Hardware. (Default: bose.cnc.meas.Mapping.empty)
        StepAssociations(:, 1) bose.cnc.metrics.StepAssociation = bose.cnc.metrics.StepAssociation.empty % Maps StepMetrics to StepNames or StepTypes. (Default: bose.cnc.metrics.StepAssociation.empty)
        Subject(:, 1) bose.cnc.meas.Person {bose.common.validators.mustBeEmptyOrScalar} = bose.cnc.meas.Person.empty % Any Subject (if any) involved in the measurement. (Default: bose.cnc.meas.Person.empty)
        SessionDataFolder(:,1) {bose.common.validators.isStringLike} = ''
    end % Public properties

    %% GET-PUBLIC SET-PRIVATE PROPERTIES
    properties (SetAccess = private, SetObservable)
        CurrentStepIndex(1, 1) uint8 {mustBePositive} = 1 % Keep the current measurement step number to form a corresponding DataRecord. (Default: 1)
        DeviceHandle(:, 1) {bose.common.validators.mustBeEmptyOrScalar} = [] % A connection handle to the measurement hardware. (Default: [])
    end % Get-Public, Set-Private properties

    %% DEPENDENT PROPERTIES
    properties (Dependent)
        CurrentStep(:, 1) bose.cnc.meas.Step % The current Step ready for measurement. (Default: bose.cnc.meas.Step.empty)
    end % Dependent properties

    %% NOTIFY EVENTS
    events
        SessionDeleted % Triggered when the delete method is run (explicitly or implicitly)
        PreMeasurement % Triggered immediately prior to data collection, after asserting readiness
        PostMeasurement % Triggered immediately after data collection, prior to file saves
        PostMeasurementSave % Triggered at the very end of the measurement process, after any file saves
    end % Events

    %% PRIVATE CONSTRUCTOR
    methods (Access = private)
        function obj = Session(varargin)
            %SESSION Private Constructor
            %
            %See also: bose.cnc.meas.Session,
            %   bose.cnc.meas.Session.start
            parser = bose.cnc.meas.Session.createParser;
            parser.parse(varargin{:});

            logger = bose.cnc.logging.getLogger;
            logger.debug('bose.cnc.meas.Session constructor');

            obj.Configuration = parser.Results.Configuration;
            obj.CurrentFit = parser.Results.CurrentFit;
            obj.Environment = parser.Results.Environment;
            obj.Headphone = parser.Results.Headphone;
            obj.Operator = parser.Results.Operator;
            obj.StepAssociations = parser.Results.StepAssociations;
            obj.Subject = parser.Results.Subject;
            obj.SessionDataFolder = '';%The session data folder will be created upon selecting a configuration.
            % Set Hardware last, as it will attempt to connect to Hardware
            try
               obj.InputMapping = parser.Results.InputMapping;
               obj.OutputMapping = parser.Results.OutputMapping;
               obj.Hardware = parser.Results.Hardware;
            catch ME
                logger.warning(sprintf('%s', ME.message));
                obj.Hardware = bose.cnc.meas.Hardware.empty;
                obj.InputMapping = bose.cnc.meas.Mapping.empty;
                obj.OutputMapping = bose.cnc.meas.Mapping.empty;
            end
        end % Constructor
    end % Private constructor

    %% PUBLIC METHODS
    methods (Access = public)
        function delete(obj)
            logger = bose.cnc.logging.getLogger;
            logger.debug('bose.cnc.meas.Session.delete function');
            notify(obj, 'SessionDeleted');
        end % Deconstructor

        function results = isDeviceConnected(obj)
            %ISDEVICECONNECTED Returns true/false if the Meas. device is connected.
            results = ~isempty(obj.DeviceHandle) && ...
            bose.cnc.validators.isDeviceHandle(obj.DeviceHandle) && ...
                obj.DeviceHandle.IsConnected;
        end % isDeviceConnected

        function [result,reason] = isValid(obj)
            %ISVALID Returns true if the Session has all valid properties.
            %
            %See also: bose.cnc.meas.Session

            %HACK(ALEX): DataRecords aren't validated, but that might be an expensive recursive call if we have a lot of DataRecords.
            reason = '';
            %For Environment, Subject, and Headphone, empty is a valid state.
            if(~obj.Environment.isValid)
                reason = strcat(reason,'Invalid Environment, ');
            end
            if(~obj.Subject.isValid)
                reason = strcat(reason,'Invalid Subject, ');
            end
            if(any(~[obj.Headphone.isValid]))
                reason = strcat(reason,'Invalid Headphone, ');
            end
            tfInputMapping = all(obj.InputMapping.isValid) && all([obj.InputMapping.IsInput]);
            if(~tfInputMapping)
                reason = strcat(reason,'Invalid Input mapping, ');
            end
            tfOutputMapping = all(obj.OutputMapping.isValid) && all([obj.OutputMapping.IsOutput]);
            if(~tfOutputMapping)
                reason = strcat(reason,'Invalid output mapping, ');
            end
            if(~obj.Configuration.isValid)
                reason = strcat(reason,'Invalid Configuration, ');
            end
            if(~obj.Hardware.isValid)
                reason = strcat(reason,'Invalid Hardware selection, ');
            end
            if(~obj.Operator.isValid)
                reason = strcat(reason,'Invalid Operator Selection, ');
            end
            result = obj.Configuration.isValid && ...
                     obj.Hardware.isValid && ...
                     tfInputMapping && ...
                     obj.Operator.isValid && ...
                     tfOutputMapping && ...
                     obj.Environment.isValid...
                     && obj.Subject.isValid...
                     && all(obj.Headphone.isValid);
        end % isValid
                    
        [selectedInputMappings, selectedOutputMappings] = assertReadiness(obj)
        clearChannelMapping(obj)
        deleteDataRecords(obj, dataRecordIndex, deleteFiles)
        isDone = incrementStep(obj)
        measuredDut = measure(obj, saveDataRecord)
        [linearityError, noiseError] = measureLn(obj, varargin)
        listeners = registerListeners(obj)
        resetSession(obj)
        selectCurrentStep(obj, newStep)
        toFile(obj, filePath)
        validateMapping(obj)
        [folderPathOut] = createSessionDataFolder(obj);
        % Hardware methods
        configureHardware(obj)
        configureHardwareCalibrationMode(obj)
        configureHardwareInputMapping(obj)
        configureHardwareOutputMapping(obj)
        configureHardwareSignals(obj)
        connectAndConfigure(obj)
        connectHardware(obj)
        disconnectHardware(obj)
        [dataRecordIndexes] = findLatestNonRepeatedDataRecords(obj)
    end % Public methods

    %% GET/SET METHODS
    methods
        function val = get.CurrentStep(obj)
            % Default to empty
            if isempty(obj.Configuration) || isempty(obj.Configuration.Sequence)
                val = bose.cnc.meas.Step.empty;
            else
                val = obj.Configuration.Sequence(obj.CurrentStepIndex);
            end

        end % get.CurrentStep

        function set.Configuration(obj, configuration)
            % Only set valid configurations, and if the device is connected, configure it.
            % If the configuration is empty, set the property and return early.
            if isempty(configuration)
                obj.Configuration = configuration;
                % Clear any Mappings that no longer match the Configuration
                obj.validateMapping;
                return
            end

            % Otherwise, only set the configuration if it is valid, else error.
            [tfConfiguration, reasonsConfiguration] = configuration.isValid;
            if tfConfiguration
                if(~isempty(obj.SessionDataFolder) && ~isempty(obj.Configuration) && ...
                   ~strcmpi(obj.Configuration.Name,configuration.Name))
                    %If the configuration name is different make a new
                    %session data folder
                    obj.SessionDataFolder = '';
                end
                obj.Configuration = configuration; 
                obj.CurrentStepIndex = 1;
            else
                %HACK(ALEX): Is this strjoin correct?
                error( ...
                    'bose:cnc:meas:Session:InvalidConfiguration', ...
                    [ ...
                        'Session.Configuration cannot be set to an ' ...
                        'invalid configuration: %s' ...
                    ], ...
                    strjoin(reasonsConfiguration{1}, ' ') ...
                );
            end

            % Trim any Mappings that no longer match the InputSignals in the Configuration
            obj.validateMapping;

            % Set the CurrentStepIndex to 1.
            % If the device is connected, selectCurrentStep configures it.
            obj.selectCurrentStep(1);
        end % set.Configuration

        function set.Hardware(obj, hardware)
            % Only set valid hardware configurations, and attempt to connect to the device and configure it.

            %TODO(ALEX): This method needs to be cleaned up to support rme type and to better organize connect/configure.

            oldValue = obj.Hardware;

            if ~isempty(oldValue)
                oldDeviceName = oldValue.DeviceName;
            else
                oldDeviceName = "";
            end

            % If the hardware configuration is empty, set the property and
            %   return early.
            if isempty(hardware)
                % Set obj.DeviceHandle and obj.Hardware to empty
                obj.disconnectHardware;
                obj.Hardware = bose.cnc.meas.Hardware.empty;

                % Clear any Mappings that no longer match the Hardware
                obj.validateMapping;
                return
            end

            % Otherwise, only set the hardware configuration if it is valid, else error.
            if hardware.isValid
                obj.Hardware = hardware;
            else
                %TODO(ALEX): isValid isn't specific enough, it just returns true/false.
                error('bose:cnc:meas:Session:InvalidHardware', ...
                ['Session.Hardware cannot be set to an invalid ' ...
                    'configuration.']);
            end

            % Attempt to connect to the device if not already connected.
            %TODO(ALEX): If we are connected, we should check to see if we are connected to the correct device.
            if ~obj.isDeviceConnected || ~strcmpi(oldDeviceName, hardware.DeviceName)
                try
                    obj.disconnectHardware;
                    obj.connectHardware;
                catch ME
                    % If we fail, revert to the old Hardware configuration and rethrow
                    obj.Hardware = oldValue;
                    rethrow(ME);
                end
            end

            % Before we configure outputs/signals, trim any unmatched Mappings
            obj.validateMapping;

            % Now that we are connected, attempt to configure the Hardware.
            try
                obj.configureHardware;
            catch ME
                % If we fail, revert to the old Hardware configuration and rethrow
                obj.Hardware = oldValue;

                if ~isempty(oldValue)
                    obj.configureHardware;
                end

                rethrow(ME);
            end
        end % set.Hardware

        function set.InputMapping(obj, inputMapping)
            % Only set a valid mapping, and if the device is connected, configure it.

            % Only set the mapping if it is valid, else error.
            if ~all(inputMapping.isValid)
                error( ...
                    'bose:cnc:meas:Session:InvalidMapping', ...
                    'The input mapping cannot be set with blank/empty channels.' ...
                );
            end

            oldMapping = obj.InputMapping;
            obj.InputMapping = inputMapping;

            % Configure the device if it is connected and if any of the mappings are different, although order is ignored
            if obj.isDeviceConnected && (~all(ismember(oldMapping, inputMapping)) || ~all(ismember(inputMapping, oldMapping)))
                try
                    obj.configureHardwareInputMapping;
                catch ME
                    obj.InputMapping = oldMapping;
                    rethrow(ME);
                end
            end
        end % set.InputMapping

        function set.OutputMapping(obj, outputMapping)
            % Only set a valid mapping, and if the device is connected, configure it.

            % Only set the mapping if it is valid, else error.
            if ~all(outputMapping.isValid)
                error( ...
                    'bose:cnc:meas:Session:InvalidMapping', ...
                    'The output mapping cannot be set with blank/empty channels.' ...
                );
            end

            oldMapping = obj.OutputMapping;
            obj.OutputMapping = outputMapping;

            % Configure the device if it is connected and if any of the mappings are different, although order is ignored
            if obj.isDeviceConnected && (~all(ismember(oldMapping, outputMapping)) || ~all(ismember(outputMapping, oldMapping)))
                try
                    obj.configureHardwareOutputMapping;
                catch ME
                    obj.OutputMapping = oldMapping;
                    rethrow(ME);
                end
            end
        end % set.OutputMapping

        function set.SessionDataFolder(obj,newFolder)
            obj.SessionDataFolder = newFolder;
            logger = bose.cnc.logging.getLogger;
            if(~isempty(strtrim(newFolder)))
                logger.info(sprintf('Working Path set to %s',newFolder));
            end
        end
       
    end % Get/Set methods

    %% PUBLIC STATIC METHODS
    methods (Access = public, Static)
        function obj = start(varargin)
            %START Starts a Session; Returns the singleton Session.
            %
            %   Session.start can also accept inputs as a struct with
            %   fieldnames that match the input argument names. The
            %   bose.cnc.meas.Session.template method returns a struct
            %   with the correct fieldnames.
            %
            %   https://www.mathworks.com/matlabcentral/fileexchange/24911-design-pattern-singleton-creational
            %
            %   MATLAB OOP doesn't have the notion of static properties.
            %   Properties become available once the constructor of the class
            %   is invoked. In the case of the Singleton Pattern, it is then
            %   undesirable to use the constructor as a global point of access
            %   since it creates a new instance before you can check if an
            %   instance already exists. The solution is to use a persistent
            %   variable within a unique static method start() which calls
            %   the constructor to create a unique 'singleton' instance. The
            %   persistent variable can be interrogated prior to object
            %   creation and after object creation to check if the singleton
            %   object exists.
            %
            %Parameter Arguments:
            %   Configuration (bose.cnc.meas.Configuration): The "Measurement Configuration" that contains the Sequence of measurement Steps and the SignalParameters. (Default: bose.cnc.meas.Configuration.empty)
            %   CurrentFit (uint8): Keep the current fit index for when we form a DataRecord. (Default: 1)
            %   Environment (bose.cnc.meas.Environment): The Environment (if any) where the measurements will take place.
            %   Hardware (bose.cnc.meas.Hardware): Configuration object for the measurement Hardware (i.e. MDAQ, LDAQ, etc.). (Default: bose.cnc.meas.Hardware.empty)
            %   Headphone (bose.cnc.meas.Headphone): The "Device under Test" (if any) used during the measurement. (Default: bose.cnc.meas.Headphone.empty)
            %   InputMapping (string): Maps columns of the recorded signals to physical channels on the measurement Hardware. (Default: bose.cnc.meas.Mapping.empty)
            %   Operator (string): The Operator of the measurement, e.g., "Dr. Bose". (Default: bose.cnc.meas.Person.empty)
            %   OutputMapping (string): Maps columns of the excitation signals to physical channels on the measurement Hardware. (Default: bose.cnc.meas.Mapping.empty)
            %   StepAssociations (bose.cnc.metrics.StepAssociation): Maps StepMetrics to StepNames or StepTypes. (Default: bose.cnc.metrics.StepAssociation.empty)
            %   Subject (bose.cnc.meas.Person): Any Subject (if any) involved in the measurement. (Default: bose.cnc.meas.Person.empty)
            %
            %See also: bose.cnc.meas.Session,
            %   bose.cnc.meas.Session.template

            persistent cncMeasureSession % Returns empty if the variable hasn't been set before.

            if isempty(cncMeasureSession) || ~isvalid(cncMeasureSession)
                obj = bose.cnc.meas.Session(varargin{:});
                cncMeasureSession = obj; % Set the persistent variable
            else
                obj = cncMeasureSession;

                parser = bose.cnc.meas.Session.createParser;
                parser.parse(varargin{:});

                % If we are using all defaults, don't change any parameters
                if numel(parser.Parameters) ~= numel(parser.UsingDefaults)
                    obj.Configuration = parser.Results.Configuration;
                    obj.CurrentFit = parser.Results.CurrentFit;
                    obj.Environment = parser.Results.Environment;
                    obj.Headphone = parser.Results.Headphone;
                    obj.InputMapping = parser.Results.InputMapping;
                    obj.Operator = parser.Results.Operator;
                    obj.OutputMapping = parser.Results.OutputMapping;
                    obj.StepAssociations = parser.Results.StepAssociations;
                    obj.Subject = parser.Results.Subject;      
                    obj.SessionDataFolder = parser.Results.SessionDataFolder;
                    % Set Hardware last, as it will attempt to connect to Hardware
                    try
                        obj.Hardware = parser.Results.Hardware;
                    catch ME
                        logger = bose.cnc.logging.getLogger;
                        logger.warning(sprintf('%s', ME.message));
                        obj.Hardware = bose.cnc.meas.Hardware.empty;
                    end
                end
            end
        end % start

        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's static constructor.
            %
            %See also: bose.cnc.meas.Session.start
            parser = bose.cnc.meas.Session.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end % template
        obj = fromFile(filePath)
    end % Public, Static methods

    %% PRIVATE STATIC METHODS
    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('Configuration', bose.cnc.meas.Configuration.empty);
            parser.addParameter('CurrentFit', 1);
            parser.addParameter('Environment', bose.cnc.meas.Environment.empty);
            parser.addParameter('Hardware', bose.cnc.meas.Hardware.empty);
            parser.addParameter('Headphone', bose.cnc.meas.Headphone.empty);
            parser.addParameter('InputMapping', bose.cnc.meas.Mapping.empty);
            parser.addParameter('Operator', bose.cnc.meas.Person.empty);
            parser.addParameter('OutputMapping', bose.cnc.meas.Mapping.empty);
            parser.addParameter('StepAssociations', bose.cnc.metrics.StepAssociation.empty);
            parser.addParameter('Subject', bose.cnc.meas.Person.empty);
            parser.addParameter('SessionDataFolder','');
        end % createParser
    end % Static, Private, Hidden methods
end % classdef
