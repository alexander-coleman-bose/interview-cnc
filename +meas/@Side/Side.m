classdef Side
    %SIDE Enum for valid sides of a Headphone or Signal.
    %
    %Enumeration members:
    %   Both
    %   Left
    %   Right
    %   None
    %
    %See also: bose.cnc.meas, enumeration, bose.cnc.meas.Signal

    % Alex Coleman
    % $Id$

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ENUMERATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    enumeration
        Both % Only for Headphones, not for Signals
        Left
        Right
        None
    end % Enumeration

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        results = eq(obj, comparisonObj)
        results = ne(obj, comparisonObj)
    end % Public methods
end % classdef
