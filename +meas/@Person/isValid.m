function [results, reasons] = isValid(obj)
    %ISVALID Returns true if the object is "Valid".
    %
    %Person is Valid if:
    %   ~strcmp(Person.LastName, "")
    %
    %See also: bose.cnc.meas.Person

    % Alex Coleman
    % $Id$

    results = true(size(obj));
    reasons = cell(size(obj));
    for indObj = 1:numel(obj)
        theseReasons = string.empty;

        % LastName cannot be blank
        if strcmp(obj(indObj).LastName, "")
            results(indObj) = false;
            thisReason = "Person.LastName cannot be blank.";
            theseReasons = [theseReasons; thisReason];
        end

        reasons{indObj} = theseReasons;
    end
end % isValid
