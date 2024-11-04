function obj = fromJsonFile(varargin)
    %FROMJSONFILE Loads all Configurations from a given file pattern.
    %
    %Usage:
    %   configuration = bose.cnc.meas.Configuration.fromFile;
    %   configuration = bose.cnc.meas.Configuration.fromFile(targetPath);
    %   configuration = bose.cnc.meas.Configuration.fromFile(targetPath, pathSpec);
    %
    %Optional Positional Arguments:
    %   targetPath (string-like): Folder or file to load Configurations from.
    %       (Default: pwd)
    %   pathSpec (string-like): Pattern with which to find files. (Default:
    %       fullfile('**', 'Configuration*.json'))
    %
    %Returns:
    %   obj (bose.cnc.meas.Configuration): The bose.cnc.meas.Configuration object(s)
    %       loaded from the file(s).
    %
    %Errors:
    %   InvalidTarget - When the target cannot be found as either a folder or a
    %       file.
    %
    %See also: bose.cnc.meas.Configuration, bose.cnc.meas.Configuration.fromFile

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Configuration:fromFile:';
    logger = bose.cnc.logging.getLogger;

    defaultPathSpec = fullfile('**', 'Configuration*.json'); % All *.json files, recursive.

    %% Handle inputs
    parser = inputParser;
    parser.addOptional('targetPath', pwd, @bose.common.validators.mustBeStringLike);
    parser.addOptional('pathSpec', defaultPathSpec, @bose.cnc.validators.mustBeValidPathSpec);
    parser.parse(varargin{:});
    targetPath = string(parser.Results.targetPath);
    pathSpec = string(parser.Results.pathSpec);

    %% Find all the files
    foundFiles = cell.empty;
    for indPath = 1:numel(targetPath)
        if isfolder(targetPath(indPath))
            fullSpec = fullfile(targetPath(indPath), pathSpec);

            for indSpec = 1:numel(fullSpec)
                dirList = dir(fullSpec(indSpec));
                rawFiles = fullfile({dirList.folder}, {dirList.name});
                foundFiles = [foundFiles, rawFiles];
            end
        elseif isfile(targetPath(indPath))
            foundFiles = [foundFiles, targetPath(indPath)];
        else
            mError = MException( ...
                [idHeader 'InvalidTarget'], ...
                [ ...
                    'The specified target (%s) could not be found as ' ...
                    'either a folder or a file.' ...
                ], ...
                targetPath ...
            );
            logger.error(sprintf('%s', mError.message), mError);
        end % if isfolder elseif isfile
    end % for all targets

    % Remove any duplicate files
    uniqueFiles = string(unique(foundFiles));

    %% Load all the Configurations
    obj = bose.cnc.meas.Configuration.empty;
    for indFile = 1:numel(uniqueFiles)
        try
            loadStruct = jsondecode(jsonread(uniqueFiles(indFile)));

            %HACK(ALEX): We have to manually convert DateCreated field to specify InputFormat
            loadStruct.DateCreated = datetime(loadStruct.DateCreated, 'InputFormat', bose.cnc.datetimeStorageFormat);

            % We don't allocate the array because we don't know how many can be read
            obj = [obj; bose.cnc.meas.Configuration(loadStruct)];
            logger.info(sprintf( ...
                'Loaded Configuration (%d of %d) from %s', ...
                indFile, ...
                numel(uniqueFiles), ...
                uniqueFiles(indFile) ...
            ));
        catch ME
            if ( ...
                strcmpi(ME.identifier, 'bose:common:jsonread:FileDoesNotExist') || ...
                strcmpi(ME.identifier, 'bose:common:jsonread:InvalidJsonContent') || ...
                strcmpi(ME.identifier, 'MATLAB:InputParser:UnmatchedParameter') ...
            )
                logger.warning(sprintf( ...
                    'Failed to load Configuration (%d of %d) from %s: %s', ...
                    indFile, ...
                    numel(uniqueFiles), ...
                    uniqueFiles(indFile), ...
                    ME.message ...
                ));
            else
                logger.error(sprintf( ...
                    'Failed to load Configuration (%d of %d) from %s: %s', ...
                    indFile, ...
                    numel(uniqueFiles), ...
                    uniqueFiles(indFile), ...
                    ME.message ...
                ), ME);
            end
        end % try/catch
    end % indFile = 1:numel(uniqueFiles)
end % function
