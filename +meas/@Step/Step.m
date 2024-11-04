classdef Step < bose.cnc.classes.ConvertibleToStruct & bose.cnc.classes.StructInput
    %STEP Defines a measurement Step with a Type and Signals.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.Step.Step, bose.cnc.meas.Signal,
    %   bose.cnc.meas.SignalParameters, bose.cnc.meas.StepType

    % Alex Coleman
    % $Id$

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        ExcitationFilters = double.empty(0,6,0) % SOS filter(s) to generate the Excitation signal(s). (Default: double.empty(0,6,0))
        ExcitationGain(1,1) double {mustBeReal, mustBeFinite, mustBeNonNan, mustBePositive} = 1 % Linear gain to be applied to the Excitation signal. (Default: 1)
        ExcitationType(1,1) bose.cnc.meas.ExcitationType = bose.cnc.meas.ExcitationType.None % Type of Excitation signal generation to be used. (Default: bose.cnc.meas.Excitation.None)
        InputSignals(:,1) bose.cnc.meas.Signal = bose.cnc.meas.Signal.empty % The input Signal(s) used in the measurement. (Default: bose.cnc.meas.Signal.empty)
        LoopOverFits(1,1) logical = false % One logical per Step of whether each Step in the Sequence is repeated per-Fit. (Default: false)
        Name(1,1) string = string % The Name of the Step. (Default: "")
        OutputSignals(:,1) bose.cnc.meas.Signal = bose.cnc.meas.Signal.empty % The output Signal(s) used in the measurement. (Default: bose.cnc.meas.Signal.empty)
        SaveTimeData(1,1) logical = false % If true, save the time data for this measurement. (Default: false)
        SignalParameters(1,1) bose.cnc.meas.SignalParameters = bose.cnc.meas.SignalParameters % The SignalParameters of the measurement signals. (Default: bose.cnc.meas.SignalParameters)
        Type(1,1) bose.cnc.meas.StepType = bose.cnc.meas.StepType.Generic % The StepType of the measurement. (Default: bose.cnc.meas.StepType.Generic)
    end % Public properties

    properties (Constant, Access = protected)
        StructFieldsBase64 = "ExcitationGain" % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64.
        StructFieldsBase64OrNull = "ExcitationFilters" % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64 or set to "NULL" if empty.
        StructFieldsDatetime = string.empty % These fields will be converted to strings using bose.cnc.datetimeStorageFormat.
        StructFieldsDependent = "DisplayName" % These fields will be removed from the struct.
        StructFieldsString = ["ExcitationType", "Type"] % These fields will be converted to strings.
        StructFieldsStruct = ["InputSignals", "OutputSignals", "SignalParameters"] % These fields will be converted to structs.
    end % Constant, Protected properties

    properties (Dependent)
        DisplayName(1,1) string % Default formatted display name for Steps.
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = Step(varargin)
            %STEP Returns a bose.cnc.meas.Step.
            %
            %   This constructor can also accept inputs as a struct with fieldnames that
            %   match the input argument names. The bose.cnc.meas.Step.template method
            %   returns a struct with the correct fieldnames.
            %
            %Parameter Arguments:
            %   ExcitationFilters (double): SOS filter(s) to generate the Excitation signal(s). (Default: double.empty(0,6,0))
            %   ExcitationGain (double): Linear gain to be applied to the Excitation signal. (Default: 1)
            %   ExcitationType (bose.cnc.meas.ExcitationType): Type of Excitation signal generation to be used. (Default: bose.cnc.meas.Excitation.None)
            %   InputSignals (bose.cnc.meas.Signal): The input Signal(s) used in the measurement. (Default: bose.cnc.meas.Signal.empty)
            %   LoopOverFits (logical): One logical per Step of whether each Step in the Sequence is repeated per-Fit. (Default: false)
            %   Name (string): The Name of the Step. (Default: "")
            %   OutputSignals (bose.cnc.meas.Signal): The output Signal(s) used in the measurement. (Default: bose.cnc.meas.Signal.empty)
            %   SaveTimeData (logical): If true, save the time data for this measurement. (Default: false)
            %   SignalParameters (bose.cnc.meas.SignalParameters): The SignalParameters of the measurement signals. (Default: bose.cnc.meas.SignalParameters)
            %   Type (bose.cnc.meas.StepType): The StepType of the measurement. (Default: bose.cnc.meas.StepType)
            %
            %See also: bose.cnc.meas.Step,
            %   bose.cnc.meas.Step.template, bose.cnc.meas.ExcitationType,
            %   bose.cnc.meas.Signal, bose.cnc.meas.SignalParameters, bose.cnc.meas.StepType

            idHeader = 'bose:cnc:meas:Step:';

            % If we have a struct array of arguments as the input, recurse on this function
            if nargin == 1 && isstruct(varargin{1}) && numel(varargin{1}) > 1
                obj = arrayfun(@bose.cnc.meas.Step, varargin{1});
                return
            end

            parser = bose.cnc.meas.Step.createParser;
            parser.parse(varargin{:});

            % Regular inputs
            obj.ExcitationType = parser.Results.ExcitationType;
            obj.LoopOverFits = parser.Results.LoopOverFits;
            obj.Name = parser.Results.Name;
            obj.SaveTimeData = parser.Results.SaveTimeData;
            obj.SignalParameters = parser.Results.SignalParameters;
            obj.Type = parser.Results.Type;

            % Only set if the signals are non-empty, to avoid type validation for double.empty
            if ~isempty(parser.Results.InputSignals)
                obj.InputSignals = parser.Results.InputSignals;
            end
            if ~isempty(parser.Results.OutputSignals)
                obj.OutputSignals = parser.Results.OutputSignals;
            end

            % Decode base64 ExcitationFilters
            if bose.common.validators.isStringLike(parser.Results.ExcitationFilters)
                tempVal = string(parser.Results.ExcitationFilters);
                try
                    if strcmpi(tempVal, 'NULL')
                        obj.ExcitationFilters = double.empty(0, 6, numel(obj.OutputSignals));
                    else
                        obj.ExcitationFilters = bose.cnc.math.unwrapSos( ...
                            bose.cnc.datastore.decodeBase64(tempVal, 'double'), ...
                            numel(obj.OutputSignals) ...
                        );
                    end
                catch ME
                    error( ...
                        [idHeader 'InvalidExcitationFilters'], ...
                        [ ...
                            'If Step.ExcitationFilters is a string, it must be a ' ...
                            'valid base64 encoded string of a numeric ' ...
                            'value or "NULL".' ...
                        ] ...
                    );
                end
            else
                obj.ExcitationFilters = parser.Results.ExcitationFilters;
            end

            % Decode base64 ExcitationGain
            if bose.common.validators.isStringLike(parser.Results.ExcitationGain)
                tempVal = string(parser.Results.ExcitationGain);
                try
                    obj.ExcitationGain = bose.cnc.datastore.decodeBase64(tempVal);
                catch ME
                    error( ...
                        [idHeader 'InvalidExcitationGain'], ...
                        [ ...
                            'If Step.ExcitationGain is a string, it must be a ' ...
                            'valid base64 encoded string of a numeric ' ...
                            'value.' ...
                        ] ...
                    );
                end
            else
                obj.ExcitationGain = parser.Results.ExcitationGain;
            end
        end % Constructor
    end % Constructor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        excitationSignals = getExcitationSignals(obj, signalMask)
        [results, reasons] = isValid(obj)
        objKeys = saveToDatabase(obj, configurationKey)
        cellRows = toCellRow(obj)
    end % Public methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GET/SET METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function displayName = get.DisplayName(obj)
            stepFlags = '';
            if obj.SaveTimeData
                stepFlags = [stepFlags 'T'];
            end
            if obj.LoopOverFits
                stepFlags = [stepFlags 'F'];
            end
            if isempty(stepFlags)
                displayName = obj.Name;
            else
                displayName = sprintf("%s [%s]", obj.Name, stepFlags);
            end
        end % get.DisplayName

        function obj = set.ExcitationFilters(obj, excitationFiltersRaw)
            obj.ExcitationFilters = bose.cnc.math.importSos(excitationFiltersRaw);
        end
    end % Get/Set methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% STATIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
        obj = loadFromDatabase(objKeys)

        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Step.Step
            parser = bose.cnc.meas.Step.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end
    end % Public, Static methods

    %% PRIVATE STATIC METHODS
    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser();
            parser.addParameter('ExcitationFilters', double.empty(0,6,1), @(x) bose.common.validators.isStringLike(x) || isnumeric(x));
            parser.addParameter('ExcitationGain', 1, @(x) bose.common.validators.isStringLike(x) || (isnumeric(x) && x > 0));
            parser.addParameter('ExcitationType', bose.cnc.meas.ExcitationType.None);
            parser.addParameter('InputSignals', bose.cnc.meas.Signal.empty);
            parser.addParameter('LoopOverFits', false);
            parser.addParameter('Name', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('OutputSignals', bose.cnc.meas.Signal.empty);
            parser.addParameter('SaveTimeData', false);
            parser.addParameter('SignalParameters', bose.cnc.meas.SignalParameters);
            parser.addParameter('Type', bose.cnc.meas.StepType.Generic);
        end % createParser
    end % Static, Private, Hidden methods
end % Classdef
