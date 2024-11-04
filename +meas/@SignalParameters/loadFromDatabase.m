function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all SignalParameters from a given set of table keys.
    %
    %   The SqlClient must be connected.
    %
    %Required Arguments:
    %   objKeys (int32): An array of SignalParameters objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.SignalParameters): An array of SignalParameters
    %
    %See also: bose.cnc.meas.SignalParameters,
    %   bose.cnc.meas.SignalParameters.saveToDatabase

    % Alex Coleman
    % $Id$

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);
    sqlClient = bose.cnc.datastore.SqlClient.start;

    % Loop over every key
    obj = bose.cnc.meas.SignalParameters.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            warning('bose:cnc:meas:SignalParameters:loadFromDatabase:NotFound', ...
                    'No record matched SignalParametersKey %.0f in database %s', ...
                    objKeys(indObj), sqlClient.DatabaseName);
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, objKey)
    % Get the result table that contains keys
    tableName = sprintf('%s.WH.SignalParameters', sqlClient.DatabaseName);
    keyName = 'SignalParametersKey';
    fetchString = sprintf('SELECT * FROM %s WHERE %s = %.0f', ...
                          tableName, keyName, objKey);

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, output an empty array.
    if isempty(objTable)
        obj = bose.cnc.meas.SignalParameters.empty;
    else
        templateStruct = bose.cnc.meas.SignalParameters.template;

        % Replace keys with objects for each property of SignalParameters.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        templateStruct.Fs = objTable.SignalParameterFs(rowIndex);
        templateStruct.Nfft = objTable.SignalParameterNfft(rowIndex);
        templateStruct.NOverlap = objTable.SignalParameterNOverlap(rowIndex);
        templateStruct.TUp = objTable.SignalParameterTUp(rowIndex);
        templateStruct.TPrerun = objTable.SignalParameterTPrerun(rowIndex);
        templateStruct.TRecord = objTable.SignalParameterTRecord(rowIndex);
        templateStruct.TDown = objTable.SignalParameterTDown(rowIndex);
        templateStruct.Window = objTable.SignalParameterWindow{rowIndex};

        obj = bose.cnc.meas.SignalParameters(templateStruct);
    end
end % local_loadSingleFromDatabase
