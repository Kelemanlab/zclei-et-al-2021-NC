function Vout=Vread_singleFrame(vobj,frame)
% input video object and frame #
% info=get(vobj);
vobj.CurrentTime = 0;
% disp((frame-1)/vobj.FrameRate);
vobj.CurrentTime=(frame-1)/vobj.FrameRate;
Vout=readFrame(vobj);