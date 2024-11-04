function [dataRecords, associationMatrix] = sliceStep(obj, stepSpecs)
    %SLICESTEP Returns a set of DataRecords that match the given StepName(s)/StepType(s).
    %
    %   Returns any DataRecord where the StepName or StepType match the given
    %   string. Multiple strings may be specified.
    %
    %Usage:
    %   dataRecords = dataRecords.sliceStep("Driver");
    %   [dataRecords, associationMatrix] = dataRecords.sliceStep("Driver");
    %   dataRecords = dataRecords.sliceStep(["Driver", "Coupling"]);
    %
    %Optional Positional Arguments:
    %   stepSpecs (string-like): A char, string(s), or cellstr(s) to match
    %       DataRecords to. If "all" is given, match all DataRecords. (Default:
    %       match all DataRecords)
    %
    %Returns:
    %   dataRecords (bose.cnc.meas.DataRecord): The subset of DataRecords that match
    %       at least one of the spec strings.
    %   associationMatrix (logical): A matrix whose rows represent the original
    %       input set of DataRecords, and whose columns represent the different spec
    %       strings. A true value in the matrix means that DataRecord matches that
    %       spec string.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.DataRecord.StepName,
    %   bose.cnc.meas.DataRecord.StepType

    % Alex Coleman
    % $Id$

    narginchk(1, 2)
    if nargin < 2
        stepSpecs = "all";
    end
    bose.common.validators.mustBeStringLike(stepSpecs);

    stringSpec = string(stepSpecs);
    numDataRecords = numel(obj);
    numStepSpecs = numel(stringSpec);
    stepNames = [obj.StepName]';
    stepTypes = [obj.StepType]';
    stepTypeNames = string(stepTypes);

    associationMatrix = false(numDataRecords, numStepSpecs);
    for indSpec = 1:numStepSpecs
        if strcmpi(stringSpec(indSpec), "all")
            associationMatrix(:, indSpec) = true(numDataRecords, 1);
        else
            % StepName & StepType
            associationMatrix(:, indSpec) = ( ...
                strcmpi(stringSpec(indSpec), stepNames) ...
                | strcmpi(stringSpec(indSpec), stepTypeNames) ...
            );
        end
    end % For every spec string

    % Return a set of DataRecords that match at least one of the spec strings.
    dataRecords = obj(max(associationMatrix, [], 2));
end % function
