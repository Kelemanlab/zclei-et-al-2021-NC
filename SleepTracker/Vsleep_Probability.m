function [Pdoze,Pwake,h]= Vsleep_Probability(Dis,thresholdLoco,binSizeLoco)
% walking distance as input
% P(wake) and P(doze) % per 30 min as output
% walking distance binned in binSizeLoco (seconds)
% threshold for walking distance is 10pixel per 10 seconds

if nargin<5
    initialTime = 0;
end
if nargin<4
    binSizeSleep = 1800;
end

if isempty(thresholdLoco)
    thresholdLoco = 10;
end


thresholdLoco = thresholdLoco*binSizeLoco/10;
%%
thresholdSleep = 300./binSizeLoco; % sleep threshold 5 mins
[flyNo,binNo]=size(Dis);
k = rem(binNo,30);
if k && k<5
    Dis = Dis(:,1:end-k);
elseif k && k>=5
    Dis = [Dis,nan(flyNo,30-k)];
end
[flyNo,binNo]=size(Dis);

Acti = (Dis>thresholdLoco);

Acti30 = reshape(Acti,flyNo,30,[]);
ActiT30 = squeeze(sum(Acti30(:,1:end-1,:),2));
Trans = diff(Acti30,[],2');

Tw = (Trans==1);
Td = (Trans==-1);

Pwake = squeeze(sum(Tw,2))./(29-ActiT30);
Pdoze = squeeze(sum(Td,2))./ActiT30;

%%
h  = figure('color',[1,1,1],'position',[100,100,1200,800]);
subplot(1,2,1);imagesc(Pdoze);colorbar;title('P(doze)');
subplot(1,2,2);imagesc(Pwake);colorbar;title('P(wake)');

end


