function objKeys = saveToDatabase(obj)
    %SAVETODATABASE Saves each Headphone through a database connection.
    %
    %   If there is a duplicate object, this method will return the key of the
    %   original record instead of creating a new object in the Database.
    %
    %   The SqlClient must be connected.
    %
    %Returns:
    %   objKeys (int32): Table Key for the stored Headphone.
    %
    %See also: bose.cnc.meas.Headphone, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Headphone.loadFromDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Headphone:saveToDatabase:';

    sqlClient = bose.cnc.datastore.SqlClient.start;

    storedProcedureName = sprintf('%s.FR.getHeadphoneKey', sqlClient.DatabaseName);

    % Loop over every Headphone given
    objKeys = int32(zeros(numel(obj), 1));

    for indObj = 1:numel(obj)

        if ~obj(indObj).isValid
            warning( ...
                [idHeader 'InvalidHeadphone'], ...
                [ ...
                    'This Headphone (%d of %d) was invalid and will not be ' ...
                    'uploaded to the database.' ...
                ], ...
                indObj, ...
                numel(obj) ...
            );
            objKeys(indObj) = int32(0);
            continue
        end

        typeKey = obj(indObj).Type.saveToDatabase;

        % Convert datetime to correct format
        manufactureDate = string(obj(indObj).ManufactureDate, sqlClient.DatetimeSendFormat);

        fetchString = sprintf( ...
            "EXECUTE %s '%s', '%s', '%s', '%s', '%s', '%s'", ...
            storedProcedureName, ...
            obj(indObj).Name, ...
            obj(indObj).Type.Name, ...
            obj(indObj).Description, ...
            manufactureDate, ...
            obj(indObj).SerialNumber, ...
            obj(indObj).Side ...
        );

        %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
        try
            objKeyTable = sqlClient.fetch(fetchString);
            objKey = int32(objKeyTable.HeadphoneKey);

            local_saveAddedPropertyKey(sqlClient, objKey, obj(indObj).AdditionalProperties);
        catch ME

            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                warning( ...
                    [idHeader 'UploadFailed'], ...
                    'This Headphone (%d of %d) failed to be uploaded. %s', ...
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

function local_saveAddedPropertyKey(sqlClient, deviceKey, addedPropertyArray)
    idHeader = 'bose:cnc:meas:Headphone:saveToDatabase:';

    % Store the AddedProperty array.
    addedPropertyKeys = addedPropertyArray.saveToDatabase;

    % Create the cross-reference for every property
    procedureName = sprintf('%s.WH.GetHeadphonesPropertyXrefKey', ...
    sqlClient.DatabaseName);
    objKeys = int32(zeros(numel(addedPropertyKeys), 1));

    for indKey = 1:numel(addedPropertyKeys)
        fetchString = sprintf( ...
            "EXECUTE %s %.0f, %.0f", ...
            procedureName, ...
            deviceKey, ...
            addedPropertyKeys(indKey) ...
        );

        try
            objKeyTable = sqlClient.fetch(fetchString);
            objKey = int32(objKeyTable.HeadphonesPropertyXrefKey);
        catch ME

            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                warning( ...
                    [idHeader 'UploadFailed'], ...
                    [ ...
                        'This HeadphonesPropertyXrefKey (%d of %d) failed ' ...
                        'to be uploaded. %s' ...
                    ], ...
                    indKey, ...
                    numel(addedPropertyKeys), ...
                    sqlClient.Message ...
                );
                objKey = int32(0);
            else
                rethrow(ME);
            end

        end

        objKeys(indKey) = objKey;
        %TODO(ALEX): If an object fails to upload or is invalid, its key will be zero in this array.
    end % For every object to upload

end % local_saveAddedPropertyKey
