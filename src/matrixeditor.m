classdef matrixeditor < handle
    
    properties
        M
        fcnOK
    end

    properties(Hidden)
        parent
        mainGrid
        optGrid
        castDropdown
        flipDropdown
        rotButton
        permuteButton
        inverseButton
        topGrid
        textArea
        bottomGrid
        okButton
        cancelButton
        dimSizes
        dimShow
        castOptions = {'double','single','uint8','uint16','uint32','uint64','int8','int16','int32','int64','logical'}
    end
    
    methods
        function obj = matrixeditor(M)

            if nargin < 1, M = zeros(3,3); end
            
            obj.parent = uifigure('Name','Matrix Editor');
            
            obj.mainGrid = uigridlayout(obj.parent,[3 1],'ColumnWidth',{'1x'},'RowHeight',{25, 65, '1x', 25},'RowSpacing',5,'ColumnSpacing',5);
            
            % options
            obj.optGrid = uisetlayout(uigridlayout(obj.mainGrid,[1 5],'Padding',0,'ColumnWidth',{80 60 60 70 60 '1x'},'ColumnSpacing',5),1,1);
            obj.castDropdown = uisetlayout(uidropdown(obj.optGrid,'Items',obj.castOptions,'ValueChangedFcn',@obj.CastDropdownFcn),1,1);
            obj.flipDropdown = uisetlayout(uidropdown(obj.optGrid,'ValueChangedFcn',@obj.FlipDropdownFcn,'Items',{''},'Placeholder','flip','Value',''),1,2);
            obj.rotButton = uisetlayout(uibutton(obj.optGrid,'Text','rot90','ButtonPushedFcn',@obj.rot90Button),1,3);
            obj.permuteButton = uisetlayout(uibutton(obj.optGrid,'Text','permute','ButtonPushedFcn',@obj.permuteButtonFcn),1,4);
            obj.inverseButton = uisetlayout(uibutton(obj.optGrid,'Text','inverse','ButtonPushedFcn',@obj.inverseButtonFcn,'Enable','off'),1,5);
            % inverse

            % top
            obj.topGrid = uisetlayout(uigridlayout(obj.mainGrid,[1 1],'Padding',0,'Scrollable','on','RowHeight',{22 22},'RowSpacing',2,'ColumnSpacing',5),2,1);

            % center
            obj.textArea = uisetlayout(uitextarea(obj.mainGrid,'FontName','Courier New','WordWrap','off','ValueChangedFcn',@obj.TextChanged),3,1);

            % bottom
            obj.bottomGrid = uigridlayout(obj.mainGrid,[1 3],'Padding',0,'ColumnWidth',{'1x','1x'},'RowHeight',{'1x'});
            uisetlayout(obj.bottomGrid,4,1);
            
            obj.okButton = uisetlayout(uibutton(obj.bottomGrid,'Text','OK','ButtonPushedFcn',@obj.OKPressed),1,1);
            obj.cancelButton = uisetlayout(uibutton(obj.bottomGrid,'Text','Cancel','ButtonPushedFcn',@(src,evt) obj.parent.delete),1,2);

            obj.UpdateMatrix(M);

        end

        function OKPressed(obj,~,~)
            if ~isempty(obj.fcnOK)
                obj.fcnOK(obj.M);
            end
        end

        function UpdateSizes(obj)
            sz = size(obj.M);
            for i=1:numel(sz)
                obj.dimSizes{i}.Value = sz(i);
            end
        end

        function MakeDims(obj)
            nd = ndims(obj.M);
            sz = size(obj.M);
            if isempty(obj.dimShow)
                pg = ones(1,nd);
            else
                pg = [1 1 cellfun(@(c) c.Value,obj.dimShow)];
                pg(end+1:nd) = 1;
            end

            g = obj.topGrid;
            delete(g.Children)
            g.ColumnWidth = [{40} repmat({80},1,nd) {25 25}];
            uisetlayout(uilabel(g,'Text','Size:','VerticalAlignment','Center'),1,1);
            uisetlayout(uilabel(g,'Text','Show:','VerticalAlignment','Center'),2,1);
            obj.dimShow = cell(1,nd-2);
            obj.dimSizes = cell(1,nd);
            for i=1:nd
                obj.dimSizes{i} = uisetlayout(uispinner(g,'Value',sz(i),'Limits',[1 inf],'ValueChangedFcn',@obj.ChangeSize),1,i+1);
                if i <= 2
                    
                    a = {'Rows(:)', 'Columns(:)'};
                    uisetlayout(uilabel(g,'Text',a{i},'VerticalAlignment','Center','HorizontalAlignment','Center','FontName','Courier New'),2,i+1);

                else
                    s = uisetlayout(uispinner(g,'Value',pg(i),'ValueChangedFcn',@obj.UpdateTextArea,'Limits',[1 sz(i)]),2,i+1);
                    obj.dimShow{i-2} = s;
                    obj.dimSizes{i}.Limits = [2 inf];
                end
            end
            uisetlayout(uibutton(g,'Text','+','ButtonPushedFcn',@obj.AddDim),1,nd+2);
            if nd > 2
                uisetlayout(uibutton(g,'Text','-','ButtonPushedFcn',@obj.RmDim),1,nd+3);
            end
        end

        function AddDim(obj,~,~)
            nd = ndims(obj.M);
            pg = repmat({':'},1,nd);
            A = obj.M;
            A(pg{:},2) = 0;
            obj.UpdateMatrix(A);
        end

        function RmDim(obj,~,~)
            nd = ndims(obj.M);
            if nd <= 2, return, end
            pg = repmat({':'},1,nd-1);
            obj.UpdateMatrix(obj.M(pg{:},1));
        end

        function UpdateTextArea(obj,~,~)
            pg = cellfun(@(c) c.Value,obj.dimShow,'uni',0);
            
