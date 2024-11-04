classdef Person < bose.cnc.classes.ConvertibleToStruct & bose.cnc.classes.StructInput
    %PERSON Describes a measurement subject, designer, or operator.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.DataRecord, bose.cnc.meas.Person.Person

    % $Id$

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        FirstName(1,1) string = string % The FirstName of the Person. (Default: "")
        LastName(1,1) string = string % The LastName of the Person. (Default: "")
    end % Public properties

    properties (Dependent)
        DisplayName(1,1) string
    end % Dependent properties

    properties (Constant, Access = protected)
        StructFieldsBase64 = string.empty % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64.
        StructFieldsBase64OrNull = string.empty % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64 or set to "NULL" if empty.
        StructFieldsDatetime = string.empty % These fields will be converted to strings using bose.cnc.datetimeStorageFormat.
        StructFieldsDependent = "DisplayName" % These fields will be removed from the struct.
        StructFieldsString = string.empty % These fields will be converted to strings.
        StructFieldsStruct = string.empty % These fields will be converted to structs.
    end % Constant, Protected properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        function obj = Person(varargin)
            %PERSON Returns a Person.
            %
            %   This constructor can also accept inputs as a struct with fieldnames that
            %   match the input argument names. The bose.cnc.meas.Person.template method
            %   returns a struct with the correct fieldnames.
            %
            %Parameter Arguments:
            %   FirstName (string): The FirstName of the Person. (Default: "")
            %   LastName (string): The LastName of the Person. (Default: "")
            %
            %See also: bose.cnc.meas.Person

            % If we have a struct array of arguments as the input, recurse on this function
            if nargin == 1 && isstruct(varargin{1}) && numel(varargin{1}) > 1
                obj = arrayfun(@bose.cnc.meas.Signal, varargin{1});
                return
            end

            parser = bose.cnc.meas.Person.createParser;
            parser.parse(varargin{:});

            obj.FirstName = parser.Results.FirstName;
            obj.LastName = parser.Results.LastName;
        end % Constructor
    end % Constructor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GET/SET METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function value = get.DisplayName(obj)
            if strcmp(obj.LastName, "")
                value = "";
            elseif strcmp(obj.FirstName, "")
                value = obj.LastName;
            else
                value = sprintf("%s %s", obj.FirstName, obj.LastName);
            end
        end % get.DisplayName
    end % Get/Set Methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        results = eq(obj, comparisonObj)
        [results, reasons] = isValid(obj)
        results = ne(obj, comparisonObj)
        objKeys = saveToDatabase(obj)
        varargout = sort(obj, varargin)
    end % Public methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% STATIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
        obj = loadFromDatabase(objKeys)

        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Person.Person
            parser = bose.cnc.meas.Person.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end

        function obj = fromString(personStrings)
            %FROMSTRING Constructs a Person object by separating first/last name from a single string.
            %
            %Usage:
            %   obj = bose.cnc.meas.Person.fromString(personStrings);
            %
            %Required Positional Arguments:
            %   personStrings (stringlike): String to parse into a Person, i.e. 'Alex Coleman'
            %
            %Returns:
            %   obj (bose.cnc.meas.Person): The constructed Person object.
            %
            %See also: bose.cnc.meas.Person

            narginchk(1, 1);

            parser = inputParser;
            parser.addRequired('personStrings', @bose.common.validators.mustBeStringLike);
            parser.parse(personStrings);
            personStrings = string(parser.Results.personStrings);

            obj = repmat(bose.cnc.meas.Person, size(personStrings));
            for indPerson = 1:numel(personStrings)
                thisString = strtrim(personStrings(indPerson));
                theseSplits = strsplit(thisString, ' ', 'CollapseDelimiters', true);
                switch numel(theseSplits)
                case 1
                    obj(indPerson) = bose.cnc.meas.Person('LastName', theseSplits);
                otherwise
                    obj(indPerson) = bose.cnc.meas.Person( ...
                        'FirstName', theseSplits(1), ...
                        'LastName', theseSplits(end) ...
                    );
                end % switch
            end % for every person

            obj = reshape(obj, size(personStrings));
        end % fromString
    end % Static methods

    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('FirstName', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('LastName', string, @bose.common.validators.mustBeStringLike);
        end % createParser
    end % Static, Private, Hidden methods
end % classdef
