function objKeys = saveToDatabase(obj)
    %SAVETODATABASE Saves each AddedProperty through a database connection.
    %
    %   If there is a duplicate object, this method will return the key of the
    %   original record instead of creating a new object in the Database.
    %
    %   The SqlClient must be connected.
    %
    %Returns:
    %   objKeys (int32): Table Key for the stored AddedProperty.
    %
    %See also: bose.cnc.meas.AddedProperty, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.AddedProperty.loadFromDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:AddedProperty:saveToDatabase:';

    sqlClient = bose.cnc.datastore.SqlClient.start;

    storedProcedureName = sprintf('%s.FR.getPropertyKey', sqlClient.DatabaseName);

    % Loop over every AddedProperty given
    objKeys = int32(zeros(numel(obj), 1));
    [objValid, objReasons] = obj.isValid;

    for indObj = 1:numel(obj)

        if ~objValid(indObj)
            warning( ...
                [idHeader 'InvalidAddedProperty'], ...
                strjoin([objReasons{indObj}], '\n') ...
            );
            objKeys(indObj) = int32(0);
            continue
        end

        fetchString = sprintf( ...
            "EXECUTE %s '%s', %s, '%s'", ...
            storedProcedureName, ...
            obj(indObj).Description, ...
            string(obj(indObj).Value), ... %HACK(ALEX): We only attempt to store Value as a string.
            obj(indObj).ValueStr ...
        );

        %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
        try
            objKeyTable = sqlClient.fetch(fetchString);
            objKey = int32(objKeyTable.PropertyKey);
        catch ME

            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                warning( ...
                    [idHeader 'UploadFailed'], ...
                    'This AddedProperty (%d of %d) failed to be uploaded. %s', ...
                    indObj, numel(obj), sqlClient.Message ...
                );
                objKey = int32(0);
            else
                rethrow(ME);
            end

        end

        objKeys(indObj) = objKey;
    end % For every object to upload

end % saveToDatabase
