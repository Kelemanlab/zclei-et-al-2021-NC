function varargout = SleepTracker_v1p1(varargin)
% SleepTracker_v1p1 MATLAB code for SleepTracker_v1p1.fig
%      SleepTracker_v1p1, by itself, creates a new SleepTracker_v1p1 or raises the existing
%      singleton*.
%
%      H = SleepTracker_v1p1 returns the handle to a new SleepTracker_v1p1 or the handle to
%      the existing singleton*.
%
%      SleepTracker_v1p1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SleepTracker_v1p1.M with the given input arguments.
%
%      SleepTracker_v1p1('Property','Value',...) creates a new SleepTracker_v1p1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SleepTracker_v1p1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SleepTracker_v1p1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SleepTracker_v1p1

% Last Modified by GUIDE v2.5 13-Dec-2021 09:28:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SleepTracker_v1p1_OpeningFcn, ...
                   'gui_OutputFcn',  @SleepTracker_v1p1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SleepTracker_v1p1 is made visible.
function SleepTracker_v1p1_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SleepTracker_v1p1 (see VARARGIN)

% Choose default command line output for SleepTracker_v1p1
handles.output = hObject;
handles.FileName = [];
handles.FileName_full = [];
handles.groupName = [];
handles.idxplot= 0;

handles.defaultDir = 'C:\Vtracker\SleepDefault.txt';
if exist(handles.defaultDir,'file')
    fileID = fopen(handles.defaultDir);
    A = textscan(fileID,'%s');
    A = [A{:}];
    handles.dataDir = A{2};
    handles.saveDir = A{4};
    set(handles.ed_saveDir,'string',handles.saveDir);
else
    handles.dataDir = 'C:\Vtracker';
    handles.saveDir = 'C:\Vtracker\dataPlot';
    set(handles.ed_saveDir,'string',handles.saveDir);
end

