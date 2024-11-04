function results = eq(obj, comparisonObj)
    %EQ (==) Determine equality for bose.cnc.meas.Environment objects.
    %
    %   results = eq(A, B);
    %   results = A == B;
    %
    %   A == B returns a logical array with elements set to logical 1 (true)
    %   where arrays A and B are equal; otherwise, the element is logical 0
    %   (false). Both objects must be the same size, or one must be a scalar.
    %
    %   A and B are equal when...
    %       [A.Name] == [B.Name]
    %     & [A.Description] == [B.Description]
    %
    %See also: bose.cnc.meas.Environment, bose.cnc.meas.Environment.ne

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Environment:eq:';

    if isempty(obj) || isempty(comparisonObj)
        results = logical.empty;
    elseif ~isa(comparisonObj, 'bose.cnc.meas.Environment')
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be bose.cnc.meas.Environment.' ...
        );
    elseif numel(obj) == 1 || numel(comparisonObj) == 1 || isequal(size(obj), size(comparisonObj))
        tempResults = ...
            [obj.Name] == [comparisonObj.Name] & ...
            [obj.Description] == [comparisonObj.Description];
        results = reshape(tempResults, max(size(obj), size(comparisonObj)));
    else
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be the same size, or one must be a scalar.' ...
        );
    end
end % eq
