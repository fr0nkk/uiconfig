classdef datetime < uic.abstract
    
    properties
        default = 730486 % 2000-01-01
        Format = 'yyyy-MM-dd HH:mm:ss'
    end
    
    methods
        function obj = datetime(default,Format)
            if nargin >= 2
                obj.Format = Format;
            end
            if nargin >= 1 && ~isempty(default)
                obj.default = obj.validate(default);
            end
            obj.oArgs = {obj.default,obj.Format};
        end

        function val = validate(obj,val)
            if isfloat(val)
                val = datetime(val,'ConvertFrom','datenum');
            end
            if ~isdatetime(val)
                error('must be datetime class')
            end

            if isnat(val)
                error('invalid time, must be format: %s',obj.Format);
            end

            if ~isscalar(val)
                error('datetime must be scalar')
            end

            val = obj.validate@uic.abstract(val);
        end

        function str = toString(obj,val)
            val.Format = obj.Format;
            str = char(val);
        end

        function val = fromString(obj,str)
            val = datetime(str,'InputFormat',obj.Format);
        end

    end
end

