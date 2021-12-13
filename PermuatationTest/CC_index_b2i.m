function [Bfiles,SavePath] = CC_index_b2i(Bfiles,SavePath)

if nargin<1
    
    [FileName,FilePath] = uigetfile('.xlsx','select batch index files',...
        'G:\','MultiSelect','on');
    if ~iscell(FileName(1))
        FileName = {FileName};
    end
    Bfiles = cellfun(@(x)[FilePath x],FileName,'uni',0);
end

if nargin<2
    SavePath = uigetdir('G:\');
    SavePath = [SavePath,'\'];
end

if isempty(SavePath)||isnumeric(SavePath)
    SavePath = 'G:\temp';
end

raw = [];
for i=1:length(FileName)
    [~,~,R]=xlsread(Bfiles{i});
    raw=[raw; R(2:end,:)];
end
raw = [R(1,:); raw];
clear  R;
 

Header = [raw(1,1),'Arena Label',raw(1,2:end)];
Body = raw(2:end,:);

% find individual groups
[GroupPaths,~,GroupIndexes] = unique(Body(:,1));
[~,GroupNames] = cellfun(@fileparts,GroupPaths,'UniformOutput',false);
GroupNo = length(GroupNames);

% Save to individual xlsx files.
h = waitbar(0,[num2str(GroupNo) ' groups to go']);
set(h, 'Name','Saving Individual Groups...');
pause(1);
for i=1:GroupNo
    temp = Body((GroupIndexes==i),:);
    temp_an = cellfun(@(x)strsplit(x,'_'),temp(:,2),'uni',0);
    temp_an = reshape([temp_an{:}],2,[])';
    temp(:,2) = cellfun(@(x)str2num(x),temp_an(:,2),'uni',0);
    temp = [Header;[temp(:,1),cell(size(temp,1),1),sortrows(temp(:,2:end),1)]];
    xlswrite([SavePath GroupNames{i} '.xlsx'],temp);
    waitbar(i/GroupNo,h,[num2str(i) ' / ' num2str(GroupNo) ' done']);
end
waitbar(1,h, 'All done');
pause(1);
close(h);