function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all HeadphoneTypes from a given set of table keys.
    %
    %   The SqlClient must be connected.
    %
    %Required Arguments:
    %   objKeys (int32): An array of HeadphoneType objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.HeadphoneType): An array of HeadphoneTypes
    %
    %See also: bose.cnc.meas.HeadphoneType, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.HeadphoneType.saveToDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:HeadphoneType:loadFromDatabase:';

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);
    sqlClient = bose.cnc.datastore.SqlClient.start;

    % Loop over every key
    obj = bose.cnc.meas.HeadphoneType.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            warning( ...
                [idHeader 'NotFound'], ...
                'No record matched HeadphoneTypeKey %.0f in database %s', ...
                objKeys(indObj), ...
                sqlClient.DatabaseName ...
            );
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, objKey)
    % Get the result table that contains keys
    tableName = sprintf('%s.WH.HeadphoneTypes', sqlClient.DatabaseName);
    keyName = 'HeadphoneTypeKey';
    fetchString = sprintf( ...
        'SELECT * FROM %s WHERE %s = %.0f', ...
        tableName, ...
        keyName, ...
        objKey ...
    );

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, output an empty array.
    if isempty(objTable)
        obj = bose.cnc.meas.HeadphoneType.empty;
    else
        templateStruct = bose.cnc.meas.HeadphoneType.template;

        % Replace keys with objects for each property of HeadphoneType.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        templateStruct.FormFactor = bose.cnc.meas.HeadphoneFormFactor.fromLabel(objTable.HeadphoneFormFactor{rowIndex});
        templateStruct.Name = objTable.HeadphoneTypeName{rowIndex};

        parentKey = objTable.ParentHeadphoneTypeKey(rowIndex);
        if ~isnan(parentKey)
            parentObj = local_loadSingleFromDatabase(sqlClient, parentKey);
            templateStruct.Parent = parentObj.Name;
        end

        projectKey = objTable.ProjectKey(rowIndex);
        if ~isnan(projectKey)
            templateStruct.Project = local_loadProjectName(sqlClient, projectKey);
        end

        obj = bose.cnc.meas.HeadphoneType(templateStruct);
    end
end % local_loadSingleFromDatabase

function projectName = local_loadProjectName(sqlClient, objKey)
    % Get the result table that contains keys
    tableName = sprintf('%s.WH.Projects', sqlClient.DatabaseName);
    keyName = 'ProjectKey';
    fetchString = sprintf( ...
        'SELECT ProjectName FROM %s WHERE %s = %.0f', ...
        tableName, ...
        keyName, ...
        objKey ...
    );

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, output an empty string.
    if isempty(objTable)
        projectName = "";
    else
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.
        projectName = objTable.ProjectName{rowIndex};
    end
end % local_loadProjectName
