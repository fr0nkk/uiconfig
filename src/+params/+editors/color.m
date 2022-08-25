classdef color < handle
    
    properties
        textField
        colorButton
        cparam
        cfgset
        g
    end
    
    methods
        function obj = color(cparam,val,parent,cfgset)
            obj.g = uigridlayout(parent,[1 2],'ColumnWidth',{'1x',50},'Padding',0,'ColumnSpacing',5);

            obj.textField = uisetlayout(uieditfield(obj.g,'text','Value',cparam.toString(val),'Editable',cparam.editable,'ValueChangedFcn',@obj.SetFromText),1,1);

            obj.colorButton = uisetlayout(uibutton(obj.g,'BackgroundColor',double(val)./255,'Text','','ButtonPushedFcn',@obj.SetFromButton,'Enable',cparam.editable),1,2);

            obj.cfgset = cfgset;
            obj.cparam = cparam;
        end

        function SetFromText(obj,src,evt)
            obj.cparam.uisetprop(obj.textField,obj.cfgset);
%             if obj.cparam.uisetprop(obj.textField,obj.cfgset)
%                 obj.colorButton.BackgroundColor = double(obj.cparam.fromString(obj.textField.Value))./255;
%             end
        end

        function SetFromButton(obj,src,evt)
            f = ancestor(obj.colorButton,'figure');
            c = uisetcolor(obj.colorButton.BackgroundColor);
            figure(f);
            if ~isscalar(c)
                obj.textField.Value = obj.cparam.toString(uint8(round(c.*255)));
                obj.SetFromText;
            end
        end
    end
end

