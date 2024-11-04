classdef SealQualityParameters < bose.cnc.classes.ConvertibleToStruct & bose.cnc.classes.StructInput
    %SEALQUALITYPARAMETERS Object that defines a set of parameters required to calculate Seal Quality.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.SealQualityParameters.SealQualityParameters

    % Alex Coleman
    % $Id$

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        TargetFrequency(1, 1) double {mustBePositive} = 94 % [Hz] The target frequency at which to calculate Seal Quality. (Default: 94)
        ClipMax(1, 1) double {mustBeNonNan} = double.empty % Cap the Seal Quality to this maximum value. (Default: double.empty)
        ClipMin(1, 1) double {mustBeNonNan} = double.empty % Cap the Seal Quality to this minimum value. (Default: double.empty)
        RawMax(1, 1) double {mustBeNonNan} = double.empty % [dB] Normalize the raw Gsd dB magnitude to this maximum. (Default: double.empty)
        RawMin(1, 1) double {mustBeNonNan} = double.empty % [dB] Normalize the raw Gsd dB magnitude to this minimum. (Default: double.empty)
    end % Public properties

    %% CONSTANT PROPERTIES
    properties (Constant, Access = protected)
        StructFieldsBase64 = string.empty % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64.
        StructFieldsBase64OrNull = ["ClipMax", "ClipMin", "RawMax", "RawMin"] % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64 or set to "NULL" if empty.
        StructFieldsDatetime = string.empty % These fields will be converted to strings using bose.cnc.datetimeStorageFormat.
        StructFieldsDependent = string.empty % These fields will be removed from the struct.
        StructFieldsString = string.empty % These fields will be converted to strings.
        StructFieldsStruct = string.empty % These fields will be converted to structs.
    end % Constant, Protected properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = SealQualityParameters(varargin)
            %SEALQUALITYPARAMETERS Returns a set of parameters required to calculate Seal Quality.
            %
            %   This constructor can also accept inputs as a struct with fieldnames that
            %   match the input argument names. The
            %   bose.cnc.meas.SealQualityParameters.template method returns a struct with
            %   the correct fieldnames.
            %
            %Parameter Arguments:
            %   TargetFrequency (double): [Hz] The target frequency at which to calculate
            %       Seal Quality. (Default: 94)
            %   ClipMax (double): Cap the Seal Quality to this maximum value. (Default:
            %       double.empty)
            %   ClipMin (double): Cap the Seal Quality to this minimum value. (Default:
            %       double.empty)
            %   RawMax (double): [dB] Normalize the raw Gsd dB magnitude to this maximum.
            %       (Default: double.empty)
            %   RawMin (double): [dB] Normalize the raw Gsd dB magnitude to this minimum.
            %       (Default: double.empty)
            %
            %See also: bose.cnc.meas.SealQualityParameters,
            %   bose.cnc.meas.SealQualityParameters.template

            % If we have a struct array of arguments as the input, recurse on this function
            if nargin == 1 && isstruct(varargin{1}) && numel(varargin{1}) > 1
                obj = arrayfun(@bose.cnc.meas.SealQualityParameters, varargin{1});
                return
            end

            parser = bose.cnc.meas.SealQualityParameters.createParser;
            parser.parse(varargin{:});

            resultsCell = fieldnames(parser.Results);

            for indInput = 1:numel(resultsCell)
                obj.(resultsCell{indInput}) = parser.Results.(resultsCell{indInput});
            end
        end % Constructor
    end % Constructor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        function sealQuality = calculate(obj, gsdIn, freqVec)
            %CALCULATE Calculate Seal Quality from the given parameters and input Gsd.
            %
            %Syntax:
            %   sealQuality = sealQualityParameters.calculate(gsdIn, freqVec);
            %
            %Required Positional Arguments:
            %   gsdIn (double): Complex linear double of Gsd transfer functions, size is
            %       [frequencies] x [number of Gsd curves]. All transfer functions must have
            %       the same sequence of frequencies.
            %   freqVec (double): Vector of frequency values for the transfer functions.
            %
            %See also: bose.cnc.meas.SealQualityParameters

            sealQuality = zeros(numel(obj), size(gsdIn, 2));

            for indObj = 1:numel(obj)
                sealQuality(indObj, :) = bose.cnc.math.calculateSealQuality( ...
                    gsdIn, ...
                    freqVec, ...
                    obj(indObj).TargetFrequency, ...
                    'clipMax', obj.ClipMax, ...
                    'clipMin', obj.ClipMin, ...
                    'rawMax', obj.RawMax, ...
                    'rawMin', obj.RawMin ...
                );
            end
        end % calculate
    end % Public methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% STATIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
        function templateStruct = template()
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.SealQualityParameters.SealQualityParameters
            parser = bose.cnc.meas.Configuration.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end
    end % Public, Static methods

    %% PRIVATE STATIC METHODS
    methods (Static, Access = protected, Hidden)

        function parser = createParser()
            parser = inputParser();
            parser.addParameter('TargetFrequency', 94);
            parser.addParameter('ClipMax', double.empty);
            parser.addParameter('ClipMin', double.empty);
            parser.addParameter('RawMax', double.empty);
            parser.addParameter('RawMin', double.empty);
        end % createParser
    end % Static, Private, Hidden methods
end % classdef
