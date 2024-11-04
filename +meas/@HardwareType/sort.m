function varargout = sort(obj, varargin)
    %SORT Sort HardwareTypes by string(HardwareType), ascending.
    %
    %   Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of HardwareTypes.
    %
    %       unsortedArray = test.cnc.setup.randomHardwareType(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of HeadphoneTypes and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomHardwareType(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.HardwareType, string.sort

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    typeNames = string(obj);
    [~, sortIndex] = sort(typeNames, varargin{:});

    sortedArray = obj(sortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, sortIndex};
    end
end
