function resetSession(obj)
    %RESETSESSION Reset the session to an empty state.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %
    %See also: bose.cnc.meas.Session,
    %   bose.cnc.meas.Session.start

    % $Id$

    logger = bose.cnc.logging.getLogger;
    logger.debug('bose.cnc.meas.Session.resetSession function');

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            'bose:cnc:meas:Session:resetSession:NumelSession', ...
            ['Session.resetSession can only be run with a single ' ...
             'Session, not %s'], ...
            numel(obj) ...
        );
    end

    % Clear the Hardware first to delete the DeviceHandle
    obj.Hardware = bose.cnc.meas.Hardware.empty;

    % Clear all Public properties
    obj.Configuration = bose.cnc.meas.Configuration.empty;
    obj.Environment = bose.cnc.meas.Environment.empty;
    obj.InputMapping = bose.cnc.meas.Mapping.empty;
    obj.Operator = bose.cnc.meas.Person.empty;
    obj.OutputMapping = bose.cnc.meas.Mapping.empty;
    obj.Subject = bose.cnc.meas.Person.empty;
    obj.Headphone = bose.cnc.meas.Headphone.empty;

    % Clear remaining Private properties
    obj.CurrentFit = 1;
    obj.CurrentStepIndex = 1;
    obj.DataRecords = bose.cnc.meas.DataRecord.empty;
end % resetSession
