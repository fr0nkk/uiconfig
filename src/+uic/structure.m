classdef structure < uic.abstract
    
    properties
        default = struct
    end
    
    methods
        function obj = structure(default)
            if nargin >= 1, obj.default = default; end
            obj.oArgs = {obj.default};
        end
        
        function val = validate(obj,val)
            if ~isstruct(val)
                error('Not a struct')
            end
            val = obj.validate@uic.abstract(val);
        end

        function str = toString(obj,val)
            str = jsonencode(val);
        end

        function val = fromString(obj,str)
            val = jsondecode(str);
        end
    end
end

