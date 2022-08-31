function cfg = dependent_plot()

    % create config
    m = struct;
    m.polynom = uic.vector([1 0 0 0]);
    m.equation = uic.char();
    m.equation.enabled = false;
    m.xlims = uic.vector([-10 10],2);
    m.step = uic.scalar(1);
    m.line = uic.selection({'none','-','--',':','-.'},'-');
    m.marker = uic.selection({'none','+','o','*','.'},'o');
    
    cfg = uiconfig(m,'plot controller');
    
    % create plot
    figure
    p = plot(nan,nan);
    
    % listen to config changes
    addlistener(cfg,'ParamChanged',@(cfg,pname) myCallback(cfg,p))
    
    % set initial state
    myCallback(cfg,p);
    
    % show config
    cfg.ui

end

function myCallback(cfg,p)

    x = cfg.xlims(1) : cfg.step : cfg.xlims(2);
    y = polyval(cfg.polynom,x);
    
    p.XData = x;
    p.YData = y;
    p.LineStyle = cfg.line;
    p.Marker = cfg.marker;
    p.Parent.XLim = cfg.xlims;
    p.Parent.YLim = [min(y) max(y)];
    
    str = strjoin(compose('%.5gx^%i',cfg.polynom',(numel(cfg.polynom)-1:-1:0)'),' + ');
    cfg.meta.equation.enabled = true;
    
    % addlistener is not recursive by default so this assignment will not trigger the ParamChanged event of cfg
    cfg.equation = str;
    
    cfg.meta.equation.enabled = false;

end


