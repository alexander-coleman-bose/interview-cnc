classdef CalibrationMode
    %CALIBRATIONMODE Enum for valid types of measurement hardware calibration mode.
    %
    %   This mode is currently only used for LDAQ hardware devices.
    %
    %Enumeration members:
    %   Hardware: Hardware calibration mode for LDAQ
    %   None: No calibration mode used
    %   Software: Software calibration mode for LDAQ
    %
    %See also: bose.cnc.meas, enumeration, bose.cnc.meas.Hardware, ldaq

    % Alex Coleman
    % $Id$

    enumeration
        Hardware
        Software
        None
    end
end
