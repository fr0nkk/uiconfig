classdef matrix < params.abstract
    %MATRIX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        default = nan
        sz = [];

        % size restriction
        % [] : no restriction
        % [5] : matrix must be 5x5
        % [3 4] : matrix must be 3 x 4
        % [5 nan] : matrix must be size 5 x any

    end
    
    methods
        function obj = matrix(default,sz)
            if nargin >= 1, obj.default = default; end
            if nargin >= 2
                if isscalar(sz)
                    sz = [sz sz];
                end
                obj.sz = sz;
            end
        end

        function val = validate(obj,val)
            if isempty(val)
                error('Empty value')
            end
            if ~isempty(obj.sz)
                a = obj.sz;
                i = isnan(a);
                a(i) = 1;
                s = size(val);
                s(end+1:numel(obj.sz)) = 1;
                s(i) = 1;
                if numel(a) ~= numel(s) || ~all(a==s)
                    error('Invalid size');
                end
            end

            val = cast(val,class(obj.default));

            val = obj.validate@params.abstract(val);
        end

        function str = toString(obj,val)
            szStr = sprintf('%ix',size(val));
            
            fmt = [obj.getFmt(1) ' '];
            valStr = sprintf(fmt,val(:));

            str = sprintf('(%s) %s',szStr(1:end-1),valStr(1:end-1));
        end

        function val = fromString(obj,str)
            k = find(str == ')',1);
            szStr = [str(2:k-1) 'x'];
            szStr(end) = 'x';
            msz = num2cell(sscanf(szStr,'%dx'));

            fmt = [obj.getFmt(0) ' '];

            valStr = [str(k+2:end) ' '];

            val = reshape(cast(sscanf(valStr,fmt),class(obj.default)),msz{:});
        end

        function c = ui(obj,val,parent,cfgset)
            c = params.editors.matrix(obj,val,parent,cfgset).g;
        end

        function fmt = getFmt(obj,d)
            c = class(obj.default);
            switch c
                case 'double'
                    if d
                        fmt = '%.16g';
                    else
                        fmt = '%g';
                    end
                case 'single'
                    if d
                        fmt = '%.8g';
                    else
                        fmt = '%g';
                    end
                case {'int8','int16','int32','int64'}
                    fmt = '%li';
                case {'uint8','uint16','uint32','uint64','logical'}
                    fmt = '%lu';
                otherwise
                    error('Invalid class: %s',c);
            end
        end
    end

end
