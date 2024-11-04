function deleteDataRecords(obj, varargin)
    %DELETEDATARECORDS Deletes DataRecords from the Session.
    %
    %   If no DataRecord index is selected, all DataRecords are deleted.
    %
    %Optional Positional Arguments:
    %   dataRecordIndex (numeric): The indices of the DataRecords to be deleted. (Default: all DataRecords)
    %   deleteFiles (logical): If true, also attempt to delete any corresponding .mat files in the current directory. (Default: true)
    %
    %Throws:
    %   NumelSession - When Session isn't scalar.
    %   InvalidIndex - When the index input is outside of the range of the DataRecord array.
    %
    %See also: bose.cnc.meas.Session

    % $Id$

    idHeader = 'bose:cnc:meas:Session:deleteDataRecords:';

    % Validate that we have only a single (not zero) Session object.
    if numel(obj) ~= 1
        error( ...
            [idHeader 'NumelSession'], ...
            ['Session.deleteDataRecords can only be run with a single ' ...
             'Session, not %s'], ...
            numel(obj) ...
        );
    end

    % Create a list of all valid indices
    numDataRecords = numel(obj.DataRecords);
    allDataRecords = 1:numDataRecords;

    % Handle inputs
    parser = inputParser;
    parser.addOptional('dataRecordIndex', allDataRecords, @mustBePositive);
    parser.addOptional('deleteFiles', true);
    parser.parse(varargin{:});

    if ~islogical(parser.Results.dataRecordIndex)
        parsedIndex = double(parser.Results.dataRecordIndex);
    else
        parsedIndex = parser.Results.dataRecordIndex;
    end
    deleteFiles = logical(parser.Results.deleteFiles);
    sessionDataFolder = obj.SessionDataFolder;
    deletedDataFolder = fullfile(obj.SessionDataFolder,'deleted/');
    if islogical(parsedIndex)
        indexString = string(find(parsedIndex));
    elseif numel(parsedIndex) > 1
        indexString = sprintf("[%s]", strjoin(string(parsedIndex)));
    else
        indexString = string(parsedIndex);
    end

    logger = bose.cnc.logging.getLogger;
    logger.debug(sprintf('Session.deleteDataRecords: %s', indexString));

    % Check index validity. Error if we try to delete an index outside of the max
    if any(parsedIndex > numDataRecords)
        errMsg = sprintf( ...
            'Failed to delete DataRecord #%s: Invalid index of record.', ...
            indexString ...
        );
        mError = MException( ...
            [idHeader 'InvalidIndex'], ...
            errMsg ...
        );
        logger.error(errMsg, mError);
    end

    % Delete any associated files in the current directory
        dataRecords = obj.DataRecords(parsedIndex);
        for indRecord = 1:numel(dataRecords)
            thisFile = fullfile(sessionDataFolder, dataRecords(indRecord).FileName);
            if isfile(thisFile)
                if deleteFiles
                    try
                        delete(thisFile);
                    catch ME
                        logger.warning(sprintf('Could not delete %s', thisFile));
                        continue
                    end
                    logger.info(sprintf('Deleted %s', thisFile));
                else
                    try
                        if(~isfolder(deletedDataFolder))
                            mkdir(deletedDataFolder);
                        end
                        
                        
                        movefile(thisFile,deletedDataFolder);
                    catch ME
                        logger.warning(sprintf('Could not move %s to deleted folder', thisFile));
                        continue
                    end
                    logger.info(sprintf('Moved %s to deleted folder', thisFile));
                end
            else
                logger.warning(sprintf('Could not find %s. Removing the file from the session anyways... If this was an imported data record you can ignore this warning.', thisFile));
            end
        end % for every selected DataRecord
    % Delete the record(s) from the Session
    obj.DataRecords(parsedIndex) = [];
end % function
