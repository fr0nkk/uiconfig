function cfg = all_examples()

m = struct;
m.simple = simple_params;
m.dynamic = dynamic_param;

cfg = uiconfig(m,'all params');

end

