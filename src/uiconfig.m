classdef uiconfig < dynamicprops

    events
        % use addlistener on this event to catch when any parameter changes
        ParamChanged

        % you can use addlistener on a parameter to catch when this
        % particular parameter changes
    end
    
    properties
        % meta data of the config, constraints etc
        zprop_meta
        
        % ui display name of this config
        zprop_name = 'uiconfig'

        % should be hidden when it is part of some other config
        zprop_hidden = false

        % use switch pname to modify other parameters that depends on pname
        zprop_postset = @(cfg,pname) false; % should return updateNodesFlag

        zprop_autoUpdateUi = true
    end

    properties%(Access=private)
        zprop_currentui = {}
    end

    methods
        function obj = uiconfig(cfgmeta,name,hiddenFlag,postSetFcn)
            if isa(cfgmeta,'uiconfig')
                obj = cfgmeta;
                return
            end
            obj.zprop_meta = cfgmeta;

            if nargin >= 2, obj.zprop_name = name; end
            if nargin >= 3, obj.zprop_hidden = hiddenFlag; end
            if nargin >= 4, obj.zprop_postset = postSetFcn; end

            fldnm = fieldnames(obj.zprop_meta);
            for i=1:numel(fldnm)
                pname = fldnm{i};
                prop = obj.addprop(pname);
                p = obj.zprop_meta.(pname);
                if isa(p,'params.abstract')
                    obj.(pname) = p.default;
                    prop.SetMethod = SetProp(obj,pname);
                    prop.SetObservable = true;
                elseif isstruct(p) || isa(p,'uiconfig')
                    obj.(pname) = uiconfig(p,pname);
                else
                    error('illegal class (%s) for %s',class(p),pname);
                end
            end
        end

        function zfcn_reset(obj,isRecursive)
            if nargin < 2, isRecursive = false; end
            if ~isRecursive
                obj.zfcn_enableuis(false);
                temp = onCleanup(@() obj.zfcn_enableuis(true));
            end

            fn = fieldnames(obj.zprop_meta);
            for i=1:numel(fn)
                f = fn{i};
                p = obj.zprop_meta.(f);
                if isa(p,'params.abstract')
                    obj.(f) = obj.zprop_meta.(f).default;
                else
                    obj.(f).zfcn_reset(true);
                end
            end

            if ~isRecursive
                clear temp
                obj.zfcn_updateuis;
            end
        end

        function c = zfcn_copy(obj)
            c = uiconfig(obj.zprop_meta,obj.zprop_name,obj.zprop_hidden,obj.zprop_postset);
            c.zfcn_fromStruct(obj.zfcn_toStruct);
        end

        function zfcn_fromStruct(obj,s,isRecursive)

            if nargin < 3, isRecursive = false; end
            if ~isRecursive
                obj.zfcn_enableuis(false);
                temp = onCleanup(@() obj.zfcn_enableuis(true));
            end
            
            obj.zfcn_reset;
            fn = fieldnames(s);
            for i=1:numel(fn)
                f = fn{i};
                p = obj.zprop_meta.(f);
                if isa(p,'params.abstract')
                    obj.(f) = s.(f);
                else
                    obj.(f).zfcn_fromStruct(s.(f),true);
                end
            end

            if ~isRecursive
                clear temp
                obj.zfcn_updateuis;
            end
        end

        function s = zfcn_toStruct(obj)
            s = struct;
            fn = fieldnames(obj.zprop_meta);
            for i=1:numel(fn)
                f = fn{i};
                p = obj.zprop_meta.(f);
                if isa(p,'params.abstract')
                    v = obj.(f);
                else
                    v = obj.(f).zfcn_toStruct;
                end
                s.(f) = v;
            end
        end

        function fig = ui(obj,showHidden)
            if nargin < 2, showHidden = false; end

            fig = uifigure('Name',obj.zprop_name);
            fig.UserData.NoRefresh = false;

            g = uigridlayout(fig,[1 2],'ColumnWidth',{'1x' '3x'});

            P = uisetlayout(uipanel(g,'UserData',struct('ShowHidden',showHidden)),1,2);

            T = uisetlayout(uitree(g,'SelectionChangedFcn',@(src,evt) NodeSelect(src,P)),1,1);
            
            MakeNodes(obj,T,P);

            fig.UserData.Refresh = @() NodeSelect(T,P);
            fig.UserData.RefreshTree = @() MakeNodes(obj,T,P);
            ResursiveAddUI(obj,fig)
        end

        function zfcn_updateuis(obj,name,updateNodes)
            obj.zprop_currentui = obj.zprop_currentui(cellfun(@isvalid,obj.zprop_currentui));
            for i=1:numel(obj.zprop_currentui)
                if updateNodes
                    disp('ref')
                    obj.zprop_currentui{i}.UserData.RefreshTree();
                end
