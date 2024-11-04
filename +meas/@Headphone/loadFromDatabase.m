function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all Headphones from a given set of table keys.
    %
    %   The SqlClient must be connected.
    %
    %Required Arguments:
    %   objKeys (int32): An array of Headphone objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.Headphone): An array of Headphones
    %
    %See also: bose.cnc.meas.Headphone, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Headphone.saveToDatabase

    % Alex Coleman
    % $Id$

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);
    sqlClient = bose.cnc.datastore.SqlClient.start;

    % Loop over every key
    obj = bose.cnc.meas.Headphone.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            warning('bose:cnc:meas:Headphone:loadFromDatabase:NotFound', ...
                    'No record matched HeadphoneKey %.0f in database %s', ...
                    objKeys(indObj), sqlClient.DatabaseName);
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, objKey)
    % Get the result table that contains keys
    tableName = sprintf('%s.WH.Headphones', sqlClient.DatabaseName);
    keyName = 'HeadphoneKey';
    fetchString = sprintf('SELECT * FROM %s WHERE %s = %.0f', ...
                          tableName, keyName, objKey);

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, output an empty array.
    if isempty(objTable)
        obj = bose.cnc.meas.Headphone.empty;
    else
        templateStruct = bose.cnc.meas.Headphone.template;

        % Replace keys with objects for each property of Headphone.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        % AdditionalProperties
        templateStruct.AdditionalProperties = local_loadAddedProperty(sqlClient, objKey);

        % Description
        templateStruct.Description = objTable.Description{rowIndex};

        % ManufactureDate
        templateStruct.ManufactureDate = datetime(objTable.ManufactureDate{rowIndex}, 'InputFormat', sqlClient.DatetimeSelectFormat);

        % Name
        templateStruct.Name = objTable.HeadphoneName{rowIndex};

        % SerialNumber
        templateStruct.SerialNumber = objTable.SerialNumber{rowIndex};

        % Side
        templateStruct.Side = objTable.Side{rowIndex};

        % Type
        typeKey = objTable.HeadphoneTypeKey(rowIndex);
        headphoneType = bose.cnc.meas.HeadphoneType.loadFromDatabase(typeKey);
        templateStruct.Type = headphoneType;

        obj = bose.cnc.meas.Headphone(templateStruct);
    end
end % local_loadSingleFromDatabase

function addedProperties = local_loadAddedProperty(sqlClient, deviceKey)
    tableName = sprintf('%s.FR.HeadphonesPropertyXref', sqlClient.DatabaseName);
    keyName = 'HeadphoneKey';

    fetchString = sprintf('SELECT PropertyKey FROM %s WHERE %s = %.0f', ...
                          tableName, keyName, deviceKey);

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, return empty
    if isempty(objTable)
        addedProperties = bose.cnc.meas.AddedProperty.empty;
    else
        addedProperties = ...
            bose.cnc.meas.AddedProperty.loadFromDatabase(objTable.PropertyKey);
    end
end % local_loadAddedProperty
