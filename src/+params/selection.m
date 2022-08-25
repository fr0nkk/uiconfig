classdef selection < params.char
    
    properties
        options
    end
    
    methods
        function obj = selection(options,default)
            if ~iscell(options)
                error('options must be cell array of char')
            end
            if nargin < 2, default = options{1}; end

            obj@params.char(default,false);

            obj.options = options;
            
        end

        function val = validate(obj,val)
            if ~ismember(val,obj.options)
                error('%s is not member of (%s)',val,strjoin(obj.options,', '));
            end
            val = obj.validate@params.char(val);
        end

        function c = ui(obj,val,parent,cfgset,varargin)
            c = uidropdown(parent,'Value',val,'Enable',obj.editable,'ValueChangedFcn',@(src,evt) cfgset(src.Value),'Items',obj.options);
        end
    end
end

