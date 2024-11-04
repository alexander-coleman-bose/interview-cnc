function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all Mapping objects from a given set of table keys.
    %
    %   The SqlClient must be connected.
    %
    %Required Arguments:
    %   objKeys (int32): An array of Mapping objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.Mapping): An array of Mappings
    %
    %See also: bose.cnc.meas.Mapping, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Mapping.saveToDatabase

    % Alex Coleman
    % $Id$

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);
    sqlClient = bose.cnc.datastore.SqlClient.start;

    % Loop over every key
    obj = bose.cnc.meas.Mapping.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            warning('bose:cnc:meas:Mapping:loadFromDatabase:NotFound', ...
                    'No record matched MappingKey %.0f in database %s', ...
                    objKeys(indObj), sqlClient.DatabaseName);
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, objKey)
    % Get the result table that contains keys
    tableName = sprintf('%s.WH.Mappings', sqlClient.DatabaseName);
    keyName = 'MappingKey';
    fetchString = sprintf('SELECT * FROM %s WHERE %s = %.0f', ...
                          tableName, keyName, objKey);

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, output an empty array.
    if isempty(objTable)
        obj = bose.cnc.meas.Mapping.empty;
    else
        templateStruct = bose.cnc.meas.Mapping.template;

        % Replace keys with objects for each property of Mapping.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        templateStruct.Channel = objTable.MappingChannel{rowIndex};
        templateStruct.Signal = ...
            bose.cnc.meas.Signal.loadFromDatabase(objTable.SignalKey(rowIndex));

        obj = bose.cnc.meas.Mapping(templateStruct);
    end
end % local_loadSingleFromDatabase
