function selectCurrentStep(obj, newStep)
    %SELECTCURRENTSTEP Set the CurrentStepIndex number for the measurement Session.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %   NoMeasurementConfiguration - When no Configuration is loaded in the Session.
    %   InvalidStepIndex - When the new Step is greater than the number of Steps in the Sequence.
    %
    %See also: bose.cnc.meas.Session

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Session:selectCurrentStep:';

    % Handle inputs
    parser = inputParser;
    parser.addRequired('newStep');
    parser.parse(newStep);
    newStep = double(parser.Results.newStep);

    % Log the call
    logger = bose.cnc.logging.getLogger;
    logger.debug(sprintf('bose.cnc.meas.Session.selectCurrentStep: %.0f', newStep));

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            [idHeader 'NumelSession'], ...
            [ ...
                'Session.selectCurrentStep can only be run with a single ' ...
                'Session, not %s' ...
            ], ...
            numel(obj) ...
        );
    end

    % Check to see if we have a Configuration object.
    if isempty(obj.Configuration)
        error( ...
            [idHeader 'NoMeasurementConfiguration'], ...
            'Selecting a step failed: No measurement Configuration loaded.' ...
        );
    end

    % Error if the selected Step is greater than the number of Steps in the Configuration
    oldStep = obj.CurrentStepIndex;

    if newStep > numel(obj.Configuration.Sequence)
        error( ...
            [idHeader 'InvalidStepIndex'], ...
            [ ...
                'Selecting a Step failed: Cannot select Step #%d, there ' ...
                'are only %d Steps in the Configuration Sequence.' ...
            ], ...
            newStep, ...
            numel(obj.Configuration.Sequence) ...
        );
    elseif oldStep ~= newStep
        obj.CurrentStepIndex = newStep;
    end % if oldStep ~= newStep

end % function
