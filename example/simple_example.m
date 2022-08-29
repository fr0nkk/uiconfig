function cfg = simple_example()

meta = struct;

meta.some_number = uic.scalar(10);
meta.some_vector = uic.vector(1:10);
meta.some_matrix = uic.matrix(rand(3,3));
meta.some_bool = uic.bool(true);
meta.some_char = uic.char('some text');
meta.some_selection = uic.selection({'Option 1','Option 2'});
meta.some_color = uic.color(uint8([0 255 0]));
meta.some_file = uic.file();
meta.some_dir = uic.file([],'dir');
meta.some_fcn = uic.fcn(@disp);

cfg = uiconfig(meta,'simple example');

end

