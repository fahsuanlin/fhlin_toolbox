function version=checkVersion(filename)

fid = fopen(filename,'r','l','US-ASCII'); % US-ASCII necessary for UNIX based systems
    fseek(fid,0,'eof');
    fileSize = ftell(fid);
    
    % start of actual measurment data (sans header)
    fseek(fid,0,'bof');
    
    firstInt  = fread(fid,1,'uint32');
    secondInt = fread(fid,1,'uint32');
    
    % check software version (VB or VD?)
    if and(firstInt < 10000, secondInt<=64) 
        % this is a very lazy version check and work in progress; may sometimes fail
        version = 'vd';
        disp('Software version: VD');

    else
        % in VB versions, the first 4 bytes indicate the beginning of the
        % raw data part of the file
        version  = 'vb';
        disp('Software version: VB');

    end