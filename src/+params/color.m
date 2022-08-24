classdef color < params.vector
    
    properties
        
    end
    
    methods
        function obj = color(default)
            if nargin < 1, default = uint8([128 128 128]); end
            if ~isa(default,'uint8')
                error('color must be 1x3 uint8');
            end
            obj@params.vector(default,3);
        end

        function c = ui(obj,val,parent,cfgset)
            c = params.editors.color(obj,val,parent,cfgset).g;
        end
    end
end




