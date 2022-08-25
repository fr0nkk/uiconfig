classdef abstract
    properties(Abstract)
        default
    end

    properties
        name = ''
        description = ''
        hidden logical = false
        enabled logical = true
        constant logical = false
        validFcn = @(val) val
        UserData
    end

    properties(Dependent)
        editable
    end

    methods
%         function obj = abstract()
%             obj.default = obj.validate(obj.default);
%         end
    end

    methods
        function val = validate(obj,val)
            if obj.constant && ~strcmp(obj.toString(val),obj.toString(obj.default))
                error('Param is constant')
            end
            if ~obj.enabled
                error('Param is not enabled');
            end
            val = obj.validFcn(val);
        end

        function ui_base(obj,g,i,name,val,cfgset)
            uisetlayout(uilabel(g,'Text',name,'Tooltip',obj.description),i,1);
            uisetlayout(obj.ui(val,g,cfgset),i,2);
        end

        function c = ui(obj,val,parent,cfgset)
            c = uieditfield(parent,'text', ...
                'Value',obj.toString(val), ...
                'ValueChangedFcn',@(src,evt) obj.uisetprop(src,cfgset), ...
                'Editable',obj.editable);
        end

        function success = uisetprop(obj,comp,cfgset)
            success = true;
            comp.BackgroundColor = [1 1 1];
            comp.Tooltip = '';
            try
                v = obj.fromString(comp.Value);
                v = obj.validate(v);
            catch ME
                comp.Tooltip = ME.message;
                comp.BackgroundColor = [1 0.8 0.8];
                success = false;
                return
            end
            cfgset(v);
        end

        function tf = get.editable(obj)
            tf = ~obj.constant && obj.enabled;
        end
    end
    
    methods(Abstract)
        str = toString(obj,val)
        val = fromString(obj,str)
    end
end


