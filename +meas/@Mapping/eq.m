function results = eq(obj, comparisonObj)
    %EQ (==) Determine equality for bose.cnc.meas.Mapping objects.
    %
    %   results = eq(A, B);
    %   results = A == B;
    %
    %   A == B returns a logical array with elements set to logical 1 (true)
    %   where arrays A and B are equal; otherwise, the element is logical 0
    %   (false). Both objects must be the same size, or one must be a scalar.
    %
    %   A and B are equal when...
    %       [A.Channel] == [B.Channel]
    %     & [A.Signal] == [B.Signal]
    %
    %See also: bose.cnc.meas.Mapping, bose.cnc.meas.Mapping.ne

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Mapping:eq:';

    if isempty(obj) || isempty(comparisonObj)
        results = logical.empty;
    elseif ~isa(comparisonObj, 'bose.cnc.meas.Mapping')
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be bose.cnc.meas.Mapping,' ...
        );
    elseif numel(obj) == 1 || numel(comparisonObj) == 1 || all(size(obj) == size(comparisonObj))
        tempResults = ...
            [obj.Channel] == [comparisonObj.Channel] & ...
            [obj.Signal] == [comparisonObj.Signal];
        results = reshape(tempResults, max(size(obj), size(comparisonObj)));
    else
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be the same size, or one must be a scalar.' ...
        );
    end
end % eq
