function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all DataRecords from a given set of table keys.
    %
    %   The SqlClient must be connected, and the S3Client must be initialized.
    %
    %Required Arguments:
    %   objKeys (int32): An array of DataRecord objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.DataRecord): An array of dataRecords
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.datastore.SqlClient,
    %   bose.cnc.datastore.S3Client, bose.cnc.meas.DataRecord.saveToDatabase

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:DataRecord:loadFromDatabase:';
    logger = bose.cnc.logging.getLogger;

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);
    sqlClient = bose.cnc.datastore.SqlClient.start;
    s3Client = bose.cnc.datastore.S3Client.start;

    % Loop over every key
    obj = bose.cnc.meas.DataRecord.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, s3Client, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            logger.warning(sprintf( ...
                'No record matched DataRecordKey %.0f in database %s', ...
                objKeys(indObj), ...
                sqlClient.DatabaseName ...
            ));
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, s3Client, objKey)
    idHeader = 'bose:cnc:meas:DataRecord:loadFromDatabase:';
    logger = bose.cnc.logging.getLogger;

    % Get the result table that contains keys
    tableName = sprintf('%s.WH.DataRecords', sqlClient.DatabaseName);
    keyName = 'DataRecordKey';

    fetchString = sprintf( ...
        'SELECT * FROM %s WHERE %s = %.0f', ...
        tableName, ...
        keyName, ...
        objKey ...
    );

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    logger.debug(sprintf('%s:fetchString => %s', idHeader, fetchString));
    objTable = sqlClient.fetch(fetchString);

    if isempty(objTable)
        obj = bose.cnc.meas.DataRecord.empty;
    else
        templateStruct = bose.cnc.meas.DataRecord.template;

        % Replace keys with objects for each property of DataRecord.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        % Date
        templateStruct.Date = datetime( ...
            objTable.DataRecordDate{rowIndex}, ...
            'InputFormat', sqlClient.DatetimeSelectFormat ...
        );

        % Environment
        environmentKey = objTable.EnvironmentKey(rowIndex);
        if isnan(environmentKey)
            templateStruct.Environment = bose.cnc.meas.Environment.empty;
        else
            templateStruct.Environment = ...
                bose.cnc.meas.Environment.loadFromDatabase(environmentKey);
        end

        % Fit
        templateStruct.Fit = objTable.DataRecordFit(rowIndex);

        % Hardware
        hardwareKey = objTable.HardwareKey(rowIndex);
        templateStruct.Hardware = ...
            bose.cnc.meas.Hardware.loadFromDatabase(hardwareKey);

        % Headphone
        headphoneKey = objTable.HeadphoneKey(rowIndex);
        if isnan(headphoneKey)
            templateStruct.Headphone = bose.cnc.meas.Headphone.empty;
        else
            templateStruct.Headphone = ...
                bose.cnc.meas.Headphone.loadFromDatabase(headphoneKey);
        end

        % Input & Output Mapping
        [inputMapping, outputMapping] = local_loadMapping(sqlClient, objKey);
        templateStruct.InputMapping = inputMapping;
        templateStruct.OutputMapping = outputMapping;

        % ExcitationFilters, ExcitationGain, ExcitationType - Dependent on OutputMapping
        templateStruct.ExcitationGain = ...
        bose.cnc.datastore.decodeBase64(objTable.DataRecordExcitationGain, 'double');
        wrappedFilters = ...
            bose.cnc.datastore.decodeBase64(objTable.DataRecordExcitationFilters, 'double');
        numelFilterCoeffs = numel(wrappedFilters);
        numOutputs = numel(outputMapping); % numel(mappings) equal to numel(signals)
        if numOutputs == 0
            numBiquads = 0;
        else
            numBiquads = numelFilterCoeffs / numOutputs / 6;
        end
        unwrapSize = [numBiquads, 6, numOutputs];
        templateStruct.ExcitationFilters = reshape(wrappedFilters, unwrapSize);
        templateStruct.ExcitationType = objTable.DataRecordExcitationType{rowIndex};

        % Operator
        operatorKey = objTable.DataRecordOperator(rowIndex);
        templateStruct.Operator = ...
            bose.cnc.meas.Person.loadFromDatabase(operatorKey);

        % SignalParameters
        signalParametersKey = objTable.SignalParametersKey(rowIndex);
        templateStruct.SignalParameters = ...
            bose.cnc.meas.SignalParameters.loadFromDatabase(signalParametersKey);

        % StepName
        templateStruct.StepName = objTable.DataRecordStepName{rowIndex};

        % StepType
        templateStruct.StepType = objTable.DataRecordStepType{rowIndex};

        % Subject
        subjectKey = objTable.DataRecordSubject(rowIndex);
        if isnan(subjectKey)
            templateStruct.Subject = bose.cnc.meas.Person.empty;
        else
            templateStruct.Subject = ...
                bose.cnc.meas.Person.loadFromDatabase(subjectKey);
        end

        % ToolboxVersion
        templateStruct.ToolboxVersion = objTable.DataRecordToolboxVersion{rowIndex};

        % XsData
        templateStruct.XsData = local_loadXsData( ...
            sqlClient, ...
            s3Client, ...
            objTable.XsDataKey(rowIndex) ...
        );

        obj = bose.cnc.meas.DataRecord(templateStruct);
    end
