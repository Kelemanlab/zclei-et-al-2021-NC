function sig = sigCheck_multigroups(st)%,tailTog)
% st: single mesearuse of groups stored in cell
% tailTog, -1, smaller
%           0, equal
%           1, bigger
% output in sig:
% sig.S single group checked with ttest if mean=0
% sig.T paired groups checked with ttest if they have equal means
% sig.R paired groups checked with ranksum test if they have equal median


% if nargin <2 || isempty(tailTog)
%      tailTog = 0;
% end
%  
 
      trmNo = size(st,2);
      stgg = [];
      sig.S = nan(trmNo,2);
      stm = [];
for i = 1:trmNo
    if ~isempty(st{i})
        sn(i) = length(st{i});
        stgg = [stgg;i.*ones(sn(i),1)];
        sig.S(i,1) = jbtest(st{i});
        [~,sig.S(i,2)] = ttest(st{i});
        sig.S(i,3) = signrank(st{i},0);
        stm = [stm;st{i}(:)];
    end
end
%    sig.S = round(sig.S,4);
      
             combs = nchoosek((1:trmNo),2);
             combn = size(combs,1);
              sig.T = nan(combn,1);
              sig.R = nan(combn,1);
             for j = 1:combn
                 A =  st{combs(j,1)};
                 B =  st{combs(j,2)};
                 if ~isempty(A)&&~isempty(B)
                     [~, sig.T(j)] = ttest2( st{combs(j,1)}, st{combs(j,2)});
                     [ sig.R(j),~] = ranksum( st{combs(j,1)}, st{combs(j,2)});
                 end
             end
             
%              if trmNo >2
                
%                  [ap,atbl,ast]=anova1(stm, stgg);
%                  [kp,ktbl,kst]=kruskalwallis(stm, stgg);
%                  
% %                  [ap,atbl,ast]=kruskalwallis(yy,aa);
%                  amc = multcompare(ast);
%                  sig.ANO = squareform(round(amc(:,6),4))+diag(ones(trmNo,1));
%                  kmc = multcompare(kst);
%                  sig.Krus = squareform(round(kmc(:,6),4))+diag(ones(trmNo,1));

%              end
%               sig.T = round( sig.T,4);
%               sig.R = round( sig.R,4);
              sig.T = squareform( sig.T) + diag(ones(trmNo,1));
              sig.R = squareform( sig.R) + diag(ones(trmNo,1));
%               pause(3);
%               close all;