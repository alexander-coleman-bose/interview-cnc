function isDone = incrementStep(obj)
    %INCREMENTSTEP Increment the CurrentStep, taking into account the Fit Loop and Sequence.
    %
    %Returns:
    %   isDone(logical): done with all Steps
    %
    %See also: bose.cnc.meas.Session, bose.cnc.meas.Session.selectCurrentStep

    % Alex Coleman
    % $Id$

    isDone = false;

    % If we are at the last Step of the Fit Loop
    if ( ...
        obj.CurrentStep.LoopOverFits && ...
        obj.CurrentStepIndex == find(obj.Configuration.LoopOverFits, 1, 'last') ...
    )
        % If we are on the last Fit, we are done with the Fit Loop
        if obj.CurrentFit >= obj.Configuration.NumFits
            logger.info('Done with all Fits!');
        else % increment the Fit and go to the start of the Fit Loop
            obj.CurrentFit = obj.CurrentFit + 1;
            logger.info(sprintf('Next Fit: %.0f', obj.CurrentFit));
            obj.selectCurrentStep(find(obj.Configuration.LoopOverFits, 1, 'first'));
            logger.info(sprintf('Next Step: %s', obj.CurrentStep.Name));
            return
        end
    end

    % If we are at the last Step of the Sequence
    if obj.CurrentStepIndex >= numSteps
        logger.info('Done with all Steps!');
        isDone = true;
        return
    else
        obj.selectCurrentStep(obj.CurrentStepIndex + 1);
        logger.info(sprintf('Next Step: %s', obj.CurrentStep.Name));
    end
end % function
