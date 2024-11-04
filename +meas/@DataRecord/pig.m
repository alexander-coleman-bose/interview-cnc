function out = pig(dataRecords)
%PIG Computes and outputs passive insertion gain.
%   Calculate predicted and measured ANR performance from CPSD measurements
%   and digital filter specifications.
%
%   PIG(DATARECORDS) returns a 1xN array of structs with the fields
%   "name," "signals", and "data," where N is the number of DataRecord
%   objects passed in. Each struct in the output represents a container of
%   pig's that can be calculated from the corresponding DataRecord.
%
%   NOTE: TIG and PIG calculations require DataRecords from multiple step
%   types and assumes that they are the same length and have corresponding
%   metadata.
%
%   OUT struct:
%           out.name        =   name of the metric
%           out.signals     =   string(s) of metric name, and signal name and corresponding number
%                               used in the calculation
%           out.data        =   [Nfreq x 1] double array(s) of response data
%
% See also bose.cnc.meas.DataRecord,
% bose.cnc.meas.DataRecord.metricsToDatabase
%
%   References:
%     https://wiki.bose.com/display/NRTG/Output+Quantities

% $Id$

% Properties of metric
measName = "pig";
y_signal = bose.cnc.meas.StepType.NoisePassive;
x_signal = bose.cnc.meas.StepType.NoiseOpen;

% Get dependent metrics
Rcr_pass = dataRecords.rcr_pass;
Rcr_open = dataRecords.rcr_open;

% Remove empty entries
Rcr_pass = Rcr_pass(~cellfun('isempty',{Rcr_pass.data}));
Rcr_open = Rcr_open(~cellfun('isempty',{Rcr_open.data}));

msgIdHeader = sprintf('bose:cnc:meas:DataRecord:%s',mfilename);

out = struct();

% Check if anything is empty
if isempty(Rcr_pass)
    error([msgIdHeader ':IsEmpty'],...
        'Measurement rcr_passive is empty, calculation cannot be complete.');
end
if isempty(Rcr_open)
    error([msgIdHeader ':IsEmpty'],...
        'Measurement rcr_open is empty, calculation cannot be complete.');
end

% Check that num and den sizes match
if all(size([Rcr_pass.data]) == size([Rcr_open.data]))

    % Get DataRecords of desired StepType
    dataRecords_pass = dataRecords([dataRecords.StepType] == y_signal);
    dataRecords_open = dataRecords([dataRecords.StepType] == x_signal);

    % Check that there is only one signal of each type
    if numel(dataRecords_pass) ~= size([Rcr_pass.data],2)
        error([msgIdHeader ':MultiSignal'],...
            'Multi-signals detected in DataRecords of StepType %s. \nThis function does not currently support multi-signal calculations.',...
            dataRecords_pass(1).StepType);
    end
    if numel(dataRecords_open) ~= size([Rcr_open.data],2)
        error([msgIdHeader ':MultiSignal'],...
            'Multi-signals detected in DataRecords of StepType %s. \nThis function does not currently support multi-signal calculations.',...
            dataRecords_open(1).StepType);
    end

    % For every pig measurement
    for i_pig = 1:numel(dataRecords_pass)
        out(i_pig).name = measName;
        out(i_pig).signals = sprintf("%s %s %s %s", ...
            Rcr_pass(i_pig).name, Rcr_pass(i_pig).signals, ...
            Rcr_open(i_pig).name, Rcr_open(i_pig).signals);
        out(i_pig).data = Rcr_pass(i_pig).data ./ Rcr_open(i_pig).data;
    end
else
    error([msgIdHeader ':SizeMismatch'],...
        'Size mismatch between %s: [%d %d], and %s [%d %d].',...
        Rcr_pass(1).name,...
        size([Rcr_pass.data],1), size([Rcr_pass.data],2),...
        Rcr_open(1).name,...
        size([Rcr_open.data],1), size([Rcr_open.data],2));
end


end
