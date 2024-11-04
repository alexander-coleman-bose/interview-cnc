classdef SignalType
    %SIGNALTYPE Enum for valid types of a Signal.
    %
    %Enumeration members:
    %   AsrcSignal     (t): Output from ASRC that requires a correction factor to be applied to the measurement output.
    %   CalibrationMic (a): A calibrated mic used as a reference during calibration.
    %   CanalMic (c): A canal/"performance" microphone input.
    %   DriverLoopback (d): A loopback input from a driver.
    %   DriverOutput (D): An output signal to a driver.
    %   EarMic (e): An ear microphone input (head & ear simulators).
    %   FeedbackMic (s): A feedback/"system" mic input.
    %   FeedForwardMic (o): A feedforward/"outside" mic input.
    %   GenericMic (g): A generic, non-typed mic input.
    %   GenericOutput (G): A generic, non-typed output.
    %   ReferenceMic (r): A reference mic input.
    %   RoomOutput (R): An output signal to speakers in the environment.
    %
    %See also: bose.cnc.meas, enumeration, bose.cnc.meas.StepType

    % Alex Coleman
    % $Id$

    %% PROPERTIES
    properties
        Label(1, 1) string = string % The single character label for the SignalType, used in plotting and analysis features (i.e. c, d, o, s, r, ...).
    end % Public properties

    properties (GetAccess = private, SetAccess = immutable, Hidden)
        BoolOutput(1, 1) logical = false % BoolOutput is true when the SignalType is an output signal, else false.
    end % Private properties

    %% CONSTRUCTOR
    methods
        function obj = SignalType(signalLabel, isOutput)
            obj.Label = signalLabel;
            obj.BoolOutput = isOutput;
        end
    end % Constructor

    %% PUBLIC METHODS
    methods (Access = public)
        function result = isInput(obj)
            %ISINPUT Returns true if the SignalType is for an Input.
            %
            %See also: bose.cnc.meas.SignalType,
            %   bose.cnc.meas.SignalType.isOutput
            result = false(size(obj));

            for indObj = 1:numel(obj)
                result(indObj) = ~obj(indObj).BoolOutput;
            end
        end % isInput

        function result = isOutput(obj)
            %ISOUTPUT Returns true if the SignalType is for an Output.
            %
            %See also: bose.cnc.meas.SignalType,
            %   bose.cnc.meas.SignalType.isInput
            result = false(size(obj));

            for indObj = 1:numel(obj)
                result(indObj) = obj(indObj).BoolOutput;
            end
        end % isOutput
    end % Public methods

    methods (Static)
        function obj = fromLabel(signalLabel)
            %FROMLABEL Construct a SignalType based off of a signal Label.
            %
            %   Note: Case sensitive.
            %
            %Required Arguments:
            %   signalLabel(string): A string array of signal labels.
            %
            %Returns:
            %   obj(bose.cnc.meas.SignalType): An array of SignalType
            %       objects that match the given signal Labels.
            %
            %See also: bose.cnc.meas.SignalType

            % Handle inputs
            parser = inputParser;
            parser.addRequired('signalLabel', @bose.common.validators.mustBeStringLike);
            parser.parse(signalLabel);
            signalLabel = string(parser.Results.signalLabel);

            % Get valid Enums and Labels
            validEnums = enumeration('bose.cnc.meas.SignalType');
            validLabels = [validEnums.Label];

            obj = bose.cnc.meas.SignalType.empty;
            for indLabel = 1:numel(signalLabel)
                signalTypeMask = contains(validLabels, signalLabel(indLabel), 'IgnoreCase', false);
                typeName = string(validEnums(signalTypeMask));
                signalType = bose.cnc.meas.SignalType(typeName);
                obj = [obj; signalType];
            end
        end % fromLabel
    end % Public, static methods

    %% ENUMERATION
    enumeration
        AsrcSignal      ("t", false)
        CalibrationMic  ("a", false)
        CanalMic        ("c", false)
        DriverLoopback  ("d", false)
        DriverOutput    ("D", true)
        EarMic          ("e", false)
        FeedbackMic     ("s", false)
        FeedForwardMic  ("o", false)
        GenericMic      ("g", false)
        GenericOutput   ("G", true)
        ReferenceMic    ("r", false)
        RoomOutput      ("R", true)
    end % Enumeration
end % classdef
