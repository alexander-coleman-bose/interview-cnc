function [results, reasons] = isValid(obj)
    %ISVALID Returns true if the object is "Valid".
    %
    %Headphone is Valid if:
    %   all(Headphone.AdditionalProperties.isValid)
    % & all(Headphone.InputSignals.isValid)
    % & Headphone.ManufactureDate ~= datetime(0, 'ConvertFrom', 'epochtime')
    % & ~strcmp(Headphone.Name, "")
    % & all(Headphone.OutputSignals.isValid)
    % & Headphone.Type.isValid
    %
    %See also: bose.cnc.meas.Headphone

    % Alex Coleman
    % $Id$

    results = true(size(obj));
    reasons = cell(size(obj));
    for indObj = 1:numel(obj)
        theseReasons = string.empty;

        % AdditionalProperties must be valid
        [tfProperties, reasonsProperties] = obj(indObj).AdditionalProperties.isValid;
        if ~all(tfProperties)
            results(indObj) = false;
            addedProperties = [obj(indObj).AdditionalProperties]';
            thisReason = sprintf( ...
                "This Headphone (%s) has invalid Additional Properties (%s): %s", ...
                obj(indObj).Name, ...
                strjoin([addedProperties.Description], ", "), ...
                strjoin([reasonsProperties{~tfProperties}], " ") ...
            );
            theseReasons = [theseReasons; thisReason];
        end

        % ManufactureDate must be non-default
        if obj(indObj).ManufactureDate == datetime(0, 'ConvertFrom', 'epochtime')
            results(indObj) = false;
            thisReason = sprintf( ...
                "This Headphone (%s) doesn't have ManufactureDate set.", ...
                obj(indObj).Name ...
            );
            theseReasons = [theseReasons; thisReason];
        end

        % Name cannot be blank
        if strcmp(obj(indObj).Name, "")
            results(indObj) = false;
            thisReason = "Headphone.Name cannot be blank.";
            theseReasons = [theseReasons; thisReason];
        end

        % Type must be Valid
        [tfType, reasonsType] = obj(indObj).Type.isValid;
        if ~tfType
            results(indObj) = false;
            thisReason = sprintf( ...
                "This Headphone (%s) has an invalid Type: %s", ...
                obj(indObj).Name, ...
                reasonsType{1} ...
            );
            theseReasons = [theseReasons; thisReason];
        end
    end % for every obj
end % function
