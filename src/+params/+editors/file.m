classdef file < handle
    
    properties
        textField
        editButton
        cparam
        cfgset
        g
    end
    
    methods
        function obj = file(cparam,val,parent,cfgset)
            obj.g = uigridlayout(parent,[1 2],'ColumnWidth',{'1x',50},'Padding',0,'ColumnSpacing',5);

            obj.textField = uisetlayout(uieditfield(obj.g,'text','Value',cparam.toString(val),'Editable',cparam.editable,'ValueChangedFcn',@obj.SetFromText),1,1);

            obj.editButton = uisetlayout(uibutton(obj.g,'Text','Select','ButtonPushedFcn',@obj.SetFromButton,'Enable',cparam.editable),1,2);

            obj.cfgset = cfgset;
            obj.cparam = cparam;
        end

        function SetFromText(obj,src,evt)
            obj.cparam.uisetprop(obj.textField,obj.cfgset);
        end

        function SetFromButton(obj,src,evt)
            a = ancestor(obj.editButton,'figure');
            filt = obj.cparam.fromString(obj.textField.Value);
            switch obj.cparam.type
                case 'get'
                    [f,d] = uigetfile(filt);
                case 'put'
                    [f,d] = uiputfile(filt);
                case 'dir'
                    f = uigetdir(filt);
                    d = [];
                otherwise
                    error('invalid file type, must be get, put or dir');
            end
            figure(a);
            if f
                fn = fullfile(d,f);
                obj.FinishEdit(fn);
            end
        end

        function FinishEdit(obj,M)
            obj.textField.Value = obj.cparam.toString(M);
            obj.SetFromText;
        end
    end
end

