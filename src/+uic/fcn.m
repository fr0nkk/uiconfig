classdef fcn < uic.abstract
    
    properties
        default = @(varargin) 0
    end
    
    methods
        function obj = fcn(default)
            if nargin >= 1, obj.default = default; end
            obj.oArgs = {obj.default};
        end

        function val = validate(obj,val)
            if ~isa(val,'function_handle')
                error('Not a function handle')
            end
            val = obj.validate@uic.abstract(val);
        end

        function str = toString(obj,val)
            str = func2str(val);
            if ~startsWith(str,'@')
                str = ['@' str];
            end
        end

        function val = fromString(obj,str)
            val = str2func(str);
        end
    end
end