%                 if strcmp(obj.zprop_currentui{i}.Children.Children(2).SelectedNodes.NodeData.zprop_name,name)
                obj.zprop_currentui{i}.UserData.Refresh();
%                     disp('refresh');
%                 end
            end
        end

        function zfcn_enableuis(obj,tf)
            obj.zprop_currentui = obj.zprop_currentui(cellfun(@isvalid,obj.zprop_currentui));
            for i=1:numel(obj.zprop_currentui)
                obj.zprop_currentui{i}.UserData.NoRefresh = ~tf;
            end
        end
    end
end

function ResursiveAddUI(o,fig)
    o.zprop_currentui{end+1} = fig;
    fn = fieldnames(o.zprop_meta);
    for i=1:numel(fn)
        f = o.(fn{i});
        if isa(f,'uiconfig')
            ResursiveAddUI(f,fig);
        end
    end
end

function MakeNodes(obj,T,P)
%     if ~isempty(T.SelectedNodes)
%         curNode = T.SelectedNodes.Text;
%     else
%         curNode = [];
%     end
    delete(T.Children);
    a = structfun(@(s) isa(s,'params.abstract'),obj.zprop_meta);
    if all(a)
        % only params
        T.Visible = 0;
        P.Layout.Column = [1 2];
        N = uitreenode(T,'Text',obj.zprop_name,'NodeData',obj);
%         T.SelectedNodes = N;
    else
        T.Visible = 1;
        P.Layout.Column = 2;
        if ~any(a)
            % only categories
            fn = fieldnames(obj.zprop_meta);
            for i=1:numel(fn)
                RecursiveAddNode(obj.(fn{i}),T,P);
            end
        else
            % mixed
%             N = uitreenode(T,'Text',obj.zprop_name,'NodeData',obj);
            RecursiveAddNode(obj,T,P);
            
        end
        N = T.Children(1);
        N.expand;
        
    end
    T.SelectedNodes = N;
    NodeSelect(T,P);
end

function f = SetProp(obj, pname) %#ok<INUSL> 
    function setProp(obj, val)
        obj.(pname) = obj.zprop_meta.(pname).validate(val);
        tf = obj.zprop_postset(obj,pname);
        obj.zfcn_updateuis(obj.zprop_name,tf);
        ev = ParamChangedEvent(pname,val);
        notify(obj,'ParamChanged',ev);
    end
    f = @setProp;
end

function NodeSelect(T,P)
    if P.Parent.Parent.UserData.NoRefresh, return, end

    delete(P.Children);

    o = T.SelectedNodes.NodeData;
    fn = fieldnames(o.zprop_meta);
    tf = cellfun(@(c) isa(o.zprop_meta.(c),'params.abstract'),fn);
    
    fni = fn(tf);
    if ~P.UserData.ShowHidden
        tf = ~cellfun(@(c) o.zprop_meta.(c).hidden,fni);
        fni = fni(tf);
    end
    n = numel(fni);
    if n < 1, return, end

    g = uigridlayout(P,[n 2],'ColumnWidth',{'1x', '3x'},'RowHeight',repmat({25},1,n),'Scrollable','on');

    for i=1:numel(fni)
        f = fni{i};
        m = o.zprop_meta.(f);
        if isempty(m.name)
            name = f;
        else
            name = m.name;
        end
        m.ui_base(g,i,name,o.(f),@(v) uisetprop(o,f,v));
%         uisetlayout(uilabel(g,'Text',name,'Tooltip',m.description),i,1);
%         uisetlayout(m.ui(o.(f),g,@(v) uisetprop(o,f,v)),i,2);
    end
end

function uisetprop(o,f,v)
    o.(f) = v;
end

function N = RecursiveAddNode(o,parent,P)
N = uitreenode(parent,'Text',o.zprop_name,'NodeData',o);
    fn = fieldnames(o.zprop_meta);
    for i=1:numel(fn)
        f = o.(fn{i});
        if isa(f,'uiconfig') && (~f.zprop_hidden || P.UserData.ShowHidden)
%             N = uitreenode(parent,'Text',f.zprop_name,'NodeData',f);
            RecursiveAddNode(f,N,P);
        end
    end
end

