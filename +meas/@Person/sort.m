function varargout = sort(obj, varargin)
    %SORT Sort Person objects by Person.LastName, ascending.
    %
    %   Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of Person objects.
    %
    %       unsortedArray = test.cnc.setup.randomPerson(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of Person objects and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomPerson(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.Person, string.sort

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    sizeObj = size(obj);

    typeNames = reshape([obj.LastName], sizeObj);
    [~, sortIndex] = sort(typeNames, varargin{:});

    sortedArray = obj(sortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, sortIndex};
    end
end
