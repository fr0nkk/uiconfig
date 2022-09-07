classdef abstract < handle
    properties(Abstract)
        default
    end

    properties(SetObservable=true)
        value
    end

    properties
        name = ''
        description = ''
        hidden logical = false
        enabled logical = true
        constant logical = false
        validFcn = @(val) val
        postset
    end

    properties(Dependent)
        editable
    end

    properties(Hidden)
        uicomp = {}
        uipos = [];
        cfgset
    end

    methods
        function set.value(obj,v)
            obj.value = obj.validate(v);
            obj.updateValue;
            obj.trig_postset;
        end

        function uiSetValue(obj,v)
            obj.cfgset(v);
        end

        function set.hidden(obj,h)
            obj.hidden = h;
            obj.updateHidden;
        end

        function set.enabled(obj,tf)
            obj.enabled = tf;
            obj.updateEditable;
        end

        function set.constant(obj,tf)
            obj.constant = tf;
            obj.updateEditable;
        end

        function trig_postset(obj)
            if ~isempty(obj.postset)
                obj.postset();
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
            g.RowHeight{i} = 25*(~obj.hidden || g.Parent.UserData.ShowHidden);
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
                obj.uiSetValue(obj.fromString(comp.Value));
%                 obj.value = obj.fromString(comp.Value);
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

        function updateValue(obj)
            c = obj.validcomp;
            cellfun(@obj.updateValueFcn,c);
        end

        function updateHidden(obj)
            [c,i] = obj.validcomp;
            for j=1:numel(c)
                P = c{j}.Parent.Parent;
                tf = ~obj.hidden || P.UserData.ShowHidden;
                obj.updateHiddenFcn(c{j},i(j),tf);
            end
        end

        function updateEditable(obj)
            c = obj.validcomp;
            cellfun(@obj.updateEditableFcn,c);
        end

        function [c,i] = validcomp(obj)
            tf = cellfun(@isvalid,obj.uicomp);
            obj.uicomp = obj.uicomp(tf);
            obj.uipos = obj.uipos(tf);
            c = obj.uicomp;
            i = obj.uipos;
        end

        function updateHiddenFcn(obj,comp,i,tf)
            comp.Parent.RowHeight{i} = 25*tf;
        end

        function updateValueFcn(obj,comp)
            comp.Value = obj.toString(obj.value);
        end

        function updateEditableFcn(obj,comp)
            comp.Editable = obj.editable;
        end

        function varargout = addvaluelistener(obj,callback,varargin)
            [varargout{1:nargout}] = addlistener(obj,'value','PostSet',@(src,evt) callback(obj.value,varargin{:}));
        end
        
    end
    
    methods(Abstract)
        str = toString(obj,val)
        val = fromString(obj,str)
    end
end


