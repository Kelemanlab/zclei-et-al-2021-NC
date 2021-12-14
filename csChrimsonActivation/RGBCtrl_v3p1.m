function varargout = RGBCtrl_v3p1(varargin)

% 20180524 leiz
% -terminator function for program abort


% 20180523 leiz
% -cleared bug in RUN mode: release rig connection handle when aborted
% -cleared bug in Manual mode: 0.1s pause after '???' to read current pulse parameter.
% -Reset button added to reset RGB board.

% 20180504 leiz
% -read LED status 'started' and 'finished' from Serial.println in Arduino.
% -Arduino version RGB_J007017_20180427
% -not yet used for timing of program steps.


%04302018 leiz v1.12
% updated logical for ON and RUN button, pulse and progrom can be
% stopped/aborted in realtime.

%04292018 leiz v1.12
% try and catch errors in RUN section.



% RGBCTRL_V3P1 MATLAB code for RGBCtrl_v3p1.fig
%      RGBCTRL_V3P1, by itself, creates a new RGBCTRL_V3P1 or raises the existing
%      singleton*.
%
%      H = RGBCTRL_V3P1 returns the handle to a new RGBCTRL_V3P1 or the handle to
%      the existing singleton*.
%
%      RGBCTRL_V3P1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RGBCTRL_V3P1.M with the given input arguments.
%
%      RGBCTRL_V3P1('Property','Value',...) creates a new RGBCTRL_V3P1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RGBCtrl_v3p1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RGBCtrl_v3p1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RGBCtrl_v3p1

% Last Modified by GUIDE v2.5 03-May-2019 14:33:18

% update log:
%     Feb 22,2016: improved connect button, with error code disp.
%     Feb 23.2016: fixed patternswitch bug

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RGBCtrl_v3p1_OpeningFcn, ...
                   'gui_OutputFcn',  @RGBCtrl_v3p1_OutputFcn, ...
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


% --- Executes just before RGBCtrl_v3p1 is made visible.
function RGBCtrl_v3p1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RGBCtrl_v3p1 (see VARARGIN)



%Directory to save experimental data

serial_port_for_LED_Controller = get(handles.com_txt,'string');
handles.s1 = serial(serial_port_for_LED_Controller, 'BaudRate', 9600, 'Terminator', 'CR');
handles.con = 0;
% Choose default command line output for RGBCtrl_v3p1
handles.output = hObject;
handles.protocolDir = 'D:\Protocol';
handles.expDataDir = 'D:\Matdoc\flybowl m';
%handles.defaultProtocol = defaultProtocol;
% Initiate pulse parameters
handles.waitTime = 0;
handles.pulseWidth = 25;
handles.pulsePeriod = 50;
handles.pulseNum = 1;
handles.offTime = 0;
handles.cycleNum = 0;
%RGB int
handles.REDint = 0;
handles.GRNint = 0;
handles.BLUint = 0;
handles.IRint = 0;

handles.expRun = 0;
handles.expFile = [];
handles.LEDON = 0;

% Set LED Array as all on
handles.LEDpattern = true(1,16);
%handles.LEDpattern = [1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

% messenger log
handles.log = {};

guidata(hObject, handles);

% UIWAIT makes RGBCtrl_v3p1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RGBCtrl_v3p1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function RED_int_Callback(hObject, eventdata, handles)
% hObject    handle to RED_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if ~handles.con
    handles.log = [handles.log;{'Rig not connected'}];
    set(handles.msg,'string',flip(handles.log));
%     set(handles.msg,'string','Rig not connected');
    set(handles.RED_intVal, 'String', '0');
    set(handles.RED_int, 'Value', 0);
    set(hObject,'value',0);
    return
end

handles.REDint = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.RED_intVal, 'String', num2str(handles.REDint));
%send message to messenger
handles.log = [handles.log;{['Red int set to ',num2str(handles.REDint),'%']}];
set(handles.msg,'string',flip(handles.log));

%send command to controller
fprintf(handles.s1, ['RED ',num2str(handles.REDint)]);
pause(1);
while handles.s1.BytesAvailable > 1 
    display(fscanf(handles.s1));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function RED_int_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RED_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function GRN_int_Callback(hObject, eventdata, handles)
% hObject    handle to GRN_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.con
    handles.log = [handles.log;{'Rig not connected'}];
    set(handles.msg,'string',flip(handles.log));
    set(handles.GRN_intVal, 'String', '0');
    set(hObject,'value',0);
    return
