classdef datetime < uic.abstract
    
    properties
        default = now
        dispFormat = 'yyyy-MM-dd HH:mm:ss'
        internalFormat = 'yyyy-MM-dd HH:mm:ss.SSSSSSSSS';
    end
    
    methods
        function obj = datetime(default,DisplayFormat)
            if nargin >= 1 && ~isempty(default)
                obj.default = obj.validate(default);
            end
            if nargin >= 2
                obj.dispFormat = DisplayFormat;
            end
            obj.oArgs = {obj.default,obj.dispFormat};
        end

        function val = validate(obj,val)
            if isfloat(val)
                val = datetime(val,'ConvertFrom','datenum');
            end
            if ~isdatetime(val)
                error('must be datetime class')
            end

            if isnat(val)
                error('invalid time, must be format: %s',obj.dispFormat);
            end

            if ~isscalar(val)
                error('datetime must be scalar')
            end

            val = obj.validate@uic.abstract(val);
        end

        function c = uiTextField(obj,parent)
            v = obj.value;
            v.Format = obj.dispFormat;
            c = uieditfield(parent,'Value',char(v),'Enable',obj.editable,'ValueChangedFcn',@(src,evt) obj.setPropFromField(src));
        end

        function setPropFromField(obj,comp)
            try
                value = datetime(comp.Value,'InputFormat',obj.dispFormat);
            catch
                value = str2double(comp.Value);
            end

            comp.BackgroundColor = [1 1 1];
            comp.Tooltip = '';
            try
                obj.uiSetValue(value);
            catch ME
                if isvalid(comp)
                    comp.Tooltip = ME.message;
                    comp.BackgroundColor = [1 0.8 0.8];
                else
                    disp('component is deleted')
                    return
                end
            end
        end

        function updateValueFcn(obj,comp)
            v = obj.value;
            v.Format = obj.dispFormat;
            comp.Value = char(v);
        end

        function str = toString(obj,val)
            val.Format = obj.internalFormat;
            str = char(val);
        end

        function val = fromString(obj,str)
            val = datetime(str,'InputFormat',obj.internalFormat);
        end

    end
end

