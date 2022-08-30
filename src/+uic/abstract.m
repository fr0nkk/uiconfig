classdef abstract < handle
    properties(Abstract)
        default
    end

    properties
        value
        name = ''
        description = ''
        hidden logical = false
        enabled logical = true
        constant logical = false
        validFcn = @(val) val
        postsetFcn;
    end

    properties(Dependent)
        editable
    end

    properties(Hidden)
        uicomp = {}
        uipos = [];
    end

    methods
        function set.value(obj,v)
            obj.value = obj.validate(v);
            obj.updateui;
            obj.postset;
        end

        function set.hidden(obj,h)
            obj.hidden = h;
            obj.updateuih;
        end

        function postset(obj)
            if ~isempty(obj.postsetFcn)
                obj.postsetFcn();
            end
        end

        function val = validate(obj,val)
            if obj.constant && ~strcmp(obj.toString(val),obj.toString(obj.default))
                error('Param is constant')
            end
            if ~obj.enabled
                error('Param is not enabled');
            end
            val = obj.validFcn(val);
        end

        function makeui(obj,g,i)
            uisetlayout(uilabel(g,'Text',obj.name,'Tooltip',obj.description),i,1);
            c = uisetlayout(obj.uiTextField(g),i,2);
            c.UserData.NoUpdate = false;
            obj.uicomp{end+1} = c;
            obj.uipos(end+1) = i;
            g.RowHeight{i} = 25*~obj.hidden;
        end

        function c = uiTextField(obj,parent)
            c = uieditfield(parent,'text', ...
                'Value',obj.toString(obj.value), ...
                'ValueChangedFcn',@(src,evt) obj.setPropFromTextField(src), ...
                'Editable',obj.editable);
        end

        function success = setPropFromTextField(obj,comp)
            success = true;
            comp.BackgroundColor = [1 1 1];
            comp.Tooltip = '';
            try
                obj.value = obj.fromString(comp.Value);
            catch ME
                success = false;
                if isvalid(comp)
                    comp.Tooltip = ME.message;
                    comp.BackgroundColor = [1 0.8 0.8];
                else
                    disp('component is deleted')
                    return
                end
            end
        end

        function tf = get.editable(obj)
            tf = ~obj.constant && obj.enabled;
        end

        function updateui(obj)
            c = obj.validcomp;
            cellfun(@obj.updateuiFcn,c)
        end

        function updateuih(obj)
            [c,i] = obj.validcomp;
            for j=1:numel(c)
                P = c{j}.Parent.Parent;
                tf = ~obj.hidden || P.UserData.ShowHidden;
                obj.updateuihFcn(c{j},i(j),tf);
            end
        end

        function [c,i] = validcomp(obj)
            tf = cellfun(@isvalid,obj.uicomp);
            obj.uicomp = obj.uicomp(tf);
            obj.uipos = obj.uipos(tf);
            c = obj.uicomp;
            i = obj.uipos;
        end

        function updateuihFcn(obj,comp,i,tf)
            comp.Parent.RowHeight{i} = 25*tf;
        end

        function updateuiFcn(obj,comp)
            comp.Value = obj.toString(obj.value);
        end
    end
    
    methods(Abstract)
        str = toString(obj,val)
        val = fromString(obj,str)
    end
end


