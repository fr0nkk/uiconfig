classdef color < handle
    
    properties
        textField
        colorButton
        cparam
        g
    end
    
    methods
        function obj = color(cparam,parent)
            obj.g = uigridlayout(parent,[1 2],'ColumnWidth',{'1x',50},'Padding',0,'ColumnSpacing',5);

            obj.textField = uisetlayout(uieditfield(obj.g,'text','Value',cparam.toString(cparam.value),'Editable',cparam.editable,'ValueChangedFcn',@obj.SetFromText),1,1);

            obj.colorButton = uisetlayout(uibutton(obj.g,'BackgroundColor',double(cparam.value)./255,'Text','','ButtonPushedFcn',@obj.SetFromButton,'Enable',cparam.editable),1,2);

            obj.cparam = cparam;
        end

        function SetFromText(obj,src,evt)
            obj.cparam.setPropFromTextField(obj.textField);
        end

        function SetFromButton(obj,src,evt)
            f = ancestor(obj.colorButton,'figure');
            c = uisetcolor(obj.colorButton.BackgroundColor);
            figure(f);
            if ~isscalar(c)
                obj.cparam.value = uint8(round(c.*255));
            end
        end
    end
end

