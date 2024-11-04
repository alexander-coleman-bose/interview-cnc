classdef DataRecord < bose.cnc.classes.StructInput
    %DATARECORD Object that defines a full record of a CNC measurement.
    %
    %   bose.cnc.meas.DataRecord is immutable, which means that its properties
    %   cannot change after it is created. This is so that once a record is made of
    %   a measurement, it cannot be changed.
    %
    %See also: bose.cnc.meas, bose.cnc.meas.DataRecord.DataRecord, datetime,
    %   bose.cnc.meas.Environment, bose.cnc.meas.Hardware, bose.cnc.meas.Mapping,
    %   bose.cnc.meas.Person, bose.cnc.meas.SignalParameters, bose.cnc.meas.StepType,
    %   bose.cnc.meas.Headphone

    % $Id$

    %% PUBLIC, IMMUTABLE PROPERTIES
    % https://www.mathworks.com/help/matlab/matlab_oop/validate-property-values.html
    properties (SetAccess = immutable)
        Date(1,1) datetime % Date & time when the measurement was taken.
        Environment(:,1) bose.cnc.meas.Environment {bose.common.validators.mustBeEmptyOrScalar} % The Environment the measurement was taken in (if any).
        ExcitationFilters(:,6,:) double {bose.cnc.validators.mustBeValidSos} % SOS filter used to generate the Excitation signal.
        ExcitationGain(1,1) double {mustBeReal, mustBeFinite, mustBeNonNan, mustBePositive} = 1 % Linear gain to be applied to the Excitation signal.
        ExcitationType(1,1) bose.cnc.meas.ExcitationType % Type of Excitation signal generation to be used. (Default: bose.cnc.meas.Excitation.None)
        Fit(1,1) uint64 % The fit index of the measurement.
        Hardware(1,1) bose.cnc.meas.Hardware % The measurement Hardware used in the measurement.
        Headphone(:,1) bose.cnc.meas.Headphone % The device/headphone tested or used during the measurement (if any).
        InputMapping(:,1) bose.cnc.meas.Mapping % The mapping of the measurement Hardware input channel(s) to Signal(s).
        Operator(1,1) bose.cnc.meas.Person % The Person that made the measurement.
        OutputMapping(:,1) bose.cnc.meas.Mapping % The mapping of the measurement Hardware output channel(s) to Signal(s).
        SignalParameters(1,1) bose.cnc.meas.SignalParameters % The parameters used to calculate the cross-spectral data.
        StepName(1,1) string % The name of the measurement Step taken.
        StepType(1,1) bose.cnc.meas.StepType % The Type of measurement.
        Subject(:,1) bose.cnc.meas.Person {bose.common.validators.mustBeEmptyOrScalar} % The Subject involved in the measurement (if any).
        ToolboxVersion(1,1) string = "0.0.0" % The version of the toolbox used to create this DataRecord.
        XsData(:,:,:) single % [Units?] The cross-spectral data generated from the measurement.
        TimeData(:,:) single = single.empty; %The time data from the inital measurement (Does not have to be populated).
    end % Public, Immutable properties

    %% DEPENDENT PROPERTIES
    properties (Dependent)
        DisplayName(1,1) string % Default formatted display name for DataRecords.
        FileName(1,1) string % Default file name for the DataRecord "DataRecord-yyyymmddTHHMMSS-<datahash(obj)>.mat".
        InputSignals(:,1) bose.cnc.meas.Signal % The input Signal(s) used in the measurement.
        OutputSignals(:,1) bose.cnc.meas.Signal % The output Signal(s) used in the measurement.
    end % Dependent properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = DataRecord(varargin)
            %DATARECORD Returns a measurement DataRecord object.
            %
            %   This constructor can also accept inputs as a struct with fieldnames that
            %   match the input argument names. The bose.cnc.meas.DataRecord.template method
            %   returns a struct with the correct fieldnames.
            %
            %Required Parameter Arguments:
            %   Date (datetime): Date & time when the measurement was taken.
            %   Environment (bose.cnc.meas.Environment): The Environment the measurement was taken in (if any).
            %   ExcitationFilters (double): SOS filter used to generate the Excitation signal.
            %   ExcitationGain (double): Linear gain to be applied to the Excitation signal.
            %   ExcitationType (bose.cnc.meas.ExcitationType): Type of Excitation signal generation to be used. (Default: bose.cnc.meas.Excitation.None)
            %   Fit (uint64): The fit index of the measurement.
            %   Hardware (bose.cnc.meas.Hardware): The measurement Hardware used in the measurement.
            %   Headphone (bose.cnc.meas.Headphone): The device/headphone tested or used during the measurement (if any).
            %   InputMapping (bose.cnc.meas.Mapping): The mapping of the measurement Hardware input channel(s) to Signal(s).
            %   Operator (bose.cnc.meas.Person): The Person that made the measurement.
            %   OutputMapping (bose.cnc.meas.Mapping): The mapping of the measurement Hardware output channel(s) to Signal(s).
            %   SignalParameters (bose.cnc.meas.SignalParameters): The parameters used to calculate the cross-spectral data.
            %   StepName (string): The name of the measurement Step taken.
            %   StepType (bose.cnc.meas.StepType): The Type of measurement.
            %   Subject (bose.cnc.meas.Person): The subject involved in the measurement (if any).
            %   ToolboxVersion (string): The version of the toolbox used to create this DataRecord.
            %   XsData (single): [Units?] The cross-spectral data generated from the measurement.
            %   TimeData (double) : The time data aquired from the input. Will be blank if the user never selected "save time data"
            %
            %Throws:
            %   bose:cnc:meas:DataRecord:InvalidInput - When not all required inputs are specified.
            %
            %See also: bose.cnc.meas.DataRecord, bose.cnc.meas.Environment,
            %   bose.cnc.meas.ExcitationType, uint64, bose.cnc.meas.Hardware,
            %   bose.cnc.meas.Headphone, bose.cnc.meas.Mapping,
            %   bose.cnc.meas.Person, bose.cnc.meas.SignalParameters,
            %   bose.cnc.meas.StepType, datetime, bose.cnc.meas.Session

            idHeader = 'bose:cnc:meas:DataRecord:';

            parser = bose.cnc.meas.DataRecord.createParser;
            parser.parse(varargin{:});

            % HACK(ALEX): The inputParser doesn't like expanding a struct for
            % required arguments, so we instead make the inputs parameters, but
            % error if any defaults are used.
            if ~isempty(parser.UsingDefaults)
                defaultArgs = strjoin(parser.UsingDefaults, ', ');
                error( ...
                    [idHeader 'InvalidInput'], ...
                    'The following argument(s) must be specified: %s', ...
                    defaultArgs ...
                );
            end

            obj.Date = parser.Results.Date;
            obj.Environment = parser.Results.Environment;
            obj.ExcitationFilters = parser.Results.ExcitationFilters;
            obj.ExcitationGain = parser.Results.ExcitationGain;
            obj.ExcitationType = parser.Results.ExcitationType;
            obj.Fit = parser.Results.Fit;
            obj.Hardware = parser.Results.Hardware;
            obj.Headphone = parser.Results.Headphone;
            obj.InputMapping = parser.Results.InputMapping;
            obj.Operator = parser.Results.Operator;
            obj.OutputMapping = parser.Results.OutputMapping;
            obj.SignalParameters = parser.Results.SignalParameters;
            obj.StepName = parser.Results.StepName;
            obj.StepType = parser.Results.StepType;
            obj.Subject = parser.Results.Subject;
            obj.ToolboxVersion = parser.Results.ToolboxVersion;
            if size(parser.Results.XsData, 3) > 1
                obj.XsData = bose.cnc.math.serializeHermitian(single(parser.Results.XsData));
            else
                obj.XsData = parser.Results.XsData;
            end
            obj.TimeData = single(parser.Results.TimeData);
        end % Constructor
    end % Constructor

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        % Validation methods
        val = datahash(obj)
        results = isValid(obj)

        % Export methods
        obj = exportToRmeout(obj, varargin)
        val = getXsData(obj)
        objKeys = saveToDatabase(obj)
        fileNames = saveToFile(obj, varargin)
        xdutOut = xdut(obj)
        [timeDutCellArrayOut,stepNames] = timedut(obj)
        
        % Metric methods
        obj = gsd(obj)
        obj = gcd(obj)
        obj = nso(obj)
        obj = nco(obj)
        obj = ncs(obj)
        obj = rcr_open(obj)
        obj = rcr_pass(obj)
        obj = rcr_active(obj)
        obj = coh_co(obj)
        obj = coh_cs(obj)
        obj = pig(obj)
        obj = tig(obj)
        trialKeys = metricsToDatabase(obj, varargin)
        metricStruct = calculate(obj, stepMetrics)
        [associatedMetrics, associationMatrix] = findAssociatedMetrics(obj)

        % Plotting methods
        [fh, ah] = plotAssociatedMetrics(obj)
        [fh, ah] = plotMetrics(obj, stepMetrics, associationMatrix)

        % Signal methods
        excitationSignals = getExcitationSignals(obj)

        % Utility methods
        signalMasks = findInputSignals(obj, signalStrings)
        [dataRecords, associationMatrix] = sliceFit(obj, fitNums)
        [dataRecords, associationMatrix] = sliceHeadphone(obj, headphoneSpecs)
        [dataRecords, associationMatrix] = sliceStep(obj, stepSpec)
        [dataRecords, associationMatrix] = sliceSubject(obj, subjectSpecs)
        tableOut = getMetadataTable(obj)
    end % Public methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GET/SET METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function displayName = get.DisplayName(obj)
            datetimeFormat = 'HH:mm:ss'; % similar to ISO 8601
            if isempty(obj.Subject)
                displayName = sprintf( ...
                    "(%s) %s - F%.0f", ...
                    string(obj.Date, datetimeFormat), ...
                    obj.StepName, ...
                    obj.Fit ...
                );
            else
                displayName = sprintf( ...
                    "(%s) %s - %s - F%.0f", ...
                    string(obj.Date, datetimeFormat), ...
                    obj.StepName, ...
                    obj.Subject.DisplayName, ...
                    obj.Fit ...
                );
            end
        end % get.DisplayName

        function fileName = get.FileName(obj)
