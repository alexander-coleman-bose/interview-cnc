function [associatedMetrics, associationMatrix] = findAssociatedMetrics(obj, stepAssociations)
    %FINDASSOCIATEDMETRICS Returns all unique associated Metrics for each DataRecord.
    %
    %   For each DataRecord, findAssociatedMetrics looks for StepAssociations that
    %   matches the StepName or StepType of that DataRecord (case insensitive) and
    %   returns the StepMetrics from the StepAssociations that matched.
    %
    %   If no stepAssociations are given, findAssociatedMetrics searches for
    %   StepAssociations in session.StepAssociations.
    %
    %Usage:
    %   associatedMetrics = dataRecords.findAssociatedMetrics;
    %   associatedMetrics = dataRecords.findAssociatedMetrics(stepAssociations);
    %   [associatedMetrics, associationMatrix] = dataRecords.findAssociatedMetrics;
    %
    %Optional Positional Arguments:
    %   stepAssociations (bose.cnc.metrics.StepAssociation): Find Metrics from these
    %       associations only. (Default: use session.StepAssociations)
    %
    %Returns:
    %   associatedMetrics (bose.cnc.metrics.StepMetric): The Metrics found for the
    %       given DataRecords.
    %   associationMatrix (logical): A logical mask matching the given DataRecords
    %       on the first dimension and associatedMetrics on the second dimension.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.metrics.StepAssociation,
    %   bose.cnc.meas.Session, bose.cnc.meas.DataRecord.sliceStep

    % Alex Coleman
    % $Id$

    %% Handle inputs
    narginchk(1, 2);
    if nargin < 2
        session = bose.cnc.meas.Session.start;
        stepAssociations = session.StepAssociations;
    end

    numDataRecords = numel(obj);

    % If we don't have any DataRecords or any StepAssociations, return early.
    if numDataRecords == 0 || numel(stepAssociations) == 0
        associatedMetrics = bose.cnc.metrics.StepMetric.empty;
        associationMatrix = logical.empty(numDataRecords, 0);
        return
    end

    %% Find matching metrics
    stepSpecs = [stepAssociations.StepSpec]'; % Nx1
    allMetrics = [stepAssociations.StepMetric]'; % Nx1
    [~, allMatrix] = obj.sliceStep(stepSpecs);

    % Find any Metric that matches at least one DataRecord
    associationMask = max(allMatrix, [], 1);
    fullAssociatedMetrics = allMetrics(associationMask);
    fullAssociationMatrix = allMatrix(:, associationMask);

    % Get unique metrics and the associated DataRecords. I use a custom loop
    %   rather than the StepMetric.unique method here so that I can also update
    %   the associationMatrix.
    associationMatrix = logical.empty(numDataRecords, 0);
    associatedMetrics = bose.cnc.metrics.StepMetric.empty;
    while ~isempty(fullAssociatedMetrics)
        % Find all of the same metric and merge columns
        sameMetricMask = fullAssociatedMetrics(1) == fullAssociatedMetrics; % Nx1
        mergedColumn = max(fullAssociationMatrix(:, sameMetricMask), [], 2);

        % Add the next unique Metric
        associationMatrix = [associationMatrix, mergedColumn];
        associatedMetrics = [associatedMetrics; fullAssociatedMetrics(1)];

        % Remove all copies of the next Metric
        fullAssociationMatrix(:, sameMetricMask) = [];
        fullAssociatedMetrics(sameMetricMask) = [];
    end % uniqueness loop
end % function
