function obj = loadobj(objIn)
    %LOADOBJ Custom load process from MAT for DataRecord objects.
    %
    %   https://www.mathworks.com/help/matlab/ref/loadobj.html
    %
    %See also: bose.cnc.meas.DataRecord

    % Alex Coleman
    % $Id$

    template = bose.cnc.meas.DataRecord.template;
    template.Date = objIn.Date;
    template.Environment = objIn.Environment;
    template.ExcitationFilters = objIn.ExcitationFilters;
    template.ExcitationGain = objIn.ExcitationGain;
    template.ExcitationType = objIn.ExcitationType;
    template.Fit = objIn.Fit;
    template.Hardware = objIn.Hardware;
    template.Headphone = objIn.Headphone;
    template.InputMapping = objIn.InputMapping;
    template.Operator = objIn.Operator;
    template.OutputMapping = objIn.OutputMapping;
    template.SignalParameters = objIn.SignalParameters;
    template.StepName = objIn.StepName;
    template.StepType = objIn.StepType;
    template.Subject = objIn.Subject;
    template.ToolboxVersion = objIn.ToolboxVersion;
    template.XsData = objIn.XsData; % Trigger serialization in constructor
    template.TimeData = objIn.TimeData; % Trigger serialization in constructor

    obj = bose.cnc.meas.DataRecord(template);
end % function
