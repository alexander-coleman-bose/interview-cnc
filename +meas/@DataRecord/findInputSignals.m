function signalMasks = findInputSignals(obj, varargin)
    %FINDINPUTSIGNALS Match the SignalStrings to DataRecord.InputSignals.
    %
    %   Attempts to match the signalStrings to first the Signal.Name, then the
    %   SignalType of the InputSignals. Case insensitive.
    %
    %Optional Argument:
    %   signalStrings (string): Strings to match to Signals Names/Types, "" matches all signals. (Default: "")
    %
    %Returns:
    %   signalMasks (logical): Logical mask of size [N X], where N is the number of
    %       InputSignals, and X is the number of strings that were matched.
    %
    %See also: bose.cnc.meas.DataRecord

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:DataRecord:findInputSignals:';

    % Check to make sure that we only have a single DataRecord
    if numel(obj) ~= 1
        error( ...
            [idHeader 'InvalidInput'], ...
            'DataRecord.findInputSignals can only be run on a single DataRecord.' ...
        );
    end

    parser = inputParser;
    parser.addOptional('signalStrings', "", @bose.common.validators.mustBeStringLike);
    parser.parse(varargin{:});
    signalStrings = string(parser.Results.signalStrings);

    % Check if we have the required signals by Signal.Name, SignalType, and use
    %   all signals if SignalString is ""
    inputSignals = obj.InputSignals;
    nameArray = [inputSignals.Name]';
    typeArray = string([inputSignals.Type]');
    signalMasks = false(numel(inputSignals), numel(signalStrings));

    for indString = 1:numel(signalStrings)
        % 1. Signal.Name or "" for all signals
        if strcmp(signalStrings(indString), string)
            signalMasks(:, indString) = true(size(inputSignals));
        else
            signalMasks(:, indString) = strcmpi(nameArray, signalStrings(indString));
        end

        % 2. SignalType
        if sum(signalMasks(:, indString)) == 0
            signalMasks(:, indString) = strcmpi(typeArray, signalStrings(indString));
        end
    end % For every string to match
end % findInputSignals
