function [name, tissue, cond, enclosingTissueIdx, enclosingTissueName] = etc_render_fsbrain_tissue_read(index_name)
%   This function reads a tissue index file, and extracts the name, conductivity,
%   and enclosing tissue of each tissue listed in the tissue index file.

%   Copyright WAW/SNM 2019-2020


    %Attempt to open index file
    index_file = fopen(index_name);
    if(index_file<0)
        error(['Cannot open tissue index file [' index_name ']']);
    end
    
    name = {};
    tissue = {};
    cond = [];
    enclosingTissueName = {};
    
    %Extract list of meshes and associated filenames from tissue index file
    lineCounter = 0;
    while ~feof(index_file)
        currentLine = fgetl(index_file);
        lineCounter = lineCounter + 1;
        if(isempty(currentLine))
            continue;
        end
        if(currentLine(1) ~= '>') %Only care about lines that start with this indicator
            continue;
        end

        %Find field delimiters in the current line, check that all four fields
        %exist
        dividerIndex = find(currentLine == ':');
        if(length(dividerIndex) ~= 3)
            warning(['Entry [' currentLine '] on line ' num2str(lineCounter) ' of tissue_index.txt should contain exactly four fields separated by '':''']);
            continue;
        end

        tempTissueName = strtrim(currentLine(2:dividerIndex(1)-1));
        tempFileName = strtrim(currentLine(dividerIndex(1)+1:dividerIndex(2)-1));
        tempConductivity = strtrim(currentLine(dividerIndex(2)+1:dividerIndex(3)-1));
        tempEnclosingTissueName = strtrim(currentLine(dividerIndex(3)+1:end));

        %Check that the filename itself exists
        if(isempty(tempFileName))
            error(['No file name found on line ' num2str(lineCounter) ' of ' index_name]);
        end
        %Check that the file exists
        if ~exist(tempFileName, 'file')
            error(['File [' tempFileName '] referenced on line ' num2str(lineCounter) ' of ' index_name ' does not exist.']);
        end

        %Check that the tissue has a name associated with it
        if(isempty(tempTissueName))
            error(['No tissue name found on line ' num2str(lineCounter) ' of ', index_name]);
        end

        %Check that the tissue has a conductivity associated with it
        if(isempty(tempConductivity))
            error(['No tissue conductivity found on line ' num2str(lineCounter) ' of ' index_name]);
        end
        tempTissueConductivity = str2double(tempConductivity);
        %Check that the tissue conductivity could be parsed as a double
        if(isnan(tempTissueConductivity))
            error(['Tissue conductivity on line ' num2str(lineCounter) ' of ' index_name ' is not numeric']);
        end

        %Check that the tissue has an enclosing tissue associated with it
        if(isempty(tempEnclosingTissueName))
            error(['Enclosing tissue is not specified on line ' num2str(lineCounter) ' of ' index_name]);
        end
        %At this point, all data *should* be valid
        name{end+1} = tempFileName;
        tissue{end+1} = tempTissueName;
        cond(end+1) = tempTissueConductivity;
        enclosingTissueName{end+1} = tempEnclosingTissueName;
    end
    
    %Now: Check that there are no duplicate tissue names
    for j=1:length(tissue)
        if(any(strcmp(tissue(j+1:end), tissue{j})))
            error(['Multiple tissues share the name [' tissue{j} ']']);
        end
    end
    
    %Now: Check that each enclosingTissue is in the list of tissues, and create
    %a direct association between the enclosed tissue and the enclosing tissue
    enclosingTissueIdx = zeros(length(enclosingTissueName));
    for j=1:length(tissue)
        if(strcmp(enclosingTissueName{j}, 'FreeSpace'))
           continue; 
        end

        if(~any(strcmp(enclosingTissueName{j}, tissue)))
            error(['Tissue [' enclosingTissueName{j} '] was listed as an enclosing tissue for tissue [' tissue{j} '], but this enclosing tissue could not be found in the list of available tissues']);
        end

        enclosingTissueIdx(j) = find(strcmp(enclosingTissueName{j}, tissue));
    end
    
end