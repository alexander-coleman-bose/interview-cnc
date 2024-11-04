function connectAndConfigure(obj)
    %CONNECTANDCONFIGURE Connect to and configure the measurement hardware device.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %
    %See also: bose.cnc.meas.Session

    % $Id$

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            'bose:cnc:meas:Session:connectAndConfigure:NumelSession', ...
            ['Session.connectAndConfigure can only be run with a ' ...
             'single Session, not %s'], ...
            numel(obj) ...
        );
    end

    %TODO: Should we check to see if the correct device is connected here?
    if ~obj.isDeviceConnected
        obj.connectHardware;
    end

    % configure LDAQ
    obj.configureHardware;
end % function
