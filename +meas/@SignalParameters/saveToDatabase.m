function objKeys = saveToDatabase(obj)
    %SAVETODATABASE Saves each SignalParameters through a database connection.
    %
    %   If there is a duplicate object, this method will return the key of the
    %   original record instead of creating a new object in the Database.
    %
    %   The SqlClient must be connected.
    %
    %Returns:
    %   objKeys (int32): Table Key for the stored SignalParameters.
    %
    %See also: bose.cnc.meas.SignalParameters, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.SignalParameters.loadFromDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:SignalParameters:saveToDatabase:';

    sqlClient = bose.cnc.datastore.SqlClient.start;

    storedProcedureName = sprintf('%s.WH.GetSignalParametersKey', sqlClient.DatabaseName);

    % Loop over every SignalParameters given
    objKeys = int32(zeros(numel(obj), 1));
    [objValid, objReasons] = obj.isValid;

    for indObj = 1:numel(obj)

        if ~objValid(indObj)
            warning( ...
                [idHeader 'InvalidSignalParameters'], ...
                strjoin([objReasons{indObj}], '\n') ...
            );
            objKeys(indObj) = int32(0);
            continue
        end

        %FIXME(ALEX): Data is currently being truncated.
        fetchString = sprintf( ...
        "EXECUTE %s '%s', %.0f, %.0f, %f, %f, %f, %f, %f", ...
            storedProcedureName, ...
            obj(indObj).Window, ...
            obj(indObj).NOverlap, ...
            obj(indObj).Nfft, ...
            obj(indObj).TUp, ...
            obj(indObj).TPrerun, ...
            obj(indObj).TRecord, ...
            obj(indObj).TDown, ...
            obj(indObj).Fs ...
        );

        %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
        try
            objKeyTable = sqlClient.fetch(fetchString);
            objKey = int32(objKeyTable.SignalParametersKey);
        catch ME

            if strcmp(ME.identifier, 'database:database:JDBCDriverError')
                warning( ...
                    [idHeader 'UploadFailed'], ...
                    [ ...
                        'This SignalParameters (%d of %d) failed to be ' ...
                        'uploaded. %s' ...
                    ], ...
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