%             fileName = sprintf( ...
%                 'DataRecord-%s-%s.mat', ...
%                 string(obj.Date, bose.cnc.datetimeFileFormat), ...
%                 datahash(obj) ...
%             );
              if(~isempty(obj.Subject))
                subjectName = strjoin([obj.Subject.FirstName(1),obj.Subject.LastName(1)],'');
              else
                  subjectName = "Missing";
              end
              fitString = strjoin(["f",string(obj.Fit)],'');
              if(~isempty(obj.StepName))
                step = obj.StepName;
              else
                  step = "Missing";
              end
              fileName = sprintf('DR-%s-%s-%s-%s.mat',...
                                 string(obj.Date, bose.cnc.datetimeFileFormat),...
                                 subjectName,step,fitString);
        end % get.FileName

        function inputSignals = get.InputSignals(obj)
            if isempty(obj.InputMapping)
                inputSignals = bose.cnc.meas.Signal.empty;
            else
                inputSignals = vertcat(obj.InputMapping.Signal);
            end
        end % get.InputSignals

        function outputSignals = get.OutputSignals(obj)
            if isempty(obj.OutputMapping)
                outputSignals = bose.cnc.meas.Signal.empty;
            else
                outputSignals = vertcat(obj.OutputMapping.Signal);
            end
        end % get.OutputSignals
    end % Get/Set Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% STATIC METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static)
        function templateStruct = template
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.DataRecord.DataRecord
            parser = bose.cnc.meas.DataRecord.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end % template

        obj = loadFromDatabase(objKeys)
        obj = loadFromFile(targetFile)
        obj = loadFromFolder(targetFolder);
        obj = loadobj(loadStruct)
        dataRecord = rmeoutToDataRecord(varargin)
    end % Public, Static methods

    %% PRIVATE STATIC METHODS
    methods (Static, Access = protected, Hidden)
        function parser = createParser
            parser = inputParser();
            parser.addParameter('Date', datetime(0, 'ConvertFrom', 'epochtime'));
            parser.addParameter('Environment', bose.cnc.meas.Environment.empty);
            parser.addParameter('ExcitationFilters', double.empty);
            parser.addParameter('ExcitationGain', double.empty);
            parser.addParameter('ExcitationType', bose.cnc.meas.ExcitationType.empty);
            parser.addParameter('Fit', uint64(false));
            parser.addParameter('Hardware', bose.cnc.meas.Hardware.empty);
            parser.addParameter('Headphone', bose.cnc.meas.Headphone.empty);
            parser.addParameter('InputMapping', bose.cnc.meas.Mapping.empty);
            parser.addParameter('Operator', bose.cnc.meas.Person.empty);
            parser.addParameter('OutputMapping', bose.cnc.meas.Mapping.empty);
            parser.addParameter('SignalParameters', bose.cnc.meas.SignalParameters.empty);
            parser.addParameter('StepName', string, @bose.common.validators.mustBeStringLike);
            parser.addParameter('StepType', bose.cnc.meas.StepType.empty);
            parser.addParameter('Subject', bose.cnc.meas.Person.empty);
            parser.addParameter('ToolboxVersion', string);
            parser.addParameter('XsData', double.empty);
            parser.addParameter('TimeData',double.empty);
        end % createParser
    end % Static, Private, Hidden methods
end % Classdef
