function configureHardwareSignals(obj)
    %CONFIGUREHARDWARESIGNALS Configure the output, rate, points of the device.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %   DeviceNotConnected - When the measurement hardware isn't connected.
    %   NoMeasurementConfiguration - When no Configuration is loaded in the Session.
    %
    %See also: bose.cnc.meas.Session, bose.cnc.meas.Session.configureHardware

    % $Id$

    idHeader = 'bose:cnc:meas:Session:configureHardwareSignals:';

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            [idHeader 'NumelSession'], ...
            ['Session.configureHardwareSignals can only be run with a ' ...
             'single Session, not %s'], ...
            numel(obj) ...
        );
    end

    % Check obj.DeviceHandle is connected, if not error.
    if ~obj.isDeviceConnected
        error( ...
            [idHeader 'DeviceNotConnected'], ...
            'Hardware configuration failed: No device connected.' ...
        );
    end

    % For every Step OutputSignal, set the Hardware Output/ExcitationSignal.
    if obj.Hardware.Type == bose.cnc.meas.HardwareType.ldaq
        if ~isempty(obj.Configuration)
            thisStep = obj.CurrentStep;
            sigParams = thisStep.SignalParameters;

            if thisStep.ExcitationType == bose.cnc.meas.ExcitationType.None
                obj.DeviceHandle.Points = sigParams.TotalSamples;

                %HACK(ALEX): Deactivate all outputs and only activate what we need, this violates the expectations of OutputMapping
                if ~isempty(obj.OutputMapping)
                    allOutputs = cellstr([obj.OutputMapping.Channel]);
                    obj.DeviceHandle.deactivate(allOutputs{:});
                end

            elseif thisStep.ExcitationType == bose.cnc.meas.ExcitationType.External
                obj.DeviceHandle.Points = sigParams.TotalSamples;

                %HACK(ALEX): Deactivate all outputs and only activate what we need, this violates the expectations of OutputMapping
                if ~isempty(obj.OutputMapping)
                    allOutputs = cellstr([obj.OutputMapping.Channel]);
                    obj.DeviceHandle.deactivate(allOutputs{:});
                end

                %HACK(ALEX): mappedChannels can be "" if signals aren't mapped
                signalChannels = obj.OutputMapping.findChannelBySignal(thisStep.OutputSignals);
                mappedMask = ~strcmp(signalChannels, "");
                mappedChannels = cellstr(signalChannels(mappedMask));

                %HACK(ALEX): Assume that all "External" excitations can still be controlled by LDAQ output gain
                if ~isempty(mappedChannels)
                    obj.DeviceHandle.activate(mappedChannels{:});
                    for indChannel = 1:numel(mappedChannels)
                        obj.DeviceHandle.(mappedChannels{indChannel}).Gain = db20(thisStep.ExcitationGain);
                    end
                end
            else
                %HACK(ALEX): Set all outputs to zero first, since all mapped outputs are activated.
                obj.DeviceHandle.setOutput(zeros(sigParams.TotalSamples, 1));

                % Generate the excitation signals for the mapped channels
                %HACK(ALEX): mappedChannels can be "" if signals aren't mapped
                signalChannels = obj.OutputMapping.findChannelBySignal(thisStep.OutputSignals);
                mappedMask = ~strcmp(signalChannels, "");
                mappedChannels = signalChannels(mappedMask);
                excitationSignals = thisStep.getExcitationSignals(mappedMask);

                % Find the linear gain required to normalize the peak of the signals to 0.9999999999
                if ~isempty(excitationSignals)
                    [~, scalesOut] = bose.cnc.math.setPeak(excitationSignals, 1.0 - eps, 1);
                end

                % Adjust channel gain to achieve original signal level at the output
                for indChannel = 1:numel(mappedChannels)
                    thisChannel = char(mappedChannels(indChannel)); % convert string to char
                    targetGain = db20(1/scalesOut(indChannel));
                    maxGain = obj.DeviceHandle.(thisChannel).PossibleGains(end);
                    minGain = obj.DeviceHandle.(thisChannel).PossibleGains(1);

                    if targetGain > maxGain || targetGain < minGain
                        error( ...
                            [idHeader 'GainOutOfBounds'], ...
                            [ ...
                                'This Hardware.DeviceModel (%s) cannot ' ...
                                'support the requested gain (%s) ' ...
                                'to reach the desired signal level; max ' ...
                                'supported gain: %.1f dB, min supported gain %.1f dB, target gain: %.1f dB' ...
                            ], ...
                            obj.Hardware.DeviceModel, ...
                            thisChannel, ...
                            minGain, ...
                            maxGain, ...
                            targetGain ...
                        );
                    end

                    % Find the next highest viable gain
                    % Stick to increments of channel.GainResolution (1.0 dB)
                    possibleGains = obj.DeviceHandle.(thisChannel).PossibleGains;
                    actualGain = possibleGains(find(possibleGains >= targetGain, 1, 'first'));

                    % Scale the excitationSignals
                    obj.DeviceHandle.(thisChannel).Gain = actualGain;
                    obj.DeviceHandle.setOutput( ...
                        excitationSignals(:, indChannel) .* 1/undb20(actualGain), ...
                        thisChannel ...
                    );
                end
            end % if ExcitationType is None/External/Else

            % Set Device Signal Rate
            if obj.DeviceHandle.Rate ~= sigParams.Fs
                obj.DeviceHandle.Rate = sigParams.Fs;
            end
        else
            sampleRate = 48e3;
            if obj.DeviceHandle.Rate ~= sampleRate
                obj.DeviceHandle.Rate = sampleRate;
            end
            obj.DeviceHandle.setOutput(zeros(sampleRate, 1));
        end % if ~isempty(obj.Configuration)
    end % if Hardware.Type is ldaq
end % function
