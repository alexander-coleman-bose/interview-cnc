function [folderPathOut] = createSessionDataFolder(obj)
%CREATESESSIONDATAFOLDER Creates a folder to hold all session data
%While the path is returned, this directly modifies the session class.
logger = bose.cnc.logging.getLogger;
folderPathOut = '';
if(~isempty(obj.Configuration))
    %Clean the configuraiton name and make it into a path.
    pathReadyConfigName = matlab.lang.makeValidName(obj.Configuration.Name);
    d = datetime;
    d.Format = '-dd-MM-uuu-HH-mm-ss';
    pathReadyConfigName = strcat(pathReadyConfigName,char(d));
    folderPathOut = fullfile(pwd,pathReadyConfigName);
    %Use mkdir withoutput to suppress already exist warning.
    [status, msg, ~] = mkdir(char(folderPathOut));
    if(status ~= 1)
        logger.warning(sprintf('%s',msg));
    end
    obj.SessionDataFolder = folderPathOut;
else
    logger.warning('Could not create session data folder as configuration is currently not-set');
end

end

