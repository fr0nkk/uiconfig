classdef file < params.char
    
    properties
        type = 'get' % get, put, dir
    end
    
    methods
        function obj = file(type,default)
            if nargin < 2, default = getenv('USERPROFILE'); end
            obj@params.char(default,false);

            if nargin >= 1, obj.type = type; end
        end

        function val = validate(obj,val)
            val = obj.validate@params.char(val);
        end

        function c = ui(obj,val,parent,cfgset)
            c = params.editors.file(obj,val,parent,cfgset).g;
        end
    end
end

