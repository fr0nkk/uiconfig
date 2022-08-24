classdef matrix < handle
    
    properties
        textField
        editButton
        cparam
        cfgset
        g
    end
    
    methods
        function obj = matrix(cparam,val,parent,cfgset)
            obj.g = uigridlayout(parent,[1 2],'ColumnWidth',{'1x',50},'Padding',0,'ColumnSpacing',5);

            obj.textField = uisetlayout(uieditfield(obj.g,'text','Value',cparam.toString(val),'Editable',~cparam.constant,'ValueChangedFcn',@obj.SetFromText),1,1);

            obj.editButton = uisetlayout(uibutton(obj.g,'Text','Edit','ButtonPushedFcn',@obj.SetFromButton),1,2);

            obj.cfgset = cfgset;
            obj.cparam = cparam;
        end

        function SetFromText(obj,src,evt)
            obj.cparam.uisetprop(obj.textField,obj.cfgset);
        end

        function SetFromButton(obj,src,evt)
            u = matrixeditor(obj.cparam.fromString(obj.textField.Value));
            u.fcnOK = @(M) obj.FinishEdit(M,u);
            u.castDropdown.Enable = false;
            u.parent.WindowStyle = 'modal';
        end

        function FinishEdit(obj,M,u)
            obj.textField.Value = obj.cparam.toString(M);
            obj.SetFromText;
            u.parent.delete;
        end
    end
end

