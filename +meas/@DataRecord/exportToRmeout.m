function rmeout = exportToRmeout(obj)
    %EXPORTTORMEOUT Export DataRecord object(s) into a struct of xduts (rmeout struct).
    %
    %Returns:
    %   rmeout (struct): A struct of xduts, where the field names of the rmeout
    %       struct correspond to the StepNames of the DataRecord(s).
    %
    %Errors:
    %   EmptySubject - When attempting to export some DataRecords with no Subject
    %       and some DataRecords with a Subject.
    %   MissingInputSignals - When attempting to export DataRecords with no
    %       InputSignals.
    %   InvalidXsData - When attempting to export DataRecords of the same StepType
    %       but with differently sized data.
    %   InvalidSignals - When attempting to export a DataRecord with multiple
    %       mapped Signals with the same SignalType.
    %   SideSignals - When the left and right sides do not have the same number of
    %       signals.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.DataRecord.xdut, xdut

    % Alex Coleman
    % $Id$

    narginchk(1, 1);

    % Initialize the rmeout struct
    rmeout = struct;
    % Get all StepTypeLabels
    allStepNames = [obj.StepName];
    stepNames = unique([obj.StepName]);
    % By StepName (struct dim)
    for indType = 1:numel(stepNames)
        stepTypeMask = allStepNames == stepNames(indType);
        dataRecordsThisType = obj(stepTypeMask);
        rmeout.(matlab.lang.makeValidName(stepNames(indType))) = xdut(dataRecordsThisType);
    end % for every StepName
end % function
