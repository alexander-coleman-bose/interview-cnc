function [dataRecordIndexes] = findLatestNonRepeatedDataRecords(obj)
%getLatestNonRepeatedDataRecords Gets valid indexes of data records that
%are not repeated and also are the latest instance of the
%subject/headphone/fit/step combination.
%
% Written by Will Kolb
% $Id$
dataRecordIndexes = false(size(obj.DataRecords));
dataRecordIndexes(1) = true;
for x = 2:numel(obj.DataRecords)
    sameStep = strcmp(obj.DataRecords(x).StepName, [obj.DataRecords(dataRecordIndexes).StepName]);
    sameSubject = obj.DataRecords(x).Subject == [obj.DataRecords(dataRecordIndexes).Subject];
    sameFit = obj.DataRecords(x).Fit == [obj.DataRecords(dataRecordIndexes).Fit];
    sameHeadphone = obj.DataRecords(x).Headphone == [obj.DataRecords(dataRecordIndexes).Headphone];
    repeatedDRIdx = (sameStep & sameSubject &  sameFit & sameHeadphone);
    comparableDR = obj.DataRecords(repeatedDRIdx);
    if(~isempty(comparableDR))
        dataRecordIndexes(x) = obj.DataRecords(x).Date > comparableDR.Date;
        dataRecordIndexes(repeatedDRIdx) = false;
    else
        dataRecordIndexes(x) = true;
    end
end

end
