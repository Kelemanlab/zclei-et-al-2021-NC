function [disb,h] = Vplot_dist(refPos,vFR,binSize,ppm)
if nargin<4
    ppm = 1;
    unit = '(pixel)';
else
    unit = '(mm)';
end


% binSize in second
flyNo = size(refPos,1);
pdiff = refPos(:,:,2:end)-refPos(:,:,1:end-1);
dis = squeeze(sqrt(pdiff(:,1,:).^2+pdiff(:,2,:).^2));

binWidth =uint16(vFR*binSize);

disb = binn(dis,binWidth,2)./ppm;

% for i = 1:flyNo
%     exIdx = isoutlier(disb(i,:),'quartile');
%     disb(i,exIdx) = nan;
% end

% ym = max(disb(:));
ym = prctile(disb(:),99.95);
ym = 50*ceil(ym./50);

% binNo = size(disb,2);
plotSq = [1:2:2*ceil(flyNo/2),2:2:2*ceil(flyNo/2)]';
h = figure('position',[50,-400,2400,2000],'color',[1,1,1]);
for i = 1:flyNo
    subplot(ceil(flyNo./2),2,plotSq(i));
    bar(disb(i,:)','LineWidth',1);
    ylim([0,ym]);
    ylabel({'Walking distance';unit});
    xlabel(['Time (',num2str(binSize),'s)']);
    
    title(['Arena #', num2str(i)]);
end
