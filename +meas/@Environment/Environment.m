classdef Environment < bose.cnc.classes.StructInput
    %ENVIRONMENT Describes a Environment where a measurement can take place.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.DataRecord,
    %   bose.cnc.meas.Environment.Environment

    % $Id$

    %% PROPERTIES
    properties
        Description(1,1) string = string % A Description of the Environment. (Default: "")
        Name(1,1) string = string % The Name of the Environment. (Default: "")
    end % Public properties

    %% METHODS
    methods
        function obj = Environment(varargin)
            %ENVIRONMENT Returns a measurement Environment object.
            %
            %   Environment can also accept inputs as a struct with fieldnames
            %   that match the input argument names. The
            %   bose.cnc.meas.Environment.template method returns a struct
            %   with the correct fieldnames.
            %
            %Optional Arguments:
            %   Description (string): A Description of the Environment. (Default: "")
            %   Name (string): The Name of the Environment. (Default: "")
            %
            %See also: bose.cnc.meas.Environment,
            %   bose.cnc.meas.Signal
            parser = bose.cnc.meas.Environment.createParser;
            parser.parse(varargin{:});

            obj.Description = parser.Results.Description;
            obj.Name = parser.Results.Name;
        end % Constructor

        function results = isValid(obj)
            %ISVALID Returns true if the object is "Valid"
            %
            %Environment is Valid if:
            %   ~strcmp(Environment.Name, "")

            results = false(size(obj));
            for indObj = 1:numel(obj)
                results(indObj) = ~strcmp(obj(indObj).Name, "");
            end
        end % isValid

        results = eq(obj, comparisonObj)
        results = ne(obj, comparisonObj)
        objKeys = saveToDatabase(obj)
        varargout = sort(obj, varargin)
    end % Public methods

    methods (Static)
        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Environment.Environment
            parser = bose.cnc.meas.Environment.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end

        obj = loadFromDatabase(objKeys)
    end % Static methods

    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('Description', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('Name', string, @bose.common.validators.mustBeStringLike);
        end % createParser
    end % Static, Private, Hidden methods
end % classdef
