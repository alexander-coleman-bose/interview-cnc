function [dataRecords, associationMatrix] = sliceHeadphone(obj, headphoneSpecs)
    %SLICEHEADPHONE Returns a set of DataRecords that match the given Headphone name(s).
    %
    %   Returns any DataRecord where the Headphone.Name or HeadphoneType.Name
    %   matches the given string. Multiple strings may be specified.
    %
    %Usage:
    %   dataRecords = dataRecords.sliceHeadphone("Smalls C0");
    %   [dataRecords, associationMatrix] = dataRecords.sliceHeadphone("Smalls C0);
    %   dataRecords = dataRecords.sliceHeadphone(["Smalls C0", "Lando C2"]);
    %
    %Optional Positional Arguments:
    %   headphoneSpecs (string-like): A char, string(s), or cellstr(s) to match
    %       DataRecords to. If "all" is given, match all DataRecords. (Default:
    %       match all DataRecords)
    %
    %Returns:
    %   dataRecords (bose.cnc.meas.DataRecord): The subset of DataRecords that match
    %       at least one of the spec strings.
    %   associationMatrix (logical): A matrix whose rows represent the original
    %       input set of DataRecords, and whose columns represent the different spec
    %       strings. A true value in the matrix means that DataRecord matches that
    %       spec string.
    %
    %Throws:
    %   EmptyHeadphone - When sliceHeadphone is not "all" and a DataRecord has an
    %       empty Headphone.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.DataRecord.Headphone,
    %   bose.cnc.meas.Headphone, bose.cnc.meas.HeadphoneType

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:DataRecord:sliceHeadphone:';

    narginchk(1, 2)
    if nargin < 2
        headphoneSpecs = "all";
    end
    bose.common.validators.mustBeStringLike(headphoneSpecs);

    stringSpec = string(headphoneSpecs);
    numDataRecords = numel(obj);
    numHeadphoneSpecs = numel(stringSpec);
    associationMatrix = false(numDataRecords, numHeadphoneSpecs);

    for indObj = 1:numel(obj)
        if isempty(obj(indObj).Headphone) && ~all(strcmpi(stringSpec, "all"))
            error( ...
                [idHeader 'EmptyHeadphone'], ...
                [ ...
                    'You cannot slice by Headphone across DataRecords ' ...
                    'without a Headphone unless you specify "all"' ...
                ] ...
            );
        end
    end

    for indSpec = 1:numHeadphoneSpecs
        if strcmpi(stringSpec(indSpec), "all")
            associationMatrix(:, indSpec) = true(numDataRecords, 1);
        else
            for indObj = 1:numel(obj)
                headphones = [obj(indObj).Headphone];
                headphoneNames = [headphones.Name];
                headphoneTypes = [headphones.Type];
                headphoneTypeNames = [headphoneTypes.Name];

                % Headphone.Name or HeadphoneType.Name matches stringSpec
                associationMatrix(indObj, indSpec) = any( ...
                    strcmpi(stringSpec(indSpec), headphoneNames) ...
                    | strcmpi(stringSpec(indSpec), headphoneTypeNames) ...
                );
            end
        end
    end % For every spec string

    % Return a set of DataRecords that match at least one of the spec strings.
    dataRecords = obj(max(associationMatrix, [], 2));
end % function
