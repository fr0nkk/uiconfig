classdef (ConstructOnLoad) ParamChangedEvent < event.EventData
   properties
      param
      value
   end
   
   methods
       function data = ParamChangedEvent(param,value)
         data.param = param;
         data.value = value;
      end
   end
end