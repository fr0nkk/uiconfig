classdef abstract
    properties(Abstract)
        default
    end

    properties
        name = ''
        description = ''
        hidden = false
        constant = false
        validFcn = @(val) val
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
            val = obj.validFcn(val);
        end

        function c = ui(obj,val,parent,cfgset,varargin)
            c = uieditfield(parent,'text', ...
                'Value',obj.toString(val), ...
                'ValueChangedFcn',@(src,evt) obj.uisetprop(src,cfgset,varargin{:}), ...
                'Editable',~obj.constant);
        end

        function success = uisetprop(obj,comp,cfgset,varargin)
            success = true;
            try
                v = obj.fromString(comp.Value);
                v = obj.validate(v);
                cfgset(v);
                comp.Value = obj.toString(v);
                for i=1:numel(varargin)
                    varargin{i}(v);
                end
                comp.BackgroundColor = [1 1 1];
                comp.Tooltip = '';
            catch ME
                comp.Tooltip = ME.message;
                comp.BackgroundColor = [1 0.8 0.8];
                success = false;
            end
        end
    end
    
    methods(Abstract)
        str = toString(obj,val)
        val = fromString(obj,str)
    end
end


