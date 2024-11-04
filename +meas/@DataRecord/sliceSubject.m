function [dataRecords, associationMatrix] = sliceSubject(obj, subjectSpecs)
    %SLICESUBJECT Returns a set of DataRecords that match the given Subject name(s).
    %
    %   Returns any DataRecord where the Subject.DisplayName matches the given
    %   string. Multiple strings may be specified.
    %
    %Usage:
    %   dataRecords = dataRecords.sliceSubject("Alex Coleman");
    %   [dataRecords, associationMatrix] = dataRecords.sliceSubject("Coleman");
    %   dataRecords = dataRecords.sliceSubject(["Alex Coleman", "Janet L Xu"]);
    %
    %Optional Positional Arguments:
    %   subjectSpecs (string-like): A char, string(s), or cellstr(s) to match
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
    %   EmptySubject - When sliceSubject is not "all" and a DataRecord has an empty
    %       Subject.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.DataRecord.Subject,
    %   bose.cnc.meas.Person

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:DataRecord:sliceSubject:';

    narginchk(1, 2)
    if nargin < 2
        subjectSpecs = "all";
    end
    bose.common.validators.mustBeStringLike(subjectSpecs);

    stringSpec = string(subjectSpecs);
    numDataRecords = numel(obj);
    numSubjectSpecs = numel(stringSpec);
    associationMatrix = false(numDataRecords, numSubjectSpecs);

    for indObj = 1:numel(obj)
        if isempty(obj(indObj).Subject) && ~all(strcmpi(stringSpec, "all"))
            error( ...
                [idHeader 'EmptySubject'], ...
                [ ...
                    'You cannot slice by Subject across DataRecords ' ...
                    'without a Subject unless you specify "all"' ...
                ] ...
            );
        end
    end

    subjects = [obj.Subject]'; %FIXME(ALEX): This function will fail with empty Subjects
    displayNames = [subjects.DisplayName]'; % must be Nx1
    for indSpec = 1:numSubjectSpecs
        if strcmpi(stringSpec(indSpec), "all")
            associationMatrix(:, indSpec) = true(numDataRecords, 1);
        else
            % DisplayName contains subjectSpec
            associationMatrix(:, indSpec) = strcmpi(displayNames, stringSpec(indSpec));
        end
    end % For every spec string

    % Return a set of DataRecords that match at least one of the spec strings.
    dataRecords = obj(max(associationMatrix, [], 2));
end % function
