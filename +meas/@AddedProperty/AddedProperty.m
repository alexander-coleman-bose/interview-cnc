classdef AddedProperty < bose.cnc.classes.StructInput
    %ADDEDPROPERTY Describes additional properties for a Headphone.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.Person, bose.cnc.meas.Headphone,
    %   bose.cnc.meas.AddedProperty.AddedProperty

    % $Id$

    %% PROPERTIES
    properties
        Description(1,1) string {local_mustBeLessThan100Characters} = string % Description of AddedProperty (i.e. "Preferred Stay Hear Plus (SHP) tip size"). (Default: "")
        Value(1,1) double = 0 % Double value of the AddedProperty. (Default: 0)
        ValueStr(1,1) string = string % String value of the AddedProperty (i.e. "M"). (Default: "")
    end % Public properties

    %% PUBLIC METHODS
    methods
        function obj = AddedProperty(varargin)
            %ADDEDPROPERTY Returns a AddedProperty.
            %
            %   AddedProperty can also accept inputs as a struct with
            %   fieldnames that match the input argument names. The
            %   bose.cnc.meas.AddedProperty.template method returns a
            %   struct with the correct fieldnames.
            %
            %Optional Arguments:
            %   Description (string): Description of AddedProperty (i.e. "Preferred Stay Hear Plus (SHP) tip size"). (Default: "")
            %   Value (double): % Double value of the AddedProperty. (Default: 0)
            %   ValueStr (string): String value of the AddedProperty (i.e. "M"). (Default: "")
            %
            %See also: bose.cnc.meas.AddedProperty
            parser = bose.cnc.meas.AddedProperty.createParser;
            parser.parse(varargin{:});

            obj.Description = parser.Results.Description;
            obj.Value = parser.Results.Value;
            obj.ValueStr = parser.Results.ValueStr;
        end % Constructor

        [results, reasons] = isValid(obj)
        objKeys = saveToDatabase(obj)
    end % Public methods

    %% STATIC METHODS
    methods (Static)
        obj = loadFromDatabase(objKeys)

        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.AddedProperty.AddedProperty
            parser = bose.cnc.meas.AddedProperty.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end
    end % Static methods

    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('Description', string, ...
                                @bose.common.validators.mustBeStringLike);
            parser.addParameter('Value', 0, @mustBeFinite);
            parser.addParameter('ValueStr', string, ...
                                @bose.common.validators.mustBeStringLike);
        end % createParser
    end % Static, Private, Hidden methods
end % classdef

function local_mustBeLessThan100Characters(inputVal)
    if strlength(inputVal) > 100
        errorId = 'bose:cnc:meas:AddedProperty:DescriptionLength';
        error(errorId, 'Description must be <= 100 characters.');
    end
end % local_mustBeLessThan100Characters
