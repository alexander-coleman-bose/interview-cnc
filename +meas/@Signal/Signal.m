classdef Signal < bose.cnc.classes.ConvertibleToStruct & bose.cnc.classes.StructInput
    %SIGNAL Defines a Signal to be used in a measurement.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.Signal.Signal, bose.cnc.meas.Side,
    %   bose.cnc.meas.SignalType

    % Alex Coleman
    % $Id$

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = public)
        Name(1,1) string = string % The full name of the signal. (Default: "")
        Scale(1,1) double {mustBePositive} = 1 % The linear scaling factor applied to the Signal during the measurement. (Default: 1)
        Side(1,1) bose.cnc.meas.Side = bose.cnc.meas.Side.None % The Signal's side. (Default: bose.cnc.meas.Side.None)
        Type(1,1) bose.cnc.meas.SignalType = bose.cnc.meas.SignalType.GenericMic % The Signal's type. (Default: bose.cnc.meas.SignalType.GenericMic)
        Units(1,1) string = "volt" % The units of the Signal. (Default: "volt")
    end % Public properties

    properties (Dependent)
        DisplayName(1,1) string % A formatted string describing the object.
        ScaleQuant(1,1) quant % The Scale of the Signal in the form of a quant object.
    end % Dependent properties

    properties (Constant, Access = protected)
        StructFieldsBase64 = "Scale" % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64.
        StructFieldsBase64OrNull = string.empty % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64 or set to "NULL" if empty.
        StructFieldsDatetime = string.empty % These fields will be converted to strings using bose.cnc.datetimeStorageFormat.
        StructFieldsDependent = ["DisplayName", "ScaleQuant"] % These fields will be removed from the struct.
        StructFieldsString = ["Side", "Type"] % These fields will be converted to strings.
        StructFieldsStruct = string.empty % These fields will be converted to structs.
    end % Constant, Protected properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = Signal(varargin)
            %SIGNAL Returns a bose.cnc.meas.Signal.
            %
            %   This constructor can also accept inputs as a struct with fieldnames that
            %   match the input argument names. The bose.cnc.meas.Signal.template method
            %   returns a struct with the correct fieldnames.
            %
            %Parameter Arguments:
            %   Name (string-like): The full name of the signal. (Default: "")
            %   Scale (double): The linear scaling factor applied to the Signal during the measurement. (Default: 1)
            %   Side (bose.cnc.meas.Side): The Signal's side. (Default: bose.cnc.meas.Side.None)
            %   Type (bose.cnc.meas.SignalType): The Signal's type. (Default: bose.cnc.meas.SignalType.GenericMic)
            %   Units (string-like): The units of the Signal. (Default: "volt")
            %
            %See also: bose.cnc.meas.Signal, bose.cnc.meas.Signal.template,
            %   bose.cnc.meas.Signal

            idHeader = 'bose:cnc:meas:Signal:';

            % If we have a struct array of arguments as the input, recurse on this function
            if nargin == 1 && isstruct(varargin{1}) && numel(varargin{1}) > 1
                obj = arrayfun(@bose.cnc.meas.Signal, varargin{1});
                return
            end

            parser = bose.cnc.meas.Signal.createParser;
            parser.parse(varargin{:});

            % Regular inputs
            obj.Name = parser.Results.Name;
            obj.Side = parser.Results.Side;
            obj.Type = parser.Results.Type;
            obj.Units = parser.Results.Units;

            % Decode base64 inputs
            if bose.common.validators.isStringLike(parser.Results.Scale)
                tempVal = string(parser.Results.Scale);
                try
                    obj.Scale = bose.cnc.datastore.decodeBase64(tempVal);
                catch ME
                    error( ...
                        [idHeader 'InvalidScale'], ...
                        [ ...
                            'If Signal.Scale is a string, it must be a ' ...
                            'valid base64 encoded string of a numeric ' ...
                            'value.' ...
                        ] ...
                    );
                end
            else
                obj.Scale = parser.Results.Scale;
            end
        end % Constructor
    end % Constructor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GET/SET METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function val = get.DisplayName(obj)
            val = sprintf( ...
                "%s (%s, %.2g %s/volt)", ...
                obj.Name, ...
                obj.Side, ...
                obj.Scale, ...
                obj.Units ...
            );
        end % get.DisplayName

        function val = get.ScaleQuant(obj)
            % Convert to char and run through umks (system toolbox) to standardize names
            umksUnits = umks(char(obj.Units));
            val = quant( ...
                obj.Scale, ...
                'linear', ...
                umksUnits, ...
                'volt' ...
            );
        end % get.ScaleQuant

        function obj = set.Side(obj, side)
            idHeader = 'bose:cnc:meas:Signal:';
            % Disallow "Both" side
            if side == bose.cnc.meas.Side.Both
                error( ...
                    [idHeader 'InvalidSide'], ...
                    '"Both" cannot be chosen as a valid Side for Signals.' ...
                );
            end

            obj.Side = side;
        end % set.Side
    end % Get/Set methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        results = eq(obj, comparisonObj)
        [results, reasons] = isValid(obj)
        results = ne(obj, comparisonObj)
        objKeys = saveToDatabase(obj)
        varargout = sort(obj, varargin)
        cellRows = toCellRow(obj)

        function result = isInput(obj)
            %ISINPUT Returns true if the Signal is an Input.
            %
            %See also: bose.cnc.meas.Signal, bose.cnc.meas.Signal.isOutput
            result = false(size(obj));

            for indObj = 1:numel(obj)
                result(indObj) = obj(indObj).Type.isInput;
            end
        end % isInput

        function result = isOutput(obj)
            %ISOUTPUT Returns true if the Signal is an Output.
            %
            %See also: bose.cnc.meas.Signal, bose.cnc.meas.Signal.isInput
            result = false(size(obj));

            for indObj = 1:numel(obj)
                result(indObj) = obj(indObj).Type.isOutput;
            end
        end % isOutput
    end % Public methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% STATIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
        obj = loadFromDatabase(objKeys)

        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Signal.Signal
            parser = bose.cnc.meas.Signal.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end
    end % Static methods

    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('Name', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('Scale', 1, @(x) bose.common.validators.isStringLike(x) || (isnumeric(x) && x > 0));
            parser.addParameter('Side', bose.cnc.meas.Side.None);
            parser.addParameter('Type', bose.cnc.meas.SignalType.GenericMic);
            parser.addParameter('Units', "volt", @bose.common.validators.mustBeStringLike);
        end % createParser
    end % Static, Private, Hidden methods
end % Classdef
