classdef uiconfig < dynamicprops
    
    properties
        meta
    end

    events
        ParamChanged
    end
    
    properties(Hidden)
        metaName = 'uiconfig'
        metaHidden = false
    end

    methods
        function obj = uiconfig(meta,name,hiddenFlag)
            if isa(meta,'uiconfig')
                obj = meta;
                return
            end
            obj.meta = meta;

            if nargin >= 2, obj.metaName = name; end
            if nargin >= 3, obj.metaHidden = hiddenFlag; end


            fldnm = fieldnames(obj.meta);
            for i=1:numel(fldnm)
                pname = fldnm{i};
                prop = obj.addprop(pname);
                p = obj.meta.(pname);
                if isa(p,'params.abstract')
                    prop.SetMethod = SetProp(obj,pname);
                    prop.SetObservable = true;
                    prop.GetObservable = true;
                    obj.(pname) = p.default;
                elseif isstruct(p) || isa(p,'uiconfig')
                    obj.(pname) = uiconfig(p,pname);
                else
                    error('illegal class (%s) for %s',class(p),pname);
                end
            end
        end

        function cfgReset(obj)
            fn = fieldnames(obj.meta);
            for i=1:numel(fn)
                f = fn{i};
                p = obj.meta.(f);
                if isa(p,'params.abstract')
                    obj.(f) = obj.meta.(f).default;
                else
                    obj.(f).cfgReset;
                end
            end
        end

        function c = cfgCopy(obj)
            c = uiconfig(obj.meta);
            c.cfgFromStruct(obj.cfgToStruct);
        end

        function cfgFromStruct(obj,s)
            obj.cfgReset;
            fn = fieldnames(s);
            for i=1:numel(fn)
                f = fn{i};
                p = obj.meta.(f);
                if isa(p,'params.abstract')
                    obj.(f) = s.(f);
                else
                    obj.(f).cfgFromStruct(s.(f));
                end
            end
        end

        function s = cfgToStruct(obj)
            s = struct;
            fn = fieldnames(obj.meta);
            for i=1:numel(fn)
                f = fn{i};
                p = obj.meta.(f);
                if isa(p,'params.abstract')
                    v = obj.(f);
                else
                    v = obj.(f).cfgToStruct;
                end
                s.(f) = v;
            end
        end

        function f = ui(obj,showHiddenFlag)
            if nargin < 2, showHiddenFlag = false; end

            f = uifigure;

            g = uigridlayout(f,[1 2],'ColumnWidth',{'1x' '3x'});

            P = uisetlayout(uipanel(g,'UserData',struct('ShowHidden',showHiddenFlag)),1,2);

            T = uisetlayout(uitree(g,'SelectionChangedFcn',@(src,evt) NodeSelect(src,P)),1,1);

            N = uitreenode(T,'Text',obj.metaName,'NodeData',obj);
            RecursiveAddNode(N,obj,P);
            N.expand;
            T.SelectedNodes = N;
            NodeSelect(T,P);
%             f.UserData.cfg = obj;
            f.UserData.Refresh = @() NodeSelect(T,P);
        end
    end
end

function f = SetProp(obj, pname)
    function setProp(obj, val)
        obj.(pname) = obj.meta.(pname).validate(val);
        ev = ParamChangedEvent(pname,val);
        notify(obj,'ParamChanged',ev);
    end
    f = @setProp;
end

function NodeSelect(src,P)

    delete(P.Children);

    o = src.SelectedNodes.NodeData;
    fn = fieldnames(o.meta);
    tf = cellfun(@(c) isa(o.meta.(c),'params.abstract'),fn);
    
    fni = fn(tf);
    if ~P.UserData.ShowHidden
        tf = ~cellfun(@(c) o.meta.(c).hidden,fni);
        fni = fni(tf);
    end
    n = numel(fni);
    if n < 1, return, end

    g = uigridlayout(P,[n 2],'ColumnWidth',{'1x', '3x'},'RowHeight',repmat({25},1,n),'Scrollable','on');

    for i=1:numel(fni)
        f = fni{i};
        m = o.meta.(f);
        if isempty(m.name)
            name = f;
        else
            name = m.name;
        end
        uisetlayout(uilabel(g,'Text',name,'Tooltip',m.description),i,1);
        uisetlayout(m.ui(o.(f),g,@(v) uisetprop(o,f,v)),i,2);
    end
    
end

function uisetprop(o,f,v)
    o.(f) = v;
end

function RecursiveAddNode(parent,o,P)
    fn = fieldnames(o);
    for i=1:numel(fn)
        f = o.(fn{i});
        if isa(f,'uiconfig') && (~f.metaHidden || P.UserData.ShowHidden)
            N = uitreenode(parent,'Text',fn{i},'NodeData',f);
            RecursiveAddNode(N,f,P);
        end
    end
end

