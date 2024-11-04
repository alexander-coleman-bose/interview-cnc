classdef Hardware < bose.cnc.classes.StructInput
    %HARDWARE Describes a measurement device used during a measurement.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.DataRecord,
    %   bose.cnc.meas.Hardware.Hardware, bose.cnc.meas.HardwareType

    % Alex Coleman
    % $Id$

    %% PROPERTIES
    properties
        CalibrationMode(1,1) bose.cnc.meas.CalibrationMode = bose.cnc.meas.CalibrationMode.None % CalibrationMode of Hardware (LDAQ specific). (Default: bose.cnc.meas.CalibrationMode.None)
        ConnectionParameters(:,1) string {local_cannotHaveCommas} = string.empty % Explicit connection parameters to be used instead of DeviceName (LDAQ specific). (Default: string.empty)
        DeviceModel(1,1) string {local_mustBeLessThan96Characters} = string % Measurement Device Model (i.e. "Motu 8A"). (Default: "")
        DeviceName(1,1) string {local_mustBeLessThan96Characters} = string % Measurement Device Name (i.e. "Thanos", "mdaq053"). (Default: "")
        Name(1,1) string {local_mustBeLessThan96Characters} = string % Measurement Config Name (i.e. "Lando_Reverb_Config"). (Default: "")
        NumAnalogInputs(1,1) uint8 = 0 % Number of analog input channels. (Default: 0)
        NumAnalogOutputs(1,1) uint8 = 0 % Number of analog output channels. (Default: 0)
        NumDigitalInputs(1,1) uint8 = 0 % Number of digital input channels. (Default: 0)
        NumDigitalOutputs(1,1) uint8 = 0 % Number of digital output channels. (Default: 0)
        Type(1,1) bose.cnc.meas.HardwareType = bose.cnc.meas.HardwareType.ldaq % Measurement Device Type (i.e. ldaq or mdaq). (Default: bose.cnc.meas.HardwareType.ldaq)
    end % Public properties

    properties (Dependent)
        AllChannels(:,1) string % A list of all channel names. (i.e. "ai1", "ai2", "di1", "do1", etc). (Default: string.empty)
        InputChannels(:,1) string % A list of input channel names. (i.e. "ai1", "ai2", "di1", etc). (Default: string.empty)
        OutputChannels(:,1) string % A list of output channel names. (i.e. "ao1", "ao2", "do1", etc). (Default: string.empty)
    end % Public, Dependent properties

    %% METHODS
    methods
        function obj = Hardware(varargin)
            %HARDWARE Returns a measurement Hardware object.
            %
            %   Hardware can also accept inputs as a struct with fieldnames
            %   that match the input argument names. The
            %   bose.cnc.meas.Hardware.template method returns a struct
            %   with the correct fieldnames.
            %
            %Optional Arguments:
            %   CalibrationMode (bose.cnc.meas.CalibrationMode): CalibrationMode of Hardware (LDAQ specific). (Default: bose.cnc.meas.CalibrationMode.None)
            %   ConnectionParameters (string): Explicit connection parameters to be used instead of DeviceName (LDAQ specific). (Default: string.empty)
            %   DeviceModel (string): Measurement Device Model (i.e. "Motu 8A"). (Default: "")
            %   DeviceName (string): Measurement Device Name (i.e. "Thanos", "mdaq053"). (Default: "")
            %   Name (string): Measurement Config Name (i.e. "Lando_Reverb_Config"). (Default: "")
            %   NumAnalogInputs (uint8): Number of analog input channels. (Default: 0)
            %   NumAnalogOutputs (uint8): Number of analog output channels. (Default: 0)
            %   NumDigitalInputs (uint8): Number of digital input channels. (Default: 0)
            %   NumDigitalOutputs (uint8): Number of digital output channels. (Default: 0)
            %   Type (bose.cnc.meas.HardwareType): Measurement Device Type (i.e. ldaq or mdaq). (Default: bose.cnc.meas.HardwareType.ldaq)
            %
            %See also: bose.cnc.meas.Hardware
            parser = bose.cnc.meas.Hardware.createParser;
            parser.parse(varargin{:});

            obj.CalibrationMode = parser.Results.CalibrationMode;
            obj.ConnectionParameters = parser.Results.ConnectionParameters;
            obj.DeviceModel = parser.Results.DeviceModel;
            obj.DeviceName = parser.Results.DeviceName;
            obj.Name = parser.Results.Name;
            obj.NumAnalogInputs = parser.Results.NumAnalogInputs;
            obj.NumAnalogOutputs = parser.Results.NumAnalogOutputs;
            obj.NumDigitalInputs = parser.Results.NumDigitalInputs;
            obj.NumDigitalOutputs = parser.Results.NumDigitalOutputs;
            obj.Type = parser.Results.Type;
        end % Constructor

        function value = get.AllChannels(obj)
            value = [obj.InputChannels; obj.OutputChannels];
        end % get.AllChannels

        function value = get.InputChannels(obj)
            analogInputChannels = "ai" + string(1:obj.NumAnalogInputs)';
            digitalInputChannels = "di" + string(1:obj.NumDigitalInputs)';
            value = [analogInputChannels; digitalInputChannels];
        end % get.InputChannels

        function value = get.OutputChannels(obj)
            analogOutputChannels = "ao" + string(1:obj.NumAnalogOutputs)';
            digitalOutputChannels = "do" + string(1:obj.NumDigitalOutputs)';
            value = [analogOutputChannels; digitalOutputChannels];
        end % get.OutputChannels

        function results = isValid(obj)
            %ISVALID Returns true if the object is "Valid".
            %
            %Hardware is Valid if:
            %   ~strcmp(Hardware.DeviceModel, "")
            % & ~strcmp(Hardware.DeviceName, "") || ~isempty(Hardware.ConnectionParameters)
            % & ~strcmp(Hardware.Name, "")
            % & (Hardware.Type ~= bose.cnc.meas.HardwareType.ldaq || Hardware.CalibrationMode ~= bose.cnc.meas.CalibrationMode.None)
            %
            %See also: bose.cnc.meas.Hardware
            if(any(size(obj) == 0))
               results = false;
               return;
            end
            results = false(size(obj));

            for indObj = 1:numel(obj)
                results(indObj) = ( ...
                    ~strcmp(obj(indObj).DeviceModel, "") && ...
                    ~strcmp(obj(indObj).DeviceName, "") || ~isempty(obj(indObj).ConnectionParameters) && ...
                    ~strcmp(obj(indObj).Name, "") && ...
                    ( ...
                        obj(indObj).Type ~= bose.cnc.meas.HardwareType.ldaq || ...
                        obj(indObj).CalibrationMode ~= bose.cnc.meas.CalibrationMode.None ...
                    ) ...
                );
            end
        end % isValid

        objKeys = saveToDatabase(obj);
        varargout = sort(obj, varargin)
    end % Public methods

    methods (Static)
        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Hardware.Hardware
            parser = bose.cnc.meas.Hardware.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end

        obj = loadFromDatabase(objKeys)
    end % Static methods

    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser;
            parser.addParameter('CalibrationMode', bose.cnc.meas.CalibrationMode.None);
            parser.addParameter('ConnectionParameters', string.empty);
            parser.addParameter('DeviceModel', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('DeviceName', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('Name', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('NumAnalogInputs', 0);
            parser.addParameter('NumAnalogOutputs', 0);
            parser.addParameter('NumDigitalInputs', 0);
            parser.addParameter('NumDigitalOutputs', 0);
            parser.addParameter('Type', bose.cnc.meas.HardwareType.ldaq);
        end % createParser
    end % Static, Private, Hidden methods
end % Classdef

function local_mustBeLessThan96Characters(inputVal)
    if strlength(inputVal) > 96
        errorId = 'bose:cnc:meas:Hardware:StringLength';
        error(errorId, 'DeviceModel, DeviceName, and Name must be <= 96 characters.');
    end
end % local_mustBeLessThan96Characters

function local_cannotHaveCommas(inputVal)
    if any(contains(inputVal, ','))
        errorId = 'bose:cnc:meas:Hardware:InvalidConnectionParameters';
        error(errorId, 'ConnectionParameters cannot contain commas (",").');
    end
end % local_cannotHaveCommas
