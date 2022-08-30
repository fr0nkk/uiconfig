function jsonSave(uicfg,filename)

s = uicfg.toStruct(true);

try
    str = jsonencode(s,'PrettyPrint',true);
catch
    str = jsonencode(s);
end

[fid,err] = fopen(filename,'w','n','UTF-8');

if fid < 0
    error(err);
end

fwrite(fid,str);

fclose(fid);

end

