function val = getXsData(obj)
    %GETXSDATA Return a full CPSD matrix from the storage-optimized form in the DataRecord.
    %
    %   DataRecord.getXsData returns the full XsData matrix of size MxNxNxP, where
    %       M is the number of frequency bins
    %       N is the hermitian square dimension (number of channels)
    %       P is the number of sides (signal groups)
    %
    %Returns:
    %   val (double): The full hermitian CPSD matrix of size MxNxNxP.
    %
    %See also: bose.cnc.meas.DataRecord

    % Alex Coleman
    % $Id$
    val = double(bose.cnc.math.deserializeHermitian(obj.XsData));
end % get.XsData
