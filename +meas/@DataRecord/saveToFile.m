function fileNames = saveToFile(obj, varargin)
    %SAVETOFILE Saves each DataRecord given to files in the targetFolder.
    %
    %Optional Arguments:
    %   targetFolder (string-like): Folder to save DataRecords to. (Default: pwd)
    %
    %Returns:
    %   fileNames (string): Array of the names of files that were saved.
    %
    %See also: bose.cnc.meas.DataRecord,
    %   bose.cnc.meas.DataRecord.loadFromFile

    % Alex Coleman
    % $Id$

    logger = bose.cnc.logging.getLogger;
    defaultTargetFolder = pwd;

    parser = inputParser;
    parser.addOptional('targetFolder', defaultTargetFolder, @bose.common.validators.mustBeStringLike);
    parser.parse(varargin{:});
    targetFolder = parser.Results.targetFolder;

    logger = bose.cnc.logging.getLogger;

    % If the targetFolder does not exist, attempt to create it.
    if isempty(targetFolder) || ~isfolder(targetFolder)
        [mkdirSuccess, mkdirMessage, mkdirMessageId] = mkdir(targetFolder);
        if ~mkdirSuccess
            mError = MException(mkdirMessageId, mkdirMessage);
            logger.error(sprintf('%s', mError.message), mError);
        end
    end

    % Loop over every DataRecord given
    fileNames = [];
    for indRecord = 1:numel(obj)
        fileNames = [fileNames ;obj.FileName];
        dataRecord = obj(indRecord);
        dataRecordWhos = whos('dataRecord');
        if dataRecordWhos.bytes > 1024^3
            dataRecordSize = sprintf('%.3f GB', dataRecordWhos.bytes/1024^3);
        elseif dataRecordWhos.bytes > 1024^2
            dataRecordSize = sprintf('%.3f MB', dataRecordWhos.bytes/1024^2);
        elseif dataRecordWhos.bytes > 1024^1
            dataRecordSize = sprintf('%.3f MB', dataRecordWhos.bytes/1024^1);
        else
            dataRecordSize = sprintf('%.3f B', dataRecordWhos.bytes);
        end

        dataRecordPath = fullfile(targetFolder, dataRecord.FileName);
        save( ...
            dataRecordPath, ...
            'dataRecord', ...
            '-v7.3' ...
        );
        logger.debug(sprintf( ...
            'Wrote DataRecord (%d of %d, %s in memory) to %s', ...
            indRecord, ...
            numel(obj), ...
            dataRecordSize, ...
            dataRecordPath ...
        ));
    end % for every DataRecord
end % function
