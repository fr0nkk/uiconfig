function varargout = dynamic_param()

    m = struct;
    
    m.show_hidden = uic.bool(false);
    
    m.selection_hide.selection = uic.selection({'scalar','vector','matrix'});
    m.selection_hide.scalar = uic.scalar(0);
    m.selection_hide.vector = uic.vector(1:5);
    m.selection_hide.matrix = uic.matrix(rand(3,3));
    
    m.dependent_param.numbers = uic.vector(1:3);
    m.dependent_param.sum = uic.scalar();
    
    m.hidden_category.param = uic.scalar(1);
    
    c = uiconfig(m,'dynamic params');
    
    c.meta.selection_hide.selection.postset = @() postset_sel(c.selection_hide);
    postset_sel(c.selection_hide);
    
    c.meta.dependent_param.numbers.postset = @() postset_num(c.dependent_param);
    postset_num(c.dependent_param);
    
    c.meta.show_hidden.postset = @() postset_hid(c);
    postset_hid(c);
    
    if nargout == 0
        c.ui;
    else
        varargout{1} = c;
    end

end

function postset_sel(cfg)
    cfg.meta.scalar.hidden = 1;
    cfg.meta.vector.hidden = 1;
    cfg.meta.matrix.hidden = 1;
    cfg.meta.(cfg.selection).hidden = 0;
end

function postset_num(cfg)
    cfg.meta.sum.enabled = true;
    cfg.sum = sum(cfg.numbers);
    cfg.meta.sum.enabled = false;
end

function postset_hid(cfg)
    cfg.hidden_category.hidden = ~cfg.show_hidden;
end
