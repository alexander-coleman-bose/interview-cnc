classdef HeadphoneType < bose.cnc.classes.StructInput
    %HEADPHONETYPE Describes a Type of Headphones.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.Headphone,
    %   bose.cnc.meas.HeadphoneFormFactor,
    %   bose.cnc.meas.HeadphoneType.HeadphoneType

    % $Id$

    %% PROPERTIES
    properties
        FormFactor(1,1) bose.cnc.meas.HeadphoneFormFactor = bose.cnc.meas.HeadphoneFormFactor.inEar % Form factor of the Headphone (i.e. inEar). (Default: bose.cnc.meas.HeadphoneFormFactor.inEar)
        Name(1,1) string {local_mustBeLessThan32Characters} = string % Name of the HeadphoneType (i.e. "Lando DP2"). (Default: "")
        Parent(1,1) string {local_mustBeLessThan32Characters} = string % Name of the HeadphoneType that this Type is derived from. (Default: "")
        Project(1,1) string {local_mustBeLessThan64Characters} = string % Name of Project for the Headphone (i.e. "Lando"). (Default: "")
    end % Public properties

    %% CONSTRUCTOR
    methods (Access = public)
        function obj = HeadphoneType(varargin)
            %HEADPHONETYPE Returns a HeadphoneType.
            %
            %   HeadphoneType can also accept inputs as a struct with
            %   fieldnames that match the input argument names. The
            %   bose.cnc.meas.HeadphoneType.template method returns a struct
            %   with the correct fieldnames.
            %
            %Optional Arguments:
            %   FormFactor (bose.cnc.meas.HeadphoneFormFactor): Form factor of the Headphone (i.e. inEar). (Default: bose.cnc.meas.HeadphoneFormFactor.inEar)
            %   Name (string): Name of the Headphone Type (i.e. "Lando DP2"). (Default: "")
            %   Parent (string): Name of the HeadphoneType that this Type is derived from. (Default: "")
            %   Project (string): Name of Project for the Headphone. (Default: "")
            %
            %See also: bose.cnc.meas.HeadphoneType
            parser = bose.cnc.meas.HeadphoneType.createParser;
            parser.parse(varargin{:});

            obj.FormFactor = parser.Results.FormFactor;
            obj.Name = parser.Results.Name;
            obj.Parent = parser.Results.Parent;
            obj.Project = parser.Results.Project;
        end % Constructor

    end % Constructor

    %% PUBLIC METHODS
    methods (Access = public)
        results = eq(obj, comparisonObj);
        objKeys = saveToDatabase(obj);
        varargout = sort(obj, varargin);
    end % Public methods

    %% STATIC METHODS
    methods (Static)
        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.HeadphoneType.HeadphoneType
            parser = bose.cnc.meas.HeadphoneType.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end

        obj = loadFromDatabase(objKeys)
    end % Static methods

    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('FormFactor', ...
                                bose.cnc.meas.HeadphoneFormFactor.inEar);
            parser.addParameter('Name', string, ...
                                @bose.common.validators.mustBeStringLike);
            parser.addParameter('Parent', string, ...
                                @bose.common.validators.mustBeStringLike);
            parser.addParameter('Project', string, ...
                                @bose.common.validators.mustBeStringLike);
        end % createParser
    end % Static, Private, Hidden methods
end % classdef

function local_mustBeLessThan32Characters(inputVal)
    if strlength(inputVal) > 32
        errorId = 'bose:cnc:meas:HeadphoneType:StringLength';
        error(errorId, 'Name & Parent must be <= 32 characters.');
    end
end % local_mustBeLessThan32Characters

function local_mustBeLessThan64Characters(inputVal)
    if strlength(inputVal) > 64
        errorId = 'bose:cnc:meas:HeadphoneType:StringLength';
        error(errorId, 'Project must be <= 64 characters.');
    end
end % local_mustBeLessThan64Characters