end

handles.GRNint = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.GRN_intVal, 'String', num2str(handles.GRNint));
%send message to messenger
handles.log = [handles.log;{['Green int set to ',num2str(handles.GRNint),'%']}];
set(handles.msg,'string',flip(handles.log));

%send command to controller
fprintf(handles.s1, ['GRN ',num2str(handles.GRNint)]);
pause(.1);
while handles.s1.BytesAvailable > 1 
    display(fscanf(handles.s1));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function GRN_int_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GRN_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function BLU_int_Callback(hObject, eventdata, handles)
% hObject    handle to BLU_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if ~handles.con
    handles.log = [handles.log;{'Rig not connected'}];
    set(handles.msg,'string',flip(handles.log));
    set(handles.BLU_intVal, 'String', '0');
    set(hObject,'value',0);
    return
end

handles.BLUint = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.BLU_intVal, 'String', num2str(handles.BLUint));
%send message to messenger
handles.log = [handles.log;{['Blue int set to ',num2str(handles.BLUint),'%']}];
set(handles.msg,'string',flip(handles.log));

%send command to controller
fprintf(handles.s1, ['BLU ',num2str(handles.BLUint)]);
pause(.1);
while handles.s1.BytesAvailable > 1 
    display(fscanf(handles.s1));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function BLU_int_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BLU_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function IR_int_Callback(hObject, eventdata, handles)
% hObject    handle to IR_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if ~handles.con
    handles.log = [handles.log;{'Rig not connected'}];
    set(handles.msg,'string',flip(handles.log));
    set(handles.IR_intVal, 'String', '0%');
    set(hObject,'value',0);
    return
end

handles.IRint = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.IR_intVal, 'String', [num2str(handles.IRint) '%']);
%send message to messenger
handles.log = [handles.log;{['IR int set to ',num2str(handles.IRint),'%']}];
set(handles.msg,'string',flip(handles.log));

%send command to controller
fprintf(handles.s1, ['IR ',num2str(handles.IRint)]);
pause(.1);
while handles.s1.BytesAvailable > 1 
    display(fscanf(handles.s1));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function IR_int_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IR_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in OnOff.
function OnOff_Callback(hObject, eventdata, handles)
% hObject    handle to OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OnOff
if ~handles.con
    handles.log = [handles.log;{'Rig not connected'}];
    set(handles.msg,'string',flip(handles.log));
    set(hObject,'value',0);
    set(hObject,'BackgroundColor',[.941 .941 .941]);
    return
end


handles.REDint = round(get(handles.RED_int,'Value')*100);
handles.GRNint = round(get(handles.GRN_int,'Value')*100);
handles.BLUint = round(get(handles.BLU_int,'Value')*100);
fprintf(handles.s1,['RED ',num2str(handles.REDint)]);
fprintf(handles.s1,['GRN ',num2str(handles.GRNint)]);
fprintf(handles.s1,['BLU ',num2str(handles.BLUint)]);

if ~(handles.REDint||handles.BLUint||handles.GRNint)
    handles.log = [handles.log;{'all RGB at int 0'}];
    set(handles.msg,'string',flip(handles.log));

end


% if isempty(handles.LEDpattern)
%     set(handles.msg,'string','LED pattern undefined');
%     set(hObject,'value',0);
%     set(hObject,'BackgroundColor',[.941 .941 .941]);
%     return
% end

button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
    handles.LEDON = 1;
    
    set(hObject,'String','Abort');
    set(hObject,'BackgroundColor','red');
%     LEDPatt = sprintf('%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d',handles.LEDpattern);
%     fprintf(handles.s1, ['PATT ', LEDPatt]);
    pause(0.1);
    while handles.s1.BytesAvailable > 1
%         disp('c1');
        fscanf(handles.s1);
            handles.log = [handles.log;{'checkPoint 1'}];
            set(handles.msg,'string',flip(handles.log));
    end
    %     flushinput(handles.s1);
    handles.waitTime = str2double(get(handles.WT_val,'String'));
    handles.pulseWidth = str2double(get(handles.PW_val,'String'));
    handles.pulsePeriod = str2double(get(handles.PP_val,'String'));
    handles.pulseNum = str2double(get(handles.PN_val,'String'));
    handles.offTime = str2double(get(handles.OT_val,'String'));
    handles.cycleNum = str2double(get(handles.CN_val,'String'));
    
