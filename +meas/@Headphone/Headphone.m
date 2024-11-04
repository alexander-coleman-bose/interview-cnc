classdef Headphone < bose.cnc.classes.StructInput
    %HEADPHONE Describes a Headphone (device under test).
    %
    %See also: bose.cnc.meas, bose.cnc.meas.DataRecord,
    %   bose.cnc.meas.HeadphoneType, datetime,
    %   bose.cnc.meas.AddedProperty, bose.cnc.meas.Side,
    %   bose.cnc.meas.Headphone.Headphone

    % $Id$

    %% PROPERTIES
    properties
        AdditionalProperties(:,1) bose.cnc.meas.AddedProperty = bose.cnc.meas.AddedProperty.empty % Any properties that are attached to the Headphone (i.e. hasNoiseCancellation). (Default: bose.cnc.meas.AddedProperty.empty)
        Description(1,1) string {local_mustBeLessThan256Characters} = string % A Description of the Headphone. (Default: "")
        ManufactureDate(1,1) datetime = datetime(0, 'ConvertFrom', 'epochtime') % Date when the Headphone was manufactured. (Default: 01-Jan-1970 00:00:00)
        Name(1,1) string {local_mustBeLessThan32Characters} = string % The Name of the Headphone (i.e. L122). (Default: "")
        SerialNumber(1,1) string {local_mustBeLessThan32Characters} = string % A unique identifier for the device (i.e. serial number). (Default: "")
        Side(1,1) bose.cnc.meas.Side {local_mustBeLessThan8Characters} = bose.cnc.meas.Side.Both % Whether this Headphone is single-sided or represents both buds/ear cups. (Default: bose.cnc.meas.Side.Both)
        Type(1,1) bose.cnc.meas.HeadphoneType = bose.cnc.meas.HeadphoneType % The Type of the Headphone (i.e. Lando DP2). (Default: bose.cnc.meas.HeadphoneType)
    end % Public properties

    %% CONSTRUCTOR
    methods (Access = public)
        function obj = Headphone(varargin)
            %HEADPHONE Returns a Headphone.
            %
            %   Headphone can also accept inputs as a struct with fieldnames
            %   that match the input argument names. The
            %   bose.cnc.meas.Headphone.template method returns a struct
            %   with the correct fieldnames.
            %
            %Parameter Arguments:
            %   AdditionalProperties: Any properties that are attached to the Headphone (i.e. hasNoiseCancellation). (Default: bose.cnc.meas.AddedProperty.empty)
            %   Description: A Description of the Headphone. (Default: "")
            %   ManufactureDate (datetime): Date when the Headphone was manufactured. (Default: 01-Jan-1970 00:00:00)
            %   Name (string): The Name of the Headphone (i.e. L122). (Default: "")
            %   SerialNumber (string): A unique identifier for the device (i.e. serial number). (Default: "")
            %   Side (bose.cnc.meas.Side): Whether this Headphone is single-sided or represents both buds/ear cups. (Default: bose.cnc.meas.Side.Both)
            %   Type (bose.cnc.meas.HeadphoneType): The Type of the Headphone (i.e. Lando DP2). (Default: bose.cnc.meas.HeadphoneType)
            %
            %See also: bose.cnc.meas.Headphone
            parser = bose.cnc.meas.Headphone.createParser;
            parser.parse(varargin{:});

            obj.AdditionalProperties = parser.Results.AdditionalProperties;
            obj.Description = parser.Results.Description;
            obj.ManufactureDate = parser.Results.ManufactureDate;
            obj.Name = parser.Results.Name;
            obj.SerialNumber = parser.Results.SerialNumber;
            obj.Side = parser.Results.Side;
            obj.Type = parser.Results.Type;
        end % Constructor
    end % Constructor

    %% PUBLIC METHODS
    methods (Access = public)
        results = eq(obj, comparisonObj)
        [results, reasons] = isValid(obj)
        results = ne(obj, comparisonObj)
        objKeys = saveToDatabase(obj);
        varargout = sort(obj, varargin);
    end % Public methods

    methods (Static)
        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Headphone.Headphone
            parser = bose.cnc.meas.Headphone.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end

        obj = loadFromDatabase(objKeys)
    end % Static methods

    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('AdditionalProperties', bose.cnc.meas.AddedProperty.empty);
            parser.addParameter('Description', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('ManufactureDate', datetime(0, 'ConvertFrom', 'epochtime'));
            parser.addParameter('Name', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('SerialNumber', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('Side', bose.cnc.meas.Side.Both);
            parser.addParameter('Type', bose.cnc.meas.HeadphoneType);
        end % createParser
    end % Static, Private, Hidden methods
end % classdef

function local_mustBeLessThan256Characters(inputVal)
    if strlength(inputVal) > 256
        errorId = 'bose:cnc:meas:Headphone:DescriptionLength';
        error(errorId, 'Description must be <= 256 characters.');
    end
end % local_mustBeLessThan256Characters

function local_mustBeLessThan32Characters(inputVal)
    if strlength(inputVal) > 32
        errorId = 'bose:cnc:meas:Headphone:NameLength';
        error(errorId, 'Name & SerialNumber must be <= 32 characters.');
    end
end % local_mustBeLessThan32Characters

function local_mustBeLessThan8Characters(inputVal)
    if strlength(string(inputVal)) > 8
        errorId = 'bose:cnc:meas:Headphone:SideNameLength';
        error(errorId, 'The name of the Side must be <= 8 characters.');
    end
end % local_mustBeLessThan8Characters
