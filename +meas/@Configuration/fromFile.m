function obj = fromFile(targetFile)
    %FROMFILE Loads all Configurations from a file
    %
    %Usage:
    %   configuration = bose.cnc.meas.Configuration.fromFile;
    %   configuration = bose.cnc.meas.Configuration.fromFile(targetPath);
    %   configuration = bose.cnc.meas.Configuration.fromFile(targetPath, pathSpec);
    
    idHeader = 'bose:cnc:meas:Configuration:fromFile:';

    %% Handle inputs
    parser = inputParser;
    parser.addRequired('targetFile', @bose.common.validators.mustBeStringLike);
    parser.parse(targetFile);
    targetFile = string(parser.Results.targetFile);
    isJson = contains(targetFile, '.json', 'IgnoreCase', true);
    isMat = contains(targetFile, '.mat', 'IgnoreCase', true);
    if(isJson)
        obj = bose.cnc.meas.Configuration.fromJsonFile(targetFile);
    elseif(isMat)
        obj = bose.cnc.meas.Configuration.fromMatFile(targetFile);
    else
        
        error([idHeader,'InvalidTarget'],'File at %s could not be loaded. Only Json or .mat files are supported',targetFile);
    end
        
end % function
