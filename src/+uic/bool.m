classdef bool < uic.scalar
    
    properties
        
    end
    
    methods
        function obj = bool(default)
            if nargin < 1, default = false; end
            default = logical(default);
            obj@uic.scalar(default);
        end

        function c = uiTextField(obj,parent)
            c = uicheckbox(parent,'Value',obj.value,'Enable',obj.editable,'ValueChangedFcn',@(src,evt) obj.setPropFromCheckbox(src),'Text','');
        end

        function setPropFromCheckbox(obj,comp)
            obj.value = comp.Value;
        end

        function updateuiFcn(obj,comp)
            comp.Value = obj.value;
        end

    end
    
end

