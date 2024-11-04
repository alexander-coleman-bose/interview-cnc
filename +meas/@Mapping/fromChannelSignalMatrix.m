function obj = fromChannelSignalMatrix(channelSignalMatrix, channels, signals)
    %FROMCHANNELSIGNALMATRIX Generate Mappings based on a logical matrix of Channels vs. Signals.
    %
    %Usage:
    %   mappings = bose.cnc.meas.Mapping.fromChannelSignalMatrix(channelSignalMatrix, session.Hardware.InputChannels, session.Configuration.InputSignals);
    %
    %Required Positional Arguments:
    %   channelSignalMatrix (logical): Matrix of Channels vs. Signals, a true value
    %       indicates that Channel mapped to that Signal.
    %   channels (string): String array of Channel names.
    %   signals (bose.cnc.meas.Signal): Array of Signals.
    %
    %Returns:
    %   obj (bose.cnc.meas.Mapping): Array of bose.cnc.meas.Mapping objects.
    %
    %See also: bose.cnc.meas.Mapping, bose.cnc.meas.Signal,
    %   bose.cnc.meas.Mapping.makeChannelSignalMatrix

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Mapping:fromChannelSignalMatrix:';
    narginchk(3, 3);

    numChannels = numel(channels);
    numSignals = numel(signals);
    if size(channelSignalMatrix, 1) ~= numChannels || size(channelSignalMatrix, 2) ~= numSignals
        error( ...
            [idHeader 'InvalidInput'], ...
            [ ...
                'The size of the channelSignalMatrix must be the number of ' ...
                'Channels (%.0f) by the number of Signals (%.0f), not ' ...
                '(%.0f x %.0f).' ...
            ], ...
            numChannels, ...
            numSignals, ...
            size(channelSignalMatrix, 1), ...
            size(channelSignalMatrix, 2) ...
        );
    end

    obj = bose.cnc.meas.Mapping.empty;
    for indChannel = 1:numel(channels)
        if any(channelSignalMatrix(indChannel, :))
            if(length(signals(channelSignalMatrix(indChannel,:))) > 1)
                error('bose:cnc:meas:mapping:fromChannelSignalMatrix:duplicateSignals',...
                      'It appears that hw channel %s is labeleld as %i signals, please ensure each hw channel is labeled only as a single signal.',...
                      channels(indChannel),length(signals(channelSignalMatrix(indChannel,:))))
            end            
            thisMapping = bose.cnc.meas.Mapping( ...
                'Channel', channels(indChannel), ...
                'Signal', signals(channelSignalMatrix(indChannel,:)) ...
            );
            obj = [obj; thisMapping];
        end
    end
end % function