%     durationTime = (handles.waitTime +...
%                    handles.pulseNum.*handles.pulsePeriod./1000+...
%                    handles.offTime./1000)...
%                    .*handles.cycleNum;
               
    if handles.pulseWidth > 0 && handles.pulsePeriod > 0

        if handles.pulseWidth > 30000
            handles.log = [handles.log;{'pulse width should be =< 30000ms.'}];
            set(handles.msg,'string',flip(handles.log));
            %                 warndlg('The value of pulse width should be equal or less than 30000ms. Please try again', 'Pulse values error');
            return;
        end
        
        if handles.pulseWidth > 30000
            handles.log = [handles.log;{'pulse period should be =< 30000ms.'}];
            set(handles.msg,'string',flip(handles.log));
            %                 warndlg('The value of pulse period should be equal or less than 30000ms. Please try again', 'Pulse values error');
            return;
        end
        
        if handles.pulseWidth > handles.pulsePeriod
            handles.log = [handles.log;{'pulse width should be =< pulse period.'}];
            set(handles.msg,'string',flip(handles.log));
            %                 warndlg('The value of pulse period should be equal or larger than pulse width. Please try again', 'Pulse values error');
            return;
        end
                
        fprintf(handles.s1, ['PULSE ', num2str(handles.pulseWidth), ' ',...
                                       num2str(handles.pulsePeriod),' ',...
                                       num2str(handles.pulseNum),' ',...
                                       num2str(handles.offTime),' ',...
                                       num2str(handles.waitTime),' ',...
                                       num2str(handles.cycleNum),...
                                       ]);
        
        fprintf(handles.s1,'???'); 
        pause(0.1);
        while handles.s1.BytesAvailable > 1
%              disp('c2');
%              fscanf(handles.s1)
            handles.log = [handles.log;fscanf(handles.s1)];
            set(handles.msg,'string',flip(handles.log));
        end
%         handles.s1.BytesAvailable

%         handles.log
        fprintf(handles.s1, 'RUN');
        pause(.1);
        if handles.cycleNum>0
            drawnow
%             tic;
            while handles.LEDON
                drawnow
                % stop when pulse is finished
                while handles.s1.BytesAvailable > 1
                    temp = fscanf(handles.s1);
                    handles.log = [handles.log;temp];
                    set(handles.msg,'string',flip(handles.log));
                    if strfind(temp,'finished')
                       handles.LEDON = 0;
                    end
                end
                % break if abort button pressed
                if get(hObject,'Value')==0
                    [handles,hObject] = Terminator(handles,hObject,'ON');
                    guidata(hObject, handles);
                    return;
                end
            end
            
            [handles,hObject] = Terminator(handles,hObject,'ON','Done!');
            guidata(hObject, handles);
        end
    else
        fprintf(handles.s1, 'ON');
    end
%     guidata(hObject, handles);
elseif button_state == get(hObject,'Min')
    [handles,hObject] = Terminator(handles,hObject,'ON');
    guidata(hObject, handles);
end
guidata(hObject, handles);


function RED_intVal_Callback(hObject, eventdata, handles)
% hObject    handle to RED_intVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RED_intVal as text
%        str2double(get(hObject,'String')) returns contents of RED_intVal as a double


% --- Executes during object creation, after setting all properties.
function RED_intVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RED_intVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IR_intVal_Callback(hObject, eventdata, handles)
% hObject    handle to IR_intVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IR_intVal as text
%        str2double(get(hObject,'String')) returns contents of IR_intVal as a double


% --- Executes during object creation, after setting all properties.
function IR_intVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IR_intVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when entered data in editable cell(s) in tb_LEDArray.
% function tb_LEDArray_CellEditCallback(hObject, eventdata, handles)
% % hObject    handle to tb_LEDArray (see GCBO)
% % eventdata  structure with the following fields (see UITABLE)
% %	Indices: row and column indices of the cell(s) edited
% %	PreviousData: previous data for the cell(s) edited
% %	EditData: string(s) entered by the user
% %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
% %	Error: error string when failed to convert EditData to appropriate value for Data
% % handles    structure with handles and user data (see GUIDATA)
% 
% LED_pattern_raw = cell2mat(get(hObject,'data'));
% 
% if isempty(find(LED_pattern_raw, 1))
%     Pattern = zeros(1,16);
% else
%     
%     Temp2 = rot90(LED_pattern_raw,2);
%     Temp3 = Temp2';
%     Temp4 = Temp3(:);
%     Pattern = Temp4';
% end
% 
% handles.LEDpattern = Pattern;
% 
% guidata(hObject, handles);

    


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure

