function results = eq(obj, comparisonObj)
    %EQ (==) Determine equality for bose.cnc.meas.HeadphoneType objects.
    %
    %   results = eq(A, B);
    %   results = A == B;
    %
    %   A == B returns a logical array with elements set to logical 1 (true)
    %   where arrays A and B are equal; otherwise, the element is logical 0
    %   (false). Both objects must be the same size, or one must be a scalar.
    %
    %   A and B are equal when...
    %       [A.FormFactor] == [B.FormFactor]
    %     & [A.Name] == [B.Name]
    %     & [A.Parent] == [B.Parent]
    %     & [A.Project] == [B.Project]
    %
    %See also: bose.cnc.meas.HeadphoneType

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:HeadphoneType:eq:';

    if isempty(obj) || isempty(comparisonObj)
        results = logical.empty;
    elseif ~isa(comparisonObj, 'bose.cnc.meas.HeadphoneType')
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be bose.cnc.meas.HeadphoneType,' ...
        );
    elseif numel(obj) == 1 || numel(comparisonObj) == 1 || all(size(obj) == size(comparisonObj))
        tempResults = ...
            [obj.FormFactor] == [comparisonObj.FormFactor] & ...
            [obj.Name] == [comparisonObj.Name] & ...
            [obj.Parent] == [comparisonObj.Parent] & ...
            [obj.Project] == [comparisonObj.Project];
        results = reshape(tempResults, max(size(obj), size(comparisonObj)));
    else
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be the same size, or one must be a scalar.' ...
        );
    end
end % eq
