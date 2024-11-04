function [timeDutCellArrayOut , stepNames] = timedut(obj)
%timedut - Takes in a single or an array of dataRecords and gives output
%for each step.
%Make each passed in data record into a time dut
logger = bose.cnc.logging.getLogger;
convertedTimeDuts = cell(size(obj));
for x =1:numel(obj)
   InputMappingSignals = [obj(x).InputMapping.Signal];
   InputMappingSignalName = [InputMappingSignals.Name];
   convertedTimeDuts{x} = timedut(obj(x).TimeData,double(obj(x).SignalParameters.Fs));
   convertedTimeDuts{x}.Output = 'Input';
   convertedTimeDuts{x}.Input.Value = cellstr(InputMappingSignalName);
   fitString = sprintf('fit%i',obj(x).Fit);
   convertedTimeDuts{x} = newdim('fit',convertedTimeDuts{x});
   convertedTimeDuts{x} = newdim('step',convertedTimeDuts{x});
   convertedTimeDuts{x} = newdim('subject',convertedTimeDuts{x});
   convertedTimeDuts{x} = newdim('headphone',convertedTimeDuts{x});
   convertedTimeDuts{x}.fit.Value = cellstr(fitString);
   convertedTimeDuts{x}.step.Value = cellstr(obj(x).StepName);
   %Subject and headphone are allowed to be empty.
   if(~isempty(obj(x).Subject))
       convertedTimeDuts{x}.subject.Value = cellstr(obj(x).Subject.DisplayName);
   else
       convertedTimeDuts{x}.subject.Value = cellstr('NoSubject');
   end
   
   if(~isempty(obj(x).Headphone))
       convertedTimeDuts{x}.headphone.Value = cellstr(strjoin([obj(x).Headphone.Name]));
   else
       convertedTimeDuts{x}.subject.Value = cellstr('NoHeadphone');
   end
end

%When making a dut you cant be sure what dim you need to concat
%on. This list is the priority of what dimension to concat on
%(lower is lower priority).
dimensionForCat = {'fit','subject','headphone'};
stepNames = convertedTimeDuts{1}.step.Value;
timeDutCellArrayOut = convertedTimeDuts(1);
for x = 2:numel(obj)
    thisTimeDut = convertedTimeDuts{x};
    thisStepName = thisTimeDut.step.Value;
    thisStepIdx = find(contains(stepNames,thisStepName),1);
    if(isempty(thisStepIdx))
        stepNames= [stepNames thisStepName];
        thisStepName = length(stepNames);
        timeDutCellArrayOut{end+1} = thisTimeDut;
        continue;
    end
    catCompleted = false;
    for y = length(dimensionForCat):-1:1
        if(any(contains(timeDutCellArrayOut{thisStepIdx}.(dimensionForCat{y}).Value,...
               thisTimeDut.(dimensionForCat{y}).Value)))
               continue; 
        end
        timeDutCellArrayOut{thisStepIdx} = cat(dimensionForCat{y},timeDutCellArrayOut{thisStepIdx},thisTimeDut);
        catCompleted = true;
    end
    if(~catCompleted)
        ME = MException('bose:cnc:meas:DataRecord:timedut:RepeatedData', ...
                        ['Saving data is only supported for data that does not have a repeated headphone,subject,fit,step combination.',...
                        'Please ensure none of your selected data includes repeated recording stages']);
        throw(ME);
    end
end
    timeDutWhos = whos('timeDutCellArrayOut');
    timeDutSizeMB = timeDutWhos.bytes/1024^2;
    infoString = sprintf('Converted %i DataRecords across %i Recording steps to %i timeduts (%3.1f MB)'...
                         ,numel(obj), numel(stepNames), numel(timeDutCellArrayOut),timeDutSizeMB);
    logger.info(infoString);

end % function
