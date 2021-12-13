function [refPos, id, err] = Vtrack_flyId(arenaBox,Flies,rnd,frame)
% aBox, arena box by x1,y1,w,l
% fPos, fly centroid
% rnd, loop rounds
% frame, frame #
% if nargin<5
%     prePos = [0,0];
% end
% maxStep = 
fPos = (reshape([Flies(:).Centroid],2,[]))';
fNo = size(fPos,1);
aNo = size(arenaBox,1);
id = nan(aNo,1);
refPos = nan(aNo,4);
err = [];
for ii = 1:fNo
    Flies(ii).id = ii;
end
widx = zeros(fNo,aNo)>0;
% FliesOut = struct;%repmat(Flies(1),aNo,1);

for i=1:aNo
    
    d = fPos-arenaBox(i,1:2)-.5*arenaBox(i,3:4);
    if arenaBox(i,3)==arenaBox(i,4)
        dc = sqrt(d(:,1).^2+d(:,2).^2);
        widx(:,i) = (dc<= .5*arenaBox(i,3));
    else
        widx(:,i) =(d(:,1)<=arenaBox(i,3)&...
            d(:,1)>= 0&...
            d(:,2)<=arenaBox(i,4)&...
            d(:,2)>= 0);
    end
    
    curNo = sum(widx(:,i));
    %     disp(i);
    %     disp(curNo);
    if curNo ==0
        id(i) = nan;
        err = [rnd,frame,i,fNo];
%         disp(err);
        continue
    end
    
    curFlies = Flies(widx(:,i));
    [~,idx] = max([curFlies(:).Area]);
    id(i) = curFlies(idx).id;
%     FliesOut(i) = Flies(id(i)); 
    refPos(i,1:2) = fPos(id(i),:)-arenaBox(i,1:2);
    refPos(i,3:4) = fPos(id(i),:);
end
%  FliesOut = FliesOut';