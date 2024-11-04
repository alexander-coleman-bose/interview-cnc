classdef Configuration < bose.cnc.classes.ConvertibleToStruct & bose.cnc.classes.StructInput
    %CONFIGURATION Object that defines a CNC Measurement Configurations.
    %
    %   Configuration represents a collection of measurement Configuration
    %   parameters, including:
    %       - The Sequence of measurement Steps
    %       - Which Steps are repeated per Fit (the FitLoop)
    %       - The number of Fits for that Configuration
    %       - The Date when the Configuration was created
    %       - The Designer of the Configuration
    %       - The Name of the Configuration
    %
    %See also: bose.cnc.meas, bose.cnc.meas.Configuration.Configuration, datetime,
    %   bose.cnc.meas.Person, bose.cnc.meas.Step, bose.cnc.meas.Session

    % Alex Coleman
    % $Id$

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        DateCreated(1, 1) datetime = datetime(0, 'ConvertFrom', 'epochtime') % The Date when the measurement Configuration was created. (Default: datetime(0, 'ConvertFrom', 'epochtime'))
        Designer(1, 1) bose.cnc.meas.Person = bose.cnc.meas.Person % The Designer of the measurement Configuration. (Default: bose.cnc.meas.Person)
        Name(1, 1) string = string % The name of the Configuration. (Default: "")
        NumFits(1, 1) uint8 {mustBePositive} = 1 % The number of Fits in the measurement Configuration. (Default: 1)
        Sequence(:, 1) bose.cnc.meas.Step = bose.cnc.meas.Step.empty % The Sequence of measurement Steps. (Default: bose.cnc.meas.Step.empty)
    end % Public properties

    %% DEPENDENT PROPERTIES
    properties (Dependent, SetAccess = protected)
        FileName(1, 1) string % Default JSON file name for the Configuration "Configuration-<Name>.json".
        InputSignals(:, 1) bose.cnc.meas.Signal % The unique set of input Signal(s) from all Sequence Steps. Dependent on Sequence.
        LoopOverFits(:, 1) logical % One logical per Step of whether each Step in the Sequence is repeated per-Fit. Dependent on Sequence.
        MatFileName(1, 1) string % Default MAT file name for the Configuration "Configuration-<Name>.mat".
        OutputSignals(:, 1) bose.cnc.meas.Signal % The unique set of output Signal(s) from all Sequence Steps. Dependent on Sequence.
        SaveTimeData(:, 1) logical % One logical per Step of whether to save the time data for each Step. Dependent on Sequence.
    end % Dependent properties

    %% CONSTANT PROPERTIES
    properties (Constant, Access = protected)
        StructFieldsBase64 = string.empty % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64.
        StructFieldsBase64OrNull = string.empty % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64 or set to "NULL" if empty.
        StructFieldsDatetime = "DateCreated" % These fields will be converted to strings using bose.cnc.datetimeStorageFormat.
        StructFieldsDependent = ["FileName", "InputSignals", "LoopOverFits", "MatFileName", "OutputSignals", "SaveTimeData"] % These fields will be removed from the struct.
        StructFieldsString = string.empty % These fields will be converted to strings.
        StructFieldsStruct = ["Designer", "Sequence"] % These fields will be converted to structs.
    end % Constant, Protected properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = Configuration(varargin)
            %CONFIGURATION Returns a measurement configuration object.
            %
            %   This constructor can also accept inputs as a struct with fieldnames that
            %   match the input argument names. The bose.cnc.meas.Configuration.template
            %   method returns a struct with the correct fieldnames.
            %
            %Parameter Arguments:
            %   DateCreated (datetime): The Date when the measurement Configuration was
            %       created. (Default: datetime(0, 'ConvertFrom', 'epochtime'))
            %   Designer (bose.cnc.meas.Person): The Designer of the measurement
            %       Configuration. (Default: bose.cnc.meas.Person)
            %   LoopOverFits (logical): One logical per Step of whether each Step in the
            %       Sequence is repeated per-Fit. (Default: logical.empty)
            %   Name (string): The name of the Configuration. (Default: "")
            %   NumFits (uint8): The number of Fits in the measurement Configuration.
            %       (Default: 1)
            %   Sequence (bose.cnc.meas.Step): The Sequence of measurement Steps. (Default:
            %       bose.cnc.meas.Step.empty)
            %
            %See also: bose.cnc.meas.Configuration, bose.cnc.meas.Configuration.template,
            %   bose.cnc.meas.SignalParameters, datetime

            % If we have a struct array of arguments as the input, recurse on this function
            if nargin == 1 && isstruct(varargin{1}) && numel(varargin{1}) > 1
                obj = arrayfun(@bose.cnc.meas.Configuration, varargin{1});
                return
            end

            parser = bose.cnc.meas.Configuration.createParser;
            parser.parse(varargin{:});

            % Attempt to convert to datetime from string using datetimeStorageFormat
            dateCreated = parser.Results.DateCreated;
            if isstring(dateCreated)
                try
                    dateCreated = datetime(dateCreated, 'InputFormat', bose.cnc.datetimeStorageFormat);
                catch ME
                    if strcmpi(ME.identifier, 'MATLAB:datetime:ParseErrSuggestLocale')
                        dateCreated = datetime(dateCreated);
                    else
                        rethrow(ME)
                    end
                end
            else
                dateCreated = datetime(dateCreated);
            end
            obj.DateCreated = dateCreated;
            obj.Designer = parser.Results.Designer;
            obj.Name = parser.Results.Name;
            obj.NumFits = parser.Results.NumFits;
            obj.Sequence = parser.Results.Sequence;
        end % Constructor
    end % Constructor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        [results, reasons] = isValid(obj)
        varargout = sort(obj, varargin)
        [objKeys, configurationVersions] = saveToDatabase(obj)
        fileNames = toFile(obj, targetPath, makePretty)
        versionNumber = fetchVersion(obj)
    end % Public methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PROTECTED METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = protected)
        fileNames = toJsonFile(obj, targetPath, makePretty)
        fileNames = toMatFile(obj, targetPath)
    end % Protected methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GET/SET METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function val = get.FileName(obj)
            val = sprintf( ...
                "Configuration-%s.json", ...
                matlab.lang.makeValidName(obj.Name, 'ReplacementStyle', 'delete') ...
            );
        end % get.FileName

        function val = get.InputSignals(obj)
            allInputSignals = vertcat(obj.Sequence.InputSignals);
            val = unique(allInputSignals);
        end % get.InputSignals

        function val = get.LoopOverFits(obj)
            val = reshape([obj.Sequence.LoopOverFits], size(obj.Sequence));
        end % get.LoopOverFits

        function val = get.MatFileName(obj)
            val = sprintf( ...
                "Configuration-%s.mat", ...
                matlab.lang.makeValidName(obj.Name, 'ReplacementStyle', 'delete') ...
            );
        end % get.MatFileName

        function val = get.OutputSignals(obj)
            allOutputSignals = vertcat(obj.Sequence.OutputSignals);
            val = unique(allOutputSignals);
        end % get.OutputSignals

        function val = get.SaveTimeData(obj)
            val = reshape([obj.Sequence.SaveTimeData], size(obj.Sequence));
        end % get.SaveTimeData

        function obj = set.DateCreated(obj, val)
            % Attempt to convert from string using datetimeStorageFormat
            if isstring(val)
                try
                    val = datetime(val, 'InputFormat', bose.cnc.datetimeStorageFormat);
                catch ME
                    if strcmpi(ME.identifier, 'MATLAB:datetime:ParseErrSuggestLocale')
                        val = datetime(val);
                    else
                        rethrow(ME)
                    end
                end
            else
                val = datetime(val);
            end

            % Round to the nearest millisecond
            dateStr = string(val, bose.cnc.datetimeStorageFormat);
            obj.DateCreated = datetime(dateStr, 'InputFormat', bose.cnc.datetimeStorageFormat);

            % Set the display format for the datetime
            obj.DateCreated.Format = bose.cnc.datetimeDisplayFormat;
        end % set.DateCreated
    end % Get/Set methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% STATIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
        obj = fromFile(targetPath, pathSpec)
        obj = loadFromDatabase(objKeys)
        output = searchDatabase(varargin)

        function templateStruct = template()
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Configuration.Configuration
            parser = bose.cnc.meas.Configuration.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end
    end % Public, Static methods

    %% PRIVATE STATIC METHODS
    methods (Static, Access = protected)
        obj = fromJsonFile(targetPath, pathSpec)
        obj = fromMatFile(targetPath, pathSpec)
    end

    methods (Static, Access = protected, Hidden)
        function parser = createParser()
            parser = inputParser();
            parser.addParameter('DateCreated', datetime(0, 'ConvertFrom', 'epochtime'));
            parser.addParameter('Designer', bose.cnc.meas.Person);
            parser.addParameter('Name', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('NumFits', 1, @mustBeNonnegative);
            parser.addParameter('Sequence', bose.cnc.meas.Step.empty);
        end % createParser
    end % Static, Private, Hidden methods
end % Classdef
