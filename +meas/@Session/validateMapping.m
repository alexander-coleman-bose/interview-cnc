function validateMapping(obj)
    %VALIDATEMAPPING Remove any Mappings that have unmatched Channels/Signals.
    %
    %   If any Mapping has a Channel not in the Hardware, or a Signal not in the
    %   Configuration, drop it.
    %
    %See also: bose.cnc.meas.Session

    % Alex Coleman
    % $Id$

    % If Configuration or Hardware are empty, set Mappings to empty and return.
    if isempty(obj.Configuration) || isempty(obj.Hardware)
        obj.clearChannelMapping;
        return
    end

    % Remove any Mappings that have unmatched Signals or Channels
    if ~isempty(obj.InputMapping)
        inputSignals = [obj.InputMapping.Signal]';
        obj.InputMapping(~ismember(inputSignals, obj.Configuration.InputSignals)) = [];
    end
    if ~isempty(obj.InputMapping)
        inputChannels = [obj.InputMapping.Channel]';
        obj.InputMapping(~ismember(inputChannels, obj.Hardware.InputChannels)) = [];
    end
    if ~isempty(obj.OutputMapping)
        outputSignals = [obj.OutputMapping.Signal]';
        obj.OutputMapping(~ismember(outputSignals, obj.Configuration.OutputSignals)) = [];
    end
    if ~isempty(obj.OutputMapping)
        outputChannels = [obj.OutputMapping.Channel]';
        obj.OutputMapping(~ismember(outputChannels, obj.Hardware.OutputChannels)) = [];
    end
end % function
