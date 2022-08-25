function varargout = dynamic_param_example()

    cfgmeta = struct;

    cfgmeta.hidden_node = params.bool(true);
    
    cfgmeta.hide_unhide.selection = params.selection({'scalar','vector','matrix'});
    cfgmeta.hide_unhide.scalar = params.scalar(0);
    cfgmeta.hide_unhide.vector = params.vector(1:5);
    cfgmeta.hide_unhide.matrix = params.matrix(rand(3,3));
    
    cfgmeta.dependent_param.numbers = params.vector(1:3);
    cfgmeta.dependent_param.sum = params.scalar();
    cfgmeta.dependent_param.sum.enabled = false;

    cfgmeta.node.param = params.scalar(1);
    
    c = uiconfig(cfgmeta,'dynamic_example',0,@postset);
    c.dependent_param.zprop_postset = @postset;
    c.hide_unhide.zprop_postset = @postset;
    c.node.zprop_hidden = true;
    

    postset(c.hide_unhide,'selection');

    if nargout == 0
        c.ui;
    else
        varargout{1} = c;
    end

end

function tf = postset(cfg,pname)
    tf = false;
    switch pname
        case 'numbers'
            cfg.zprop_meta.sum.enabled = true;
            cfg.sum = sum(cfg.numbers);
            cfg.zprop_meta.sum.enabled = false;
        case 'selection'
            cfg.zprop_meta.scalar.hidden = 1;
            cfg.zprop_meta.vector.hidden = 1;
            cfg.zprop_meta.matrix.hidden = 1;
            cfg.zprop_meta.(cfg.selection).hidden = 0;
        case 'hidden_node'
            cfg.node.zprop_hidden = cfg.hidden_node;
            tf = true;
    end
end
