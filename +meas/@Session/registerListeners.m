function listeners = registerListeners(obj)
    %REGISTERLISTENERS Register Pre/Post measurement event listeners to the Session.
    %
    %   This function will register the function "sessionListener" as a callback
    %   to the pre/post measurement events if that function exists. An example of a
    %   "sessionListener" file can be found at bose.cnc.examples.sessionListener.
    %
    %Returns:
    %   listeners (event.listener): A vector of the three listener objects
    %       (pre-meas, post-meas, post-save)
    %
    %See also: bose.cnc.meas.Session, bose.cnc.examples.sessionListener

    % Alex Coleman
    % $Id$

    logger = bose.cnc.logging.getLogger;
    logger.debug('bose.cnc.meas.Session.registerListeners start');

    listeners = event.listener.empty;

    if isempty(which('sessionListener'))
        logger.debug('sessionListener function not found, no listeners created.');
        return
    end

    % This callback is run during Session.measure, after validation and
    %   immediately prior to the actual measurement
    listeners = [ ...
        listeners; ...
        obj.addlistener('PreMeasurement', @sessionListener) ...
    ];

    % This callback is run during Session.measure, immediately after the actual
    %   measurement
    listeners = [ ...
        listeners; ...
        obj.addlistener('PostMeasurement', @sessionListener) ...
    ];

    % This callback is run during Session.measure, after the measurement has
    %   been stored as a DataRecord and saved to file
    listeners = [ ...
        listeners; ...
        obj.addlistener('PostMeasurementSave', @sessionListener) ...
    ];
end % function
