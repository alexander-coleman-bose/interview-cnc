function noiseSignals = makeNoise(obj, varargin)
    %MAKENOISE Generate noise based on ExcitationType.
    %
    %Required Positional Arguments:
    %   signalSize (numeric): Row vector to determine the dimension lengths of the
    %       generated signal(s).
    %
    %Optional Positional Arguments:
    %   sampleRate (numeric): Used for Pink noise to High-pass the signal at 5 Hz. (Default: 48e3)
    %   rmsValue (numeric): The RMS value to set the signal's RMS value to.
    %
    %Returns:
    %   noiseSignals (double): Output signals of size (numSamples x numOutputs).
    %
    %See also: bose.cnc.meas.ExcitationType, powernoise

    % Alex Coleman
    % $Id$

    % Handle inputs (must match generateRandNoise and generateRmsNormNoise)
    local_mustBeNonNegativeInteger = @(x) ~isempty(x) && all(x(:) >= 0) && all(floor(x(:)) == x(:));
    parser = inputParser;
    parser.addRequired('signalSize', local_mustBeNonNegativeInteger);
    parser.addOptional('sampleRate', 48e3, @mustBePositive);
    parser.parse(varargin{:});
    signalSize = parser.Results.signalSize;
    sampleRate = parser.Results.sampleRate;

    % Generate base signal
    switch obj
        case bose.cnc.meas.ExcitationType.Pink
            outputPower = 1;
        case bose.cnc.meas.ExcitationType.White
            outputPower = 0;
        case {bose.cnc.meas.ExcitationType.None, bose.cnc.meas.ExcitationType.External}
            noiseSignals = zeros(signalSize);
            return
    end

    noiseSignals = bose.cnc.math.powernoise(outputPower, prod(signalSize));
    noiseSignals = reshape(noiseSignals, signalSize);

    %HACK(ALEX): 5 Hz high-pass to reduce signal amplitude without reducing target band energy
    [filtB, filtA] = biquad(5 / (sampleRate / 2), 1 / sqrt(2), 'hpf');
    noiseSignals = filter(filtB, filtA, noiseSignals);
end % function
