function out = tig(dataRecords)
%TIG Computes and outputs total insertion gain.
%   Calculate predicted and measured ANR performance from CPSD measurements
%   and digital filter specifications.
%
%   TIG(DATARECORDS) returns a 1xN array of structs with the fields
%   "name," "signals", and "data," where N is the number of DataRecord
%   objects passed in. Each struct in the output represents a container of
%   tig's that can be calculated from the corresponding DataRecord.
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
measName = "tig";
y_signal = bose.cnc.meas.StepType.NoiseActive;
x_signal = bose.cnc.meas.StepType.NoiseOpen;

% Get dependent metrics
Rcr_active = dataRecords.rcr_active;
Rcr_open = dataRecords.rcr_open;

% Remove empty entries
Rcr_active = Rcr_active(~cellfun('isempty',{Rcr_active.data}));
Rcr_open = Rcr_open(~cellfun('isempty',{Rcr_open.data}));

msgIdHeader = sprintf('bose:cnc:meas:DataRecord:%s',mfilename);

out = struct();

% Check if anything is empty
if isempty(Rcr_active)
    error([msgIdHeader ':IsEmpty'],...
        'Measurement rcr_active is empty, calculation cannot be complete.');
end
if isempty(Rcr_open)
    error([msgIdHeader ':IsEmpty'],...
        'Measurement rcr_open is empty, calculation cannot be complete.');
end

% Check that num and den sizes match
if all(size([Rcr_active.data]) == size([Rcr_open.data]))

    % Get DataRecords of desired StepType
    dataRecords_active = dataRecords([dataRecords.StepType] == y_signal);
    dataRecords_open = dataRecords([dataRecords.StepType] == x_signal);

    % Check that there is only one signal of each type
    if numel(dataRecords_active) ~= size([Rcr_active.data],2)
        error([msgIdHeader ':MultiSignal'],...
            'Multi-signals detected in DataRecords of StepType %s. \nThis function does not currently support multi-signal calculations.',...
            dataRecords_active(1).StepType);
    end
    if numel(dataRecords_open) ~= size([Rcr_open.data],2)
        error([msgIdHeader ':MultiSignal'],...
            'Multi-signals detected in DataRecords of StepType %s. \nThis function does not currently support multi-signal calculations.',...
            dataRecords_open(1).StepType);
    end

    % For every tig measurement
    for i_tig = 1:numel(dataRecords_active)
        out(i_tig).name = measName;
        out(i_tig).signals = sprintf("%s %s %s %s", ...
            Rcr_active(i_tig).name, Rcr_active(i_tig).signals, ...
            Rcr_open(i_tig).name, Rcr_open(i_tig).signals);
        out(i_tig).data = Rcr_active(i_tig).data ./ Rcr_open(i_tig).data;
    end
else
    error([msgIdHeader ':SizeMismatch'],...
        'Size mismatch between %s: [%d %d], and %s [%d %d].',...
        Rcr_active(1).name,...
        size([Rcr_active.data],1), size([Rcr_active.data],2),...
        Rcr_open(1).name,...
        size([Rcr_open.data],1), size([Rcr_open.data],2));
end

end
