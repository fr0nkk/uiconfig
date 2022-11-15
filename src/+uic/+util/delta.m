function delta(cfg,time,delta_table,varargin)
% table must contain: time (datetime), param (full.path.to.param), value (char format for meta.fromString())

    if ischar(delta_table), delta_table = readtable(delta_table,varargin{:}); end
    
    cfg0 = cfg.toStruct;
    
    for i=1:size(delta_table)
        if delta_table.time(i) > time, continue, end
        s = subsfcn(delta_table.param{i});
        v = delta_table.value{i};
        if isempty(v), v = subsref(cfg0,s); end
        if numel(s) == 1
            uip = subsref(cfg.meta,s);
        else
            uip = subsref(subsref(cfg,s(1:end-1)).meta,s(end));
        end
        cfg = subsasgn(cfg,s,uip.fromString(v));
    end

end

function s = subsfcn(p)
    pname = strsplit(p,'.');
    s = cellfun(@(c) struct('type','.','subs',c),pname);
end
