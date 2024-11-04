function obj = loadFromFolder(TargetFolder)
    %LoadFromFolder Loads all DataRecords from a given folder
    %
    %Optional Arguments:
    %   targetFolder (string-like): Folder to load DataRecords from. (Default: pwd)
    %
    %Errors:
    %   InvalidInput - If the pathSpec is empty, contains empty strings, or
    %       doesn't end with a file extension.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.DataRecord.saveToFile
    % Will Kolb
    % $Id$
    idHeader = 'bose:cnc:meas:DataRecord:loadFromFolder:';
    logger = bose.cnc.logging.getLogger;
    parser = inputParser;
    parser.addRequired('TargetFolder');
    parser.parse(TargetFolder);
    %Get everything in that folder (Techincally this works with file
    %patterns).
    fileListing = dir(TargetFolder);
    obj = [];
    for x= 1:length(fileListing)
       %If the file is a .mat file,  
       filepath = fullfile(fileListing(x).folder,fileListing(x).name);
        if(contains(filepath,'.mat')) %There's probably a premade function for this...
            matObj = matfile(filepath); %matfile does not load the .mat
            if(any(contains(fieldnames(matObj),'dataRecord')))
              obj = [obj bose.cnc.meas.DataRecord.loadFromFile(filepath)];
            end
        elseif(contains(filepath,'.json'))
            warning(strcat(idHeader,'jsonNotSupported'),...
                  'Currently JSON is not supported for folder loading');
        end
    end