function configureHardwareInputMapping(obj)
    %CONFIGUREHARDWAREINPUTMAPPING Configure the active input channels of the device.
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %   DeviceNotConnected - When the measurement hardware isn't connected.
    %   NoInputMapping - When no InputMapping is loaded in the Session.
    %
    %See also: bose.cnc.meas.Session,
    %   bose.cnc.meas.Session.configureHardware

    % $Id$

    idHeader = 'bose:cnc:meas:Session:configureHardwareInputMapping:';

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            [idHeader 'NumelSession'], ...
            ['Session.configureHardwareInputMapping can only be run ' ...
             'with a single Session, not %s'], ...
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

    if obj.Hardware.Type == bose.cnc.meas.HardwareType.ldaq
        totalNumChannels = obj.Hardware.NumAnalogInputs + obj.Hardware.NumDigitalInputs;
        if totalNumChannels > 0
            allInputChannels = cellstr(obj.Hardware.InputChannels);

            % Deactivate all channels and reset all custom names first
            obj.DeviceHandle.deactivate(allInputChannels{:});
            %Clear all ldaq custom names
            for indChannel = 1:totalNumChannels
                obj.DeviceHandle.(allInputChannels{indChannel}).ChannelName = sprintf('UnmappedInput%i',indChannel);
            end
            
            for indChannel = 1:totalNumChannels
                obj.DeviceHandle.(allInputChannels{indChannel}).ChannelName = allInputChannels{indChannel};
            end

            for indMapping = 1:numel(obj.InputMapping)
                thisMapping = obj.InputMapping(indMapping);
                obj.DeviceHandle.activate(char(thisMapping.Channel));
                currentScale = obj.DeviceHandle.(thisMapping.Channel).Scale;
                currentUnits = currentScale.units;

                % Only set the Scale if it is different from the current Scale quant
                if ( ...
                    currentScale.data ~= thisMapping.Signal.Scale || ...
                    ~strcmp(currentUnits.out, thisMapping.Signal.Units) || ...
                    ~strcmp(currentScale.type, 'li') ...
                )
                    
                    scaleQuant = thisMapping.Signal.ScaleQuant;
                    %hardwareUnits = obj.DeviceHandle.(thisMapping.Channel).ClipThreshold.units;
                    hardwareUnits = obj.DeviceHandle.(thisMapping.Channel).Scale.units;
                    channelUnits = scaleQuant.units;
                    inputUnits = channelUnits.in;
                    outputUnits = channelUnits.out;
                    if(~strcmp(hardwareUnits.in,channelUnits.in))
                            warning('bose:cnc:meas:session:configureHardwareInputMapping:inputInputmismatch_num',...
                            'Hardware input scale numerator units %s do not match configuration input scale numerator units %s! Using hardware values...',hardwareUnits.in,channelUnits.in);
                            inputUnits = hardwareUnits.in;
                    end

                    if(~strcmp(hardwareUnits.out,channelUnits.out))
                            warning('bose:cnc:meas:session:configureHardwareInputMapping:inputInputmismatch_denom',...
                            'Hardware input scale denominator units %s does not match configuration input scale denominator units %s! Using hardware values...',hardwareUnits.out,channelUnits.out);
                            outputUnits = hardwareUnits.out;
                            
                    end
                    if(isempty(inputUnits))
                        inputUnits = '  ';
                    end
                    if(isempty(outputUnits))
                       outputUnits = '  ';
                    end
                    unitsString = sprintf('%s/%s',outputUnits,inputUnits);
                    newScaleQuant = quant(scaleQuant.data, unitsString);
                    %Hack to handle unit matching fix on the ldaq side
                    %(everything was just kinda volts and scalars before)
                    obj.DeviceHandle.(thisMapping.Channel).Scale = newScaleQuant;
                end
                % Set the ChannelName
                obj.DeviceHandle.(thisMapping.Channel).ChannelName = char(thisMapping.Signal.Name);
            end % for every Mapping
        end % if we have any channels
    end % if the hardware is an ldaq
end % function
