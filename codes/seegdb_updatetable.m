function [seegdb_table, seegdb_obj]=seegdb_updatetable(seegdb_table, seegdb_obj)

%seegdb_table.Data=[];

if(isempty(seegdb_table))
%     Subject={''};
%     Electrode={''};
%     Contact={''};
%     distance=[nan];
%     X=[nan];
%     Y=[nan];
%     Z=[nan]';
% 
%     seegdb_table=table(Subject,Electrode,Contact,distance,X,Y,Z);
%     seegdb_table(end,:)=[];
% 
%     seegdb_table.Properties.VariableNames={'subject','electrode','contact','distance','X','Y','Z'};
end;
    %seegdb_table(end,:)=[]; %delete the last row

    %new_data={'a','b','c',0, 1,2,3}; %add to the last row
    %seegdb_table=[seegdb_table; new_data];

    %append to the end of the table
    switch seegdb_obj.distance.metric
        case 'MIN'
            for idx=1:length(seegdb_obj.distance.min)
                new_data={
                    seegdb_obj.distance.subject, ...
                    seegdb_obj.distance.min(idx).electrode, ...
                    seegdb_obj.distance.min(idx).contact, ...
                    seegdb_obj.distance.min(idx).distance, ...
                    seegdb_obj.distance.min(idx).x, ...
                    seegdb_obj.distance.min(idx).y, ...
                    seegdb_obj.distance.min(idx).z, ...
                    };
                seegdb_table=[seegdb_table; new_data];
            end;

        case 'COM'
            for idx=1:length(seegdb_obj.distance.com)
                new_data={
                    seegdb_obj.distance.subject, ...
                    seegdb_obj.distance.com(idx).electrode, ...
                    seegdb_obj.distance.com(idx).contact, ...
                    seegdb_obj.distance.com(idx).distance, ...
                    seegdb_obj.distance.com(idx).x, ...
                    seegdb_obj.distance.com(idx).y, ...
                    seegdb_obj.distance.com(idx).z, ...
                    };
                seegdb_table=[seegdb_table; new_data];
            end;
    end;

return;