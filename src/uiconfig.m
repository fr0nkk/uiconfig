classdef uiconfig < dynamicprops
    
    events
        % use addlistener on this event to catch when any parameter changes
        ParamChanged

        % you can use addlistener on a parameter to catch when this
        % particular parameter changes
    end

    properties
        % meta data of the config, constraints etc
        % must be struct of uic elements
        meta
        
        % ui display name of this config
        name = 'uiconfig'

        % should be hidden when it is part of some other config
        hidden = false

        uicomp = {}

        % use switch pname to modify other parameters that depends on pname
%         postsetFcn = @(cfg,pname) false; % should return updateNodesFlag
    end
    
    methods
        function obj = uiconfig(meta,name,hidden)
            if isa(meta,'uiconfig')
                obj = meta;
                return
            end
            obj.meta = meta;

            if nargin >= 2, obj.name = name; end
            if nargin >= 3, obj.hidden = hidden; end

            fldnm = fieldnames(obj.meta);
            for i=1:numel(fldnm)
                pname = fldnm{i};
                prop = obj.addprop(pname);
                p = obj.meta.(pname);
                if isa(p,'uic.abstract')
                    p.value = p.default;
                    obj.(pname) = p.value;
                    if isempty(p.name), p.name = pname; end
                    prop.SetMethod = SetProp(obj,pname);
                    prop.GetMethod = GetProp(obj,pname);
                    prop.SetObservable = true;
                elseif isstruct(p) || isa(p,'uiconfig')
                    obj.(pname) = uiconfig(p,pname);
                else
                    error('illegal class (%s) for %s',class(p),pname);
                end
            end
        end

        function fig = ui(obj,showHidden)
            if nargin < 2, showHidden = false; end

            fig = uifigure('Name',obj.name);

            g = uigridlayout(fig,[1 2],'ColumnWidth',{'1x' '2x'});

            P = uisetlayout(uipanel(g),1,2);
            P.UserData.ShowHidden = showHidden;

            T = uisetlayout(uitree(g,'SelectionChangedFcn',@(src,evt) NodeSelect(src,P)),1,1);
            P.UserData.UpdateNodes = @() MakeNodes(obj,T,P);

            MakeNodes(obj,T,P);
            NodeSelect(T,P);

            RecursiveAddFig(obj,P)
        end

        function set.hidden(obj,tf)
            obj.hidden = logical(tf);
            obj.updateui;
        end

        function s = toStruct(obj,strFlag)
            if nargin < 2, strFlag = false; end
            s = struct;
            fn = fieldnames(obj.meta);
            for i=1:numel(fn)
                f = fn{i};
                if isa(obj.(f),'uiconfig')
                    p = obj.(f).toStruct;
                else
                    p = obj.(f);
                    if strFlag
                        p = obj.meta.(f).toString(p);
                    end
                end
                s.(f) = p;
            end
        end

        function reset(obj)
            fn = fieldnames(obj.meta);
            for i=1:numel(fn)
                f = fn{i};
                if isa(obj.(f),'uiconfig')
                    obj.(f).reset;
                else
                    obj.(f) = obj.meta.(f).default;
                end
            end
        end

        function fromStruct(obj,s,strFlag)
            if nargin < 3, strFlag = false; end
            fn = fieldnames(s);
            for i=1:numel(fn)
                f = fn{i};
                if isa(obj.(f),'uiconfig')
                    obj.(f).fromStruct(s.(f),strFlag);
                else
                    v = s.(f);
                    if strFlag
                        v = obj.meta.(f).fromString(v);
                    end
                    obj.(f) = v;
                end
            end
        end

        function updateui(obj)
            obj.uicomp = obj.uicomp(cellfun(@isvalid,obj.uicomp));
            for i=1:numel(obj.uicomp)
                obj.uicomp{i}.UserData.UpdateNodes();
            end
        end

    end % methods
end

function f = SetProp(obj, pname) %#ok<INUSL> 
    function setProp(obj, val)
        obj.meta.(pname).value = val;
        obj.(pname) = obj.meta.(pname).value;
        ev = ParamChangedEvent(pname,val);
        notify(obj,'ParamChanged',ev);
    end
    f = @setProp;
end

function f = GetProp(obj, pname) %#ok<INUSL> 
    function v = getProp(obj)
        v = obj.meta.(pname).value;
    end
    f = @getProp;
end

function MakeNodes(obj,T,P)
%     if ~isempty(T.SelectedNodes)
%         curNode = T.SelectedNodes;
%     else
%         curNode = [];
%     end
    delete(T.Children);
    a = structfun(@(s) isa(s,'uic.abstract'),obj.meta);
    if all(a)
        % only params
        T.Visible = 0;
        P.Layout.Column = [1 2];
        N = uitreenode(T,'Text',obj.name,'NodeData',obj);
    else
        T.Visible = 1;
        P.Layout.Column = 2;
        if ~any(a)
            % only categories
            fn = fieldnames(obj.meta);
            for i=1:numel(fn)
                RecursiveAddNode(obj.(fn{i}),T,P);
            end
            N = T.Children(1);
        else
            % mixed
            N = RecursiveAddNode(obj,T,P);
            N.expand;
        end
        
    end
%     if ~isempty(curNode)
%         T.SelectedNodes
%     else
        T.SelectedNodes = N;
%     end
    
end

function NodeSelect(T,P)

    delete(P.Children);

    o = T.SelectedNodes.NodeData;
    fn = fieldnames(o.meta);
    tf = cellfun(@(c) isa(o.meta.(c),'uic.abstract'),fn);
    
    fni = fn(tf);
    n = numel(fni);
    if n < 1, return, end

    g = uigridlayout(P,[n 2],'ColumnWidth',{'1x', '2x'},'RowHeight',repmat({25},1,n),'Scrollable','on');

    for i=1:n
        name = fni{i};
        m = o.meta.(name);
        m.makeui(g,i);
    end
end

function N = RecursiveAddNode(o,parent,P)
    N = uitreenode(parent,'Text',o.name,'NodeData',o);
    fn = fieldnames(o.meta);
    for i=1:numel(fn)
        f = o.(fn{i});
        if isa(f,'uiconfig') && (~f.hidden || P.UserData.ShowHidden)
            RecursiveAddNode(f,N,P);
        end
    end
end

function RecursiveAddFig(o,P)
    o.uicomp{end+1} = P;
    fn = fieldnames(o.meta);
    for i=1:numel(fn)
        f = o.(fn{i});
        if isa(f,'uiconfig')
            RecursiveAddFig(f,P);
        end
    end
end
