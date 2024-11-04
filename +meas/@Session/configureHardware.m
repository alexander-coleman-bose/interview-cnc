function configureHardware(obj)
    %CONFIGUREHARDWARE Configure a connected measurement hardware device.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %   DeviceNotConnected - When the measurement hardware isn't connected.
    %
    %See also: bose.cnc.meas.Session,
    %   bose.cnc.meas.Session.connectAndConfigure,
    %   bose.cnc.meas.Session.configureHardwareCalibrationMode,
    %   bose.cnc.meas.Session.configureHardwareSignals,
    %   bose.cnc.meas.Session.configureHardwareInputMapping,
    %   bose.cnc.meas.Session.configureHardwareOutputMapping

    % $Id$

    idHeader = 'bose:cnc:meas:Session:configureHardware:';

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            [idHeader 'NumelSession'], ...
            ['Session.configureHardware can only be run with a single ' ...
             'Session, not %s'], ...
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

    % Configure what we can for now. measure() will check to see if everything is configured later.
    if ~isempty(obj.Hardware) && obj.Hardware.isValid
        obj.configureHardwareCalibrationMode;
    end

    if ~isempty(obj.Configuration) && obj.Configuration.isValid
        obj.configureHardwareSignals;
    end

    if ~isempty(obj.InputMapping)
        obj.configureHardwareInputMapping;
    end

    if ~isempty(obj.OutputMapping)
        obj.configureHardwareOutputMapping;
    end

    %HACK(ALEX): LDAQ specific hacks
    if obj.Hardware.Type == bose.cnc.meas.HardwareType.ldaq
        obj.DeviceHandle.AutoPlot = false; % Otherwise, ldaq will display a plot after every measurement
        obj.DeviceHandle.Stabilizing = 0; % Otherwise, this would double the measurement length
        obj.DeviceHandle.hideInactiveChannels; % Useful for debugging
        obj.DeviceHandle.setAllOutputGains(0);
    end
end % function
