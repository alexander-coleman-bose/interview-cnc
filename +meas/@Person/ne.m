function results = ne(obj, comparisonObj)
    %NE (~=) Determine inequality for bose.cnc.meas.Person objects.
    %
    %   results = ne(A, B);
    %   results = A ~= B;
    %
    %   A ~= B returns a logical array with elements set to logical 1 (true) where
    %   arrays A and B are not equal; otherwise, the element is logical 0 (false).
    %   Both objects must be the same size, or one must be a scalar.
    %
    %   A and B are not equal when...
    %       [A.FirstName] ~= [B.FirstName]
    %     | [A.LastName] ~= [B.LastName]
    %
    %See also: bose.cnc.meas.Person, bose.cnc.meas.Person.eq

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Person:ne:';

    if isempty(obj) || isempty(comparisonObj)
        results = logical.empty;
    elseif ~isa(comparisonObj, 'bose.cnc.meas.Person')
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be bose.cnc.meas.Person.' ...
        );
    elseif numel(obj) == 1 || numel(comparisonObj) == 1 || isequal(size(obj), size(comparisonObj))
        tempResults = ...
            [obj.FirstName] ~= [comparisonObj.FirstName] | ...
            [obj.LastName] ~= [comparisonObj.LastName];
        results = reshape(tempResults, max(size(obj), size(comparisonObj)));
    else
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be the same size, or one must be a scalar.' ...
        );
    end
end % function
