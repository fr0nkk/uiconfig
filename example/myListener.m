function myListener(src,evt,f)

cfg = evt.AffectedObject;
cfg.zprop_meta.fcn.hidden = strcmp(cfg.select,'option 1');
f.UserData.Refresh();
end

