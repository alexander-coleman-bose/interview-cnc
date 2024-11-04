function [fh, ah] = plotMetrics(obj, stepMetrics, associationMatrix)
    %PLOTMETRICS Plots the given StepMetrics calculated for these DataRecords.
    %
    %Usage:
    %   [stepMetrics, associationMatrix] = dataRecords.findAssociatedMetrics;
    %   dataRecords.plotMetrics(stepMetrics, associationMatrix);
    %   fh = dataRecords.plotMetrics(stepMetrics, associationMatrix);
    %   [fh, ah] = dataRecords.plotMetrics(stepMetrics, associationMatrix);
    %
    %Required Positional Arguments:
    %   stepMetrics (bose.cnc.metrics.StepMetric): The Metrics to be plotted.
    %
    %Optional Positional Arguments:
    %   associationMatrix (logical): A logical matrix matching DataRecords along the
    %       first dimension, and the StepMetrics along the second dimension.
    %       (Default: all Metrics for all DataRecords)
    %
    %Optional Returns:
    %   fh (matlab.ui.Figure): Figure handles to the generated plots, one for each
    %       StepMetric.
    %   ah (matlab.graphics.axis.Axes or matlab.graphics.Graphics): Axes handles or
    %       placeholder objects, with the first column containing handles to the
    %       Magnitude plots, and the second column containing handles to the Phase
    %       plots or a placeholder if the StepMetric has no Phase.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.Session,
    %   bose.cnc.meas.DataRecord.plotAssociatedMetrics,

    % Alex Coleman
    % $Id$

    %% Handle inputs
    narginchk(2, 3);
    if nargin < 2
        associationMatrix = true(numel(obj, numel(stepMetrics)));
    end

    % Calculate & Plot the StepMetrics. We loop over the Metrics so that we only
    %   plot Metrics that have been directly associated with the DataRecords
    %   instead of plotting all Metrics for all DataRecords. One figure per
    %   StepMetric.
    fh = gobjects(numel(stepMetrics), 1);
    ah = gobjects(numel(stepMetrics), 2); % The second dim is Mag/Phase, even if Phase is empty
    for indMetric = 1:numel(stepMetrics)
        thisMetric = stepMetrics(indMetric);
        metricStruct = obj(associationMatrix(:, indMetric)).calculate(thisMetric);
        fh(indMetric) = figure( ...
            'HandleVisibility', 'callback', ... Cannot be targetted by gca or findobj
            'IntegerHandle', false, ...
            'Name', string(thisMetric.Name), ...
            'NumberTitle', false, ...
            'Visible', false ...
        );

        if thisMetric.Type.IsPowerQuantity
            subplotIndex = [1 1 1];
            [ah(indMetric, 1), ~] = local_plotMagnitude(fh(indMetric), subplotIndex, metricStruct);
        else
            subplotIndex = [2 1 1];
            [ah(indMetric, 1), ~] = local_plotMagnitude(fh(indMetric), subplotIndex, metricStruct);
            xlabel(ah(indMetric, 1), ''); % plotMagnitude adds an xlabel, so remove it here.

            subplotIndex = [2 1 2];
            [ah(indMetric, 2), ~] = local_plotPhase(fh(indMetric), subplotIndex, metricStruct);

            linkaxes(ah(indMetric, 1:2), 'x');
        end

        fh(indMetric).Visible = true;
    end % For every metric
end % function

function [ah, lh] = local_plotMagnitude(fh, subplotIndex, metricStruct)
    % Constants
    XSCALE = 'log';
    XLIM = [10, 24e3];
    XGRID = true;
    YGRID = true;

    % Create the axis
    ah = subplot( ...
        subplotIndex(1), subplotIndex(2), subplotIndex(3), 'align', ...
        'Parent', fh, ...
        'XScale', XSCALE, ...
        'XLim', XLIM, ...
        'XGrid', XGRID, ...
        'Ygrid', YGRID ...
    );
    xlabel(ah, 'Frequency [Hz]');
    ylabel(ah, 'Magnitude [dB]');

    % Plot
    %HACK(ALEX): colororder() introduced in R2019b
    % colorOrder = colororder(ah);
    colorOrder = get(ah, 'ColorOrder');
    numColors = size(colorOrder, 1);
    for indData = 1:numel(metricStruct)
        numEl = numel(metricStruct(indData).magnitudeData);
        numFreq = size(metricStruct(indData).freqVector, 1);
        numSignals = numEl/numFreq;
        % Collapse from 3D (Freq x SigA x SigB) to 2D (Freq x SigAB)
        collapsedData = reshape(metricStruct(indData).magnitudeData, numFreq, numSignals);
        line( ...
            ah, ...
            metricStruct(indData).freqVector, collapsedData, ...
            'Color', colorOrder(mod(indData, numColors)+1, :) ...
        );
    end
    lh = ah.Children;
end

function [ah, lh] = local_plotPhase(fh, subplotIndex, metricStruct)
    % Constants
    XSCALE = 'log';
    XLIM = [10, 24e3];
    % YLIM is not set because unwrapped phase would go past -180:180.
    XGRID = true;
    YGRID = true;

    % Create the axis
    ah = subplot( ...
        subplotIndex(1), subplotIndex(2), subplotIndex(3), 'align', ...
        'Parent', fh, ...
        'XScale', XSCALE, ...
        'XLim', XLIM, ...
        'XGrid', XGRID, ...
        'Ygrid', YGRID ...
    );
    xlabel(ah, 'Frequency [Hz]');
    ylabel(ah, 'Phase [degrees]');

    % Plot
    %HACK(ALEX): colororder() introduced in R2019b
    % colorOrder = colororder(ah);
    colorOrder = get(ah, 'ColorOrder');
    numColors = size(colorOrder, 1);
    for indData = 1:numel(metricStruct)
        numEl = numel(metricStruct(indData).phaseData);
        numFreq = size(metricStruct(indData).freqVector, 1);
        numSignals = numEl/numFreq;
        collapsedData = reshape(metricStruct(indData).phaseData, numFreq, numSignals);
        line( ...
            ah, ...
            metricStruct(indData).freqVector, collapsedData, ...
            'Color', colorOrder(mod(indData, numColors)+1, :) ...
        );
    end
    lh = ah.Children;
end
