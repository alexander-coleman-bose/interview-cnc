function [results, reasons] = isValid(obj)
    %ISVALID Returns true if the object is "Valid".
    %
    %AddedProperty is Valid if:
    %   ~strcmp(AddedProperty.Description, "")
    %
    %See also: bose.cnc.meas.AddedProperty

    % Alex Coleman
    % $Id$

    results = true(size(obj));
    reasons = cell(size(obj));
    for indObj = 1:numel(obj)
        if strcmp("", obj(indObj).Description)
            results(indObj) = false;
            reasons{indObj} = "AddedProperty.Description cannot be blank.";
        end
    end
end % isValid
