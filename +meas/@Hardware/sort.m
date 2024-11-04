function varargout = sort(obj, varargin)
    %SORT Sort Hardware objects by Hardware.Name, ascending.
    %
    %   Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of Hardware objects.
    %
    %       unsortedArray = test.cnc.setup.randomHardware(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of Hardware objects and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomHardware(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.Hardware, string.sort

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    sizeObj = size(obj);

    deviceNames = reshape([obj.Name], sizeObj);
    [~, sortIndex] = sort(deviceNames, varargin{:});

    sortedArray = obj(sortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, sortIndex};
    end
end % function
