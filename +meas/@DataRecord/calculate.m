function metricStructs = calculate(obj, stepMetrics)
    %CALCULATE Calculate the StepMetric(s) for the given DataRecords.
    %
    %   Note: Metrics are now calculated per side, so the struct array returned for
    %   Gsd would be d-left to s-left, followed by d-right to s-right.
    %
    %Required Arguments:
    %   stepMetrics (bose.cnc.metrics.StepMetric): The StepMetrics to calculate for the given DataRecords.
    %
    %Returns:
    %   metricStructs (struct): Struct of Freq., Mag., and Phase data.
    %       .freqVector (double): Frequency sequence for the data in Hz.
    %       .magnitudeData (double): Magnitude of the generated data in dB FS.
    %       .phaseData (double): Phase of the generated data in degrees.
    %       .signalsA (bose.cnc.meas.Signal): InputSignals found for the "A" signal spec.
    %       .signalsB (bose.cnc.meas.Signal): InputSignals found for the "B" signal spec.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.metrics.StepMetric

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:DataRecord:calculate:';
    logger = bose.cnc.logging.getLogger;

    narginchk(2, 2);

    blankStruct = bose.cnc.metrics.getBlankMetricStruct;

    metricStructs = struct.empty;
    allSides = [bose.cnc.meas.Side.Left; bose.cnc.meas.Side.Right; bose.cnc.meas.Side.None];
    for indObj = 1:numel(obj)
        thisStruct = blankStruct;

        % Handle the frequency vector
        thisStruct.freqVector = obj(indObj).SignalParameters.Frequencies;
        %TODO(ALEX): Do frequency reduction/spacing here

        for indMetric = 1:numel(stepMetrics)
            % Find matching Signals in the DataRecord
            signalMaskA = obj(indObj).findInputSignals(stepMetrics(indMetric).SignalStringA);
            signalMaskB = obj(indObj).findInputSignals(stepMetrics(indMetric).SignalStringB);

            % Combine masks from multiple specs together with OR
            signalMaskA = max(signalMaskA, [], 2);
            signalMaskB = max(signalMaskB, [], 2);

            % Skip this data line if there are no matching signals
            if sum(signalMaskA) == 0 || sum(signalMaskB) == 0
                %HACK(ALEX): Should we error here, or should we return an empty struct?
                logger.warning(sprintf( ...
                    [ ...
                        'The DataRecords did not have the required ' ...
                        'signals to calculate %s' ...
                    ], ...
                    stepMetrics(indMetric).Name ...
                ));
                continue
            end

            %HACK(ALEX): Cannot be Nx1, must be 1xN
            for thisSide = allSides'
                sideMask = [obj(indObj).InputSignals.Side]' == thisSide; % Must be Nx1 to match signalMaskA/B
                sideMaskA = sideMask & signalMaskA;
                sideMaskB = sideMask & signalMaskB;

                % Get the signals found
                thisStruct.signalsA = obj(indObj).InputSignals(sideMaskA);
                thisStruct.signalsB = obj(indObj).InputSignals(sideMaskB);

                % Continue to next side if this side is empty
                if isempty(thisStruct.signalsA) || isempty(thisStruct.signalsB)
                    continue
                end

                % Calculate the raw metric/plot data
                rawData = feval(stepMetrics(indMetric).Type.FunctionHandle, obj(indObj).getXsData, sideMaskA, sideMaskB);

                % Apply smoothing
                smoothedData = bose.cnc.math.smooth( ...
                    rawData, ...
                    thisStruct.freqVector, ...
                    'SmoothingLoops', stepMetrics(indMetric).SmoothingLoops, ...
                    'SmoothingRange', stepMetrics(indMetric).SmoothingRange, ...
                    'SmoothingScale', stepMetrics(indMetric).SmoothingScale, ...
                    'SmoothingType', stepMetrics(indMetric).SmoothingType ...
                );

                % Convert to dB based on whether Metric is power quantity or not
                if stepMetrics(indMetric).Type.IsPowerQuantity
                    thisStruct.magnitudeData = 10 * log10(abs(smoothedData));
                    thisStruct.phaseData = zeros(size(smoothedData));
                else
                    thisStruct.magnitudeData = 20 * log10(abs(smoothedData));
                    if stepMetrics(indMetric).UnwrapPhase
                        thisStruct.phaseData = 180/pi * unwrap(angle(smoothedData));
                    else
                        thisStruct.phaseData = 180/pi * angle(smoothedData);
                    end
                end

                % Add the plot data to the metricStructs array
                metricStructs = [metricStructs; thisStruct];
            end % for every Side
        end % for every Metric
    end % for every DataRecord
end % calculate
