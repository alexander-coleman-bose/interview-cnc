classdef HeadphoneFormFactor
    %HEADPHONEFORMFACTOR Enum for valid types of Headphone FormFactors.
    %
    %Enumeration members:
    %   aroundEar: An around-ear device platform (i.e. Bose QC 35)
    %   inEar: An in-ear device platform (i.e. Bose QC 30)
    %   openEar: An open-ear device platform (i.e. Bose SoundWear Companion)
    %
    %See also: bose.cnc.meas, enumeration, bose.cnc.meas.Headphone

    % $Id$

    properties
        Label(1,1) string = string % The two-character label for this form factor used in the database.
    end % Public properties

    methods
        function obj = HeadphoneFormFactor(formFactorLabel)
            obj.Label = formFactorLabel;
        end % Constructor
    end % Public methods

    methods (Static)
        function obj = fromLabel(formFactorLabel)
            %FROMLABEL Construct a HeadphoneFormFactor based off of a two-character label.
            %
            %Required Arguments:
            %   formFactorLabel (string): A string array of two-character form factor labels.
            %
            %Returns:
            %   obj (bose.cnc.meas.HeadphoneFormFactor): An array of
            %       HeadphoneFormFactor objects that match the given form
            %       factor labels.
            %
            %See also: bose.cnc.meas.HeadphoneFormFactor

            % Handle inputs
            parser = inputParser;
            parser.addRequired('formFactorLabel', ...
                               @bose.common.validators.mustBeStringLike);
            parser.parse(formFactorLabel);
            formFactorLabel = string(parser.Results.formFactorLabel);

            % Get valid Enums and Labels
            validEnums = enumeration('bose.cnc.meas.HeadphoneFormFactor');
            validLabels = [validEnums.Label];

            obj = bose.cnc.meas.HeadphoneFormFactor.empty;
            for indLabel = 1:numel(formFactorLabel)
                formFactorMask = contains(validLabels, formFactorLabel(indLabel));
                formFactorName = string(validEnums(formFactorMask));
                formFactor = bose.cnc.meas.HeadphoneFormFactor(formFactorName);
                obj = [obj; formFactor];
            end
        end % fromLabel
    end % Public, static methods

    enumeration
        aroundEar   ("AE")
        inEar       ("IE")
        openEar     ("OE")
    end
end
