function objKeys = saveToDatabase(obj)
    %SAVETODATABASE Saves each Environment through a database connection.
    %
    %   If there is a duplicate object, this method will return the key of the
    %   original record instead of creating a new object in the Database.
    %
    %   The SqlClient must be connected.
    %
    %Returns:
    %   objKeys (int32): Table Key for the stored Environment.
    %
    %See also: bose.cnc.meas.Environment, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Environment.loadFromDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Environment:saveToDatabase:';

    sqlClient = bose.cnc.datastore.SqlClient.start;

    storedProcedureName = sprintf( ...
        '%s.WH.GetEnvironmentKey', ...
        sqlClient.DatabaseName ...
    );

    % Loop over every Environment given
    objKeys = int32(zeros(numel(obj), 1));

    for indObj = 1:numel(obj)

        if ~obj(indObj).isValid
            warning( ...
                [idHeader 'InvalidEnvironment'], ...
                [ ...
                    'This Environment (%d of %d) was invalid and will not ' ...
                    'be uploaded to the database.' ...
                ], ...
                indObj, ...
                numel(obj) ...
            );
            objKeys(indObj) = int32(0);
            continue
        end

        fetchString = sprintf( ...
            "EXECUTE %s '%s', '%s'", ...
            storedProcedureName, ...
            obj(indObj).Name, ...
            obj(indObj).Description ...
        );

        %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
        try
            objKeyTable = sqlClient.fetch(fetchString);
            objKey = int32(objKeyTable.EnvironmentKey);
        catch ME

            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                warning( ...
                    [idHeader 'UploadFailed'], ...
                    'This Environment (%d of %d) failed to be uploaded. %s', ...
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
        %TODO(ALEX): If an object fails to upload or is invalid, its key will be zero in this array.
    end % For every object to upload

end % saveToDatabase
