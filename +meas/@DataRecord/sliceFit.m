function [dataRecords, associationMatrix] = sliceFit(obj, fitNums)
    %SLICEFIT Returns a set of DataRecords that match the given Fit number.
    %
    %   Returns any DataRecord where the Fit matches the given number(s).
    %
    %Usage:
    %   dataRecords = dataRecords.sliceFit(1);
    %   [dataRecords, associationMatrix] = dataRecords.sliceFit(2);
    %   dataRecords = dataRecords.sliceFit(1:10);
    %
    %Optional Positional Arguments:
    %   fitNums (double): The fit number to match DataRecords with. (Default: match
    %       all Fits)
    %
    %Returns:
    %   dataRecords (bose.cnc.meas.DataRecord): The subset of DataRecords that match
    %       at least one of the Fit numbers.
    %   associationMatrix (logical): A matrix whose rows represent the original
    %       input set of DataRecords, and whose columns represent the different fit
    %       numbers. A true value in the matrix means that DataRecord matches that
    %       fit number.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.DataRecord.Fit

    % Alex Coleman
    % $Id$

    narginchk(1, 2)
    if nargin < 2
        fitNums = unique([obj.Fit]');
    else
        mustBeNumeric(fitNums);
    end

    numDataRecords = numel(obj);
    numFitNums = numel(fitNums);
    allFitNums = [obj.Fit]';

    associationMatrix = false(numDataRecords, numFitNums);
    for indFit = 1:numFitNums
        associationMatrix(:, indFit) = allFitNums == fitNums(indFit);
    end % For every spec string

    % Return a set of DataRecords that match at least one of the spec strings.
    dataRecords = obj(max(associationMatrix, [], 2));
end % function
