function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all Steps from a given set of table keys.
    %
    %   The SqlClient must be connected.
    %
    %Required Arguments:
    %   objKeys (int32): An array of Step objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.Step): An array of Steps
    %
    %See also: bose.cnc.meas.Step, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Step.loadFromDatabase

    % Alex Coleman
    % $Id$

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);
    sqlClient = bose.cnc.datastore.SqlClient.start;

    % Loop over every key
    obj = bose.cnc.meas.Step.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            warning('bose:cnc:meas:Step:loadFromDatabase:NotFound', ...
                    'No record matched StepKey %.0f in database %s', ...
                    objKeys(indObj), sqlClient.DatabaseName);
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, objKey)
    % Get the result table that contains keys
    tableName = sprintf('%s.WH.Steps', sqlClient.DatabaseName);
    keyName = 'StepKey';
    fetchString = sprintf('SELECT * FROM %s WHERE %s = %.0f', ...
                          tableName, keyName, objKey);

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    if isempty(objTable)
        obj = bose.cnc.meas.Step.empty;
    else
        templateStruct = bose.cnc.meas.Step.template;

        % Replace keys with objects for each property of Step.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        % Name
        templateStruct.Name = objTable.StepName{rowIndex};

        % Input & Output Signals
        [inputSignals, outputSignals] = local_loadSignals(sqlClient, objKey);
        templateStruct.InputSignals = inputSignals;
        templateStruct.OutputSignals = outputSignals;

        % ExcitationFilters, ExcitationGain, ExcitationType - Dependent on OutputSignals
        templateStruct.ExcitationGain = ...
            bose.cnc.datastore.decodeBase64(objTable.ExcitationGain{rowIndex}, 'double');
        templateStruct.ExcitationFilters = bose.cnc.math.unwrapSos( ...
            bose.cnc.datastore.decodeBase64( ...
                objTable.ExcitationFilters{rowIndex}, ...
                'double' ...
            ), ...
            numel(outputSignals) ...
        );
        templateStruct.ExcitationType = objTable.ExcitationType{rowIndex};

        % LoopOverFits
        templateStruct.LoopOverFits = objTable.LoopOverFits(rowIndex);

        % SaveTimeData
        templateStruct.SaveTimeData = objTable.SaveTimeData(rowIndex);

        % SignalParameters
        signalParametersKey = objTable.SignalParametersKey(rowIndex);
        templateStruct.SignalParameters = ...
            bose.cnc.meas.SignalParameters.loadFromDatabase(signalParametersKey);

        % Type
        templateStruct.Type = objTable.StepType{rowIndex};

        % Construct the object
        obj = bose.cnc.meas.Step(templateStruct);
    end
end % local_loadSingleFromDatabase

function [inputSignals, outputSignals] = local_loadSignals(sqlClient, objKey)
    inputSignals = bose.cnc.meas.Signal.empty;
    outputSignals = bose.cnc.meas.Signal.empty;
    tableName = sprintf('%s.WH.StepSignalXref', sqlClient.DatabaseName);
    keyName = 'StepKey';

    % Fetch all the Signals for this Step
    fetchString = sprintf( ...
        'SELECT SignalKey FROM %s WHERE %s = %.0f ORDER BY SignalOrder ASC', ...
        tableName, ...
        keyName, ...
        objKey ...
    );

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, return empty early
    if isempty(objTable)
        return
    end

    % Load all of the signals
    allSignals = bose.cnc.meas.Signal.loadFromDatabase(objTable.SignalKey);

    % Sort inputs from outputs
    signalTypes = reshape([allSignals.Type], size(allSignals));
    inputSignals = allSignals(signalTypes.isInput);
    outputSignals = allSignals(signalTypes.isOutput);
end % local_loadSignals
