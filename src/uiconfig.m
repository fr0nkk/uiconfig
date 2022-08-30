classdef uiconfig < dynamicprops
    
    events
        % use addlistener on this event to catch when any parameter changes
        ParamChanged
    end

    properties
        % meta data of the config, constraints etc
        % must be struct of uic elements and/or uiconfigs
        meta
        
        % ui display name of this config
        name = 'uiconfig'

        % hide this config when it is part of other config
        hidden = false
    end

    properties(Hidden)
        uicomp = {}
        id
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
            obj.id = char(java.util.UUID.randomUUID);
        end

        function fig = ui(obj,showHidden)
            if nargin < 2, showHidden = false; end

            fig = uifigure('Name',obj.name);

            g = uigridlayout(fig,[1 2],'ColumnWidth',{'1x' '2x'});

            P = uisetlayout(uipanel(g),1,2);
            P.UserData.ShowHidden = showHidden;

            T = uisetlayout(uitree(g,'SelectionChangedFcn',@(src,evt) NodeSelect(src,P),'NodeExpandedFcn',@expandFcn,'NodeCollapsedFcn',@collapseFcn),1,1);
            P.UserData.UpdateNodes = @() MakeNodes(obj,T,P);

            MakeNodes(obj,T,P);

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
                    p = obj.(f).toStruct(strFlag);
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
                    enabled = obj.meta.(f).enabled;
                    obj.meta.(f).enabled = 1;
                    obj.(f) = v;
                    obj.meta.(f).enabled = enabled;
                end
            end
        end

        function updateui(obj)
            obj.uicomp = obj.uicomp(cellfun(@isvalid,obj.uicomp));
            for i=1:numel(obj.uicomp)
                obj.uicomp{i}.UserData.UpdateNodes();
            end
        end

        function c = copy(obj)
            c = uiconfig(obj.meta,obj.hidden,obj.name);
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
    if ~isempty(T.SelectedNodes)
        curId = T.SelectedNodes.UserData.id;
    else
        curId = '';
    end
    C = findobj(T.Children);
    tf = arrayfun(@(a) a.UserData.isExpanded,C);
    expandedId = arrayfun(@(a) a.UserData.id,C(tf),'uni',0);

    delete(T.Children);
    a = structfun(@(s) isa(s,'uic.abstract'),obj.meta);

    if all(a)
        % only params
        T.Visible = 0;
        P.Layout.Column = [1 2];
        N = uitreenode(T,'Text',obj.name,'NodeData',obj);
        N.UserData.id = obj.id;
        N.UserData.isExpanded = false;
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
            expand2(N);
            N.UserData.isExpanded = true;
        end
    end

    if ~isempty(curId)
        % retrieve previously selected node on refresh
        C = findobj(T.Children);
        ids = arrayfun(@(a) a.UserData.id,C,'uni',0);
        tf = strcmp(ids,curId);
        if any(tf)
            T.SelectedNodes = C(tf);
            reexpand(T,expandedId)
            return
        end
    end

    % default
    T.SelectedNodes = N;
    NodeSelect(T,P);
    reexpand(T,expandedId);
end

function expand2(node)
    % calling .expand doesnt trigger the NodeExpandedFcn...
    % furthermore there seems to be no way to tell if a node is expanded
    node.expand;
    node.UserData.isExpanded = true;
end

function reexpand(T,ids)
    C = findobj(T.Children);
    xId = arrayfun(@(a) a.UserData.id,C,'uni',0);
    a = ismember(xId,ids);
    arrayfun(@expand2,C(a));
end

function NodeSelect(T,P)

    delete(P.Children);
    if isempty(T.SelectedNodes), return; end

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
    N.UserData.id = o.id;
    N.UserData.isExpanded = false;
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

function expandFcn(src,evt)
    evt.Node.UserData.isExpanded = true;
end

function collapseFcn(src,evt)
    evt.Node.UserData.isExpanded = false;
end
