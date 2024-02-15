function [PropData] = read_prop_data(propname,RPMD,PathName,PrintOpt)
   %
   % read in propeller data from UIUC database 
   % RPMD - desired RPM, will chose closest
   % PathName - Path where UIUC data is located
   % propname - UIUC propnames eg. 'apcsf9x6'
   % ProPData - matrix, [J,CT,CP,eta];
   % PrintOpt - set to "1" to print out which files were used
   % Note for most rpms there are two files, one for small J and one
   % for large J
   %
   workingdir = pwd;
   %
   % find all the files with the given propeller name
   %
   cd(PathName);
   filename = sprintf('%s*.txt',propname);
   AA = dir(filename);
   FileList = {AA(:).name};
   %
   % back to starting directory
   %
   cd(workingdir);
   %
   % From FileList find the two files that have the closest RPM
   %
   if isempty(FileList)
       fprintf('Error no prop files with this name exist\n');
       PropData = [];
       return;
   end
   for iv=1:length(FileList)
    FileName = char(FileList(iv));
    %
    % exclude geom and static files
    %
    index = strfind(char(FileName),'static');
    if ~isempty(index)
        RPM(iv) = -9999;
        static_index = iv;
    else
        index = strfind(char(FileName),'geom');
        if ~isempty(index)
            RPM(iv) = -9999;
        else
            index=strfind(char(FileName),'.txt');
            %
            % rpm should be last 4 characters before index
            %
            if ~isempty(index)
                RPM(iv) = str2num(FileName(index-4:index-1));
            else
                RPM(iv) = -9999;
            end
        end
    end
   end
   %
   % Now find closest two RPMs
   % note the two could both be larger than the RPMD, both smaller or
   % one smaller and one larger
   %
   Diff = abs(RPM-RPMD);

   [tmp,ii]=sort(Diff);
   i1 = ii(1);
   i2 = ii(2);
   indexes = [i1,i2];
   if max(RPM) < RPMD
       indexes= [i1,i2];
       fprintf('Warning, using largest two RPM files RPMD = %f RPM1 = %f RPM2 = %f\n',RPMD,RPM(i1),RPM(i2));
   elseif Diff(i2) > 250 & Diff(i1) <= 50
       fprintf('Warning only one RPM file for RPMD = %f\n',RPMD);
       indexes = [i1];
   elseif Diff(i1) > 50
       fprintf('Error could not find RPM file close to desired RPM, Diff = %f\n',Diff(i1));
   end 

   %
   % write out results for debugging!
   %
   %RPM
   if length(indexes) ==2 && PrintOpt == 1
    fprintf('Files Chosen: %s %s\n',char(FileList(indexes(1))),char(FileList(indexes(2))));
   elseif length(indexes) == 1 && PrintOpt == 1
    fprintf('Files Chosen: %s %s\n',char(FileList(indexes(1))));
   end

    for i=1:length(indexes)
    %
        C = strsplit(char(FileList(indexes(i))),'_');
        DD = (strsplit(C{2},'x'));
        Dv = str2num(DD{1});
        Pv = str2num(DD{2});
        DR = (strsplit(C{4},'.'));
        RPM = str2num(DR{1});

        A = importdata(fullfile(PathName,char(FileList(indexes(i)))),' ',1);
        if i == 1
            DataA = A.data;
        else
            DataB = A.data;
        end
    end
    %
    % combine data to make one look-up table for prop data and sort by J
    %
    if length(indexes)  == 2
        Data = [DataA;DataB];
        %
        % remove repeated values
        %
        
        %
        % Now sort data based on J
        %
        [tmp1,ind,idum]=unique(Data(:,1));
        DataS = Data(ind,:);
    else
        DataS = DataA;
    end
    %
    % Now add static data to top of file
    %
    StaticData = importdata(fullfile(PathName,char(FileList(static_index))),' ',1);
    %
    % find closest RPM again (use original target RPMD )
    %
    RPMS = StaticData.data(:,1);
    id = find(RPMS>=RPMD,1);
    if isempty(id)
        id = length(RPMS);
    end
    %
    % check to see if lower one is closer
    %
    if id > 1
        D1 = abs(RPMS(id)-RPMD);
        D2 = abs(RPMS(id-1)-RPMD);
        if D2<D1
            id = id-1;
        end
    end
    if PrintOpt == 1
        fprintf('Using Static Data at RPM = %5.0f \n',RPMS(id));
    end
    PropData(1,1) = 0; % J for static data
    PropData(1,2) = StaticData.data(id,2);
    PropData(1,3) = StaticData.data(id,3);
    PropData(1,4) = 0; % efficiency at static
    PropData(2:length(DataS)+1,:) = DataS(1:end,:);
    % 
    % J = PropData(:,1);
    % CT = PropData(:,2);
    % CP = PropData(:,3);
    % eff = PropData(:,4);
end

