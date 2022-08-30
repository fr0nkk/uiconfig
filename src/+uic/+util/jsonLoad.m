function jsonLoad(uicfg,filename)

[fid,err] = fopen(filename,'r','n','UTF-8');

if fid < 0
    error(err);
end

str = fread(fid,[1 inf],'*char');

fclose(fid);

s = jsondecode(str);

uicfg.fromStruct(s,true);

end

