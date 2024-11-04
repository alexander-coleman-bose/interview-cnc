classdef Mapping < bose.cnc.classes.StructInput
    %MAPPING Represents a link between a Hardware channel and a Signal.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.DataRecord,
    %   bose.cnc.meas.Mapping.Mapping, bose.cnc.meas.Signal,
    %   bose.cnc.meas.Hardware

    % Alex Coleman
    % $Id$

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = public)
        Channel(1,1) string = string % The Hardware Channel to map the Signal to, i.e. "ai1", "ao3", etc. (Default: "")
        Signal(1,1) bose.cnc.meas.Signal = bose.cnc.meas.Signal % The Signal to map the Hardware Channel to. (Default: bose.cnc.meas.Signal)
    end % Public properties

    properties (Dependent)
        DisplayName(1,1) string % A formatted string describing the object.
        IsInput(1,1) logical % True if the mapped Signal is an Input Signal.
        IsOutput(1,1) logical % True if the mapped Signal is an Output Signal.
    end % Dependent properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTRUCTOR
    methods
        function obj = Mapping(varargin)
            %MAPPING Returns a channel Mapping object.
            %
            %   Mapping can also accept inputs as a struct with fieldnames that match the
            %   input argument names. The bose.cnc.meas.Mapping.template method returns a
            %   struct with the correct fieldnames.
            %
            %Optional Arguments:
            %   Channel (string-like): The Hardware Channel to map the Signal to, i.e. "ai1", "ao3", etc. (Default: "")
            %   Signal (bose.cnc.meas.Signal): The Signal to map the Hardware Channel to. (Default: bose.cnc.meas.Signal)
            %
            %See also: bose.cnc.meas.Mapping
            parser = bose.cnc.meas.Mapping.createParser;
            parser.parse(varargin{:});

            obj.Channel = parser.Results.Channel;
            obj.Signal = parser.Results.Signal;
        end % Constructor
    end

    %% GET/SET METHODS
    methods
        function val = get.DisplayName(obj)
            val = sprintf( ...
                "%s => %s", ...
                obj.Channel, ...
                obj.Signal.DisplayName ...
            );
        end % get.DisplayName

        function val = get.IsInput(obj)
            val = obj.Signal.isInput;
        end % get.IsInput

        function val = get.IsOutput(obj)
            val = obj.Signal.isOutput;
        end % get.IsOutput
    end % Get/Set methods

    %% PUBLIC METHODS
    methods (Access = public)
        results = eq(obj, comparisonObj)
        channels = findChannelBySignal(obj, signals)
        channelSignalMatrix = makeChannelSignalMatrix(obj, channels, signals)
        results = ne(obj, comparisonObj)
        objKeys = saveToDatabase(obj)
        varargout = sort(obj, varargin)

        function results = isValid(obj)
            %ISVALID Returns true if the object is "Valid"
            %
            %Mapping is Valid if:
            %   ~strcmp(Mapping.Channel, "")
            % & Mapping.Signal.isValid

            results = false(size(obj));
            for indObj = 1:numel(obj)
                results(indObj) = ~strcmp(obj(indObj).Channel, "") && ...
                             obj(indObj).Signal.isValid;
            end
        end % isValid
    end % Public methods

    %% STATIC METHODS
    methods (Static)
        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Mapping.Mapping
            parser = bose.cnc.meas.Mapping.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end

        obj = fromChannelSignalMatrix(channelSignalMatrix, channels, signals)
        obj = loadFromDatabase(objKeys)
    end % Static methods

    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('Channel', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('Signal', bose.cnc.meas.Signal);
        end % createParser
    end % Static, Private, Hidden methods
end % classdef
