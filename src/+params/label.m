classdef label < params.char
    
    properties
        
    end
    
    methods
        function obj = label(text)
            if nargin < 1, text = pad('',50,'-'); end
            obj@params.char(text);
        end

        function ui_base(obj,g,i,name,val,cfgset)
            uisetlayout(uilabel(g,'Text',val),i,[1 2]);
        end

    end
    
end

