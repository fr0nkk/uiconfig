function myListener(src,evt,f)

cfg = evt.AffectedObject;
cfg.meta.fcn.hidden = strcmp(cfg.select,'option 1');
f.UserData.Refresh();
end

