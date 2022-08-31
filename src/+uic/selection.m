classdef selection < uic.char
    
    properties
        options
    end
    
    methods
        function obj = selection(options,default)
            if ~iscell(options)
                error('options must be cell array of char')
            end
            if nargin < 2, default = options{1}; end

            obj@uic.char(default,false);

            obj.options = options;
            
        end

        function val = validate(obj,val)
            if ~ismember(val,obj.options)
                error('%s is not member of (%s)',val,strjoin(obj.options,', '));
            end
            val = obj.validate@uic.char(val);
        end

        function c = uiTextField(obj,parent)
            c = uidropdown(parent,'Value',obj.value,'Enable',obj.editable,'ValueChangedFcn',@(src,evt) obj.setPropFromDropdown(src),'Items',obj.options);
        end

        function setPropFromDropdown(obj,comp)
            obj.uiSetValue(comp.Value);
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

