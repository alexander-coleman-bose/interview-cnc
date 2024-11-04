function connectHardware(obj)
    %CONNECTHARDWARE Connects to a measurement hardware device.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %   DeviceAlreadyConnected - When a measurement Hardware device is already connected.
    %   NoHardwareConfiguration - When no Hardware is loaded in the Session.
    %   InvalidType - When a HardwareType other than ldaq is specified.
    %
    %See also: bose.cnc.meas.Session

    %TODO(ALEX): Should there be a "disconnect" method as well?

    idHeader = 'bose:cnc:meas:Session:connectHardware:';

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            [idHeader 'NumelSession'], ...
            ['Session.connectHardware can only be run with a single ' ...
             'Session, not %s'], ...
            numel(obj) ...
        );
    end

    if obj.isDeviceConnected
        warning( ...
            [idHeader 'DeviceAlreadyConnected'], ...
            'A measurement hardware device is already connected.' ...
        );
    end

    % Check for Hardware
    if isempty(obj.Hardware)
        error( ...
            [idHeader 'NoHardwareConfiguration'], ...
            'Connection failed: Session.Hardware cannot be empty.' ...
        );
    end

    %HACK(ALEX): Right now, only ldaq is supported.
    % Check obj.Hardware.Type to be a bose.cnc.meas.HardwareType.ldaq.
    if obj.Hardware.Type == bose.cnc.meas.HardwareType.ldaq
        warnStruct = warning('off', 'MATLAB:class:PropUsingAtSyntax');
        try
            % Connect to hardware, prefer ConnectionParameters, then DeviceName
            if ~isempty(obj.Hardware.ConnectionParameters) && ~all(strcmp(obj.Hardware.ConnectionParameters, ""))
                connectionParameters = cellstr(obj.Hardware.ConnectionParameters);
            else
                connectionParameters = cellstr(obj.Hardware.DeviceName);
            end
            obj.DeviceHandle = ldaq(connectionParameters{:});
        catch ME
            warning(warnStruct);
            newError = MException( ...
                [idHeader 'CouldNotConnect'], ...
                'Could not connect to the Hardware (%s)', ...
                connectionParameters{1} ...
            );
            newError = newError.addCause(ME);
            throw(newError);
        end
        warning(warnStruct);
    else
        error( ...
            [idHeader 'InvalidType'], ...
            'Types other than ldaq are not supported by this version of Session.' ...
        );
    end
end % connectHardware
