function cfg = hidden_config

cfg.num_value = params.scalar;
cfg.mat_value = params.matrix;

cfg.const_value = params.scalar(10);
cfg.const_value.constant = true;
cfg.const_value.description = 'some description';

cfg.named_param = params.scalar(uint8(255));
cfg.named_param.name = '8bit value';

cfg.other_cfg = myconfig2;
cfg.category1.val1 = params.scalar;

cfg.some_color = params.color;

cfg.hidden_param = params.scalar;
cfg.hidden_param.hidden = true;

cfg.some_vector = params.vector;

cfg.category1.file1 = params.file;
cfg.category1.cat2.dir1 = params.file('dir');

cfg = uiconfig(cfg,'myconfig');