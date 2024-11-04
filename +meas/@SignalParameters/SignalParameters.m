classdef SignalParameters < bose.cnc.classes.ConvertibleToStruct & bose.cnc.classes.StructInput
    %SIGNALPARAMETERS Describes the parameters used to calculate cross-spectra.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.SignalParameters.SignalParameters,
    %   bose.cnc.meas.WindowType, bose.cnc.math.getWindow

    % $Id$

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        Fs(1,1) double {mustBeNonNan, mustBeFinite, mustBePositive} = 48e3 % [Hz] Sampling rate of the signal. (Default: 48e3)
        Nfft(1,1) uint32 {mustBePositive} = 16384 % Number of frequencies calculated in the FFT. (Default: 16384)
        NOverlap(1,1) uint32 = 8192 % Number of samples of overlap between windows. (Default: 8192)
        TUp(1,1) double {mustBeNumeric, mustBeNonNan, mustBeNonnegative} = 0.5 % [Seconds] The ramp-up time of the excitation signal before the stabilization period and the recorded measurement. (Default: 0.5)
        TPrerun(1,1) double {mustBeNumeric, mustBeNonNan, mustBeNonnegative} = 1 % [Seconds] The full-scale stabilization time before the recorded measurement. (Default: 1)
        TRecord(1,1) double {mustBeNumeric, mustBeNonNan, mustBeNonnegative} = 6 % [Seconds] The length of the recording. (Default: 6)
        TDown(1,1) double {mustBeNumeric, mustBeNonNan, mustBeNonnegative} = 0.5 % [Seconds] The ramp-down time of the excitation signal after the recorded measurement. (Default: 0.5)
        Window(1,1) bose.cnc.meas.WindowType = bose.cnc.meas.WindowType.hanning % The type of window applied to the overlapping, averaged frames. (Default: bose.cnc.meas.WindowType.hanning)
    end % Public properties

    properties (Dependent)
        Frequencies(:,1) double {mustBeNonNan, mustBeFinite, mustBeNonnegative} % [Hz] The frequency vector associated with the cross-spectral data. Dependent on Nfft.
        TotalSamples (1,1) double % Total number of samples in the measurement, rounded up. Dependent on TTotal and Fs.
        TTotal(1,1) double % [Seconds] The total amount of time in the measurement. Dependent on T* properties.
    end % Public, Dependent properties

    properties (Constant, Access = protected)
        StructFieldsBase64 = string.empty % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64.
        StructFieldsBase64OrNull = string.empty % These fields will be converted to base64 strings using bose.cnc.datastore.encodeBase64 or set to "NULL" if empty.
        StructFieldsDatetime = string.empty % These fields will be converted to strings using bose.cnc.datetimeStorageFormat.
        StructFieldsDependent = ["Frequencies", "TotalSamples", "TTotal"] % These fields will be removed from the struct.
        StructFieldsString = "Window" % These fields will be converted to strings.
        StructFieldsStruct = string.empty % These fields will be converted to structs.
    end % Constant, Protected properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = SignalParameters(varargin)
            %SIGNALPARAMETERS Returns a SignalParameters object.
            %
            %   This constructor can also accept inputs as a struct with fieldnames that
            %   match the input argument names. The bose.cnc.meas.SignalParameters.template
            %   method returns a struct with the correct fieldnames.
            %
            %Optional Arguments:
            %   Fs (double): [Hz] Sampling rate of the signal. (Default: 48e3)
            %   Nfft (uint32): Number of frequencies calculated in the FFT. (Default: 16384)
            %   NOverlap (uint32): Number of samples of overlap between windows. (Default:
            %       8192)
            %   TUp (double): [Seconds] The ramp-up time of the excitation signal before the
            %       stabilization period and the recorded measurement. (Default: 0.5)
            %   TPrerun (double): [Seconds] The full-scale stabilization time before the
            %       recorded measurement. (Default: 1)
            %   TRecord (double): [Seconds] The length of the recording. (Default: 6)
            %   TDown (double): [Seconds] The ramp-down time of the excitation signal after
            %       the recorded measurement. (Default: 0.5)
            %   Window (bose.cnc.meas.WindowType): The type of window applied to the
            %       overlapping, averaged frames. (Default: bose.cnc.meas.WindowType.hanning)
            %
            %See also: bose.cnc.meas.SignalParameters

            % If we have a struct array of arguments as the input, recurse on this function
            if nargin == 1 && isstruct(varargin{1}) && numel(varargin{1}) > 1
                obj = arrayfun(@bose.cnc.meas.SignalParametes, varargin{1});
                return
            end

            parser = bose.cnc.meas.SignalParameters.createParser;
            parser.parse(varargin{:});

            obj.Fs = parser.Results.Fs;
            obj.Nfft = parser.Results.Nfft;
            obj.NOverlap = parser.Results.NOverlap;
            obj.TUp = parser.Results.TUp;
            obj.TPrerun = parser.Results.TPrerun;
            obj.TRecord = parser.Results.TRecord;
            obj.TDown = parser.Results.TDown;
            obj.Window = parser.Results.Window;
        end % Constructor
    end % Constructor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GET/SET METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function freqVec = get.Frequencies(obj)
            freqVec = bose.cnc.math.getFrequencyVector(double(obj.Nfft), obj.Fs);
        end % get.Frequencies

        function totalSamples = get.TotalSamples(obj)
            totalSamples = ceil(obj.TTotal * obj.Fs);
        end % get.TotalSamples

        function tTotal = get.TTotal(obj)
            tTotal = sum([ ...
                obj.TUp, ...
                obj.TPrerun, ...
                obj.TRecord, ...
                obj.TDown ...
            ]);
        end % get.TTotal
    end % Get/Set methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        [results, reasons] = isValid(obj)
        objKeys = saveToDatabase(obj)
    end % Public methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% STATIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
        obj = loadFromDatabase(objKeys)

        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.SignalParameters.SignalParameters
            parser = bose.cnc.meas.SignalParameters.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end
    end % Static methods

    %% PRIVATE, STATIC METHODS
    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('Fs', 48e3);
            parser.addParameter('Nfft', 16384);
            parser.addParameter('NOverlap', 8192);
            parser.addParameter('TUp', 0.5);
            parser.addParameter('TPrerun', 1);
            parser.addParameter('TRecord', 6);
            parser.addParameter('TDown', 0.5);
            parser.addParameter('Window', bose.cnc.meas.WindowType.hanning);
        end % createParser
    end % Static, Private, Hidden methods
end % classdef
