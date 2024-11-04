function obj = loadFromFile(TargetFile)
    %LOADFROMFILE Loads all DataRecords from a given file pattern.
    %
    %Optional Arguments:
    %   targetFolder (string-like): Folder to load DataRecords from. (Default: pwd)
    %   pathSpec (string-like): Pattern with which to find files. (Default:
    %       fullfile('**', 'DataRecord*.mat'))
    %
    %Errors:
    %   InvalidInput - If the pathSpec is empty, contains empty strings, or
    %       doesn't end with a file extension.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.DataRecord.saveToFile

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:DataRecord:loadFromFile:';
    logger = bose.cnc.logging.getLogger;
    parser = inputParser;
    parser.addRequired('TargetFile');
    parser.parse(TargetFile);
    try
        dataRecordStruct = load(TargetFile);
        % Get any DataRecords that are stored as variables inside of the file.
        dataRecordLocated = false;
        fn = fieldnames(dataRecordStruct);
        theseDataRecords = [];
        for indField = 1:numel(fn)
            if all(isa(dataRecordStruct.(fn{indField}), 'bose.cnc.meas.DataRecord'))
                theseDataRecords = [theseDataRecords; dataRecordStruct.(fn{indField})];
                dataRecordLocated = true;
            end
        end
        if(~dataRecordLocated)
            ME = MException('bose:cnc:meas:DataRecord:loadFromFile:NoDataRecordInFile', ...
            'A Data record was not found in the file');
            throw(ME);
        end
        if(~local_checkForVerionMismatch(theseDataRecords))
            logger.warning(sprintf('Data record %s does not match the current version of the cnc toolbox. This can cause errors elsewhere!',TargetFile));
        end
        obj = theseDataRecords;
    catch ME
        if strcmp(ME.identifier, 'MATLAB:load:couldNotReadFile')
            logger.warning(sprintf( ...
                'Failed to load DataRecord from %s: %s', ...
                TargetFile,...
                ME.message ...
            ));
        else
            logger.error(sprintf( ...
                'Failed to load DataRecord from %s: %s', ...
                TargetFile,...
                ME.message ...
            ), ME);
        end
    end % try/catch
end % loadFromFile

function versionMatch = local_checkForVerionMismatch(newDR)
    versionMatch = semversion(bose.cnc.version) == semversion(newDR.ToolboxVersion);
end


