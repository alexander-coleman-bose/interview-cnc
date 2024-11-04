function obj = fromLabel(stepLabel)
    %FROMLABEL Construct a StepType based off of a step Label.
    %
    %Required Arguments:
    %   stepLabel(string): A string array of step labels.
    %
    %Returns:
    %   obj(bose.cnc.meas.StepType): An array of StepType objects
    %       that match the given step Labels.
    %
    %See also: bose.cnc.meas.StepType

    % Alex Coleman
    % $Id$

    % Handle inputs
    parser = inputParser;
    parser.addRequired('stepLabel', ...
                       @bose.common.validators.mustBeStringLike);
    parser.parse(stepLabel);
    stepLabel = string(parser.Results.stepLabel);

    % Get valid Enums and Labels
    validEnums = enumeration('bose.cnc.meas.StepType');
    validLabels = [validEnums.Label];

    obj = bose.cnc.meas.StepType.empty;
    for indLabel = 1:numel(stepLabel)
        stepTypeMask = contains(validLabels, stepLabel(indLabel));
        typeName = string(validEnums(stepTypeMask));
        stepType = bose.cnc.meas.StepType(typeName);
        obj = [obj; stepType];
    end
end % fromLabel
