function out = nco(dataRecords)
%NCO Computes and outputs Nco.
%   Calculate predicted and measured ANR performance from CPSD measurements
%   and digital filter specifications.
%
%   NCO(DATARECORDS) returns a 1xN array of structs with the fields
%   "name," "signals", and "data," where N is the number of DataRecord
%   objects passed in. Each struct in the output represents a container of
%   nco's that can be calculated from the corresponding DataRecord. If
%   there are multiple possible nco's from a single DataRecord,
%   "signals" and "data" field will be multi-dimensional.
%
%   OUT struct:
%           out.name        =   name of the metric
%           out.signals     =   [1 x Nmetrics] string(s) of signal name and corresponding number
%                               used in the calculation
%           out.data        =   [Nfreq x Nmetrics] double array(s) of response data
%
% See also bose.cnc.meas.DataRecord,
% bose.cnc.meas.DataRecord.metricsToDatabase
%
%   References:
%     https://wiki.bose.com/display/NRTG/Output+Quantities

% $Id$

% Properties of metric
measName = "nco";
y_signal = bose.cnc.meas.SignalType.CanalMic;
x_signal = bose.cnc.meas.SignalType.FeedForwardMic;
metricStepType = bose.cnc.meas.StepType.NoisePassive;

msgIdHeader = sprintf('bose:cnc:meas:DataRecord:%s',mfilename);

out = struct();

% Go through every DataRecord
for i_dataRec = 1:numel(dataRecords)
    singleDataRec = dataRecords(i_dataRec);

    % Check StepType
    if singleDataRec.StepType == metricStepType

        % Find index for desired SignalTypes
        singleSignal = [singleDataRec.InputMapping.Signal];
        mask_sig_y = ismember([singleSignal.Type],y_signal);
        mask_sig_x = ismember([singleSignal.Type],x_signal);

        % Check that 'y' and 'x' signals exist
        if sum(mask_sig_y) == 0
            error([msgIdHeader ':NoSignal'],...
                'No SignalType "%s" found in DataRecord(%d).',y_signal, i_dataRec);
        end
        if sum(mask_sig_x) == 0
            error([msgIdHeader ':NoSignal'],...
                'No SignalType "%s" found in DataRecord(%d).',x_signal, i_dataRec);
        end

        % Get indices of y and x signals
        indc_y = find(mask_sig_y);
        indc_x = find(mask_sig_x);

        % Calculate metric for every 'y' signal
        i_sig = 1; % number of metrics per DataRecord
        out(i_dataRec).data = zeros(...
            size(dataRecords(i_dataRec).SignalParameters.Frequencies,1),...
            length(indc_y)*length(indc_x)); % preallocate data
        for i_y = 1:length(indc_y)

            % Assign index for 'y'
            index_y = indc_y(i_y);

            % Calculate metric for every 'x' signal
            for i_x = 1:length(indc_x)

                % Assign index for 'x'
                index_x = indc_x(i_x);

                % Math
                SYX = dataRecords(i_dataRec).getXsData(:,index_y,index_x);
                SXX = dataRecords(i_dataRec).getXsData(:,index_x,index_x);
                out(i_dataRec).name = measName;
                out(i_dataRec).signals(:,i_sig) = sprintf("%s%.0f%s%.0f", y_signal.Label, i_y, x_signal.Label, i_x);
                out(i_dataRec).data(:,i_sig) = SYX./SXX;

                % Increment i_sig
                i_sig = i_sig + 1;

            end % for every x signal
        end % for every y signal
    else
        % Put in empty entries to maintain struct size
        out(i_dataRec).name = measName;
        out(i_dataRec).signals = string.empty;
        out(i_dataRec).data = double.empty;

    end % check StepType
end % for every DataRecord

end % nco
