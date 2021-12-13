function [Pos,errorF]=Vtrack_chunk(vobj,chunk,BG,Arenas,rnd,flySize,mask)
% reading specified chunk of the video
% chunk is defined by start time and end time.
if nargin <6
    flySize = [300,2000];
end

vobj.CurrentTime=chunk(1);
No_f = int16 (vobj.FrameRate*(chunk(2)-chunk(1)));
arenaNo = size(Arenas,1);
arenaBox = (reshape([Arenas(:).BoundingBox],4,[]))';

% flyLng = 5*ceil(sqrt(flySize(2)./5));
Pos = nan(arenaNo,4,No_f);
% flyBox = nan(flyLng*2,flyLng*2,arenaNo,No_f);
% tic
k=1;
% er = 1;
errorF = [];
% h = waitbar(0);
while vobj.CurrentTime < chunk(2) && hasFrame(vobj) 
    %%
        tmp = readFrame(vobj);
        curF = uint8(BG)-tmp(:,:,1);
        
        BW = imbinarize(curF);
        Flies = regionprops_int(BW&mask);%_int
        areaF = [Flies(:).Area];
        boxF = reshape([Flies(:).BoundingBox],4,[]); 
        bodyRatio = max(boxF(3:4,:))./min(boxF(3:4,:));
        
         Flies = Flies(areaF>flySize(1) & areaF<flySize(2) ...%by area
        & bodyRatio<3.5);  % by W / L
    
        [Pos(:,:,k),~,err] = Vtrack_flyId(arenaBox,Flies,rnd,k);
%         disp(k);
%         flyNo = size(FliesOut,1);
        
        %%
        if ~isempty(err)
            errorF = [errorF;err];
%             disp(['round #',num2str(rnd),...
%                 '; frame #',num2str(k),...
%                 '; arena #',num2str(err(3)); 
%                 '; fly detected ',num2str(flyNo)]);
        end
%    
%         % extra flyBox %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         for i=1:arenaNo
%             if ~isnan(ID(i))
%                 flyBox(:,:,i,k) = curF(Flies(ID(i)).Centroid(2)-flyLng+1:...
%                     Flies(ID(i)).Centroid(2)+flyLng,...
%                     Flies(ID(i)).Centroid(1)-flyLng+1:...
%                     Flies(ID(i)).Centroid(1)+flyLng);
%             end
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%         waitbar(k/No_f);
% disp(k);

        k=k+1;
end
% close(h);
% toc