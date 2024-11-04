function toFile(obj, filePath)
    %TOFILE Save the Session to a file; does not save DataRecords.
    %
    %Usage:
    %   session.toFile(filePath);
    %
    %Required Positional Arguments:
    %   filePath (string-like): Path to the file that you would like to save to.
    %
    %See also: bose.cnc.meas.Session, bose.cnc.meas.Session.fromFile

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Session:toFile:';

    narginchk(2, 2);

    %% Convert properties to struct
    warnStruct = warning('off', 'MATLAB:structOnObject');
    saveStruct = struct(obj);
    warning(warnStruct);

    %% Remove certain fields that can't be saved, if they exist
    fieldNames = string(fieldnames(saveStruct));
    removeFields = [ ...
        "CurrentStep", ...
        "DataRecords", ...
        "DeviceHandle", ...
        "AutoListeners__" ...
    ];
    for thisField = removeFields
        if any(ismember(fieldNames, thisField))
            saveStruct = rmfield(saveStruct, thisField);
        end
    end

    %% Save the Session
    save(string(filePath), '-struct', 'saveStruct', '-v7.3');
end % function