if ~exist('C:\Vtracker\','dir')
    mkdir('C:\Vtracker\');
end

fileID = fopen(handles.defaultDir,'w');
fprintf(fileID, 'dataDir: %s\nsaveDir: %s', handles.dataDir,handles.saveDir);
fclose(fileID);
% handles.msg = {[]};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SleepTracker_v1p1 wait for user response (see UIRESUME)
% uiwait(handles.VtrackerSleep);


% --- Outputs from this function are returned to the command line.
function varargout = SleepTracker_v1p1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in addVideo.
function addVideo_Callback(hObject, eventdata, handles)
% hObject    handle to addVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FN,FP] = uigetfile('.avi','select index files',handles.dataDir,'MultiSelect','on');

if isnumeric(FP)
    set(handles.list_msg,'string','Files not selected');
    return
end
handles.dataDir = FP;
if ~iscell(FN(1))
    FN = {FN};
end
FN_full = cellfun(@(x)([FP x]),FN,'UniformOutput',false);

% check and remove duplicated index files
set(handles.list_msg,'string','Checking duplicates');
pause(1);
[dup_file,~, dup_ind] = intersect(handles.FileName_full,FN_full);
dup_no = length(dup_file);
if ~isempty(dup_ind)
    FN_full(dup_ind) = [];
    FN(dup_ind) = [];
    set(handles.list_msg,'string',[{[num2str(dup_no),' duplicates are removed:']}, dup_file]);
else
    set(handles.list_msg,'string','No duplicates found');
end

if ~isempty(FN)
    % add video to list
    handles.FileName = [handles.FileName, FN];
    handles.FileName_full = [handles.FileName_full, FN_full];

    file_no = length(handles.FileName);
    set(handles.list_videoAdded,'min',0,'max',2,'Value',[]);
    set(handles.list_videoAdded,'string',...
        [{[num2str(file_no) ' files loaded']},handles.FileName_full]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function list_videoAdded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_videoAdded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tg_Tracking.
function tg_Tracking_Callback(hObject, eventdata, handles)
% hObject    handle to tg_Tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 set(hObject,'BackgroundColor','red');
 set(hObject,'string','wait');

if isempty(handles.FileName)
    set(handles.list_msg,'string','No video added');
    set(hObject,'BackgroundColor',[.941 .941 .941]);
    set(hObject,'Value',0);
    handles.idxplot = 0;
    guidata(hObject,handles);
    return
end
    
    handles.idxplot = get(hObject,'value');
 if ~handles.idxplot
     
     set(hObject,'BackgroundColor',[.941 .941 .941]);
     set(hObject,'Value',0);
     set(hObject,'string','Fly Tracking');
     handles.idxplot = 0;
     guidata(hObject,handles);
     return
 end
     
%  msg = get(handles.list_msg,'string');
%  if~iscell(msg)
%      msg = {msg};
%  end
 timeNow = datestr(now,30);
 set(handles.list_msg,'min',0,'max',2,'Value',[]);
 set(handles.list_msg,'string',['Tracking flies...',timeNow]);
 pause(1);
 
 arenaTypes = get(handles.pop_arenaType,'string');
 handles.arenaType = arenaTypes{get(handles.pop_arenaType,'Value')};
 arenaType = handles.arenaType;
 
 saveDir = get(handles.ed_saveDir,'string');
 if ~exist(saveDir,'dir')
     mkdir(saveDir);
 end
 
 handles.binSize = str2num(get(handles.ed_binSize,'string'));
 binSize = handles.binSize;
 
 poolobj = gcp('nocreate');
 handles.N_workers = str2num(get(handles.ed_workers,'string'));
 if handles.N_workers>16
     handles.N_workers = 16;
 end % If no pool, do not create new one.
 
 if isempty(poolobj)&& handles.idxplot
     parpool('local', handles.N_workers);
 end

 FN = handles.FileName;
 FN_full = handles.FileName_full;
 fnNo = size(FN,2);

for i = 1:fnNo
    PN = fileparts(FN_full{i});
    PN = [PN,'\'];
    msg = get(handles.list_msg,'string');
    set(handles.list_msg,'string',[msg;{[' Procesing video #',num2str(i),'/',num2str(fnNo)]};[' ',FN{i}]]);
    try
    VsleepTracking_singleVideo(FN{i},PN,...
        binSize,arenaType,...
        saveDir,1,50400);
    catch ME
        msg = get(handles.list_msg,'string');
        set(handles.list_msg,'string',[msg;{' errors:'};ME.identifier]);
    end
    
end

 set(hObject,'Value',0);
 set(hObject,'BackgroundColor',[.941 .941 .941]);
 set(hObject,'string','Fly Tracking');

 
 handles.idxplot = 0;
 msg = get(handles.list_msg,'string');
 set(handles.list_msg,'string',[msg;['Tracking completed: ',num2str(i),'/',num2str(fnNo)]]);

guidata(hObject,handles);




function ed_workers_Callback(hObject, eventdata, handles)
% hObject    handle to ed_workers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_workers as text
%        str2double(get(hObject,'String')) returns contents of ed_workers as a double


% --- Executes during object creation, after setting all properties.
function ed_workers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_workers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function VtrackerSleep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VtrackerSleep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when VtrackerSleep is resized.
function VtrackerSleep_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to VtrackerSleep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in pop_arenaType.
function pop_arenaType_Callback(hObject, eventdata, handles)
% hObject    handle to pop_arenaType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_arenaType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_arenaType


% --- Executes during object creation, after setting all properties.
function pop_arenaType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_arenaType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% set(hObject,'Value',5);
guidata(hObject,handles);

% --- Executes on button press in pb_clearVideo.
function pb_clearVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pb_clearVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.FileName = [];
handles.FileName_full = [];
set(handles.list_videoAdded,'Value',[]);
set(handles.list_videoAdded,'string',{'Video list cleared'});

guidata(hObject, handles);

function list_videoAdded_Callback(hObject, eventdata, handles)
% hObject    handle to pop_arenaType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ed_binSize_Callback(hObject, eventdata, handles)
% hObject    handle to ed_binSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_binSize as text
%        str2double(get(hObject,'String')) returns contents of ed_binSize as a double


% --- Executes during object creation, after setting all properties.
function ed_binSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_binSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_arenaDetection.
function pb_arenaDetection_Callback(hObject, eventdata, handles)
% hObject    handle to pb_arenaDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rb_saveTog.
function rb_saveTog_Callback(hObject, eventdata, handles)
% hObject    handle to rb_saveTog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_saveTog


% --- Executes on button press in pb_saveDir.
function pb_saveDir_Callback(hObject, eventdata, handles)
% hObject    handle to pb_saveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FP = uigetdir(handles.saveDir,'select a folder to save data');
if FP
    set(handles.ed_saveDir,'String',[FP,'\']);
end



function ed_saveDir_Callback(hObject, eventdata, handles)
% hObject    handle to ed_saveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_saveDir as text
%        str2double(get(hObject,'String')) returns contents of ed_saveDir as a double


% --- Executes during object creation, after setting all properties.
function ed_saveDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_saveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_deleteVideo.
function pb_deleteVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pb_deleteVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataSelected = get(handles.list_videoAdded,'Value')-1;
dataSelected (dataSelected ==0) = [];
if isempty(dataSelected)
    msg = get(handles.list_msg,'String');
   msg = [msg;{'No video selected'}]; 
   set(handles.list_msg,'String',msg);
   return
end  
removed = handles.FileName_full(dataSelected);
handles.FileName(dataSelected) = [];
handles.FileName_full (dataSelected) = [];

file_no = size(handles.FileName,2);

dataSelected(dataSelected>file_no)=[];
% if isempty(dataSelected)
%     set(handles.list_videoAdded,'Value',file_no+1);
% else
    set(handles.list_videoAdded,'Value',dataSelected);
% end

list = [{[num2str(file_no) ' files added']},handles.FileName_full];
set(handles.list_videoAdded,'string',list);

msg = get(handles.list_msg,'String');
msg = [msg;{[num2str(size(removed,2)),' video(s) removed:']}];
set(handles.list_msg,'min',0,'max',2,'Value',[]);
set(handles.list_msg,'String',msg);
   
guidata(hObject, handles);


% --- Executes on selection change in list_msg.
function list_msg_Callback(hObject, eventdata, handles)
% hObject    handle to list_msg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list_msg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_msg


% --- Executes during object creation, after setting all properties.
function list_msg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_msg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject,'string',{'Hello World'});
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);


% --- Executes on button press in pb_clearMsg.
function pb_clearMsg_Callback(hObject, eventdata, handles)
% hObject    handle to pb_clearMsg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.list_msg,'Value',[]);
set(handles.list_msg,'string',{'Zip?'});
guidata(hObject,handles);
