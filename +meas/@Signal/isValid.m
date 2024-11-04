function [results, reasons] = isValid(obj)
    %ISVALID Returns true if the object is "Valid".
    %
    %Signal is Valid if:
    %   Signal.Name is not ""
    % & Signal.Scale > 0
    % & umks(Signal.Units) doesn't error
    %
    %See also: bose.cnc.meas.Signal

    % Alex Coleman
    % $Id$

    results = true(size(obj));
    reasons = cell(size(obj));
    for indObj = 1:numel(obj)
        if strcmp("", obj(indObj).Name)
            results(indObj) = false;
            reasons{indObj} = "Signal.Name cannot be blank.";
        end
        if obj(indObj).Scale <= 0
            results(indObj) = false;
            reasons{indObj} = "Signal.Scale must be positive (> 0).";
        end
        [~, status] = umks(char(obj(indObj).Units));
        if ~isempty(status)
            results(indObj) = false;
            reasons{indObj} = string(status);
        end
    end
end % isValid
