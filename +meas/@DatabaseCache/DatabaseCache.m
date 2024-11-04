classdef DatabaseCache < bose.cnc.classes.StructInputHandle
    %DATABASECACHE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ConfigurationTable {istable(ConfigurationTable)};
        HeadphoneTypesArray {isa(HeadphoneTypesArray,'bose.cnc.meas.HeadphoneType')};
        HeadphoneObjectArray {isa(HeadphoneObjectArray,'bose.cnc.meas.Headphone')};
        HardwareObjectArray {isa(HardwareObjectArray,'bose.cnc.meas.Headphone')};
        PersonObjectArray {isa(PersonObjectArray,'bose.cnc.meas.Person')};
        EnvironmentObjectArray {isa(EnvironmentObjectArray,'bose.cnc.meas.Environment')};
    end
    
    methods(Access = private)
        function obj = DatabaseCache(varargin)
            %DATABASECACHE Construct an instance of this class
            %   Detailed explanation goes here
            parser = bose.cnc.meas.DatabaseCache.createParser;
            parser.parse(varargin{:});
            obj.ConfigurationTable = parser.Results.ConfigurationTable;
            obj.HeadphoneTypesArray = parser.Results.HeadphoneTypesArray;
            obj.HeadphoneObjectArray = parser.Results.HeadphoneObjectArray;
            obj.HardwareObjectArray = parser.Results.HardwareObjectArray;
            obj.PersonObjectArray = parser.Results.PersonObjectArray;
            obj.EnvironmentObjectArray = parser.Results.EnvironmentObjectArray;
        end
    end
    
    methods
        function isValid = hasValidConfigurationTable(obj)
           isValid = ~isempty(obj.ConfigurationTable);
        end
        
        function isValid = hasValidHeadphoneTypesArray(obj)
           isValid = ~isempty(obj.HeadphoneTypesArray);
        end
        
        function isValid = hasValidHeadphoneObjectArray(obj)
           isValid = ~isempty(obj.HeadphoneObjectArray);
        end
        
        function isValid = hasValidHardwareObjectArray(obj)
           isValid = ~isempty(obj.HardwareObjectArray);
        end
        
        function isValid = hasValidPersonObjectArray(obj)
           isValid = ~isempty(obj.PersonObjectArray);
        end
        
        function isValid = hasValidEnvironmentObjectArray(obj)
            isValid = ~isempty(obj.EnvironmentObjectArray);
        end
        
        function toMatFile(obj,targetPath)
            warnStruct = warning('off', 'MATLAB:structOnObject');
            saveStruct = struct(obj);
            warning(warnStruct);
            save(string(targetPath), '-struct', 'saveStruct', '-v7.3');
        end
        
        function obj = resetCache(obj)
            obj = obj.resetConfigurationTable();
            obj = obj.resetPersonObjectArray();
            obj = obj.resetHardwareObjectArray();
            obj = obj.resetHeadphoneObjectArray();
            obj = obj.resetHeadphoneTypesArray();
            obj = obj.resetEnvironmentObjectArray();
        end  
        
        function obj = resetConfigurationTable(obj)
            obj.ConfigurationTable = table(single.empty, string.empty, single.empty, string.empty ,'VariableNames',{'ConfigurationKey','Name','Version','DateCreated'});
        end
        
        function obj = resetPersonObjectArray(obj)
            obj.PersonObjectArray = bose.cnc.meas.Person.empty;
        end
        
        function obj = resetHardwareObjectArray(obj)
            obj.HardwareObjectArray = bose.cnc.meas.Hardware.empty;
        end
        
        function obj = resetHeadphoneObjectArray(obj)
            obj.HeadphoneObjectArray = bose.cnc.meas.Headphone.empty;
        end
        
        function obj = resetHeadphoneTypesArray(obj)
            obj.HeadphoneTypesArray =  bose.cnc.meas.HeadphoneType.empty;
        end
        
        function obj = resetEnvironmentObjectArray(obj)
           obj.EnvironmentObjectArray = bose.cnc.meas.Environment.empty; 
        end
    end
    
    methods(Static,Access = public)
        function obj = start(varargin)
            persistent uniqueInstance % Returns empty if the variable hasn't been set before.
            if isempty(uniqueInstance) || ~isvalid(uniqueInstance)
                obj = bose.cnc.meas.DatabaseCache(varargin{:});
                uniqueInstance = obj; % Set the persistent variable
            else
                obj = uniqueInstance;
            end
        end
            
        function obj = fromMatFile(targetPath)
                loadStruct = load(targetPath);
                obj = bose.cnc.meas.DatabaseCache.start(loadStruct);
        end
        
        function templateStruct = template()
            %TEMPLATE Returns a struct to be used in this class's constructor.
            %
            %See also: bose.cnc.meas.Configuration.Configuration
            parser = bose.cnc.meas.DatabaseCache.createParser;
            parser.parse;
            templateStruct = parser.Results;
        end
    end

    methods (Static, Access = protected, Hidden)
        function parser = createParser()
            parser = inputParser();
            parser.addParameter('ConfigurationTable', table(single.empty, string.empty, single.empty, string.empty ,'VariableNames',{'ConfigurationKey','Name','Version','DateCreated'}));
            parser.addParameter('HeadphoneTypesArray', bose.cnc.meas.HeadphoneType.empty);
            parser.addParameter('HeadphoneObjectArray',  bose.cnc.meas.Headphone.empty);
            parser.addParameter('HardwareObjectArray', bose.cnc.meas.Hardware.empty);
            parser.addParameter('PersonObjectArray', bose.cnc.meas.Person.empty);
            parser.addParameter('EnvironmentObjectArray',bose.cnc.meas.Environment.empty);
        end % createParser
    end % Static, Private, Hidden methods
end

