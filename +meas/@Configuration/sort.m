function varargout = sort(obj, varargin)
    %SORT Sort Configurations by Configuration.Name.
    %
    %   First, sort by Configuration.Name, ascending.
    %
    %   Additional inputs are passed to string.sort.
    %
    %Usage:
    %   Sort an array of Configurations.
    %
    %       unsortedArray = test.cnc.setup.randomConfiguration(10);
    %       sortedArray = unsortedArray.sort;
    %
    %   Sort an array of Configurations and return the sorting index.
    %
    %       unsortedArray = test.cnc.setup.randomConfiguration(10);
    %       [sortedArray, sortingIndex] = unsortedArray.sort;
    %
    %See also: bose.cnc.meas.Configuration, string.sort,
    %   test.cnc.setup.randomConfiguration

    % Alex Coleman
    % $Id$

    nargoutchk(0, 2);

    sizeObj = size(obj);

    configurationNames = reshape([obj.Name], sizeObj);
    [~, nameSortIndex] = sort(configurationNames, varargin{:});
    sortedArray = obj(nameSortIndex);

    if nargout < 2
        varargout = {sortedArray};
    else
        varargout = {sortedArray, nameSortIndex};
    end
end % function
