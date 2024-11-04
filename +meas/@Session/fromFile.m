function obj = fromFile(filePath)
    %FROMFILE Load the Session from a file; does not load DataRecords.
    %
    %Usage:
    %   session = bose.cnc.meas.Session.fromFile(filePath);
    %
    %Required Positional Arguments:
    %   filePath (string-like): Path to the file that you would like to load from.
    %
    %Optional arguments
    %       session = bose.cnc.meas.Session.fromFile(filePath,true); will
    %       attempt to align the session data folder to what was contained
    %       in the incoming file.
    %Returns:
    %   obj (bose.cnc.meas.Session): The bose.cnc.meas.Session object loaded from
    %       the file.
    %
    %See also: bose.cnc.meas.Session, bose.cnc.meas.Session.toFile

    % Alex Coleman
    % $Id$

    narginchk(1, 1);
    %% Load the struct
    loadStruct = load(filePath);
    % Get the CurrentStepIndex value
    if isfield(loadStruct, 'CurrentStepIndex')
        currentStepIndex = loadStruct.CurrentStepIndex;
        loadStruct = rmfield(loadStruct, "CurrentStepIndex");
    else
        currentStepIndex = 1;
    end
    %% Set the Session
    obj = bose.cnc.meas.Session.start(loadStruct);
    obj.selectCurrentStep(currentStepIndex);
end % function
