function [PropData_RPM,RPMtests,PropDia] = readPropDataAllRPM(propname,PathName)
%
in2m = 0.0254;
%
% search for 'x' in propname and use all numbers before to get size
%
[token,remain] = strtok(propname,'x');
%
% now find 1 or 2 numerical characters from end
%
try
   diam = str2num(token(end-1:end));
   if isempty(diam);
       diam = str2num(token(end));
   end
catch
    diam = str2num(token(end));
end
PropDia = diam*in2m;
% first find all the RPM values for this prop
%
fnameroot = sprintf('%s%s*',PathName,propname);
A = dir(fnameroot);
FileListNames = {A(:).name};
if isempty(A)
    string = sprintf('No propeller datafiles in given directory\n %s\n',PathName);
    error(string);
end
%
% parse files with "rd" in name to get rpm
%
irpm = 1;
for iii=1:length(FileListNames)
    shortname = char(FileListNames(iii));
    if ~contains(shortname,'geom') && ~contains(shortname,'static')
        %[aaa,bbb]=strtok(shortname,'.txt');
        RPMa(irpm) = 100*round(str2double(shortname(end-7:end-4))/100);
        irpm = irpm+1;
    end
end
RPMtests = unique(RPMa);
for iii = 1:length(RPMtests)
    PropData_RPM{iii} = read_prop_data(propname,RPMtests(iii),PathName,1);
end

fprintf('Found data for RPM =');
for i=1:length(RPMtests)
    fprintf(' %f',RPMtests(i));
end
fprintf('\n');

end

