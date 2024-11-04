function fileNames = toMatFile(obj, varargin)
    %TOMATFILE Save the Configuration(s) to MAT file(s).
    %
    %   You may specify either a folder or a list of file names. If a folder is
    %   specified, the Configurations will be saved to that folder using their
    %   default file names ("Configuration-<Name>.mat", see
    %   "help bose.cnc.meas.Configuration.MatFileName").
    %
    %Usage:
    %   configuration.toMatFile(targetPath);
    %
    %Optional Positional Arguments:
    %   targetPath (string-like): Path to the folder or file that you would like to
    %       save to. (Default: pwd)
    %
    %Returns:
    %   fileNames (string): Names of the files that were saved.
    %
    %Errors:
    %   InvalidTarget - When more than one folder is specified.
    %   InvalidInput - When the number of file names is different from the number of
    %       objects.
    %
    %See also: bose.cnc.meas.Configuration, bose.cnc.meas.Configuration.toFile

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Configuration:toFile:';
    logger = bose.cnc.logging.getLogger;

    % Handle inputs
    parser = inputParser;
    parser.addOptional('targetPath', pwd, @bose.common.validators.mustBeStringLike);
    parser.parse(varargin{:});
    targetPath = string(parser.Results.targetPath);

    targetIsFolder = any(isfolder(targetPath));
    if targetIsFolder
        if numel(targetPath) > 1
            mError = MException( ...
                [idHeader 'InvalidTarget'], ...
                [ ...
                    'targetPath must be a string array of file names, or a ' ...
                    'path to a single folder' ...
                ] ...
            );
            logger.error(sprintf('%s', mError.message), mError);
        end
        targetFiles = fullfile(targetPath, [obj.MatFileName]');
    else
        targetFiles = targetPath;

        if numel(targetFiles) ~= numel(obj)
            mError = MException( ...
                [idHeader 'InvalidInput'], ...
                [ ...
                    'You must have the same number of file names (%d) and ' ...
                    'objects to save (%d).' ...
                ], ...
                numel(targetFiles), ...
                numel(obj) ...
            );
            logger.error(sprintf('%s', mError.message), mError);
        end
    end

    %% Loop over files
    for indObj = 1:numel(obj)
        try
            % Convert properties to struct
            saveStruct = struct(obj(indObj));

            %% Save the Session
            save(string(targetFiles(indObj)), '-struct', 'saveStruct', '-v7.3');
            logger.info(sprintf( ...
                'Wrote Configuration (%d of %d) to %s', ...
                indObj, ...
                numel(obj), ...
                targetFiles(indObj) ...
            ));
        catch ME
            % Reenable struct warning
            logger.error( ...
                sprintf( ...
                    'Failed to save Configuration (%d of %d) to %s: %s', ...
                    indObj, ...
                    numel(obj), ...
                    targetFiles(indObj), ...
                    ME.message ...
                ), ...
                ME ...
            );
        end % try/catch
    end % for every obj

    % Handle outputs
    fileNames = targetFiles;
end % function
