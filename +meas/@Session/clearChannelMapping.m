function clearChannelMapping(obj)
    %CLEARCHANNELMAPPING Clear the Mapping between Channels and Signals.
    %
    %   Equivalent to
    %       session.InputMapping = bose.cnc.meas.Mapping.empty;
    %       session.OutputMapping = bose.cnc.meas.Mapping.empty;
    %
    %See also: bose.cnc.meas.Session, bose.cnc.meas.Session.validateMapping

    % Alex Coleman
    % $Id$

    obj.InputMapping = bose.cnc.meas.Mapping.empty;
    obj.OutputMapping = bose.cnc.meas.Mapping.empty;
end % function
