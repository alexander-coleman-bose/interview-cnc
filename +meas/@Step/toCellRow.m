function cellRows = toCellRow(obj)
    %TOCELLROW Convert bose.cnc.meas.Step object(s) to cell array rows.
    %
    %Returns:
    %   cellRows (cell): A cell array where the number of rows is the number of
    %       Steps, and the columns are Step.Name (char), Step.Type (char),
    %       LoopOverFits (logical), Step.ExcitationGain (double),
    %       Step.ExcitationFilters (double) Step.ExcitationType (char),
    %       Signals (char), Sample Rate (char), Time Envelope (char), Window
    %       (char), NFFT (uint32), NOverlap (uint32), SaveTimeData (logical)
    %
    %See also: bose.cnc.meas.Signal

    % Alex Coleman
    % $Id$

    % Return early if we don't have any signals, 0 signals X 13 columns
    if isempty(obj)
        cellRows = cell.empty(0, 13);
        return
    end

    % Step Names
    stepNames = cellstr([obj.Name]');

    % Step Types
    stepTypes = cellstr([obj.Type]');

    % Loop Over Fits
    loopOverFits = num2cell([obj.LoopOverFits]');

    % Output Gain
    outputGains = {obj.ExcitationGain}';

    % Out. Type
    outputTypes = cellstr([obj.ExcitationType]');

    % Save Time Data
    saveTimeData = num2cell([obj.SaveTimeData]');

    % SignalParameters - Fs, Window, Nfft, NOverlap, Time Envelope
    signalParameterSets = [obj.SignalParameters]';
    sampleRates = {signalParameterSets.Fs}';
    windowStrings = cellstr([signalParameterSets.Window]');
    nffts = {signalParameterSets.Nfft}';
    nOverlaps = {signalParameterSets.NOverlap}';
    timeStrings = arrayfun( ...
        @(x) sprintf( ...
            'U:%g P:%g R:%g D:%g', ...
            x.TUp, ...
            x.TPrerun, ...
            x.TRecord, ...
            x.TDown ...
        ), ...
        signalParameterSets, ...
        'UniformOutput', false ...
    );

    % Out Filters and Signals - per Step
    outputFilters = cell(numel(obj), 1);
    signalStrings = cell(numel(obj), 1);
    for indStep = 1:numel(obj)
        % Out. Filter - per Step
        theseFilters = obj(indStep).ExcitationFilters;
        if isempty(theseFilters)
            outputFilters{indStep} = 'empty';
        else
            outputFilters{indStep} = sprintf( ...
                '%.0fx%.0f biquads', ...
                size(theseFilters, 1), ...
                size(theseFilters, 3) ...
            );
        end

        % Signals - per Step
        if isempty(obj(indStep).InputSignals)
            inputSignalString = 'none';
        else
            inputSignalTypes = [obj(indStep).InputSignals.Type]';
            inputSignalString = sprintf('%s', inputSignalTypes.Label);
        end
        if isempty(obj(indStep).OutputSignals)
            outputSignalString = 'none';
        else
            outputSignalTypes = [obj(indStep).OutputSignals.Type]';
            outputSignalString = sprintf('%s', outputSignalTypes.Label);
        end
        signalStrings{indStep} = sprintf( ...
            'I:%s O:%s', ...
            inputSignalString, ...
            outputSignalString ...
        );
    end

    cellRows = [ ...
        stepNames, ...
        stepTypes, ...
        loopOverFits, ...
        outputGains, ...
        outputFilters, ...
        outputTypes, ...
        signalStrings, ...
        sampleRates, ...
        timeStrings, ...
        windowStrings, ...
        nffts, ...
        nOverlaps, ...
        saveTimeData, ...
    ];
end % function
