function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all Configurations from a given set of table keys.
    %
    %   The SqlClient must be connected.
    %
    %Required Arguments:
    %   objKeys (int32): An array of Configuration objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.Configuration): An array of configurations
    %
    %See also: bose.cnc.meas.Configuration, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Configuration.saveToDatabase

    % Alex Coleman
    % $Id$

    logger = bose.cnc.logging.getLogger;

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);

    sqlClient = bose.cnc.datastore.SqlClient.start;
    bose.cnc.validators.mustBeConnected(sqlClient);

    % Loop over every key
    obj = bose.cnc.meas.Configuration.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            logger.warning(sprintf( ...
                'No record matched ConfigurationKey %d (%d of %d) in database %s', ...
                objKeys(indObj), ...
                indObj, ...
                numel(objKeys), ...
                sqlClient.DatabaseName ...
            ));
        else
            logger.info(sprintf( ...
                'Loaded Configuration #%d (%d of %d) from %s', ...
                objKeys(indObj), ...
                indObj, ...
                numel(objKeys), ...
                sqlClient.DatabaseName ...
            ));
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, objKey)
    idHeader = 'bose:cnc:meas:Configuration:loadFromDatabase:';

    % Get the result table that contains keys
    tableName = sprintf('%s.WH.Configurations', sqlClient.DatabaseName);
    keyName = 'ConfigurationKey';
    fetchString = sprintf( ...
        'SELECT * FROM %s WHERE %s = %.0f', ...
        tableName, ...
        keyName, ...
        objKey ...
    );
    logger = bose.cnc.logging.getLogger;

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    logger.debug(sprintf('%s:fetchString => %s', idHeader, fetchString));
    objTable = sqlClient.fetch(fetchString);

    if isempty(objTable)
        obj = bose.cnc.meas.Configuration.empty;
    else
        templateStruct = bose.cnc.meas.Configuration.template;

        % Replace keys with objects for each property of Configuration.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        % DateCreated
        templateStruct.DateCreated = datetime( ...
            objTable.ConfigurationDateCreated{rowIndex}, ...
            'InputFormat', sqlClient.DatetimeSelectFormat ...
        );

        % Designer
        designerKey = objTable.ConfigurationDesigner(rowIndex);
        templateStruct.Designer = ...
            bose.cnc.meas.Person.loadFromDatabase(designerKey);

        % Name
        templateStruct.Name = objTable.ConfigurationName{rowIndex};

        % NumFits
        templateStruct.NumFits = objTable.ConfigurationNumFits(rowIndex);

        % Sequence
        templateStruct.Sequence = local_loadSteps(sqlClient, objKey);

        % Build the object
        obj = bose.cnc.meas.Configuration(templateStruct);
    end
end % local_loadSingleFromDatabase

function stepArray = local_loadSteps(sqlClient, objKey)
    idHeader = 'bose:cnc:meas:Configuration:loadFromDatabase:';
    
    tableName = sprintf('%s.WH.ConfigurationStepXref', sqlClient.DatabaseName);
    keyName = 'ConfigurationKey';
    logger = bose.cnc.logging.getLogger;

    % For inputSignals
    fetchString = sprintf( ...
        'SELECT StepKey FROM %s WHERE %s = %.0f', ...
        tableName, ...
        keyName, ...
        objKey ...
    );

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    logger.debug(sprintf('%s:fetchString => %s', idHeader, fetchString));
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, return empty
    if ~isempty(objTable)
        stepArray = bose.cnc.meas.Step.loadFromDatabase(objTable.StepKey);
    end
end % local_loadMapping
