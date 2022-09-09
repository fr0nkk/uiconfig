classdef file < handle
    
    properties
        textField
        editButton
        cparam
        g
    end
    
    methods
        function obj = file(cparam,parent)
            obj.g = uigridlayout(parent,[1 2],'ColumnWidth',{'1x',50},'Padding',0,'ColumnSpacing',5);

            obj.textField = uisetlayout(uieditfield(obj.g,'text','Value',cparam.toString(cparam.value),'Editable',cparam.editable,'ValueChangedFcn',@obj.SetFromText),1,1);

            obj.editButton = uisetlayout(uibutton(obj.g,'Text','Select','ButtonPushedFcn',@obj.SetFromButton,'Enable',cparam.editable),1,2);

            obj.cparam = cparam;
        end

        function SetFromText(obj,src,evt)
            obj.cparam.setPropFromTextField(obj.textField);
        end

        function SetFromButton(obj,src,evt)
            a = ancestor(obj.editButton,'figure');
            filt = obj.cparam.fromString(obj.textField.Value);
            title = ['Select ' obj.cparam.name];
            switch obj.cparam.type
                case 'get'
                    [f,d] = uigetfile(filt,title);
                case 'put'
                    [f,d] = uiputfile(filt,title);
                case 'dir'
                    f = uigetdir(filt,title);
                    d = [];
                case 'multi'
                    if iscell(filt)
                        filt = fullfile(fileparts(filt{1}),'*.*');
                    end
                    [f,d] = uigetfile(filt,title,'MultiSelect','on');
                otherwise
                    error('invalid file type, must be get, put, dir or multi');
            end
            figure(a);
            if iscell(f) || ischar(f)
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

