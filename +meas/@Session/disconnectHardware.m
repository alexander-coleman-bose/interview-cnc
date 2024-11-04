function disconnectHardware(obj)
    %DISCONNECTHARDWARE Disconnect & delete any measurement hardware device.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %
    %See also: bose.cnc.meas.Session,
    %   bose.cnc.meas.Session.connectHardware

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Session:disconnectHardware:';

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            [idHeader 'NumelSession'], ...
            ['Session.disconnectHardware can only be run with a single ' ...
             'Session, not %s'], ...
            numel(obj) ...
        );
    end

    if ~isempty(obj.DeviceHandle) && bose.cnc.validators.isDeviceHandle(obj.DeviceHandle)
        delete(obj.DeviceHandle);
    end
    obj.DeviceHandle = [];
end % function
