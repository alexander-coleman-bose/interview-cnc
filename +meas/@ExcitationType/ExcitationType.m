classdef ExcitationType
    %EXCITATIONTYPE Enum for types of Excitation signal generation.
    %
    %Enumeration members:
    %   None: Generate no Excitation signal.
    %   External: Output channel is activated, but the excitation is generated outside of the CNC Toolbox.
    %   Pink: Generate an Excitation signal using bose.cnc.math.powernoise(1, ...).
    %   White: Generate an Excitation signal using bose.cnc.math.powernoise(0, ...).
    %
    %See also: bose.cnc.meas, bose.cnc.meas.ExcitationType.ExcitationType,
    %   bose.cnc.meas.DataRecord, bose.cnc.meas.Step, bose.cnc.math.powernoise

    % Alex Coleman
    % $Id$

    %% PUBLIC METHODS
    methods (Access = public)
        noiseSignals = makeNoise(varargin);
    end % Public methods

    %% ENUMERATION
    enumeration
        None
        External
        Pink
        White
    end % Enumeration
end % classdef
