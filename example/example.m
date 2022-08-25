%% make config
c = myconfig;

addlistener(c,'ParamChanged',@paramCallback);
addlistener(c.category1,'ParamChanged',@paramCallback);



c.mat_value = rand(2,2);

%% show ui
f = c.ui;

addlistener(c.other_cfg,'select','PostSet',@(src,evt) myListener(src,evt,f))

%% show ui with hidden values
% c.ui(true)