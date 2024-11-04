function fileNames = toFile(obj, varargin)
    %TOFILE Save the Configuration(s) to JSON or MAT file(s).
    %
    %   You may specify either a folder or a list of file names. If a folder is
    %   specified, the Configurations will be saved to that folder using their
    %   default file names ("Configuration-<Name>.json", see
    %   "help bose.cnc.meas.Configuration.FileName").
    %
    %   If "*.json" is specified as the file extension, the object will be saved as
    %   a JSON file, and if "*.mat" is specified as the file extension, the object
    %   will be saved as a MAT file.
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
    %   InvalidFileName - When any file name doesn't contain ".json" or ".mat".
    %   InvalidInput - When the number of file names is different from the number of
    %       objects.
    %   InvalidTarget - When more than one folder is specified.
    %
    %See also: bose.cnc.meas.Configuration, bose.cnc.meas.Configuration.fromFile

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Configuration:toFile:';

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
            error( ...
                [idHeader 'InvalidTarget'], ...
                [ ...
                    'targetPath must be a string array of file names, or a ' ...
                    'path to a single folder' ...
                ] ...
            );
        end
        targetFiles = fullfile(targetPath, [obj.FileName]');
    else
        targetFiles = targetPath;

        if numel(targetFiles) ~= numel(obj)
            error( ...
                [idHeader 'InvalidInput'], ...
                [ ...
                    'You must have the same number of file names (%d) and ' ...
                    'objects to save (%d).' ...
                ], ...
                numel(targetFiles), ...
                numel(obj) ...
            );
        end
    end

    maskJson = contains(targetFiles, '.json', 'IgnoreCase', true);
    maskMat = contains(targetFiles, '.mat', 'IgnoreCase', true);
    if any(maskJson & maskMat)
        error( ...
            [idHeader 'InvalidFileName'], ...
            '".json" and ".mat" cannot both exist in the same file name.' ...
        );
    elseif sum(maskJson | maskMat) ~= numel(targetFiles)
        error( ...
            [idHeader 'InvalidFileName'], ...
            'File names must use either ".json" or ".mat" extensions.' ...
        );
    end

    fileNames = [ ...
        obj(maskJson).toJsonFile(targetFiles(maskJson), makePretty); ...
        obj(maskMat).toMatFile(targetFiles(maskMat)) ...
    ];
end % function
