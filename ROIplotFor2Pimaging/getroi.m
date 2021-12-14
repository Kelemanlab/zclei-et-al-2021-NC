function roi=getroi(workingImage,roiNumber)

if nargin<1
    prompt = {'Total ROI Number:', 'Perform ROI selection on which image (Figure No. XX):'};
    dlg_title = 'Inputs for mmROI function';
    num_lines = 1;
    def = {'1','1'};
    inputs  = str2num(char(inputdlg(prompt, dlg_title, num_lines, def)));
    if isempty(inputs)
        roi=[];
        return
    end
    roiNumber = inputs(1);
    workingImage = inputs(2);
end
% generate a jet colormap according to roiNumber
% clrMap = jet(roiNumber);
% rndprm = randperm(roiNumber);

hold on;

for i=1:roiNumber
    figure(workingImage);
    [roi(i).x, roi(i).y, roi(i).BW, roi(i).xi, roi(i).yi] = roipoly;
    xmingrid = max(roi(i).x(1), floor(min(roi(i).xi)));
    xmaxgrid = min(roi(i).x(2), ceil(max(roi(i).xi)));
    ymingrid = max(roi(i).y(1), floor(min(roi(i).yi)));
    ymaxgrid = min(roi(i).y(2), ceil(max(roi(i).yi)));
    roi(i).xgrid = xmingrid : xmaxgrid;
    roi(i).ygrid = ymingrid : ymaxgrid;
    [X, Y] = meshgrid(roi(i).xgrid, roi(i).ygrid);
    inPolygon = inpolygon(X, Y, roi(i).xi, roi(i).yi);
    Xin = X(inPolygon);
    Yin = Y(inPolygon);
        
    roi(i).area = polyarea(roi(i).xi,roi(i).yi);
    roi(i).center = [mean(Xin(:)), mean(Yin(:))];
    
    figure(workingImage);
    hold on; 
%     plot(roi(i).xi,roi(i).yi,'Color',clrMap(rndprm(i), :),'LineWidth',1);
%     text(roi(i).center(1), roi(i).center(2), num2str(i),...
%          'Color', clrMap(rndprm(i), :), 'FontWeight','Bold');
    plot(roi(i).xi,roi(i).yi,'--r','LineWidth',2);
    text(roi(i).center(1), roi(i).center(2), num2str(i),...
         'Color', 'r', 'FontWeight','Bold');
end

return
