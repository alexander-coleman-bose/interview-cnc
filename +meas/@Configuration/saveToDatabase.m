function [objKeys, configurationVersions] = saveToDatabase(obj)
    %SAVETODATABASE Saves each Configuration through a database connection.
    %
    %   If there is a duplicate object, this method will return the key of the
    %   original record instead of creating a new object in the Database.
    %
    %   The SqlClient must be connected.
    %
    %Returns:
    %   objKeys (int32): Table keys for the stored Configuration.
    %   configurationVersions (int32): Version numbers for the stored
    %       Configurations.
    %
    %See also: bose.cnc.meas.Configuration, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Configuration.loadFromDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Configuration:saveToDatabase:';
    logger = bose.cnc.logging.getLogger;

    sqlClient = bose.cnc.datastore.SqlClient.start;
    bose.cnc.validators.mustBeConnected(sqlClient);

    storedProcedureName = sprintf( ...
        '%s.WH.GetConfigurationKey', ...
        sqlClient.DatabaseName ...
    );

    nargoutchk(0, 2);

    % Loop over every Configuration given
    objKeys = int32(zeros(numel(obj), 1));
    configurationVersions = int32(zeros(numel(obj), 1));
    [objValid, objReasons] = obj.isValid;
    for indObj = 1:numel(obj)
        if ~objValid(indObj)
            logger.warning(strjoin([objReasons{indObj}], '\n'));
            objKeys(indObj) = int32(0);
            configurationVersions(indObj) = int32(0);
            continue
        end

        designerKey = obj(indObj).Designer.saveToDatabase;

        % Convert datetime to correct format
        dateCreated = string(obj(indObj).DateCreated, sqlClient.DatetimeSendFormat);

        % Save the Steps first
        try
            stepKeys = obj(indObj).Sequence.saveToDatabase;
        catch ME
            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                logger.warning(sprintf( ...
                    [ ...
                        'The Steps for this Configuration (%d of %d) ' ...
                        'failed to be uploaded: %s' ...
                    ], ...
                    indObj, ...
                    numel(obj), ...
                    sqlClient.Message ...
                ));
                objKeys(indObj) = int32(0);
                configurationVersions(indObj) = int32(0);
                continue
            else
                logger.error(sprintf('%s', ME.message), ME);
            end
        end
        stepKeyString = strjoin(string(stepKeys), ',');

        fetchString = sprintf( ...
            "EXECUTE %s %.0f, '%s', %.0f, '%s', '%s'", ...
            storedProcedureName, ...
            obj(indObj).NumFits, ...
            dateCreated, ...
            designerKey, ...
            obj(indObj).Name, ...
            stepKeyString ...
        );

        try
            logger.debug(sprintf('%s:fetchString => %s', idHeader, fetchString));
            objKeyTable = sqlClient.fetch(fetchString);
            if ismember('ErrorProcedure', objKeyTable.Properties.VariableNames)
                logger.warning(sprintf( ...
                    '%s (line %.0f): %s', ...
                    string(objKeyTable.ErrorProcedure), ...
                    objKeyTable.ErrorLine, ...
                    string(objKeyTable.ErrorMessage) ...
                ));
                objKey = int32(0);
                configurationVersion = int32(0);
            else % if no exception
                objKey = int32(objKeyTable.ConfigurationKey);
                configurationVersion = int32(objKeyTable.ConfigurationVersion);
                logger.info(sprintf( ...
                    'Wrote Configuration #%d (%d of %d) to %s', ...
                    objKey, ...
                    indObj, ...
                    numel(obj), ...
                    sqlClient.DatabaseName ...
                ));
            end
        catch ME
            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                logger.warning(sprintf( ...
                    'This Configuration (%d of %d) failed to be uploaded. %s', ...
                    indObj, ...
                    numel(obj), ...
                    sqlClient.Message ...
                ));
                objKey = int32(0);
                configurationVersion = int32(0);
            else
                logger.error(sprintf('%s', ME.message), ME);
            end
        end

        objKeys(indObj) = objKey;
        configurationVersions(indObj) = configurationVersion;
    end % For every object to upload
end % saveToDatabase
