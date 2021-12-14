

[FN,PN] = uigetfile('*.tif','Select the TIF file',...
    'D:\','multiselect','on');
FN = FN';
fnNo = size(FN,1);
% outDir = 'G:\2_LISleep\LTM\SP_vFB\b2\20191118\';
dataSet = 'demo';

outDir = uigetdir('D:\');
   if ~exist([outDir,'\pooled'],'dir')
       mkdir([outDir,'\pooled']);
   end
   if ~exist([outDir,'\singles'],'dir')
        mkdir([outDir,'\singles']);
   end
   outDir = [outDir,'\'];
%% go through each image stack
for i = 1:fnNo
%     im = mijread([PN,FN{i}]);
    roiNo = 3;
    im = load1p([PN,FN{i}]);
    ref = mean(im,3);
    h = figure('position',[100 200 1600 800]);imagesc(ref);axis image;axis off;
    hold on;title(FN{i},'interpreter','none');
    roi = getroi(h,roiNo);
    roiNo = size(roi,2);
    
    saveas (h, [outDir,'singles\',FN{i}(1:end-4),'_ROIs.png']);
    
    T = bot(im,roi);
    ht = figure('position',[100 200 1600 800]);
    plot(T);
    saveas (ht, [outDir,'singles\',FN{i}(1:end-4),'_Traces.png']);
    
    pause(.5);
    close all; delete h ht;
    save([outDir,'singles\',FN{i}(1:end-4),'.mat']);
    disp(['done ', num2str(i)]);
end

save([outDir,dataSet,'.mat']);
%%


FNmtx = cellfun(@(x)strsplit(x,'_'),FN,'uniformoutput',false);
FN_n = size(FN,1);
FNmtx = reshape([FNmtx{:}],[],FN_n);
FNmtx = FNmtx';

[genoName,~,genoIdx]=unique(FNmtx(:,2));
   genoNo = size(genoName,1);
     % find dmd rois
%      
%    [dmdName,~,dmdIdx] = unique(FNmtx(:,8));
%    dmdNo = size(dmdName,1);

  % find treatments
  trmInfo = cellfun(@(x)x(3),FNmtx(:,4),'uni',0);
  [trmName,~,trmIdx]= unique(trmInfo);
  trmNo = size(trmName,1);
  % put naive group ahead of trained group
  trmName = flip(trmName);
  trmIdx = 3-trmIdx;
  
   % stimulation protocol
%    [stiName,~,stiIdx] = unique(FNmtx(:,6));
%    stiNo = size(stiName,1);
%%
Trace = T;
Tm = squeeze(nanmean(Trace));
% dF = Trace./repmat(mean(Trace(1:120,:,:),1),800,1,1)-1;
% dF = 100.*dF;
[nt,nr,nf]=size(Trace);
% 3 rois
Traceb = Trace(:,1:2,:)-Trace(:,3,:);
Tbm = squeeze(nanmean(Traceb));
% dFb = Trace./repmat(mean(Trace(1:120,:,:),1),800,1,1)-1;;
roiNamesS = {'vFB','DAN-bp1'};%,'background'};
roiNo = size(roiNamesS,2);
save([outDir,dataSet,'.mat']);
exIdx = zeros(FN_n,1);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% pooling data by ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot full traces for each roi

for i = 1:genoNo
    curGeno = genoName{i,1};
    
    for j = 1:trmNo
        curTrm = trmName{j,1};
                   
            curIdx = (genoIdx==i & trmIdx==j & ~exIdx);
            curData = Trace (:,:,curIdx);
            if isempty(curData)
                continue
            end
            
            % plot dFb traces of each ROI
            for ii = 1: roiNo
                curRoi = roiNamesS{ii};
                temp = squeeze(curData(:,ii,:));
                curGroupName = [dataSet,'_',curGeno,'_',curRoi,'_',curTrm];
                pngSavePooled = [outDir,'\pooled\',curGroupName,'_Trace'];
                h = Traceplot_kk(temp,'Trace',curGroupName,[],[],[],'invisivble');
                saveas(h,pngSavePooled,'-png');
                clear h;

            end
    end
        

end
disp('done');





