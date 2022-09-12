classdef color < uic.vector
    
    properties
        
    end
    
    methods
        function obj = color(default)
            if nargin < 1, default = uint8([255 255 255]); end
            if ~isa(default,'uint8')
                error('color must be 1x3 uint8');
            end
            obj@uic.vector(default,3);
            obj.oArgs = {obj.default};
        end

        function c = uiTextField(obj,parent)
            c = uic.editors.color(obj,parent).g;
        end

        function updateValueFcn(obj,comp)
            comp.Children(1).Value = obj.toString(obj.value);
            comp.Children(2).BackgroundColor = double(obj.value)./255;
        end

        function updateEditableFcn(obj,comp)
            tf = obj.editable;
            comp.Children(1).Editable = tf;
            comp.Children(2).Enable = tf;
        end
    end
end




