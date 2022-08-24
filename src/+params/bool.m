classdef bool < params.scalar
    
    properties
        
    end
    
    methods
        function obj = bool(default)
            if nargin < 1, default = false; end
            default = logical(default);
            obj@params.scalar(default);
        end

        function c = ui(obj,val,parent,cfgset,varargin)
            c = uicheckbox(parent,'Value',val,'Enable',~obj.constant,'ValueChangedFcn',@(src,evt) cfgset(src.Value),'Text','');
        end

    end
    
end

