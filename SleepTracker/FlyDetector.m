function [Flies,flySize] = FlyDetector(FG,Arenas,BG,chamberType,mask)



% if nargin<3
%     
%     BWf = ~(imbinarize(FG));
% else
%     
BWf = imbinarize(BG-FG);
% end
aNo = size(Arenas,1);


if nargin<5
    mask = zeros(size(BG));
    trim = 5;
    for i = 1:aNo
        mask(Arenas(i).BoundingBox(2)+trim:...
            Arenas(i).BoundingBox(2)+Arenas(i).BoundingBox(4)-trim,...
            Arenas(i).BoundingBox(1)+trim:...
            Arenas(i).BoundingBox(1)+Arenas(i).BoundingBox(3)-trim) = 1;
    end
end
Flies = regionprops_int(BWf&mask);
idxF = [Flies(:).Area];
boxF = reshape([Flies(:).BoundingBox],4,[]);  
bodyRatio = max(boxF(3:4,:))./min(boxF(3:4,:));

switch chamberType
    case('rec14')
        flySize = [400,1700];
    case('rec28')
        flySize = [400,1700];
    case('rec72')
        flySize = [100,800];
    case('recMix')
        flySize = [100,1000];   
        %%% circul wells
    case('rnd8')
        flySize = [200,900];
    case('rnd18')
        flySize = [400,1700];
    case('rnd50')
        flySize = [200,900];
    case('tube21')
        flySize = [200,900];
end

Flies = Flies(idxF>flySize(1) & idxF<flySize(2) ...%by area
        & bodyRatio <3.5); % by W x L
    
    
    
    
