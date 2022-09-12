classdef scalar < uic.matrix
    
    properties
        
    end
    
    methods
        function obj = scalar(default)
            if nargin < 1, default = nan; end
            obj@uic.matrix(default,1);
            obj.oArgs = {obj.default};
        end

        function str = toString(obj,val)
            fmt = obj.getFmt(1);
            str = sprintf(fmt,val);
        end

        function val = fromString(obj,str)
            fmt = obj.getFmt(0);
            val = sscanf(str,fmt);
        end

        function c = uiTextField(varargin)
            c = uiTextField@uic.abstract(varargin{:});
        end

        function updateValueFcn(varargin)
            updateValueFcn@uic.abstract(varargin{:});
        end

        function updateEditableFcn(varargin)
            updateEditableFcn@uic.abstract(varargin{:});
        end

        
    end

    
end

