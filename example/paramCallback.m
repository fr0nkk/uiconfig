function paramCallback(src,evt)

fprintf('%s: Value changed for %s :\n',src.zprop_name,evt.param);
disp(evt.value);

end

