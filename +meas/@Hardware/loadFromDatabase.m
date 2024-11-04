function obj = loadFromDatabase(varargin)
    %LOADFROMDATABASE Loads all Hardware from a given set of table keys.
    %
    %   The SqlClient must be connected.
    %
    %Required Arguments:
    %   objKeys (int32): An array of Hardware objects to retrieve.
    %
    %Returns:
    %   obj (bose.cnc.meas.Hardware): An array of Hardware
    %
    %See also: bose.cnc.meas.Hardware, bose.cnc.datastore.SqlClient,
    %   bose.cnc.meas.Hardware.saveToDatabase

    % Alex Coleman
    % $Id$

    parser = inputParser;
    parser.addRequired('objKeys');
    parser.parse(varargin{:})
    objKeys = int32(parser.Results.objKeys);
    sqlClient = bose.cnc.datastore.SqlClient.start;

    % Loop over every key
    obj = bose.cnc.meas.Hardware.empty;
    for indObj = 1:numel(objKeys)
        thisObj = local_loadSingleFromDatabase(sqlClient, objKeys(indObj));

        % If the object wasn't able to found, thisObj will be empty. Warn.
        if isempty(thisObj)
            warning('bose:cnc:meas:Hardware:loadFromDatabase:NotFound', ...
                    'No record matched HardwareKey %.0f in database %s', ...
                    objKeys(indObj), sqlClient.DatabaseName);
        end

        %TODO(ALEX): We may be able to increase speed by performing a single fetch for multiple keys.
        obj = [obj; thisObj];
    end
end % loadFromDatabase

function obj = local_loadSingleFromDatabase(sqlClient, objKey)
    % Get the result table that contains keys
    tableName = sprintf('%s.WH.Hardware', sqlClient.DatabaseName);
    keyName = 'HardwareKey';
    fetchString = sprintf('SELECT * FROM %s WHERE %s = %.0f', ...
                          tableName, keyName, objKey);

    %TODO(ALEX): Once we know what errIDs typically pop out of the DB, we can catch them and continue.
    objTable = sqlClient.fetch(fetchString);

    % If the table is empty, output an empty array.
    if isempty(objTable)
        obj = bose.cnc.meas.Hardware.empty;
    else
        templateStruct = bose.cnc.meas.Hardware.template;

        % Replace keys with objects for each property of Hardware.
        rowIndex = 1; %HACK(ALEX): Since we are only pulling one row at a time.

        % Calibration Mode
        templateStruct.CalibrationMode = ...
            bose.cnc.meas.CalibrationMode(objTable.HardwareCalibrationMode{rowIndex});

        % Hardware Model/Name/Type
        templateStruct.DeviceModel = objTable.HardwareDeviceModel{rowIndex};
        templateStruct.DeviceName = objTable.HardwareDeviceName{rowIndex};
        templateStruct.Type = ...
            bose.cnc.meas.HardwareType(objTable.HardwareType{rowIndex});

        % Configuration Name
        templateStruct.Name = objTable.HardwareName{rowIndex};

        % NumChannels
        templateStruct.NumAnalogInputs = objTable.HardwareNumAnalogInputs;
        templateStruct.NumAnalogOutputs = objTable.HardwareNumAnalogOutputs;
        templateStruct.NumDigitalInputs = objTable.HardwareNumDigitalInputs;
        templateStruct.NumDigitalOutputs = objTable.HardwareNumDigitalOutputs;

        % Handle the concatenated strings that might be ""
        connectionParametersRaw = objTable.HardwareConnectionParameters{rowIndex};
        if strcmp(connectionParametersRaw, "")
            templateStruct.ConnectionParameters = string.empty;
        else
            templateStruct.ConnectionParameters = strsplit(connectionParametersRaw, ',');
        end

        % Construct the object
        obj = bose.cnc.meas.Hardware(templateStruct);
    end
end % local_loadSingleFromDatabase
