function xdutOut = xdut(obj, varargin)
    %XDUT Convert DataRecord(s) to an xdut.
    %
    %   This function divides DataRecords into the following XDUT dimensions:
    %       group
    %       subject
    %       headphone
    %       fit
    %       step
    %
    %Usage:
    %   xdutOut = myDataRecords.xdut;
    %   xdutOut = myDataRecords.xdut('');
    %
    %Optional Parameter Inputs:
    %   DuplicateStartingIndex (double): The starting index for duplicate signal
    %       types; if empty, start "x, x1, x2", otherwise start with the specified
    %       number, i.e. "x1, x2, x3" or "x0, x1, x2". (Default: double.empty)
    %
    %Returns:
    %   xdutOut (xdut): Multi-dimensional xdut.
    %
    %Errors:
    %   EmptyHeadphone - When attempting to export some DataRecords with no
    %       Headphone and some DataRecords with a Headphone.
    %   EmptySubject - When attempting to export some DataRecords with no Subject
    %       and some DataRecords with a Subject.
    %   MissingInputSignals - When attempting to export DataRecords with no
    %       InputSignals.
    %   InvalidXsData - When attempting to export DataRecords of the same StepType
    %       but with differently sized data.
    %   InvalidSignals - When attempting to export a DataRecord with multiple
    %       mapped Signals with the same SignalType.
    %   SideSignals - When the left and right sides do not have the same number of signals.
    %
    %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.DataRecord.exportToRmeout,
    %   xdut

    % Alex Coleman
    % $Id$

    idHeader = 'bose:cnc:meas:DataRecord:xdut:';
    logger = bose.cnc.logging.getLogger;

    % Handle inputs
    valid_DuplicateStartingIndex = @(x) isnumeric(x) && isscalar(x) && x >= 0;
    parser = inputParser;
    parser.addParameter('DuplicateStartingIndex', double.empty, valid_DuplicateStartingIndex);
    parser.parse(varargin{:});
    duplicateStartingIndex = parser.Results.DuplicateStartingIndex;

    % XDUT Assumptions/Default values
    XDUT_TYPE = 'xs';
    XDUT_UNITS = 'V'; % HACK(ALEX): Hack the units in for now, until we support Units.

    % Check for error conditions
    emptySubjectMask = arrayfun(@(x) isempty(x.Subject), obj);
    if any(emptySubjectMask) && any(~emptySubjectMask)
        mError = MException( ...
            [idHeader 'EmptySubject'], ...
            [ ...
                'DataRecord.xdut does not support DataRecords with ' ...
                'Subjects together with DataRecords with empty Subjects ' ...
                '(Empty Subjects found in DataRecords: %s)' ...
            ], ...
            strjoin(string(find(emptySubjectMask)), ', ') ...
        );
        logger.error(sprintf('%s', mError.message), mError);
    end
    emptyHeadphoneMask = arrayfun(@(x) isempty(x.Headphone), obj);
    if any(emptyHeadphoneMask) && any(~emptyHeadphoneMask)
        mError = MException( ...
            [idHeader 'EmptyHeadphone'], ...
            [ ...
                'DataRecord.xdut does not support DataRecords with ' ...
                'Headphones together with DataRecords with empty ' ...
                'Headphones (Empty Headphones found in DataRecords: %s)' ...
            ], ...
            strjoin(string(find(emptyHeadphoneMask)), ', ') ...
        );
        logger.error(sprintf('%s', mError.message), mError);
    end
    emptyMappingMask = arrayfun(@(x) isempty(x.InputMapping), obj);
    if any(emptyMappingMask)
        mError = MException( ...
            [idHeader 'MissingInputSignals'], ...
            [ ...
                'DataRecord.xdut does not support empty InputMapping ' ...
                '(Found in DataRecords: %s)' ...
            ], ...
            strjoin(string(find(emptyMappingMask)), ', ') ...
        );
        logger.error(sprintf('%s', mError.message), mError);
    end

    % Get all StepNames
    allStepNames = [obj.StepName]';
    [stepNames, ~, ~] = unique(allStepNames);
    [~, stepAssociations] = obj.sliceStep(stepNames);

    % Check for any mismatched frequencies or signals, but only if we have more
    %   than one Step
    if numel(stepNames) > 1
        freqVec = obj(1).SignalParameters.Frequencies;
        inputSignals = obj(1).InputSignals;
        for indRecord = 1:numel(obj)
            if ~isequal(freqVec, obj(indRecord).SignalParameters.Frequencies)
                mError = MException( ...
                    [idHeader 'MismatchedFrequencies'], ...
                    [ ...
                        'DataRecord.xdut cannot export multiple Steps with ' ...
                        'different frequency vectors at the same time.' ...
                    ] ...
                );
                logger.error(sprintf('%s', mError.message), mError);
            end
            if ~isequal(inputSignals, obj(indRecord).InputSignals)
               currentListOfInputSignals = strjoin([inputSignals.Name]);
               thisDataRecordInputSignals  = strjoin([obj(indRecord).InputSignals.Name]);
                mError = MException( ...
                    [idHeader 'MismatchedInputSignals'], ...
                    [ ...
                        'DataRecord.xdut cannot export multiple Steps with ' ...
                        'different sets of Input Signals at the same time. ' ...
                        'Data records %i to %i signals: %s .. '...
                        'Data record %i signals: %s'...
                    ] ...
                ,1,numel(obj)-1,currentListOfInputSignals,numel(obj),thisDataRecordInputSignals);
                logger.error(sprintf('%s', mError.message), mError);
            end
        end % for every DataRecord
    end % If we have more than one Step

    % Get Subject masks
    subjects = unique([obj.Subject]);
    if isempty(subjects)
        subjectNames = "MissingSubject";
        [~, subjectAssociations] = obj.sliceSubject("all");
    else
        subjectNames = [subjects.DisplayName];
        [~, subjectAssociations] = obj.sliceSubject(subjectNames);
    end

    % Get Fit masks
    fits = unique([obj.Fit]);
    [~, fitAssociations] = obj.sliceFit(fits);

    % Get Headphone masks
    headphones = unique([obj.Headphone]);
    if isempty(headphones)
        headphoneNames = "MissingHeadphone";
        [~, headphoneAssociations] = obj.sliceHeadphone("all");
        headphoneBothMask = true;
        headphoneLeftMask = false;
        headphoneRightMask = false;
    else
        headphoneNames = [headphones.Name]';
        headphoneBothMask = [headphones.Side]' == bose.cnc.meas.Side.Both;
        headphoneLeftMask = [headphones.Side]' == bose.cnc.meas.Side.Left;
        headphoneRightMask = [headphones.Side]' == bose.cnc.meas.Side.Right;
        [~, headphoneAssociations] = obj.sliceHeadphone(headphoneNames);
    end

    %HACK(ALEX): Estimate the size of the final XsData blocks based off of the first DataRecord
    tempNumInputSignals = max( ...
        numel(obj(1).InputSignals([obj(1).InputSignals.Side] == bose.cnc.meas.Side.Left)), ...
        numel(obj(1).InputSignals([obj(1).InputSignals.Side] == bose.cnc.meas.Side.Right)) ...
    );
    xsDataSize = [numel(obj(1).SignalParameters.Frequencies), tempNumInputSignals, tempNumInputSignals, 2]; % 2 sides
    xsDataMissing = nan(xsDataSize);

    % Loop over all DataRecords and generate the XDUTs
    errorInd = double.empty;
    xsDataCells = repmat({xsDataMissing}, numel(subjects), numel(headphoneNames), numel(fits), numel(stepNames));
    for indRecord = 1:numel(obj)
        thisRecord = obj(indRecord);
        xsData = thisRecord.getXsData;

        % Get the Signals/Labels
        inputSignals = thisRecord.InputSignals;
        inputSignalTypes = [inputSignals.Type];
        inputSignalLabels = [inputSignalTypes.Label];

        % Left Side
        inputSignalMaskLeft = [inputSignals.Side] == bose.cnc.meas.Side.Left;
        numLeft = numel(inputSignals(inputSignalMaskLeft));
        inputDataLeft = xsData(:, inputSignalMaskLeft, inputSignalMaskLeft);
        inputSignalLabelsLeft = inputSignalLabels(inputSignalMaskLeft);
        for indLabel = 1:numLeft % For every input signal in this group
            sameLabelIndex = find(inputSignalLabelsLeft(indLabel) == inputSignalLabelsLeft);
            % If there are any duplicate signal labels, append numbers (i.e. "o", "o1", "o2", etc.)
            if numel(sameLabelIndex) > 1
                for indDuplicate = 1:numel(sameLabelIndex)
                    if isempty(duplicateStartingIndex)
                        if indDuplicate > 1
                            duplicateString = num2str(indDuplicate - 1);
                        else
                            duplicateString = "";
                        end
                    else
                        duplicateString = num2str(indDuplicate - 1 + duplicateStartingIndex);
                    end
                    inputSignalLabelsLeft(sameLabelIndex(indDuplicate)) = inputSignalLabelsLeft(sameLabelIndex(indDuplicate)) + duplicateString;
                end
            end
        end

        % Right Side
        inputSignalMaskRight = [inputSignals.Side] == bose.cnc.meas.Side.Right;
        numRight = numel(inputSignals(inputSignalMaskRight));
        inputDataRight = xsData(:, inputSignalMaskRight, inputSignalMaskRight);
        inputSignalLabelsRight = inputSignalLabels(inputSignalMaskRight);
        for indLabel = 1:numRight % For every input signal in this group
            sameLabelIndex = find(inputSignalLabelsRight(indLabel) == inputSignalLabelsRight);
            % If there are any duplicate signal labels, append numbers (i.e. "o", "o1", "o2", etc.)
            if numel(sameLabelIndex) > 1
                for indDuplicate = 1:numel(sameLabelIndex)
                    if isempty(duplicateStartingIndex)
                        if indDuplicate > 1
                            duplicateString = num2str(indDuplicate - 1);
                        else
                            duplicateString = "";
                        end
                    else
                        duplicateString = num2str(indDuplicate - 1 + duplicateStartingIndex);
                    end
                    inputSignalLabelsRight(sameLabelIndex(indDuplicate)) = inputSignalLabelsRight(sameLabelIndex(indDuplicate)) + duplicateString;
                end
            end
        end

        % Check size relationship between Left/Right, either one side only, or both sides same size & order
        if numLeft > 0 && numRight > 0 && ~isequal(inputSignalLabelsLeft, inputSignalLabelsRight)
            errorInd = [errorInd; indRecord];
            continue
        end

        % If right-sided only
        if numLeft == 0
            xsDataCells{ ...
                subjectAssociations(indRecord, :), ...
                headphoneAssociations(indRecord, :) & (headphoneBothMask | headphoneRightMask)', ...
                fitAssociations(indRecord, :), ...
                stepAssociations(indRecord, :) ...
            } = cat(4, xsDataMissing(:, :, :, 1), inputDataRight);
            inputSignalTypeLabels = inputSignalLabelsRight;
        % If left-sided only
        elseif numRight == 0
            xsDataCells{ ...
                subjectAssociations(indRecord, :), ...
                headphoneAssociations(indRecord, :) & (headphoneBothMask | headphoneLeftMask)', ...
                fitAssociations(indRecord, :), ...
                stepAssociations(indRecord, :) ...
            } = cat(4, inputDataLeft, xsDataMissing(:, :, :, 2));
            inputSignalTypeLabels = inputSignalLabelsLeft;
        % Else both-sided
        else
            % Both-sided Headphones
            if sum(headphoneBothMask) > 0
                xsDataCells{ ...
                    subjectAssociations(indRecord, :), ...
                    headphoneAssociations(indRecord, :) & headphoneBothMask', ...
                    fitAssociations(indRecord, :), ...
                    stepAssociations(indRecord, :) ...
                } = cat(4, inputDataLeft, inputDataRight);
            end

            % Left-sided Headphones
            if sum(headphoneLeftMask) > 0
                xsDataCells{ ...
                    subjectAssociations(indRecord, :), ...
                    headphoneAssociations(indRecord, :) & headphoneLeftMask', ...
                    fitAssociations(indRecord, :), ...
                    stepAssociations(indRecord, :) ...
                } = cat(4, inputDataLeft, xsDataMissing(:, :, :, 2));
            end

            % Right-sided Headphones
            if sum(headphoneRightMask) > 0
                xsDataCells{ ...
                    subjectAssociations(indRecord, :), ...
                    headphoneAssociations(indRecord, :) & headphoneRightMask', ...
                    fitAssociations(indRecord, :), ...
                    stepAssociations(indRecord, :) ...
                } = cat(4, xsDataMissing(:, :, :, 1), inputDataRight);
            end

            % Set the signal labels
            inputSignalTypeLabels = inputSignalLabelsLeft; % Both sides are the same
        end % if left-only or right-only, else both
    end % for every DataRecord

    % Check for errored DataRecords
    if ~isempty(errorInd)
        mError = MException( ...
            [idHeader 'SideSignals'], ...
            [ ...
                'The following DataRecords did not have matching ' ...
                'SignalTypes between the Left/Right sides: %s' ...
            ], ...
            strjoin(string(errorInd), ', ') ...
        );
        logger.error(sprintf('%s', mError.message), mError);
    end

    % Concatenate over Dimension 5, Subject
    xsDataCells2 = repmat({xsDataMissing}, numel(headphoneNames), numel(fits), numel(stepNames));
    for indHeadphone = 1:numel(headphoneNames)
        for indFit = 1:numel(fits)
            for indStep = 1:numel(stepNames)
                xsDataCells2{indHeadphone, indFit, indStep} = cat(5, xsDataCells{:, indHeadphone, indFit, indStep});
            end
        end
    end % For every fit
    clear('xsDataCells');

    % Concatenate over Dimension 6, Headphone
    xsDataCells3 = repmat({xsDataMissing}, numel(fits), numel(stepNames));
    for indFit = 1:numel(fits)
        for indStep = 1:numel(stepNames)
            xsDataCells3{indFit, indStep} = cat(6, xsDataCells2{:, indFit, indStep});
        end
    end % For every fit
    clear('xsDataCells2');

    % Concatenate over Dimension 7, Fit
    xsDataCells4 = repmat({xsDataMissing}, numel(stepNames), 1);
    for indStep = 1:numel(stepNames)
        xsDataCells4{indStep} = cat(7, xsDataCells3{:, indStep});
    end
    clear('xsDataCells3');

    % Concatenate over Dimension 8, Step
    xsData = cat(8, xsDataCells4{:});
    clear('xsDataCells4');

    %HACK(ALEX): We assume all freq vectors are the same, so take the first
    frequencies = obj(1).SignalParameters.Frequencies;

    % Create the XDUT object with the numeric data, frequencies, and units
    xdutOut = xdut( ...
        xsData, ...
        frequencies, ...
        XDUT_TYPE, ...
        XDUT_UNITS, ...
        XDUT_UNITS ...
    );
    theseMapNames = mapnames(xdutOut);
    xdutOut.Label = sprintf('CncMeasure (xdut) v%s', bose.cnc.version);

    % Map Dimensions 2/3, Signals, onto the Output/Input dimensions
    %HACK(ALEX): We assume all signal labels are the same, so take the last
    xdutOut.Output.value = cellstr(inputSignalTypeLabels);
    xdutOut.Input.value = cellstr(inputSignalTypeLabels);

    % Map Dimension 4, Side/Group
    groupValue = cellstr([bose.cnc.meas.Side.Left, bose.cnc.meas.Side.Right]);
    if numel(theseMapNames) >= 4
        mapnames(xdutOut, 4, 'group');
        xdutOut.group.value = groupValue;
    else
        xdutOut = newdim('group', groupValue, xdutOut);
    end

    % Map Dimension 5, Subject
    %TODO(ALEX): replace strrep with matlab.lang.makeValidName
    subjectValue = cellstr(strrep(subjectNames, ' ', '_'));
    if numel(theseMapNames) >= 5
        mapnames(xdutOut, 5, 'subject');
        xdutOut.subject.value = subjectValue;
    else
        xdutOut = newdim('subject', subjectValue, xdutOut);
    end

    % Map Dimension 6, Headphone
    %TODO(ALEX): replace strrep with matlab.lang.makeValidName
    headphoneValue = cellstr(strrep(headphoneNames, ' ', '_'));
    if numel(theseMapNames) >= 6
        mapnames(xdutOut, 6, 'headphone');
        xdutOut.headphone.value = headphoneValue;
    else
        xdutOut = newdim('headphone', headphoneValue, xdutOut);
    end

    % Map Dimension 7, Fit
    fitValue = cellstr("fit" + fits);
    if numel(theseMapNames) >= 7
        mapnames(xdutOut, 7, 'fit');
        xdutOut.fit.value = fitValue;
    else
        xdutOut = newdim('fit', fitValue, xdutOut);
    end

    % Map Dimension 8, Step
    stepValue = cellstr(stepNames);
    if numel(theseMapNames) >= 8
        mapnames(xdutOut, 8, 'step');
        xdutOut.step.value = stepValue;
    else
        xdutOut = newdim('step', stepValue, xdutOut);
    end

    % Get the size in memory of the xdut
    xdutWhos = whos('xdutOut');
    if xdutWhos.bytes > 1024^3
        xdutSize = sprintf('%.3f GB', xdutWhos.bytes/1024^3);
    elseif xdutWhos.bytes > 1024^2
        xdutSize = sprintf('%.3f MB', xdutWhos.bytes/1024^2);
    elseif xdutWhos.bytes > 1024^1
        xdutSize = sprintf('%.3f MB', xdutWhos.bytes/1024^1);
    else
        xdutSize = sprintf('%.3f B', xdutWhos.bytes);
    end

    % Report success
    logger.info(sprintf( ...
        'Converted %d DataRecords to xdut (%s)', ...
        numel(obj), ...
        xdutSize ...
    ));
end % function
