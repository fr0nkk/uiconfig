classdef date < uic.abstract
    
    properties
        default = NaT
        dispFormat = 'yyyy-MM-dd'
    end
    
    methods
        function obj = date(default,DisplayFormat)
            if nargin >= 1 && ~isempty(default)
                obj.default = obj.validate(default);
            end
            if nargin >= 2
                obj.dispFormat = DisplayFormat;
            end
        end

        function val = validate(obj,val)
            if ~isdatetime(val)
                error('must be datetime class')
            end

            if ~isscalar(val)
                error('datetime must be scalar')
            end

            val = obj.validate@uic.abstract(val);
        end

        function c = uiTextField(obj,parent)
            c = uidatepicker(parent,'Value',obj.value,'Enable',obj.editable,'ValueChangedFcn',@(src,evt) obj.setPropFromDatePicker(src),'DisplayFormat',obj.dispFormat);
        end

        function setPropFromDatePicker(obj,comp)
            obj.uiSetValue(comp.Value);
        end

        function updateValueFcn(obj,comp)
            comp.Value = obj.value;
        end

        function updateEditableFcn(obj,comp)
            comp.Enable = obj.editable;
        end

        function str = toString(obj,val)
            val.Format = obj.dispFormat;
            str = char(val);
        end

        function val = fromString(obj,str)
            val = datetime(str,'InputFormat',obj.dispFormat);
        end

    end
end

