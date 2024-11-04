function objKeys = saveToDatabase(obj)
    %SAVETODATABASE Saves each Person through a database connection.
    %
    %   If there is a duplicate object, this method will return the key of the
    %   original record instead of creating a new object in the Database.
    %
    %   The SqlClient must be connected.
    %
    %Returns:
    %   objKeys (int32): Table Key for the stored Person.
    %
    %See also: bose.cnc.meas.Person, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Person.loadFromDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Person:saveToDatabase:';

    sqlClient = bose.cnc.datastore.SqlClient.start;

    storedProcedureName = sprintf('%s.FR.getPersonKey', ...
        sqlClient.DatabaseName);

    % Loop over every Person given
    objKeys = int32(zeros(numel(obj), 1));
    [objValid, objReasons] = obj.isValid;

    for indObj = 1:numel(obj)

        if ~objValid(indObj)
            warning( ...
                [idHeader 'InvalidPerson'], ...
                strjoin([objReasons{indObj}], '\n') ...
            );
            objKeys(indObj) = int32(0);
            continue
        end

        fetchString = sprintf( ...
            "EXECUTE %s '%s'", ...
            storedProcedureName, ...
            obj(indObj).DisplayName ...
        );

        %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
        try
            objKeyTable = sqlClient.fetch(fetchString);
            objKey = int32(objKeyTable.PersonKey);
        catch ME

            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                warning( ...
                    [idHeader 'UploadFailed'], ...
                    'This Person (%d of %d) failed to be uploaded. %s', ...
                    indObj, ...
                    numel(obj), ...
                    sqlClient.Message ...
                );
                objKey = int32(0);
            else
                rethrow(ME);
            end

        end

        objKeys(indObj) = objKey;
    end % For every object to upload

end % saveToDatabase
