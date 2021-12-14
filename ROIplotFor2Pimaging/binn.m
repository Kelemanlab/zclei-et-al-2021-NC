function outi = binn(inpi,ds,di)
% 1-D binning
% inpi: imput data
% ds: binning size
% di: dimension
ds = uint16(ds);
if nargin<3
    di = 1;
else
    di_or = 1:length(size(inpi));
    di_tar = di_or;
    di_tar(di_tar==di) =1;
    di_tar(1) = di;
    inpi = permute(inpi,di_tar);
end
    
    [orw, orl, c]=size(inpi);
    
    
    res = double(rem(orw,ds));
    fiw=(orw-res)/double(ds);
    
%     outi=zeros(fiw,orl,c);
 
 
    
    ori=reshape(inpi(1:end-res,:),ds,fiw,orl,c);
    
    ori=squeeze(nansum(ori));
    if res>1
        last = squeeze(nansum(inpi(end-res+1:end,:)));
        ori = [ori;last];
    end
    
    if di==1
        outi = ori;
    else
        outi=permute(ori,di_tar);
    end
    
    clear orw orl fil c i;
    
    return
 
   
    
        
    
    
    
    
    
    
    
    
    
    
    
    
  
    