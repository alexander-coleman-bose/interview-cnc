function objKeys = saveToDatabase(obj)
    %SAVETODATABASE Saves each Signal through a database connection.
    %
    %   If there is a duplicate object, this method will return the key of the
    %   original record instead of creating a new object in the Database.
    %
    %   The SqlClient must be connected.
    %
    %Returns:
    %   objKeys (int32): Table Key for the stored Signal.
    %
    %See also: bose.cnc.meas.Signal, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Signal.loadFromDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Signal:saveToDatabase:';

    sqlClient = bose.cnc.datastore.SqlClient.start;

    storedProcedureName = sprintf('%s.WH.GetSignalKey', sqlClient.DatabaseName);

    % Loop over every Signal given
    objKeys = int32(zeros(numel(obj), 1));
    [objValid, objReasons] = obj.isValid;

    for indObj = 1:numel(obj)

        if ~objValid(indObj)
            warning( ...
                [idHeader 'InvalidSignal'], ...
                strjoin([objReasons{indObj}], '\n') ...
            );
            objKeys(indObj) = int32(0);
            continue
        end

        if strcmp(obj(indObj).Units, "")
            unitsString = 'NULL';
        else
            unitsString = sprintf('''%s''', obj(indObj).Units);
        end

        fetchString = sprintf( ...
            "EXECUTE %s '%s', '%s', '%s', '%s', %s", ...
            storedProcedureName, ...
            obj(indObj).Name, ...
            bose.cnc.datastore.encodeBase64(obj(indObj).Scale), ...
            obj(indObj).Side, ...
            obj(indObj).Type, ...
            unitsString ...
        );

        %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
        try
            objKeyTable = sqlClient.fetch(fetchString);
            objKey = int32(objKeyTable.SignalKey);
        catch ME

            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                warning( ...
                    [idHeader 'UploadFailed'], ...
                    'This Signal (%d of %d) failed to be uploaded. %s', ...
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
