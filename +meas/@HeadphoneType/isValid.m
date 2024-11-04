function [results, reasons] = isValid(obj)
    %ISVALID Returns true if the object is "Valid".
    %
    %HeadphoneType is Valid if:
    %   ~strcmp(HeadphoneType.Name, "")
    %
    %See also: bose.cnc.meas.HeadphoneType

    % Alex Coleman
    % $Id$

    results = true(size(obj));
    reasons = cell(size(obj));
    for indObj = 1:numel(obj)
        theseReasons = string.empty;

        % Name cannot be blank
        if strcmp(obj(indObj).Name, "")
            results(indObj) = false;
            thisReason = "HeadphoneType.Name cannot be blank.";
            theseReasons = [theseReasons; thisReason];
        end
    end % for every obj
end % isValid
