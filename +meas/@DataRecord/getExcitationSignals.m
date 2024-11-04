function excitationSignals = getExcitationSignals(obj, signalMask)
    %GETEXCITATIONSIGNALS Generate a typical excitation for this DataRecord.
    %
    %   Noise is generated using the following steps:
    %       1. Noise is generated based on the ExcitationType
    %       2. Filtered by ExcitationFilters
    %       3. Adjusted to a mean of zero
    %       4. Normalized to an RMS value of 1
    %       5. Ramping from TUp/TDown is applied
    %       6. Signal is multiplied by ExcitationGain
    %
    %Usage:
    %   excitationSignals = dataRecord.getExcitationSignals;
    %   excitationSignals = dataRecord.getExcitationSignals(signalMask);
    %
    %Optional Positional Arguments:
    %   signalMask (logical): Mask to select which signals are generating out of all
    %       possible signals. (Default: all signals)
    %
    %Returns:
    %   excitationSignals (double): Excitation signals of size (Number of samples,
    %       number of OutputSignals)
    %
    %Throws:
    %   ClippingDetected - When clipping is still occuring after regenerating the
    %       signal a number of times.
    %
    %See also: bose.cnc.meas.DataRecord

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:DataRecord:getExcitationSignals:';

    % Error if ExcitationType in External or None
    if ismember( ...
        obj.ExcitationType, ...
        [bose.cnc.meas.ExcitationType.External, bose.cnc.meas.ExcitationType.None] ...
    )
        error( ...
            [idHeader 'InvalidExcitationType'], ...
            [ ...
                'You cannot generate ExcitationSignals when ExcitationType ' ...
                'is bose.cnc.meas.ExcitationType.External or ' ...
                'bose.cnc.meas.ExcitationType.None' ...
            ] ...
        );
    end

    % Setup variables
    numOutputs = numel(obj.OutputSignals);
    totalSamples = obj.SignalParameters.TotalSamples;
    sampleRate = obj.SignalParameters.Fs;

    % Handle inputs
    if nargin < 2
        signalMask = true(numOutputs, 1);
    else
        signalMask = logical(reshape(signalMask, numOutputs, 1));
    end

    % Generate the base signals
    noiseSignals = obj.ExcitationType.makeNoise( ...
    [totalSamples, numOutputs], ...
        sampleRate ...
    );

    % Use sosfilt to apply ExcitationFilters
    % If there are more outputs than filters, repeat the sequence of filters.
    if ~isempty(obj.ExcitationFilters)
        noiseSignals = bose.cnc.math.sosfiltModSignals( ...
            obj.ExcitationFilters, ...
            noiseSignals ...
        );
    end % if the filter isn't empty

    % Set the mean to 0
    noiseSignals = bose.cnc.math.zeroMean(noiseSignals);

    % Normalize the RMS value to 1.0
    noiseSignals = bose.cnc.math.setRms(noiseSignals, 1.0);

    % Normalize the peaks to +/- 0.999999999
    % noiseSignals = bose.cnc.math.setPeak(noiseSignals, 1.0 - eps);

    % Apply signal ramping (TUp/TDown)
    % floor to err on the side of giving more samples to the full-scale region
    samplesUp = floor(obj.SignalParameters.TUp * obj.SignalParameters.Fs);
    samplesDown = floor(obj.SignalParameters.TDown * obj.SignalParameters.Fs);
    indDownStart = totalSamples - samplesDown + 1;
    gainVector = ones(totalSamples, 1) * obj.ExcitationGain;
    gainVector(1:samplesUp) = linspace(0, obj.ExcitationGain, samplesUp);
    gainVector(indDownStart:end) = linspace(obj.ExcitationGain, 0, samplesDown);
    excitationSignals = noiseSignals .* gainVector;

    % Downselect the desired signals
    excitationSignals = excitationSignals(:, signalMask);
end % function
