function varargout = sort(obj, varargin)
    %SORT Sort Headphones by Headphone.Name, ascending.
    %
    %   Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of Headphones.
    %
    %       unsortedArray = test.cnc.setup.randomHeadphone(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of Headphones and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomHeadphone(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.Headphone, string.sort

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
