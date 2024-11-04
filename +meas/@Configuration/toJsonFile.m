function fileNames = toJsonFile(obj, varargin)
    %TOJSONFILE Save the Configuration(s) to JSON file(s).
    %
    %   You may specify either a folder or a list of file names. If a folder is
    %   specified, the Configurations will be saved to that folder using their
    %   default file names ("Configuration-<Name>.json", see
    %   "help bose.cnc.meas.Configuration.FileName").
    %
    %Usage:
    %   configuration.toFile(targetPath);
    %
    %Optional Positional Arguments:
    %   targetPath (string-like): Path to the folder or file that you would like to
    %       save to. (Default: pwd)
    %   makePretty (logical): If true, add JSON whitespace formatting, see "help
    %       jsonwrite". (Default: true)
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
    parser.addOptional('makePretty', true, @(x) isnumeric(x) || islogical(x));
    parser.parse(varargin{:});
    targetPath = string(parser.Results.targetPath);
    makePretty = logical(parser.Results.makePretty);

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
        targetFiles = fullfile(targetPath, [obj.FileName]');
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

    % For every Configuration, write it to file with jsonwrite
    for indObj = 1:numel(obj)
        jsonwrite(targetFiles(indObj), struct(obj(indObj)), makePretty);
        logger.info(sprintf( ...
            'Wrote Configuration (%d of %d) to %s', ...
            indObj, ...
            numel(obj), ...
            targetFiles(indObj) ...
        ));
    end

    % Handle outputs
    fileNames = targetFiles;
end % function