%             m = num2cell(obj.M,[1 2]);
            c = class(obj.M);
            switch c
                case 'double'
                    fmt = '%.16g';
                case 'single'
                    fmt = '%.8g';
                case {'uint8','uint16','uint32','uint64','logical'}
                    fmt = '%lu';
                case {'int8','int16','int32','int64'}
                    fmt = '%li';
                otherwise
                    error('Unknown type: %s',c)
            end

%             str = compose(fmt,m{1,1,pg{:}});
            str = compose(fmt,obj.M(:,:,pg{:}));

            n = max(cellfun(@numel,str),[],1);

            str = cellfun(@(c,n) pad(c,n),num2cell(str,1),num2cell(n),'uni',0);
            str = horzcat(str{:});

            str = num2cell(str,2);
            str = cellfun(@(c) strjoin(c,' '),str,'uni',0);

            obj.textArea.Value = str;

            sz = size(obj.M);
            obj.inverseButton.Enable = isempty(pg) && sz(1) == sz(2);
        end

        function TextChanged(obj,~,~)
            str = obj.textArea.Value;
            str = str(~cellfun(@isempty,strtrim(str)));
            pg = cellfun(@(c) c.Value,obj.dimShow,'uni',0);
            str = cellfun(@(c) strsplit(c,{' ',','},'CollapseDelimiters',true),str,'Uni',0);
            c = class(obj.M);
            switch c
                case {'double', 'single'}
                    fmt = '%g';
                case {'uint8','uint16','uint32','uint64','logical'}
                    fmt = '%lu';
                case {'int8','int16','int32','int64'}
                    fmt = '%li';
                otherwise
                    error('Unknown type: %s',c)
            end
            rows = cellfun(@(cc) cellfun(@(c) sscanf(c,fmt),cc,'uni',0),str,'uni',0);
            rows = cellfun(@(c) horzcat(c{:}),rows,'uni',0);
            n = cellfun(@numel,rows);
            p = num2cell(max(n) - n);
            rows = cellfun(@(c,c2) [c zeros(1,c2)],rows,p,'uni',0);
            m = vertcat(rows{:});

            sz = size(obj.M);
            mm = zeros(sz(1:2),'like',obj.M);
            szm = min(size(m),sz(1:2));
            mm(1:szm(1),1:szm(2)) = m(1:szm(1),1:szm(2));
            obj.M(:,:,pg{:}) = mm;
            obj.UpdateTextArea;
        end

        function ChangeSize(obj,~,~)
            sz = size(obj.M);
            newSz = cellfun(@(c) c.Value,obj.dimSizes);
            newM = zeros(newSz,'like',obj.M);
            pg = arrayfun(@(a) 1:a,min(sz,newSz),'uni',0);
            newM(pg{:}) = obj.M(pg{:});
            obj.M = newM;
            for i=3:numel(sz)
                obj.dimShow{i-2}.Limits = [1 newSz(i)];
            end
            
            obj.UpdateTextArea;
        end

        function CastDropdownFcn(obj,src,evt)
            obj.UpdateMatrix(cast(obj.M,obj.castDropdown.Value));
        end

        function FlipDropdownFcn(obj,src,evt)
            dim = sscanf(extractAfter(obj.flipDropdown.Value,' '),'%i');
            obj.flipDropdown.Value = '';
            obj.UpdateMatrix(flip(obj.M,dim));
        end

        function rot90Button(obj,src,evt)
            obj.UpdateMatrix(rot90(obj.M));
        end

        function permuteButtonFcn(obj,src,evt)
%             obj.UpdateMatrix(rot90(obj.M));
        end

        function inverseButtonFcn(obj,src,evt)
            obj.UpdateMatrix(inv(obj.M));
        end

        function UpdateMatrix(obj,M)
            obj.M = M;
            obj.castDropdown.Value = class(M);
            obj.flipDropdown.Items = [{''} compose('dim %i',1:ndims(M))];
            obj.MakeDims;
            obj.UpdateTextArea;
        end
        
    end
end

