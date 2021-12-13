function [SSb,refPos,aerrorF]=VsleepTracking_singleVideo (FN,PN,...
    binSize,...
    arenaType,...
    outDir,...
    initialTime,...
    endTime...
    )

if nargin<5
    outDir = [PN,'\dataPlot\'];
    if ~exist(outDir,'dir')
        mkdir(outDir);
    end
end
if nargin<4
    aerrorF = {'arena type not defined'};
    return
end

if nargin<6
    initialTime = 1;
end
if nargin<7
    endTime = 0;
end

path = [PN,FN];
FNn = FN(1:end-4);
mv=VideoReader(path);
vH = mv.Height;
vW = mv.Width;
if endTime == 0
    vD = mv.Duration;
else
    vD = endTime;
end
vFR = mv.FrameRate;
hw = waitbar(0,'Detecting arenas and flies...','Name','Tracking status');
%% background
vFT = vD*vFR;

% if Frame_tot>=400
% tic
    bga = nan(vH,vW,3,200);
    kf = floor(1:vFT/200:vFT);
   parfor i=1:200
        bga(:,:,:,i) = Vread_singleFrame(mv,kf(i));
    end
    BG = uint8(mean(bga(:,:,1,:),4)); clear bga;
%     h=figure;imagesc(BG);axis image;axis off;
%     hold on;title('backgroud');
% else
%     im = Vread_chunk(mv,[0 mv.Duration]);
%     BG = squeeze(mean(im(:,:,1,:),4));    
% end
% toc
%
%% find arenas and flies
mv.CurrentTime = 0;
AG = rgb2gray(readFrame(mv));
[Arenas,~,h,flySize,mask,ppm] = ArenaDetector(AG,arenaType,BG);
saveas (h, [outDir,FNn,'_Arenas.png']); 
close(h);
clear h;
save([outDir,FNn,'.mat'],'-regexp', '^(?!(hw)$).');
arenaNo = size(Arenas,1);

%% parallel reading by chuncks
figure(hw);
waitbar(1/4,hw,{'Arenas and flies detected';...
                'Tracking flies...'},...
                'name','Tracking status');
chunkSize = floor(vFT./48);
chunkS = ((1:chunkSize:vFT)-1)'./vFR;
chunkE = [chunkS(2:end);vD];
chunk = [chunkS,chunkE];clear chunkS chunkE;
chunk(:,3:4) = chunk.*vFR;
chunkNo = size(chunk,1);

%% tracking
tic
mv.CurrentTime = 0;
parfor i=1:chunkNo
%     disp(i);
    [Pos{i,1},errorF{i,1}] = Vtrack_chunk(mv,chunk(i,1:2),...
        BG,Arenas,i,flySize,mask);
    
end
elap = [num2str(toc),'s'];
clear i;

figure(hw);
waitbar(2/4,hw,{'Arenas and flies detected';...
                ['Tracking was done in',elap];...
                'data in plot...'},...
                'name','Tracking status');
save([outDir,FNn,'.mat'],'-regexp', '^(?!(hw)$).');

% sleep scoring
aPos = [];
% aBox = [];
aerrorF= [];

for i=1:chunkNo
    aPos = cat(3,aPos,Pos{i});
%     aBox = cat(4,aBox,Box{i});
    aerrorF = cat(1,aerrorF,errorF{i});
end
% % loco-motion ploting
% moving distance
% binSize = 60;
refPos = aPos(:,1:2,:);

[Disb,h] = Vplot_dist(refPos,vFR,binSize,ppm);

hold on;subtitle(FNn);
[flyNo,binNo] = size(Disb);
% saveas (h, [outDir,FN,'_walkingDistance_',num2str(binSize),'s.png']); 
close(h);
clear h;

% clear h;

% save([outDir,FN,'.mat'],'-regexp', '^(?!(hw)$).');


%
% % % trace plot in Arenas
% % h = figure('position',[100 200 2800 400]);
% % for i = 1:arenaNo
% %     subplot(1,arenaNo,i);
% %     plot(squeeze(aPos(i,1,:)),squeeze(aPos(i,2,:)));
% %     title(['Arena #', num2str(i)]);
% %     axis image;
% %     axis off;
% % end
% % if exist([outDir,FN,'_traces.png'],'file')
% %     saveas (h, [outDir,FN,'_traces.png']);
% % else
% %     saveas (h, [outDir,FN,'_loco.png']);
% % end
% % 
% % close(gcf);clear h;
% sleep ploting
% if sleepTog
    thresholdLoco = 10/ppm; % threshold in mm by the standard of 10 pixel per 10s.
    [SSb,SS,h,h1,S]= Vsleep_score(Disb,thresholdLoco,binSize,1800,initialTime);
    figure(h);subtitle(FNn);

    if exist([outDir,FNn,'_Sleep.png'],'file')
        saveas (h, [outDir,FNn,'_Sleep(1).png']);
    else
        saveas (h, [outDir,FNn,'_Sleep.png']);
    end
    
    [Pdoze,Pwake,h2]= Vsleep_Probability(Disb,thresholdLoco,binSize);
    figure(h2);subtitle(FNn);
    saveas (h2, [outDir,FNn,'_Probability.png']);
    
    close(h);close(h1);close (h2);
    clear h h1 h2;

figure(hw);
waitbar(3/4,hw,{'Arenas and flies detected';...
                ['Tracking was done in ',elap];...
                'data ploted';...
                'saving meta data...'},...
                'name','Tracking status');
            pause(1);
%     save([outDir,FN,'.mat']);
% end

%
% h = figure('position',[0 0 1500 800]);
% plot(Disb','LineWidth',1);%,'Color',[.5,.5,.5]);
% hold on;errorbar((1:binNo),mean(Disb)',nansem(Disb',2),'-ob','LineWidth',2);
% ylabel({'Walking distance';'(pixel)'});
% xlabel({'Time';['binSize:',num2str(binSize),'s']});
% saveas (h, [outDir,FN,'_walkingDistance_mean.png']);
% close(gcf);
% clear h;
%

save([outDir,FNn,'.mat'],'-regexp', '^(?!(hw)$).');
disp(['data saved to:',outDir,FNn,'.mat']);

figure(hw);
waitbar(4/4,hw,{'Arenas and flies detected';...
               ['Tracking was done in ',elap];...
                'data ploted';...
                'meta data saved';
                'done'},...
                'Tracking status');
pause(3);
close(hw);
           
