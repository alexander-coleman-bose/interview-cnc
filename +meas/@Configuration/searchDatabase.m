function varargout = searchDatabase(varargin)
    %SEARCHDATABASE Search the currently connected database for matching Configurations.
    %
    %   The SqlClient must be connected.
    %
    %Syntax:
    %   output = bose.cnc.meas.Configuration.searchDatabase('key', searchKey, 'name', searchName, 'latest', searchLatest, 'output', searchOutput);
    %
    %Usage:
    %   Search the database for all Configurations that contain "Smalls" in the
    %   name and return all versions.
    %       output = bose.cnc.meas.Configuration.searchDatabase('name', 'Smalls');
    %
    %   Search the database for a Configuration with a table key of 12.
    %       output = bose.cnc.meas.Configuration.searchDatabase('key', 12);
    %
    %   Search the database for all Configurations that contain "Lando" in the name
    %   and only return the latest versions of each Configuration.
    %       output = bose.cnc.meas.Configuration.searchDatabase('name', 'Lando', 'latest', true);
    %
    %   Search the database for all Configuration that contain "Goodyear" in the
    %   name, and return a table of keys, names, versions, dates, and designers,
    %   which is much faster.
    %       outTable = bose.cnc.meas.Configuration.searchDatabase('name', 'Goodyear', 'output', 'table');
    %
    %Optional Parameter Arguments:
    %   key (numeric or string-like): Search for a specific key on the
    %       Configurations table. (Default: double.empty)
    %   latest (logical): If true, only return the latest version of every
    %       Configuration found. (Default: false)
    %   name (string-like): Search for Configurations which names that contain this
    %       pattern. (Default: string.empty)
    %   output (string-like): Determine the type of output. (Default: "object")
    %       "object": Return bose.cnc.meas.Configuration objects
    %       "table": Return a table with columns for keys, names, version, dates,
    %           and designers. Much faster than returning full objects.
    %
    %Returns:
    %   output (table or bose.cnc.meas.Configuration): All matching Configurations
    %       found on the database, with the type of output determined by the
    %       "output" argument.
    %
    %Errors:
    %   InvalidInput - When "output" isn't "object" or "table".
    %
    %See also: bose.cnc.meas.Configuration, bose.cnc.datastore.SqlClient

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:Configuration:searchDatabase:';
    logger = bose.cnc.logging.getLogger;

    parser = inputParser;
    parser.addParameter('key', double.empty);
    parser.addParameter('latest', false, @(x) isnumeric(x) || islogical(x));
    parser.addParameter('name', string.empty, @bose.common.validators.mustBeStringLike);
    parser.addParameter('output', "object", @bose.common.validators.mustBeStringLike);
    parser.parse(varargin{:});
    if bose.common.validators.isStringLike(parser.Results.key)
        searchKeys = int32(str2double(parser.Results.key));
    else
        searchKeys = int32(parser.Results.key);
    end
    searchLatest = logical(parser.Results.latest);
    searchNames = string(parser.Results.name);
    searchOutput = lower(string(parser.Results.output));

    % Validate 'output' argument
    nargoutchk(0, 1);
    if ~all(ismember(searchOutput, ["object", "table"]))
        mError = MException( ...
            [idHeader 'InvalidInput'], ...
            '"output" argument must be "object" or "table".' ...
        );
        logger.error(sprintf('%s', mError.message), mError);
    end

    % Get a connection to the database, else error
    sqlClient = bose.cnc.datastore.SqlClient.start;
    bose.cnc.validators.mustBeConnected(sqlClient);

    % Generate statements to filter by name or key
    whereStatement = string.empty;
    whereStatements = string.empty;
    if ~isempty(searchKeys)
        whereStatements = [ ...
            whereStatements; ...
            "ConfigurationKey IN (" + join(string(searchKeys), ",") + ")" ...
        ];
    end
    if ~isempty(searchNames)
        whereStatements = [ ...
            whereStatements; ...
            "ConfigurationName LIKE ('%" + join(searchNames, "%','%") + "%')" ...
        ];
    end
    if ~isempty(whereStatements)
        whereStatement = "WHERE (" + join(whereStatements, " AND ") + ")";
    end
    fetchString = sprintf( ...
        [ ...
            'WITH P AS (SELECT PersonKey, RTRIM(LTRIM(CONCAT(FirstName, '' '', LastName))) AS Designer FROM WH.People) ' ...
            'SELECT ConfigurationKey, ConfigurationName AS Name, ConfigurationVersion as Version, ConfigurationDateCreated as DateCreated, Designer ' ...
            'FROM WH.Configurations AS C ' ...
            'JOIN P ON (P.PersonKey=C.ConfigurationDesigner) %s ORDER BY ' ...
            'C.ConfigurationName ASC, C.ConfigurationVersion DESC' ...
        ], ...
        whereStatement ...
    );
    logger.debug(sprintf('%s:fetchString => %s', idHeader, fetchString));
    objTable = sqlClient.fetch(fetchString);
    if ~isempty(objTable)
        objTable.DateCreated = datetime(objTable.DateCreated, 'InputFormat', sqlClient.DatetimeSelectFormat);
        objTable.Name = string(objTable.Name);
        objTable.Designer = string(objTable.Designer);

        % Filter down to latest if requested
        if searchLatest
            % Because of table ordering, the first names found are always the latest versions
            [~, uniqueInd] = unique(string(objTable.Name));
            objTable = objTable(uniqueInd, :);
        end
    end

    % Handle output
    switch searchOutput
    case "object"
        varargout = {bose.cnc.meas.Configuration.loadFromDatabase(objTable.ConfigurationKey)};
    case "table"
        varargout = {objTable};
    end
end % function