%close the serial port connection
if strcmp(handles.s1.status,'open')
    fprintf(handles.s1, 'off');
    fprintf(handles.s1, 'stop');
    fclose(handles.s1);
end
fclose(instrfind);
delete(hObject);
% clear all



function PW_val_Callback(hObject, ~, handles)
% hObject    handle to PW_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PW_val as text
%        str2double(get(hObject,'String')) returns contents of PW_val as a double

handles.pulseWidth = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PW_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PW_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.pulseWidth = str2double(get(hObject,'String')) ;
guidata(hObject, handles);



function PP_val_Callback(hObject, ~, handles)
% hObject    handle to PP_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PP_val as text
%        str2double(get(hObject,'String')) returns contents of PP_val as a double
handles.pulsePeriod = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PP_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PP_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.pulsePeriod = str2double(get(hObject,'String')) ;
guidata(hObject, handles);



% --- Executes on button press in exp_select.
function exp_select_Callback(hObject, eventdata, handles)
% hObject    handle to exp_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of exp_select
oldPath = pwd;
% cd(handles.expProtocolDir);
if isempty(handles.protocolDir)
    handles.protocolDir = 'D:\protocol\';
end
[filename, pathname] = uigetfile('*.xlsx', 'Select an protocol file',handles.protocolDir);
handles.protocolDir = pathname;

if isequal(filename,0)
       handles.log = [handles.log;{'Protocol not selected'}];
    set(handles.msg,'string',flip(handles.log)); 
   return
else
   expFile = fullfile(pathname, filename);
   set(handles.exp_name, 'string', expFile);
   
end

indata = xlsread(expFile);

handles.stepNum = (1:1:size(indata,1));
handles.REDintSP = indata(:,1);
handles.GRNintSP = indata(:,2);
handles.BLUintSP = indata(:,3);

handles.pulseWidthSP = indata(:,4);
handles.pulsePeriodSP = indata(:,5);
handles.pulseNumSP = indata(:,6);
handles.offTimeSP = indata(:,7);
handles.waitTimeSP = indata(:,8);
handles.duration = indata(:,9);
handles.patternstep = zeros(size(indata,1),1);

% reading LED pattern
% if size(indata,2) >9
%     handles.patternswitch = 1;
%     LEDud = [zeros(1,16);zeros(1,16)];
%     LEDud(1,1:2)=[1,1];
%     LEDud(2,5:6)=[1,1];
%     handles.LEDud = LEDud;
%     handles.patternstep = indata(:,8);
% else
%     indata(:,8)=zeros(handles.stepNum(end),1);
% end
handles.expData = indata;
handles.expFile = expFile;
% dos(['xlsx ',expFile, ' &']);
cd(oldPath);

guidata(hObject, handles);

