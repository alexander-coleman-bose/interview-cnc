function [fh, ah] = plotAssociatedMetrics(obj)
    %PLOTASSOCIATEDMETRICS Plots StepMetrics associated with these DataRecords from Session.StepAssociations.
    %
    %   This function is a placeholder for a more customizable plotting interface.
    %
    %Usage:
    %   dataRecords.plotAssociatedMetrics;
    %   fh = dataRecords.plotAssociatedMetrics;
    %   [fh, ah] = dataRecords.plotAssociatedMetrics;
    %
    %Optional Returns:
    %   fh (matlab.ui.Figure): Figure handles to the generated plots, one for each
    %       StepMetric.
    %   ah (matlab.graphics.axis.Axes or matlab.graphics.Graphics): Axes handles or
    %       placeholder objects, with the first column containing handles to the
    %       Magnitude plots, and the second column containing handles to the Phase
    %       plots or a placeholder if the StepMetric has no Phase.
    %
    %See also: bose.cnc.meas.DataRecord,
    %   bose.cnc.meas.DataRecord.findAssociatedMetrics,
    %   bose.cnc.meas.DataRecord.plotMetrics, bose.cnc.meas.Session

    % Alex Coleman
    % $Id$

    % Get all unique metrics associated with the provided DataRecords through the meas.Session.
    [uniqueMetrics, associationMatrix] = obj.findAssociatedMetrics;

    % Calculate & Plot using plotMetrics
    [fh, ah] = obj.plotMetrics(uniqueMetrics, associationMatrix);
end % function
