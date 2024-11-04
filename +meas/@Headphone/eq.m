function results = eq(obj, comparisonObj)
    %EQ (==) Determine equality for bose.cnc.meas.Headphone objects.
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
    %
    %See also: bose.cnc.meas.Headphone, bose.cnc.meas.Headphone.ne

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Headphone:eq:';

    if isempty(obj) || isempty(comparisonObj)
        results = logical.empty;
    elseif ~isa(comparisonObj, 'bose.cnc.meas.Headphone')
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be bose.cnc.meas.Headphone,' ...
        );
    elseif numel(obj) == 1 || numel(comparisonObj) == 1 || isequal(size(obj), size(comparisonObj))
        tempResults = ...
            [obj.Name] == [comparisonObj.Name];
        results = reshape(tempResults, max(size(obj), size(comparisonObj)));
    else
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be the same size, or one must be a scalar.' ...
        );
    end
end % function
