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
    c.dependent_param.postsetFcn = @postset;
    c.hide_unhide.postsetFcn = @postset;
    c.node.hidden = true;
    

    postset(c.hide_unhide,'selection');
    postset(c.dependent_param,'numbers');

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
            cfg.meta.sum.enabled = true;
            cfg.sum = sum(cfg.numbers);
            cfg.meta.sum.enabled = false;
        case 'selection'
            cfg.meta.scalar.hidden = 1;
            cfg.meta.vector.hidden = 1;
            cfg.meta.matrix.hidden = 1;
            cfg.meta.(cfg.selection).hidden = 0;
        case 'hidden_node'
            cfg.node.hidden = cfg.hidden_node;
            tf = true;
    end
end
