function configureHardwareCalibrationMode(obj)
    %CONFIGUREHARDWARECALIBRATIONMODE Configure hardware calibration mode (ldaq).
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %   DeviceNotConnected - When the measurement hardware isn't connected.
    %   NoHardwareConfiguration - When no Hardware is loaded in the Session.
    %
    %See also: bose.cnc.meas.Session,
    %   bose.cnc.meas.Session.configureHardware

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Session:configureHardwareCalibrationMode:';

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            [idHeader 'NumelSession'], ...
            [ ...
                'Session.configureHardwareCalibrationMode can only be run ' ...
                'with a single Session, not %s' ...
            ], ...
            numel(obj) ...
        );
    end

    % Check obj.DeviceHandle is connected, if not error.
    if ~obj.isDeviceConnected
        error( ...
            [idHeader 'DeviceNotConnected'], ...
            'Hardware configuration failed: No device connected.' ...
        );
    end

    % Check to see if we have a Hardware object.
    if isempty(obj.Hardware)
        error( ...
            [idHeader 'NoHardwareConfiguration'], ...
            'Hardware configuration failed: No Hardware configuration loaded.' ...
        );
    end

    % Set the CalibrationMode (LDAQ Specific), if different
    if obj.Hardware.Type == bose.cnc.meas.HardwareType.ldaq && ~strcmpi(obj.DeviceHandle.CalibrationMode, char(obj.Hardware.CalibrationMode))
        obj.DeviceHandle.CalibrationMode = lower(char(obj.Hardware.CalibrationMode));
    end
end % function
