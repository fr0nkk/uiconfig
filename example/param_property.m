function varargout = param_property()

    m = struct;
    
    m.param1 = uic.scalar(1);
    m.param1.name = 'Named param';
    
    m.param2 = uic.scalar(2);
    m.param2.name = 'Can by any char /$%?';
    m.param2.description = {'multi','line','description'};
    
    m.param3 = uic.scalar(3);
    m.param3.name = 'hover me';
    m.param3.description = 'this is a description';
    
    m.param4 = uic.scalar(4);
    m.param4.name = 'constant param';
    m.param4.description = 'Can only be equal to its default value';
    m.param4.constant = true;
    
    m.param5 = uic.scalar(5);
    m.param5.name = 'disabled param';
    m.param5.enabled = false;
    
    m.param6 = uic.matrix(rand(3));
    m.param6.enabled = false;
    m.param6.name = 'disabled matrix';
    m.param6.description = 'Can click edit to view but not OK';
    
    c = uiconfig(m);
    
    
    if nargout == 0
        c.ui;
    else
        varargout{1} = c;
    end

end