function channelSignalMatrix = makeChannelSignalMatrix(obj, channels, signals)
    %MAKECHANNELSIGNALMATRIX Make a logical matrix of Mappings from Channels to Signals.
    %
    %Usage:
    %   channelSignalMatrix = session.InputMapping.makeChannelSignalMatrix(session.Hardware.InputChannels, session.Configuration.InputSignals);
    %
    %Required Positional Arguments:
    %   channels (string): String array of Channel names.
    %   signals (bose.cnc.meas.Signal): Array of Signals.
    %
    %Returns:
    %   channelSignalMatrix (logical): Matrix of size NxM, where N is the number of
    %       Channels, and M is the number of Signals. A true value means that
    %       Channel is mapped to that Signal.
    %
    %See also: bose.cnc.meas.Mapping, bose.cnc.meas.Signal,
    %   bose.cnc.meas.Mapping.fromChannelSignalMatrix

    % Alex Coleman
    % $Id$

    narginchk(3, 3);

    numChannels = numel(channels);
    numSignals = numel(signals);
    channelSignalMatrix = false(numChannels, numSignals);
    for indMapping = 1:numel(obj)
        channelSignalMatrix( ...
            channels == obj(indMapping).Channel, ...
            signals == obj(indMapping).Signal ...
        ) = true;
    end
end % function
