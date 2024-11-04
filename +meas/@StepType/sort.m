function varargout = sort(obj, varargin)
    %SORT Sort StepTypes by string(StepType), ascending.
    %
    %   Sorted by string(StepType). Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of StepTypes.
    %
    %       unsortedArray = test.cnc.setup.randomStepType(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of StepTypes and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomStepType(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.StepType, string.sort, test.cnc.setup.randomStepType

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    sizeObj = size(obj);

    stepTypes = reshape(string(obj), sizeObj);
    [~, sortIndex] = sort(stepTypes, varargin{:});

    sortedArray = obj(sortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, sortIndex};
    end
end % function
