      
function [h,sig] = plotCIV(gd,ptResult,ptHeader,Ntrm,NLI,savePath,DataSet,togeps,togxls)
col=@(x)reshape(x,numel(x),1);
boxplot2=@(C,varargin)boxplot(cell2mat(cellfun(col,col(C),'uni',0)),...
    cell2mat(arrayfun(@(I)I*ones(numel(C{I}),1),col(1:numel(C)),'uni',0)),varargin{:});

CI = {gd.EN.CI,gd.ET.CI,gd.CN.CI,gd.CT.CI};
CImed = round([gd.EN.med,gd.ET.med,gd.CN.med,gd.CT.med],2);
CImea = round([gd.EN.mea,gd.ET.mea,gd.CN.mea,gd.CT.mea],2);
CIsem = round([gd.EN.sem,gd.ET.sem,gd.CN.sem,gd.CT.sem],2);
CIbox = CI;
LI = round([ptResult(1),ptResult(6)],2);
trmNo = length(Ntrm);
sig = sigCheck_multigroups(CI);

ttag = datestr(now,30);
CIn = zeros(1,4);
for i=1:4
    if ~isempty(CIbox{i})
        CIn(i) = length(CIbox{i});
    else
        CIbox{i} = nan;
    end
end
h=figure('Position',[100 100 1400 800],'color',[1 1 1]);
        subplot(4,2,[1,3,5]);
        hold on; boxplot2(CIbox);box off;
        title('');
        titleObj = get(gca,'title');
        titleY = titleObj.Position(2);
        for i=1:4
            text(i,titleY,{num2str(CImed(i));['n=',num2str(CIn(i))]},...
                'HorizontalAlignment','center');
        end
        xticks(1:trmNo);
        xlim([0 4.5]);
        set(gca,'xticklabel',Ntrm,'TickLabelInterpreter','none');
        ylabel('CIs');
        hold on;subplot(4,2,7);plot(1);
        pos = get(subplot(4,2,7),'position');
        delete(subplot(4,2,7));
        tb = uitable(h);
        set(tb,'Data',sig.R,...
            'ColumnName',Ntrm,...
            'RowName',Ntrm);
        set(tb,'units','normalized');
        set(tb,'position',pos);
        hold on; subplot(4,2,7);text(0,1.1,'Ranksum');axis off;
        
        subplot(4,2,[2,4,6]);
        hold on; bar(LI);
        xlim([0 3]);
        xticks((1:2));
        xticklabels(NLI);
        xlabel({['p(exp by median) = ',num2str(ptResult(2))];...
            ['p(ctrl by median) = ',num2str(ptResult(7))];...
            ['p(LI_E = LI_C by median) = ',num2str(ptResult(11))];...
            ['p(LI_E = LI_C by mean) = ',num2str(ptResult(14))]},'interpreter','none');
        ylabel('LI(%)');
        title(['LI = ',num2str(LI)]);
        subtitle(DataSet);
    
        if togeps
            saveas(h,[savePath,'\',DataSet,'_',ttag],'eps');
            saveas(h,[savePath,'\',DataSet,'_',ttag],'png');
        end
        
        % write data to xlsx file
        if togxls
            xlsxFile = [savePath,'\',DataSet,'_',ttag,'.xlsx'];
            xlswrite(xlsxFile,{'DataSet',DataSet});
            xlswrite(xlsxFile,ptHeader,1,'A4');
            writematrix(ptResult,xlsxFile,'Range','B4');
            xlswrite(xlsxFile,Ntrm,1,'E4');
            xlswrite(xlsxFile,{'CI median';'CI avg';'CI sem';'n';'CIs'},1,'D5');
            writematrix(round([CImed;CImea;CIsem;CIn],2),xlsxFile,'Range','E5');
            ciR ={'E9','F9','G9','H9','I9'};
            for iii = 1:trmNo
                writematrix(CI{iii},xlsxFile,'Range',ciR{iii});
            end
        end
%         clear h;
%         save([savePath,'\',DataSet,'_',ttag,'.mat']);
