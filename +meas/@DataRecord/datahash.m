function val = datahash(obj)
    %DATAHASH Checksum for DataRecord XsData.
    %
    %   The datahash is calculated from the single-type serialized form of the
    %   XsData.
    %
    %Returns:
    %   val (string): The unique hash string for this unique DataRecord.
    %
    %See also: bose.cnc.meas.DataRecord, common/datahash

    % Alex Coleman
    % $Id$

    cellVal = cell(size(obj));
    for indObj = 1:numel(obj)
        cellVal{indObj} = datahash(obj(indObj).XsData);
    end
    val = string(cellVal);
end % function