end % local_loadSingleFromDatabase

function xsData = local_loadXsData(sqlClient, s3Client, objKey)
    idHeader = 'bose:cnc:meas:DataRecord:loadFromDatabase:';
    logger = bose.cnc.logging.getLogger;

    % Get the result table that contains keys
    tableName = sprintf('%s.WH.XsData', sqlClient.DatabaseName);
    keyName = 'XsDataKey';

    fetchString = sprintf( ...
        'SELECT XsDataLocation FROM %s WHERE %s = %.0f', ...
        tableName, ...
        keyName, ...
        objKey ...
    );

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    logger.debug(sprintf('%s:fetchString => %s', idHeader, fetchString));
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, output an empty array.
    if isempty(objTable)
        mError = MException( ...
            [idHeader 'XsDataNotFound'], ...
            'No results were found in %s for %s = %.0f', ...
            tableName, ...
            keyName, ...
            objKey ...
        );
        logger.error(sprintf('%s', mError.message), mError);
    else
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        fileLocation = objTable.XsDataLocation{rowIndex};
        xsData = s3Client.load(fileLocation);
    end
end % local_loadXsData

function [inputMapping, outputMapping] = local_loadMapping(sqlClient, objKey)
    idHeader = 'bose:cnc:meas:DataRecord:loadFromDatabase:';
    logger = bose.cnc.logging.getLogger;

    inputMapping = bose.cnc.meas.Mapping.empty;
    outputMapping = bose.cnc.meas.Mapping.empty;
    tableName = sprintf('%s.WH.DataRecordMappingXref', sqlClient.DatabaseName);
    keyName = 'DataRecordKey';

    % For inputSignals
    fetchString = sprintf( ...
        'SELECT MappingKey FROM %s WHERE %s = %.0f AND DataRecordMappingXrefType = 0', ...
        tableName, keyName, objKey ...
    );

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    logger.debug(sprintf('%s:fetchString => %s', idHeader, fetchString));
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, return empty
    if ~isempty(objTable)
        inputMapping = ...
            bose.cnc.meas.Mapping.loadFromDatabase(objTable.MappingKey);
    end

    % For outputSignals
    fetchString = sprintf( ...
        'SELECT MappingKey FROM %s WHERE %s = %.0f AND DataRecordMappingXrefType = 1', ...
        tableName, keyName, objKey ...
    );

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    logger.debug(sprintf('%s:fetchString => %s', idHeader, fetchString));
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, return empty
    if ~isempty(objTable)
        outputMapping = ...
            bose.cnc.meas.Mapping.loadFromDatabase(objTable.MappingKey);
    end
end % local_loadMapping
