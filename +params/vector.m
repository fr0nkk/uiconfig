classdef vector < params.matrix
    
    properties
        
    end
    
    methods
        function obj = vector(default,sz)
            if nargin < 1, default = nan; end
            if nargin < 2, sz = []; end
            if isempty(sz), sz = nan; end
            obj@params.matrix(default,[1 sz(1)]);
        end

        function str = toString(obj,val)
            fmt = [obj.getFmt(1) ' '];
            str = sprintf(fmt,val);
            str = str(1:end-1);
        end

        function val = fromString(obj,str)
            str = [strtrim(str) ' '];
            fmt = [obj.getFmt(0) ' '];
            val = sscanf(str,fmt)';
        end

        function c = ui(varargin)
            c = ui@params.abstract(varargin{:});
        end

        
    end

    
end