% --- Executes on button press in exp_run.
function exp_run_Callback(hObject, eventdata, handles)
% hObject    handle to exp_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of exp_run
try
    % check if rig is connected
    if ~handles.con
        handles.log = [handles.log;{'Rig not connected'}];
        set(handles.msg,'string',flip(handles.log));
        set(hObject,'value',0);
        set(hObject,'BackgroundColor',[.941 .941 .941]);
        handles.expRun = 0;
        handles.LEDon = 0;
        guidata(hObject,handles);
        return
    end
    
    % check if exp file is loaded.
    if isempty(handles.expFile)
        handles.log = [handles.log;{'Protocol not loaded'}];
        set(handles.msg,'string',flip(handles.log));
        set(hObject,'value',0);
        set(hObject,'BackgroundColor',[.941 .941 .941]);
        handles.expRun = 0;
        handles.LEDon = 0;
        guidata(hObject,handles);
        return
    end
    % if isempty(handles.LEDpattern)
    %     set(handles.msg,'string','LED pattern undefined');
    %     set(hObject,'value',0);
    %     set(hObject,'BackgroundColor',[.941 .941 .941]);
    %     return
    % end
    handles.saveDir = get(handles.saveTo_dir,'String');
    if ~exist(handles.saveDir,'dir')
        mkdir(handles.saveDir);
    end
    handles.expRun = get(hObject,'value');
    
    if handles.expRun
        
        set(hObject,'String','STOP');
        set(hObject,'BackgroundColor','red');
        pause(0.1);
        while handles.s1.BytesAvailable > 1
            display(fscanf(handles.s1));
        end
        
        %go thouhg each step
        for step=1:length(handles.stepNum)
            %check exp status
            drawnow;
            if ~get(hObject,'value')
                    [handles,hObject] = Terminator(handles,hObject,'RUN');
                    guidata(hObject, handles);
                return
            end
            %                 %define LED pattern
            %         if handles.patternstep(step)
            %             LEDPatt = sprintf('%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d',handles.LEDud(handles.patternstep(step),:));
            %         else
            %             LEDPatt = sprintf('%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d',handles.LEDpattern);
            %         end
            %         fprintf(handles.s1, ['PATT ', LEDPatt]);
            
            
            % display current step
            allOn = 0;
            allOff = 0;
            
            currentStep = ['ST:', num2str(handles.stepNum(step)),...
                ' RGB:', num2str(handles.REDintSP(step)),'/',num2str(handles.GRNintSP(step)),'/',num2str(handles.BLUintSP(step)) ...
                ' PW:', num2str(handles.pulseWidthSP(step)), ' PP:', num2str(handles.pulsePeriodSP(step)),...
                ' PN:', num2str(handles.pulseNumSP(step)),  ' OT:', num2str(handles.offTimeSP(step)),...
                ' WT:', num2str(handles.waitTimeSP(step)), ' DU:',num2str(handles.duration(step))];
            handles.log = [handles.log;{currentStep}];
            set(handles.msg,'string',flip(handles.log));
            guidata(hObject, handles);
            %         set(handles.msg, 'string', currentStep);
            pause(0.1);
            
            
            % if intensity = 0, turn off LEDs for this step
            if handles.REDintSP(step)==0&&handles.GRNintSP(step)==0&&handles.BLUintSP(step)==0
                allOff = 1;
            % if pulse period = 0 or pulse width = 0, always on this step
            elseif handles.pulsePeriodSP(step) == 0 || handles.pulseWidthSP(step)==0
                allOn = 1;
            end

            % set RGB intensity
            fprintf(handles.s1, ['RED ',num2str(handles.REDintSP(step))]);
            fprintf(handles.s1, ['GRN ',num2str(handles.GRNintSP(step))]);
            fprintf(handles.s1, ['BLU ',num2str(handles.BLUintSP(step))]);
            
            % blink LED (calculate the iteration number)
            if allOff == 1 % off step
                fprintf(handles.s1, 'OFF');
                fprintf(handles.s1, 'STOP');
                aa = tic;
                drawnow           
                while toc(aa) < (double(handles.duration(step)))
                    drawnow
                    if get(hObject,'Value')==0
                        set(hObject,'String','RUN');
                        set(hObject,'value',0);
                        set(hObject,'BackgroundColor',[.941 .941 .941]);
                        handles.e = 0;
                        handles.expRun = 0;
                        handles.LEDon = 0;
                        fprintf(handles.s1, 'OFF');
                        fprintf(handles.s1, 'STOP');
                        handles.log = [handles.log;{'Aborted'}];
                        set(handles.msg,'string',flip(handles.log));
                        guidata(hObject,handles);
                        return;
                    end
                end
            elseif allOn == 1
                fprintf(handles.s1, 'ON');
                aa = tic;
                drawnow
                while toc(aa) < (double(handles.duration(step)))
                    drawnow
                    if get(hObject,'Value')==0
                        fprintf(handles.s1, 'OFF');
                        set(hObject,'String','RUN');
                        set(hObject,'value',0);
                        set(hObject,'BackgroundColor',[.941 .941 .941]);
                        handles.LEDON = 0;
                        handles.expRun = 0;
                        handles.log = [handles.log;{'Aborted'}];
                        set(handles.msg,'string',flip(handles.log));
                        guidata(hObject,handles);
                        return;
                    end
                end
                fprintf(handles.s1, 'OFF');
                fprintf(handles.s1, 'STOP');
            else
                if handles.pulseNumSP(step) < 1
                    handles.log = [handles.log;{'pulse number should be 1-1000.'}];
                    set(handles.msg,'string',flip(handles.log));
                    [handles,hObject] = Terminator(handles,hObject,'RUN');
                    guidata(hObject, handles);
                    return;
                end
                
                if handles.pulseWidthSP(step) > 30000
                    handles.log = [handles.log;{'pulse width should be =< 30000ms.'}];
                    set(handles.msg,'string',flip(handles.log));
                    [handles,hObject] = Terminator(handles,hObject,'RUN');
                    guidata(hObject, handles);
                    return;
                end
                
                if handles.pulseWidthSP(step) > 30000
                    handles.log = [handles.log;{'pulse period should be =< 30000ms.'}];
                    set(handles.msg,'string',flip(handles.log));
                    [handles,hObject] = Terminator(handles,hObject,'RUN');
                    guidata(hObject, handles);
                    return;
                end
                
                if handles.pulseWidthSP(step) > handles.pulsePeriodSP(step)
                    handles.log = [handles.log;{'pulse width should be =< pulse period.'}];
                    set(handles.msg,'string',flip(handles.log));
                    [handles,hObject] = Terminator(handles,hObject,'RUN');
                    guidata(hObject, handles);
                    %                 warndlg('The value of pulse period should be equal or larger than pulse width. Please try again', 'Pulse values error');
                    return;
                end
                
                %             (calculate the iteration number)
                handles.cycleNumSP(step) = round(handles.duration(step)./...
                    (handles.waitTimeSP(step)+...
                    handles.pulsePeriodSP(step).*handles.pulseNumSP(step).*0.001+...
                    handles.offTimeSP(step)));
                
                fprintf(handles.s1, ['PULSE ', num2str(handles.pulseWidthSP(step)), ' ',...
                    num2str(handles.pulsePeriodSP(step)), ' ',...
                    num2str(handles.pulseNumSP(step)), ' ',...
                    num2str(handles.offTimeSP(step)), ' ',...
                    num2str(handles.waitTimeSP(step)),' ',...
                    num2str(handles.cycleNumSP(step))]);
                fprintf(handles.s1, ['PULSE ', num2str(handles.pulseWidthSP(step)), ' ',...
                    num2str(handles.pulsePeriodSP(step)), ' ',...
                    num2str(handles.pulseNumSP(step)), ' ',...
                    num2str(handles.offTimeSP(step)), ' ',...
                    num2str(handles.waitTimeSP(step)),' ',...
                    num2str(handles.cycleNumSP(step))]);
                pause(0.1);
                fprintf(handles.s1, 'RUN');
                %                 delay(double(handles.duration(step)));
                aa = tic;
                drawnow
                while toc(aa) < (double(handles.duration(step)))
                    drawnow
                    if get(hObject,'Value')==0
                        [handles,hObject] = Terminator(handles,hObject,'RUN');
                        guidata(hObject, handles);
                        return;
                    end
                end
                fprintf(handles.s1, 'STOP');fprintf(handles.s1, 'OFF');
            end
            % display timer
            handles.log = [handles.log;{['Elapsed time is ', num2str(toc(aa)), ' seconds']}];
            set(handles.msg,'string',flip(handles.log));
            
        end
        
        %to guaranttee the leds are off at the end
        drawnow;
        if get(hObject,'value')
            handles.saveDir = get(handles.saveTo_dir,'string');
            logName = [handles.saveDir, '\RGBlog_', datestr(now,30), '.xls'];
            %            protocolName = regexprep(handles.expFile,'\\','\\\');
            
            
            xlswrite(logName,{handles.expFile},1,'A1');
            xlswrite(logName,{'Red','Green','Blue','PD','PP','PN','OT','WT','Time'},1,'A2');
            xlswrite(logName,handles.expData,1,'A3');
            
        end
        [handles,hObject] = Terminator(handles,hObject,'RUN','all done!');
        guidata(hObject, handles);
        %     set(handles.msg, 'string', 'Done!!');
        
        %
    else
        [handles,hObject] = Terminator(handles,hObject,'RUN');
        guidata(hObject, handles);
    end
catch ME
    handles.log = [handles.log;{ME.identifier};{ME.message}];
    set(handles.msg,'String',flip(handles.log));
    rethrow(ME);
end
guidata(hObject, handles);

function exp_name_Callback(hObject, eventdata, handles)
% hObject    handle to exp_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_name as text
%        str2double(get(hObject,'String')) returns contents of exp_name as a double


% --- Executes during object creation, after setting all properties.
function exp_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function msg_Callback(hObject, eventdata, handles)
% hObject    handle to msg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of msg as text
%        str2double(get(hObject,'String')) returns contents of msg as a double


% --- Executes during object creation, after setting all properties.
function msg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function delay(sec)

% function pause the program
% ms = delay time in seconds
tic;
while toc < sec 
    
end

function [handles,hObject] = Terminator(handles,hObject,buttonFlag,stateFlag)
if nargin<3
    buttonFlag = 'ON';
end

if nargin<4
    stateFlag = 'Aborted';
end
set(hObject,'Value',0);
set(hObject,'String',buttonFlag);
set(hObject,'BackgroundColor',[.941 .941 .941]);
fprintf(handles.s1, 'OFF');fprintf(handles.s1, 'STOP');
handles.LEDON = 0;
handles.expRun = 0;
handles.log = [handles.log;{stateFlag}];
set(handles.msg,'string',flip(handles.log));
% guidata(hObject,handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over OnOff.
function OnOff_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function PN_val_Callback(hObject, eventdata, handles)
% hObject    handle to PN_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PN_val as text
%        str2double(get(hObject,'String')) returns contents of PN_val as a double
handles.pulseNum = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PN_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PN_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.pulseNum = str2double(get(hObject,'String')) ;
guidata(hObject, handles);



function OT_val_Callback(hObject, eventdata, handles)
% hObject    handle to OT_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OT_val as text
%        str2double(get(hObject,'String')) returns contents of OT_val as a double
handles.offTime = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function OT_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OT_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.offTime = str2double(get(hObject,'String')) ;
guidata(hObject, handles);



function com_txt_Callback(hObject, eventdata, handles)
% hObject    handle to com_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of com_txt as text
%        str2double(get(hObject,'String')) returns contents of com_txt as a double


% --- Executes during object creation, after setting all properties.
function com_txt_CreateFcn(hObject, ~, handles)
% hObject    handle to com_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_connect.
function pb_connect_Callback(hObject, eventdata, handles)
% hObject    handle to pb_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.LEDON || handles.expRun
    x = get(hObject,'value');
    handles.log = [handles.log;{'LED on, switch connection later'}];
    set(handles.msg,'string',flip(handles.log));
    %    set(handles.msg,'string','LED on, switch connection later');
   set(hObject,'value',~x);
   return
end
reconnect = get(hObject,'value');
handles.con = 0;
if reconnect
    set(hObject,'string','Disconnect');
    set(hObject,'BackgroundColor','red');
    serial_port_for_LED_Controller = get(handles.com_txt,'string');
    handles.s1 = serial(serial_port_for_LED_Controller, 'BaudRate', 9600, 'Terminator', 'CR');
    if strcmp(handles.s1.status,'open')
       fclose(handles.s1);
    end
    try
        fopen(handles.s1);
        handles.con = 1;
        handles.log = [handles.log;{'Rig connected'}];
        set(handles.msg,'string',flip(handles.log));
    catch ME
        handles.log = [handles.log;{datestr(now,30);ME.message}];
        set(handles.msg,'string',flip(handles.log));
%         set(handles.msg,'string',{datestr(now,30);ME.message});
        set(hObject,'value',0);
        set(hObject,'string','Connect');
        set(hObject,'BackgroundColor',[.541 .941 .941]);
    end
    
else
    set(hObject,'string','Connect');
    set(hObject,'BackgroundColor',[.941 .941 .941]);
    if strcmp(handles.s1.status,'open')
       fclose(handles.s1);
       fclose(instrfind);
           handles.log = [handles.log;{'Rig disconnected'}];
    set(handles.msg,'string',flip(handles.log));
    end

    handles.con = 0;
end
guidata(hObject, handles);



function saveTo_dir_Callback(hObject, eventdata, handles)
% hObject    handle to saveTo_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveTo_dir as text
%        str2double(get(hObject,'String')) returns contents of saveTo_dir as a double



% --- Executes during object creation, after setting all properties.
function saveTo_dir_CreateFcn(hObject, ~, handles)
% hObject    handle to saveTo_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GRN_intVal_Callback(hObject, eventdata, handles)
% hObject    handle to GRN_intVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GRN_intVal as text
%        str2double(get(hObject,'String')) returns contents of GRN_intVal as a double


% --- Executes during object creation, after setting all properties.
function GRN_intVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GRN_intVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function BLU_intVal_Callback(hObject, eventdata, handles)
% hObject    handle to BLU_intVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BLU_intVal as text
%        str2double(get(hObject,'String')) returns contents of BLU_intVal as a double


% --- Executes during object creation, after setting all properties.
function BLU_intVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BLU_intVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WT_val_Callback(hObject, eventdata, handles)
% hObject    handle to WT_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WT_val as text
%        str2double(get(hObject,'String')) returns contents of WT_val as a double
handles.waitTime = str2double(get(hObject,'String')) ;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function WT_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WT_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.waitTime = str2double(get(hObject,'String')) ;
guidata(hObject, handles);


function CN_val_Callback(hObject, eventdata, handles)
% hObject    handle to CN_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CN_val as text
%        str2double(get(hObject,'String')) returns contents of CN_val as a double
handles.cycleNum = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function CN_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CN_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.cycleNum = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes on button press in LEDArray_cb1.
function LEDArray_cb1_Callback(hObject, eventdata, handles)
% hObject    handle to LEDArray_cb1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LEDArray_cb1


% --- Executes on button press in LEDArray_cb2.
function LEDArray_cb2_Callback(hObject, eventdata, handles)
% hObject    handle to LEDArray_cb2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LEDArray_cb2


% --- Executes on button press in LEDArray_cb3.
function LEDArray_cb3_Callback(hObject, eventdata, handles)
% hObject    handle to LEDArray_cb3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LEDArray_cb3


% --- Executes on button press in LEDArray_cb4.
function LEDArray_cb4_Callback(hObject, eventdata, handles)
% hObject    handle to LEDArray_cb4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LEDArray_cb4


% --- Executes on button press in pb_msgClear.
function pb_msgClear_Callback(hObject, eventdata, handles)
% hObject    handle to pb_msgClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.log = {};
set(handles.msg,'string','here you go');
guidata(hObject, handles);




% --- Executes on button press in saveTo_txt.
function saveTo_txt_Callback(hObject, eventdata, handles)
% hObject    handle to saveTo_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.saveDir = uigetdir;
set(handles.saveTo_dir,'string',handles.saveDir);
guidata(hObject, handles);


% --- Executes on button press in pb_reset.
function pb_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pb_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check if RGB is connected
if ~handles.con
    handles.log = [handles.log;{'Rig not connected'}];
    set(handles.msg,'string',flip(handles.log));
    set(handles.GRN_intVal, 'String', '0');
    set(hObject,'value',0);
    return
end



RGBreset = questdlg('Would you like to reset the RGB board?', ...
	'RGB reset', ...
	'Yes','No thanks','No thanks');
% Handle response
switch RGBreset
    case 'Yes'
        drawnow;
        % stop any ongoing program
        if strcmp(handles.s1.status,'open')
            fprintf(handles.s1, 'off');
            fprintf(handles.s1, 'stop');
        end
        
        
        handles.waitTime = 0;
        handles.pulseWidth = 25;
        handles.pulsePeriod = 50;
        handles.pulseNum = 1;
        handles.offTime = 0;
        handles.cycleNum = 0;
        %RGB int
        handles.REDint = 0;
        handles.GRNint = 0;
        handles.BLUint = 0;
        handles.IRint = 10;
        
        fprintf(handles.s1,['RED ',num2str(handles.REDint)]);
        fprintf(handles.s1,['GRN ',num2str(handles.GRNint)]);
        fprintf(handles.s1,['BLU ',num2str(handles.BLUint)]);
        fprintf(handles.s1,['IR ',num2str(handles.IRint)]);
        
        set(handles.RED_int,'value',0);set(handles.RED_intVal,'String', num2str(handles.REDint));
        set(handles.GRN_int,'value',0);set(handles.GRN_intVal,'String', num2str(handles.GRNint));
        set(handles.BLU_int,'value',0);set(handles.BLU_intVal,'String', num2str(handles.BLUint));
        set(handles.IR_int,'value',10);set(handles.BLU_intVal,'String', num2str(handles.BLUint));
        
        handles.expRun = 0;
        handles.LEDON = 0;
        
        set(handles.OnOff,'String','ON');
        set(hObject,'BackgroundColor',[.941 .941 .941]);
        set(handles.exp_run,'String','ON');
        set(hObject,'BackgroundColor',[.941 .941 .941]);
    
    case 'No thanks'
        
end
guidata(hObject, handles);


