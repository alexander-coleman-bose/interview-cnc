function cellRows = toCellRow(obj)
    %TOCELLROW Convert bose.cnc.meas.Signal object(s) to cell array rows.
    %
    %Returns:
    %   cellRows (cell): A cell array where the number of rows is the number of
    %       Signals, and the columns are chars of Signal.Name, Signal.Side,
    %       Signal.Type, Output/Input, Signal.Scale, Signal.Units
    %
    %See also: bose.cnc.meas.Signal

    % Alex Coleman
    % $Id$

    % Return early if we don't have any signals, 0 signals X 6 columns
    if isempty(obj)
        cellRows = cell.empty(0, 6);
        return
    end

    % Signal Names
    signalNames = cellstr([obj.Name]');

    % Signal Sides
    signalSides = cellstr([obj.Side]');

    % Signal Types
    signalTypesObj = [obj.Type]';
    signalTypes = cellstr(signalTypesObj);

    % Channel Types
    channelTypesString = repmat("Input", numel(obj), 1);
    channelTypesString(signalTypesObj.isOutput) = deal("Output");
    channelTypes = cellstr(channelTypesString);

    % Scale
    signalScales = num2cell([obj.Scale]');

    % Units
    signalUnits = cellstr([obj.Units]');

    cellRows = [ ...
        signalNames, ...
        signalSides, ...
        signalTypes, ...
        channelTypes, ...
        signalScales, ...
        signalUnits ...
    ];
end % function
