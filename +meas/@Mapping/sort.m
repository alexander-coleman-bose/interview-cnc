function varargout = sort(obj, varargin)
    %SORT Sort Mapping objects by Mapping.Channel, ascending.
    %
    %   Sorted by Mapping.Channel. Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of Mapping objects.
    %
    %       unsortedArray = test.cnc.setup.randomMapping(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of Mapping objects and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomMapping(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.Mapping, string.sort

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    sizeObj = size(obj);

    keyList = reshape([obj.Channel], sizeObj);
    [~, sortIndex] = sort(keyList, varargin{:});

    sortedArray = obj(sortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, sortIndex};
    end
end
