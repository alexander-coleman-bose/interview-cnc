function outStruct = getBlankReferenceDataStruct()
    %GETBLANKREFERENCEDATASTRUCT Get a blank "reference data" struct for use in Preferences.
    %
    %   Returns a struct with one field for every bose.cnc.meas.StepType.
    %
    %See also: bose.cnc.meas, bose.cnc.Preferences

    % Alex Coleman
    % $Id$

    outStruct = struct;
    typeStrings = string(enumeration('bose.cnc.meas.StepType'));
    for indType = 1:numel(typeStrings)
        outStruct.(typeStrings(indType)) = string.empty;
    end
end % function
