function varargout = dynamic_param_example()

    cfgmeta = struct;

    cfgmeta.hidden_node = uic.bool(true);
    
    cfgmeta.hide_unhide.selection = uic.selection({'scalar','vector','matrix'});
    cfgmeta.hide_unhide.scalar = uic.scalar(0);
    cfgmeta.hide_unhide.vector = uic.vector(1:5);
    cfgmeta.hide_unhide.matrix = uic.matrix(rand(3,3));
    
    cfgmeta.dependent_param.numbers = uic.vector(1:3);
    cfgmeta.dependent_param.sum = uic.scalar();

    cfgmeta.node.param = uic.scalar(1);
    
    c = uiconfig(cfgmeta,'dynamic_example');

    c.meta.hide_unhide.selection.postsetFcn = @() postset_sel(c.hide_unhide);
    postset_sel(c.hide_unhide);
    
    c.meta.dependent_param.numbers.postsetFcn = @() postset_num(c.dependent_param);
    postset_num(c.dependent_param);

    c.meta.hidden_node.postsetFcn = @() postset_hid(c);
    postset_hid(c);

    if nargout == 0
        c.ui;
    else
        varargout{1} = c;
    end

end

function postset_sel(cfg)

%     switch pname
%         case 'numbers'
%             cfg.meta.sum.enabled = true;
%             cfg.sum = sum(cfg.numbers);
%             cfg.meta.sum.enabled = false;
%         case 'selection'
    cfg.meta.scalar.hidden = 1;
    cfg.meta.vector.hidden = 1;
    cfg.meta.matrix.hidden = 1;
    cfg.meta.(cfg.selection).hidden = 0;
%         case 'hidden_node'
%             cfg.node.hidden = cfg.hidden_node;
%     end
end

function postset_num(cfg)
    cfg.meta.sum.enabled = true;
    cfg.sum = sum(cfg.numbers);
    cfg.meta.sum.enabled = false;
end

function postset_hid(cfg)
    cfg.node.hidden = cfg.hidden_node;
end
