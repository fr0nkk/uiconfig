classdef file < uic.abstract
    
    properties
        default = fullfile(getenv('USERPROFILE'),'*.*');
        type = 'get' % get, put, dir, multi
    end
    
    methods
        function obj = file(default,type)
            if nargin >= 1 && ~isempty(default), obj.default = default; end
            if nargin >= 2, obj.type = type; end
            obj.oArgs = {obj.default,obj.type};
        end

        function val = validate(obj,val)
            if isempty(val)
                error('Empty not allowed');
            end
            if ~ischar(val) && ~(iscell(val) && all(cellfun(@ischar,val)))
                error('invalid type, must be char or cell of char');
            end
            if iscell(val)
                val = val(:)';
            end
            val = obj.validate@uic.abstract(val);
        end

        function c = uiTextField(obj,parent)
            c = uic.editors.file(obj,parent).g;
        end

        function updateValueFcn(obj,comp)
            comp.Children(1).Value = obj.toString(obj.value);
        end

        function updateEditableFcn(obj,comp)
            tf = obj.editable;
            comp.Children(1).Editable = tf;
            comp.Children(2).Enable = tf;
        end

        function s = toString(obj,v)
            if iscell(v)
                s = strjoin(v,char(124));
            else
                s=v;
            end
        end

        function v = fromString(obj,s)
            if any(s == char(124))
                v = strsplit(s,char(124));
            else
                v = s;
            end
        end
    end
end

