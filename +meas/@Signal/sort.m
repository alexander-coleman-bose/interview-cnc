function varargout = sort(obj, varargin)
    %SORT Sort Signals by Signal.Name, ascending.
    %
    %   Sorted by Signal.Name. Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of Signals.
    %
    %       unsortedArray = test.cnc.setup.randomSignal(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of Signals and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomSignal(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.Signal, string.sort, test.cnc.setup.randomSignal

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    sizeObj = size(obj);

    signalNames = reshape([obj.Name], sizeObj);
    [~, sortIndex] = sort(signalNames, varargin{:});

    sortedArray = obj(sortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, sortIndex};
    end
end % function
