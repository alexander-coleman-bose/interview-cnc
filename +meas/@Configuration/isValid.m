function [results, reasons] = isValid(obj)
    %ISVALID Returns true if the object is "Valid".
    %
    %Configuration is Valid if:
    %   Configuration.Date ~= datetime(0, 'ConvertFrom', 'epochtime')
    % & Configuration.Designer.isValid
    % & ~strcmp(Configuration.Name, "")
    % & all(Configuration.Sequence.isValid)
    % & ~isempty(Configuration.Sequence)
    %
    %See also: bose.cnc.meas.Configuration

    % Alex Coleman
    % $Id$

    results = true(size(obj));
    reasons = cell(size(obj));
    for indObj = 1:numel(obj)
        theseReasons = string.empty;

        % DateCreated must be non-default
        if obj(indObj).DateCreated == datetime(0, 'ConvertFrom', 'epochtime')
            results(indObj) = false;
            thisReason = sprintf( ...
                "This Configuration (%s) doesn't have DateCreated set.", ...
                obj(indObj).Name ...
            );
            theseReasons = [theseReasons; thisReason];
        end

        % Designer must be Valid
        [tfDesigner, reasonsDesigner] = obj(indObj).Designer.isValid;
        if ~tfDesigner
            results(indObj) = false;
            thisReason = sprintf( ...
                "This Configuration (%s) has an invalid Designer: %s", ...
                obj(indObj).Name, ...
                reasonsDesigner{1} ...
            );
            theseReasons = [theseReasons; thisReason];
        end

        % Name cannot be blank
        if strcmp(obj(indObj).Name, "")
            results(indObj) = false;
            thisReason = "Configuration.Name cannot be blank.";
            theseReasons = [theseReasons; thisReason];
        end

        % All Sequence Steps must be Valid
        [tfSteps, reasonsSteps] = obj(indObj).Sequence.isValid;
        if ~all(tfSteps)
            results(indObj) = false;
            thisReason = sprintf( ...
                "This Configuration (%s) has invalid Sequence Steps (%s):\n\t%s", ...
                obj(indObj).Name, ...
                strjoin([obj(indObj).Sequence(~tfSteps).Name], ", "), ...
                strjoin(vertcat(reasonsSteps{~tfSteps}), sprintf("\n\t")) ...
            );
            theseReasons = [theseReasons; thisReason];
        end

        % There must be at least one Sequence Step
        if isempty(obj(indObj).Sequence)
            results(indObj) = false;
            thisReason = sprintf( ...
                "This Configuration (%s) must have at least one Step in " + ...
                "the Sequence.", ...
                obj(indObj).Name ...
            );
            theseReasons = [theseReasons; thisReason];
        end

        reasons{indObj} = theseReasons;
    end % for every obj
end % isValid
