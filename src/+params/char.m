classdef char < params.abstract
    
    properties
        default = ''
        emptyAllowed = true
    end
    
    methods
        function obj = char(default,emptyAllowed)
            if nargin >= 1, obj.default = default; end
            if nargin >= 2 && ~isempty(emptyAllowed), obj.emptyAllowed = emptyAllowed; end
        end
        
        function val = validate(obj,val)
            if ~ischar(val)
                error('Not a character array')
            end
            if ~obj.emptyAllowed && isempty(val)
                error('Empty value not allowed');
            end
            val = obj.validate@params.abstract(val);
        end

        function str = toString(obj,val)
            str = val;
        end

        function val = fromString(obj,str)
            val = str;
        end
    end
end

