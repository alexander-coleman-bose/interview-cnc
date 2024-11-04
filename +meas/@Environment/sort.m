function varargout = sort(obj, varargin)
    %SORT Sort Environments by Environment.Name, ascending.
    %
    %   Sorted by Environment.Name. Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of Environments.
    %
    %       unsortedArray = test.cnc.setup.randomEnvironment(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of Environments and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomEnvironment(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.Environment, string.sort,
    %   test.cnc.setup.randomEnvironment

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    sizeObj = size(obj);

    environmentNames = reshape([obj.Name], sizeObj);
    [~, sortIndex] = sort(environmentNames, varargin{:});

    sortedArray = obj(sortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, sortIndex};
    end
end % function
