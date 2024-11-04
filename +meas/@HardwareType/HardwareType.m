classdef HardwareType
    %HARDWARETYPE Enum for valid types of measurement hardware.
    %
    %Enumeration members:
    %   ldaq: An LDAQ device (i.e. Motu 8A)
    %   rme: An RME device (deprecated, used for importing from rmeout structs)
    %
    %See also: bose.cnc.meas, enumeration, bose.cnc.meas.Hardware

    % $Id$

    %% PUBLIC METHODS
    methods (Access = public)
        varargout = sort(obj, varargin);
    end

    enumeration
        ldaq
        rme
    end
end
