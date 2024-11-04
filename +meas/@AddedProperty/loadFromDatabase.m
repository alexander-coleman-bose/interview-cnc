function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all AddedPropertys from a given set of table keys.
    %
    %   The SqlClient must be connected.
    %
    %Required Arguments:
    %   objKeys (int32): An array of AddedProperty objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.AddedProperty): An array of AddedPropertys
    %
    %See also: bose.cnc.meas.AddedProperty, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.AddedProperty.saveToDatabase

    % Alex Coleman
    % $Id$

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);
    sqlClient = bose.cnc.datastore.SqlClient.start;

    % Loop over every key
    obj = bose.cnc.meas.AddedProperty.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            warning('bose:cnc:meas:AddedProperty:loadFromDatabase:NotFound', ...
                    'No record matched AddedPropertyKey %.0f in database %s', ...
                    objKeys(indObj), sqlClient.DatabaseName);
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, objKey)
    % Get the result table that contains keys
    tableName = sprintf('%s.FR.Properties', sqlClient.DatabaseName);
    keyName = 'PropertyKey';
    fetchString = sprintf('SELECT * FROM %s WHERE %s = %.0f', ...
                          tableName, keyName, objKey);

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, output an empty array.
    if isempty(objTable)
        obj = bose.cnc.meas.AddedProperty.empty;
    else
        templateStruct = bose.cnc.meas.AddedProperty.template;

        % Replace keys with objects for each property of AddedProperty.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        templateStruct.Description = local_loadPropertyType( ...
            sqlClient, ...
            objTable.PropertyTypeKey(rowIndex) ...
        );

        templateStruct.Value = objTable.Value(rowIndex);
        templateStruct.ValueStr = objTable.ValueStr{rowIndex};

        obj = bose.cnc.meas.AddedProperty(templateStruct);
    end
end % local_loadSingleFromDatabase

function outStr = local_loadPropertyType(sqlClient, objKey)
    tableName = sprintf('%s.FR.PropertyType', sqlClient.DatabaseName);
    keyName = 'PropertyTypeKey';
    fetchString = sprintf('SELECT Description FROM %s WHERE %s = %.0f', ...
                          tableName, keyName, objKey);

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    if isempty(objTable)
        error( ...
            'bose:cnc:meas:AddedProperty:loadFromDatabase:EmptyDescription', ...
            'No Description for Property Type %.0f on table %s', ...
            objKey, ...
            tableName ...
        );
    else
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.
        outStr = objTable.Description{rowIndex};
    end
end % local_loadPropertyType
