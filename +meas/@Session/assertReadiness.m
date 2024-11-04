function [selectedInputMappings, selectedOutputMappings] = assertReadiness(obj)
    %ASSERTREADINESS Throw an error if the Session isn't ready to measure.
    %
    %Returns:
    %   selectedInputMappings (bose.cnc.meas.Mapping): The input mappings required
    %       for the CurrentStep.
    %   selectedOutputMappings (bose.cnc.meas.Mapping): The output mappings required
    %       for the CurrentStep.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %   DeviceNotConnected - When the measurement hardware isn't connected.
    %   InvalidSession - When the Session is missing either a Mapping,
    %       Hardware, or Configuration.
    %
    %See also: bose.cnc.meas.Session, bose.cnc.meas.Session.measure

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Session:assertReadiness:';

    logger = bose.cnc.logging.getLogger;
    logger.debug('bose.cnc.meas.Session.assertReadiness function');

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        mError = MException( ...
            [idHeader 'NumelSession'], ...
            ['Session.measure can only be run with a single ' ...
             'Session, not %s'], ...
            numel(obj) ...
        );
        logger.error(sprintf('Not ready to measure: %s', mError.message), mError);
    end

    if ~obj.isDeviceConnected
        mError = MException( ...
            [idHeader 'DeviceNotConnected'], ...
            'Measurement failed: No measurement device connected.' ...
        );
        logger.error(sprintf('Not ready to measure: %s', mError.message), mError);
    end

    if ~obj.isValid
        %TODO(ALEX): Again, isValid isn't descriptive at all, maybe make it return why?
        mError = MException( ...
            [idHeader 'InvalidSession'], ...
            [ ...
                'Measurement failed: Session needs a valid Hardware, ' ...
                'Configuration, Operator, InputMapping, and OutputMapping.' ...
            ] ...
        );
        logger.error(sprintf('Not ready to measure: %s', mError.message), mError);
    end

    % Verify that we have all of the requested signals mapped
    thisStep = obj.CurrentStep;
    signals = [thisStep.InputSignals; thisStep.OutputSignals];
    mappings = [obj.InputMapping; obj.OutputMapping];
    selectedInputMappings = bose.cnc.meas.Mapping.empty;
    selectedOutputMappings = bose.cnc.meas.Mapping.empty;
    for indSignal = 1:numel(signals)
        thisSignal = signals(indSignal);
        matchedMappings = mappings([mappings.Signal]' == thisSignal);

        % If we don't find a matching channel, return an error
        if isempty(matchedMappings)
            mError = MException( ...
                [idHeader 'UnmappedSignal'], ...
                'Signal is not mapped to any hardware channel: %s', ...
                thisSignal.Name ...
            );
            logger.error(sprintf('Not ready to measure: %s', mError.message), mError);
        elseif thisSignal.isInput
            selectedInputMappings = [selectedInputMappings; matchedMappings];
        elseif thisSignal.isOutput
            selectedOutputMappings = [selectedOutputMappings; matchedMappings];
        end
    end % For every signal
end % function
