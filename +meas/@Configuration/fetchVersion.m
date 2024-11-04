function versionNumbers = fetchVersion(obj)
    %FETCHVERSION Fetch the version number of this Configuration from the database.
    %
    %   If you are not connected to the database, this function will return empty.
    %   You must be connected to the database to fetch version numbers.
    %
    %Returns:
    %   versionNumbers (int32): Version numbers for the stored Configurations. Will
    %       return empty if not connected to the database.
    %
    %See also: bose.cnc.meas.Configuration

    % Alex Coleman
    % $Id$

    sqlClient = bose.cnc.datastore.SqlClient.start;
    versionNumbers = int32.empty;
    if sqlClient.IsConnected
        % Get the Configuration versions
        %HACK(ALEX): This will also upload the Configurations immediately
        [~, versionNumbers] = obj.saveToDatabase;
    end
end % function
