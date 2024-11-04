function [results, reasons] = isValid(obj)
    %ISVALID Returns true if the object is "Valid".
    %
    %SignalParameters is Valid if:
    %   NOverlap < Nfft
    %
    %See also: bose.cnc.meas.SignalParameters

    % Alex Coleman
    % $Id$

    results = true(size(obj));
    reasons = cell(size(obj));
    for indObj = 1:numel(obj)
        if obj(indObj).NOverlap >= obj(indObj).Nfft
            results(indObj) = false;
            reasons{indObj} = sprintf( ...
                "SignalParameters cannot have NOverlap (%.0f) >= Nfft " + ...
                "(%.0f).", ...
                obj(indObj).NOverlap, ...
                obj(indObj).Nfft ...
            );
        end
    end
end % isValid
