classdef file < uic.char
    
    properties
        type = 'get' % get, put, dir
    end
    
    methods
        function obj = file(default,type)
            if nargin < 1 || isempty(default), default = getenv('USERPROFILE'); end
            obj@uic.char(default,false);
            if nargin >= 2, obj.type = type; end
        end

        function val = validate(obj,val)
            val = obj.validate@uic.char(val);
        end

        function c = uiTextField(obj,parent)
            c = uic.editors.file(obj,parent).g;
        end

        function updateuiFcn(obj,comp)
            comp.Children(1).Value = obj.toString(obj.value);
        end
    end
end

