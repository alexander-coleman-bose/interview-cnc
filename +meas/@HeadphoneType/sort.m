function varargout = sort(obj, varargin)
    %SORT Sort HeadphoneTypes by HeadphoneType.Name, ascending.
    %
    %   Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of HeadphoneTypes.
    %
    %       unsortedArray = test.cnc.setup.randomHeadphoneType(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of HeadphoneTypes and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomHeadphoneType(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.HeadphoneType, string.sort

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    sizeObj = size(obj);

    typeNames = reshape([obj.Name], sizeObj);
    [~, sortIndex] = sort(typeNames, varargin{:});

    sortedArray = obj(sortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, sortIndex};
    end
end
