function channels = findChannelBySignal(obj, signals)
    %FINDCHANNELSBYSIGNAL Returns a set of channel strings that match the given Signals.
    %
    %Usage:
    %   inputChannels = session.InputMapping.findChannelBySignal(thisStep.InputSignals);
    %
    %Required Positional Arguments:
    %   signals (bose.cnc.meas.Signal): The Signals to get mapped channels for.
    %
    %Returns:
    %   channels (string): Channel strings from the subset of Mappings that match
    %       the given Signals, in the order of the Signals.
    %
    %See also: bose.cnc.meas.Mapping, bose.cnc.meas.Signal

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Mapping:findChannelBySignal:';

    narginchk(2, 2);

    numSignals = numel(signals);
    channels = repmat(string, size(signals));
    allMappingSignals = [obj.Signal];
    for indSignal = 1:numSignals
        mappingMask = allMappingSignals == signals(indSignal);
        if sum(mappingMask) > 1
            error( ...
                [idHeader 'MultipleMappedChannels'], ...
                'This signal (%s) is mapped to more than one channel: %s', ...
                signals(indSignal).Name, ...
                strjoin([obj(mappingMask).Channel], ', ') ...
            );
        elseif sum(mappingMask) == 1
            channels(indSignal) = obj(mappingMask).Channel;
        end
    end % For every signal
end % function
