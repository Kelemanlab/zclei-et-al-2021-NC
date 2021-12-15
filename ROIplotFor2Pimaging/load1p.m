function [data path]=load1p(path,fileno)

warning('off');
if nargin==0
    [FileName,PathName] = uigetfile('*.tif','Select the TIF file','E:\I');
    path=strcat(PathName,FileName);
end

if (nargin <2)
    INFO=imfinfo(path);
    j=length(INFO);
    x=INFO(1).Width;
    y=INFO(1).Height;
else
    example=imread(path,1);
    [y, x]=size(example);
    j=fileno;
end
data=zeros(y,x,j,'int16');

% handle=waitbar(0,'Loading image');
for i=1:j
    data(:,:,i)=imread(path,i);
%     waitbar(i/j,handle)
end
% close(handle);
% disp(path);

return