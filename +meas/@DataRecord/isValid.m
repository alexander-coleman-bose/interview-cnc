function results = isValid(obj)
    %ISVALID Returns true if the object is "Valid".
    %
    %DataRecord is Valid if:
    %   DataRecord.Date ~= datetime(0, 'ConvertFrom', 'epochtime')
    % & all(DataRecord.Environment.isValid)
    % & size of ExcitationFilters is valid with number of outputs
    % & DataRecord.Fit ~= 0
    % & DataRecord.Hardware.isValid
    % & all(DataRecord.Headphone.isValid)
    % & all(DataRecord.InputMapping.isValid)
    % & DataRecord.Operator.isValid
    % & all(DataRecord.OutputMapping.isValid)
    % & DataRecord.SignalParameters.isValid
    % & ~strcmp(DataRecord.StepName.isValid)
    % & fulfill StepType.Required*Types
    % & all(DataRecord.Subject.isValid)
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.Environment.isValid,
    %   bose.cnc.meas.Hardware.isValid, bose.cnc.meas.Headphone.isValid,
    %   bose.cnc.meas.Mapping.isValid, bose.cnc.meas.Person.isValid,
    %   bose.cnc.meas.SignalParameters.isValid, datetime

    % Alex Coleman
    % $Id$

    results = false(size(obj));
    for indObj = 1:numel(obj)
        % Find out if our input signals fulfill StepType.RequiredInputTypes
        inputSignals = obj(indObj).InputSignals;
        signalTypes = vertcat(inputSignals.Type);
        requiredTypes = vertcat(obj(indObj).StepType.RequiredInputTypes);
        tfInputSignalTypes = false(size(requiredTypes));
        for indType = 1:numel(requiredTypes)
            tfInputSignalTypes(indType) = ismember(requiredTypes(indType), signalTypes);
        end

        % Find out if our output signals fulfill StepType.RequiredOutputTypes
        outputSignals = obj(indObj).OutputSignals;
        signalTypes = vertcat(outputSignals.Type);
        requiredTypes = vertcat(obj(indObj).StepType.RequiredOutputTypes);
        tfOutputSignalTypes = false(size(requiredTypes));
        for indType = 1:numel(requiredTypes)
            tfOutputSignalTypes(indType) = ismember(requiredTypes(indType), signalTypes);
        end

        % If we have no outputs, ExcitationFilters must be empty, and
        %   ExcitationType must be None.
        tfNumelOutputs = true;
        numOutputs = numel(obj(indObj).OutputSignals);
        if numOutputs == 0
            % If the number of output is 0, but we still have filters or an ExcitationType, the DataRecord is invalid
            if ~isempty(obj(indObj).ExcitationFilters) || ...
                    ( ...
                        obj(indObj).ExcitationType ~= bose.cnc.meas.ExcitationType.None && ...
                        obj(indObj).ExcitationType ~= bose.cnc.meas.ExcitationType.External ...
                    )
                tfNumelOutputs = false;
            end
        elseif ~isempty(obj(indObj).ExcitationFilters) && ...
                size(obj(indObj).ExcitationFilters, 3) ~= numOutputs
            tfNumelOutputs = false;
        elseif ~isempty(obj(indObj).ExcitationFilters) && ...
                obj(indObj).ExcitationType == bose.cnc.meas.ExcitationType.External
            tfNumelOutputs = false;
        end

        results(indObj) = ( ...
            obj(indObj).Date ~= datetime(0, 'ConvertFrom', 'epochtime') && ...
            all(obj(indObj).Environment.isValid) && ...
            tfNumelOutputs && ...
            obj(indObj).Fit ~= 0 && ...
            obj(indObj).Hardware.isValid && ...
            all(obj(indObj).Headphone.isValid) && ...
            all(obj(indObj).InputMapping.isValid) && ...
            obj(indObj).Operator.isValid && ...
            all(obj(indObj).OutputMapping.isValid) && ...
            obj(indObj).SignalParameters.isValid && ...
            ~strcmp(obj(indObj).StepName, "") && ...
            all(tfInputSignalTypes) && ...
            all(tfOutputSignalTypes) && ...
            all(obj(indObj).Subject.isValid) ...
        );
    end
end % isValid
