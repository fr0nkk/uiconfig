function cfg = myconfig2
    
cfg.value1 = params.scalar;
cfg.matrix_2x2 = params.matrix(rand(2,'single'),[2 2]);
cfg.bool = params.bool(true);
cfg.fcn = params.fcn(@disp);
cfg.select = params.selection({'option 1','option 2','option 3'},'option 2');

cfg = configparam(cfg,'myconfig2');