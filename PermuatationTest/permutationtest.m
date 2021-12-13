function [ptResult,ptHeader,ptTable] = permutationtest(SimRounds,...
    Naive,Trained,NaiveCtrl,TrainedCtrl)
% same argorithem with permutationtest.pl
 
if isempty(SimRounds)
    SimRouns = 10000;
end

if SimRounds > 1000000
    SimRouns = 1000000;
end

if nargin<5
    NaiveCtrl = [];
    TrainedCtrl = [];
end

% remove notNumbers
Naive(isnan(Naive))=[];
Trained(isnan(Trained))=[];

NaiveCtrl(isnan(NaiveCtrl))=[];
TrainedCtrl(isnan(TrainedCtrl))=[];

% element numbers in each groups.
N_Naive = length(Naive);
N_Trained = length(Trained);
N_NaiveCtrl = length(NaiveCtrl);
N_TrainedCtrl = length(TrainedCtrl);

% run the simulation if (after removing inputs that are not numbers) 
% there are still numbers left in each group
if N_Naive && N_Trained
    Naive = Naive(:);
    Trained = Trained(:);
    NaiveCtrl = NaiveCtrl(:);
    TrainedCtrl = TrainedCtrl(:);
    
    all = [Naive; Trained];
    expLImedian = 1-median(Trained)./median(Naive);
    expLI = 1-mean(Trained)./mean(Naive);
    
    CtrlProvided = 0;
    
    % set the variables needed to test against the Ctrl
	eqSupportedCountMedian = 0;	% how often H0: LIexpt==LIcont is supported
	leSupportedCountMedian = 0;	% how often H0: LIexpt<=LIcont is supported
	geSupportedCountMedian = 0;	% how often H0: LIexpt>=LIcont is supported


	eqSupportedCount = 0;	% how often H0: LIexpt==LIcont is supported
	geSupportedCount = 0;	% how often H0: LIexpt<=LIcont is supported
	leSupportedCount = 0;	% how often H0: LIexpt>=LIcont is supported
    
    
    if (N_NaiveCtrl && N_TrainedCtrl)
        
        CtrlProvided = 1;
        allCtrl = [NaiveCtrl; TrainedCtrl];
        
        CtrlLImedian = 1-median(TrainedCtrl)./median(NaiveCtrl);
        deltaLImedian = expLImedian - CtrlLImedian;
        
        CtrlLI = 1-mean(TrainedCtrl)./mean(NaiveCtrl);
        deltaLI = expLI - CtrlLI;
        % these arrays are needed for shuffling
        allNaive = [Naive; NaiveCtrl];
        allTrained = [Trained; TrainedCtrl];
        
    end
    
	 exceededCountMedian = 0;
	 exceededCount = 0;
	
     for i=1:SimRounds 
		all = all(randperm(N_Naive+N_Trained));
                
		perLImedian = 1-median(all(N_Naive+1:end))./median(all(1:N_Naive));
        if (expLImedian <= perLImedian)
            exceededCountMedian=exceededCountMedian+1;
        end
        
        perLI = 1-mean(all(N_Naive+1:end))./mean(all(1:N_Naive));
        if (expLI <= perLI)
            exceededCount=exceededCount+1;
        end
        
        if (CtrlProvided)
            allNaive = allNaive(randperm(N_Naive+N_NaiveCtrl));
            allTrained = allTrained(randperm(N_Trained+N_TrainedCtrl));
            permutedAll = [allNaive(1:N_Naive); allTrained(1:N_Trained)];
            permutedAllCtrl = [allNaive(N_Naive+1:end); allTrained(N_Trained+1:end)];
            
            perLI12Median = 1-median(permutedAll(N_Naive+1:end))./median(permutedAll(1:N_Naive));%LImedian(\permutedAll, N_Naive);
            perLI34Median = 1-median(permutedAllCtrl(N_NaiveCtrl+1:end))./median(permutedAllCtrl(1:N_NaiveCtrl));%LImedian(\permutedAllCtrl, N_NaiveCtrl);
            permutationDeltaLImedian = perLI12Median - perLI34Median;
            
            if (abs(permutationDeltaLImedian) >= abs(deltaLImedian))
                eqSupportedCountMedian=eqSupportedCountMedian+1;
            end
            if (permutationDeltaLImedian >= deltaLImedian)
                leSupportedCountMedian=leSupportedCountMedian+1 ;
            end
            if (permutationDeltaLImedian <= deltaLImedian)
                geSupportedCountMedian=geSupportedCountMedian+1;
            end
            
            perLI12 = 1-mean(permutedAll(N_Naive+1:end))./mean(permutedAll(1:N_Naive));%LImedian(\permutedAll, N_Naive);
            perLI34 = 1-mean(permutedAllCtrl(N_NaiveCtrl+1:end))./mean(permutedAllCtrl(1:N_NaiveCtrl));%LImedian(\permutedAllCtrl, N_NaiveCtrl);
            permutationDeltaLI = perLI12 - perLI34;
            
            if (abs(permutationDeltaLI) >= abs(deltaLI))
                eqSupportedCount=eqSupportedCount+1;
            end
            if (permutationDeltaLI >= deltaLI)
                leSupportedCount=leSupportedCount+1 ;
            end
            if (permutationDeltaLI <= deltaLI)
                geSupportedCount=geSupportedCount+1;
            end

        end
     end
    
    % writing results
    ptTable.LI_expByMedian = round(100*expLImedian,2);
    ptTable.p_expByMedian = exceededCountMedian / SimRounds;
    
    ptTable.LI_expByMean = round(100*expLI,2);
    ptTable.p_expByMean = exceededCount / SimRounds;
    
    ptTable.p_expByRanksum = ranksum(Naive,Trained);  % Mann-Whitney-Wilcoxon
    
    
    ptTable.LI_CtrlByMedian = nan;
    ptTable.LI_CtrlByMean = nan;
    ptTable.p_ctrlByRanksum = nan;
    ptTable.p_EC_equalMedian = nan;
    ptTable.p_EC_smallerMedian = nan;
    ptTable.p_EC_greaterMedian = nan;
    ptTable.p_EC_equalMean = nan;
    ptTable.p_EC_smallerMean = nan;
    ptTable.p_EC_greaterMean = nan;
    if (CtrlProvided)
        
        ptTable.LI_CtrlByMedian = round(100*CtrlLImedian,2);
        ptTable.LI_CtrlByMean = round(100*CtrlLI,2);
        ptTable.p_ctrlByRanksum = ranksum(NaiveCtrl,TrainedCtrl);% Mann-Whitney-Wilcoxon
        
        ptTable.p_EC_equalMedian = eqSupportedCountMedian / SimRounds;
        ptTable.p_EC_smallerMedian = leSupportedCountMedian / SimRounds;
        ptTable.p_EC_greaterMedian = geSupportedCountMedian / SimRounds;
        
        ptTable.p_EC_equalMean = eqSupportedCount / SimRounds;
        ptTable.p_EC_smallerMean = leSupportedCount / SimRounds;
        ptTable.p_EC_greaterMean = geSupportedCount / SimRounds;
        ptHeader = {'LI expByMedian(%)','p expByMedian','LI expByMean(%)','p expByMean','p expByRanksum',...
                    'LI CtrlByMedian(%)','LI CtrlByMean(%)','p CtrlByRanksum',...
                     'p E==C byMedian','p E=<C byMedian','p E>=C byMedian',...
                     'p E==C byMean','p E=<C byMean','p E>=C byMean'};
        ptHeader = ptHeader';
    else
        ptHeader = {'LI by median(%)','LI by mean(%)','p by median','p by mean','p by ranksum'};
        ptHeader = ptHeader';
    end
    
  

   ptResult = struct2cell(ptTable);
   ptResult = cell2mat(ptResult);
end
