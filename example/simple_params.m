function varargout = simple_params()

    m = struct;
    
    m.some_number = uic.scalar(10);
    m.some_vector = uic.vector(1:10);
    m.some_matrix = uic.matrix(rand(3,3));
    m.some_bool = uic.bool(true);
    m.some_char = uic.char('some text');
    m.some_selection = uic.selection({'Option 1','Option 2'});
    m.some_color = uic.color(uint8([0 255 0]));
    m.some_file = uic.file();
    m.some_dir = uic.file([],'dir');
    m.some_fcn = uic.fcn(@disp);
    m.some_struct = uic.structure(struct('abc','def'));
    m.some_files = uic.file([],'multi');
    m.some_date = uic.date;
    
    cfg = uiconfig(m,'simple params');


    if nargout == 0
        cfg.ui;
    else
        varargout{1} = cfg;
    end

end

