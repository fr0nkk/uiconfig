%% make config
c = myconfig;

addlistener(c,'ParamChanged',@paramCallback);
addlistener(c.category1,'ParamChanged',@paramCallback);

c.mat_value = rand(2,2);

%% show ui
c.ui

%% show ui with hidden values
% c.ui(true)