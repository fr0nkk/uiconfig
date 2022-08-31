function varargout = all_examples()

    m = struct;
    m.simple = simple_params;
    m.properties = param_property;
    m.dynamic = dynamic_param;
    
    cfg = uiconfig(m,'all params');
    
    if nargout == 0
        cfg.ui;
    else
        varargout{1} = cfg;
    end

end

