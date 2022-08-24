classdef scalar < params.matrix
    
    properties
        
    end
    
    methods
        function obj = scalar(default)
            if nargin < 1, default = nan; end
            obj@params.matrix(default,1);
        end

        function str = toString(obj,val)
            fmt = obj.getFmt(1);
            str = sprintf(fmt,val);
        end

        function val = fromString(obj,str)
            fmt = obj.getFmt(0);
            val = sscanf(str,fmt);
        end

        function c = ui(varargin)
            c = ui@params.abstract(varargin{:});
        end

        
    end

    
end

