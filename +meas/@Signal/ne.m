function results = ne(obj, comparisonObj)
    %NE (~=) Determine inequality for bose.cnc.meas.Signal objects.
    %
    %   results = ne(A, B);
    %   results = A ~= B;
    %
    %   A ~= B returns a logical array with elements set to logical 1 (true) where
    %   arrays A and B are not equal; otherwise, the element is logical 0 (false).
    %   Both objects must be the same size, or one must be a scalar.
    %
    %   A and B are not equal when...
    %       [A.Name] ~= [B.Name]
    %     | [A.Scale] ~= [B.Scale]
    %     | [A.Side] ~= [B.Side]
    %     | [A.Type] ~= [B.Type]
    %     | [A.Units] ~= [B.Units]
    %
    %See also: bose.cnc.meas.Signal, bose.cnc.meas.Signal.eq

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Signal:ne:';

    if isempty(obj) || isempty(comparisonObj)
        results = logical.empty;
    elseif ~isa(comparisonObj, 'bose.cnc.meas.Signal')
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be bose.cnc.meas.Signal.' ...
        );
    elseif numel(obj) == 1 || numel(comparisonObj) == 1 || isequal(size(obj), size(comparisonObj))
        tempResults = ...
            [obj.Name] ~= [comparisonObj.Name] | ...
            [obj.Scale] ~= [comparisonObj.Scale] | ...
            [obj.Side] ~= [comparisonObj.Side] | ...
            [obj.Type] ~= [comparisonObj.Type] | ...
            [obj.Units] ~= [comparisonObj.Units];
        results = reshape(tempResults, max(size(obj), size(comparisonObj)));
    else
        error( ...
            [idHeader 'InvalidInput'], ...
            'Both objects must be the same size, or one must be a scalar.' ...
        );
    end
end % ne
