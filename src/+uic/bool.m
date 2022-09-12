classdef bool < uic.scalar
    
    properties
        
    end
    
    methods
        function obj = bool(default)
            if nargin < 1, default = false; end
            default = logical(default);
            obj@uic.scalar(default);
            obj.oArgs = {obj.default};
        end

        function c = uiTextField(obj,parent)
            c = uicheckbox(parent,'Value',obj.value,'Enable',obj.editable,'ValueChangedFcn',@(src,evt) obj.setPropFromCheckbox(src),'Text','');
        end

        function setPropFromCheckbox(obj,comp)
            obj.uiSetValue(comp.Value)
%             obj.value = comp.Value;
        end

        function updateValueFcn(obj,comp)
            comp.Value = obj.value;
        end

        function updateEditableFcn(obj,comp)
            comp.Enable = obj.editable;
        end

    end
    
end

