function blobs = detectBlobs(im, param)

% Input:
%   IM - input image
%
% Ouput:
%   BLOBS - n x 4 array with blob in each row in (x, y, radius, score)
%
% Dummy - returns a blob at the center of the image

if size(im,3)>1
    im = mean(im,3)/255;
end;

sigma = 1.6;
k = sqrt(2);
sigma_final = power(k,16);
n = ceil((log(sigma_final) - log(sigma))/log(k)); 
[h, w] = size(im); 
scaleSpace = zeros(h, w, n);

% generate the Laplacian of Gaussian for the first scale level
filt_size = 2*ceil(3*sigma)+1; 
LoG =  sigma^2 * fspecial('log', filt_size, sigma);

if 1 % Faster version: keep the filter size, downsample the image
imRes = im;
for i = 1:n
    imFiltered = imfilter(imRes, LoG, 'same', 'replicate');
    imFiltered = imFiltered .^ 2;   
    scaleSpace(:,:,i) = imresize(imFiltered, size(im), 'bicubic');
    if i < n        
        imRes = imresize(im, 1/(k^i), 'bicubic');
    end
end

end;

% Slower version: increse filter size, keep image the same
if 0
    scaleSpace2 = zeros(h, w, n);
    for i = 1:n
        sigmai = sigma * k^(i-1);
        
        filt_size = 2*ceil(3*sigmai)+1;  
        LoG       =  sigmai^2 * fspecial('log', filt_size, sigmai);   
        imFiltered = imfilter(im, LoG, 'same', 'replicate'); 
        imFiltered        = imFiltered .^ 2; 
        scaleSpace2(:,:,i) = imFiltered;      
        
    end
    scaleSpace = scaleSpace2;
end;

% perform non-maximum suppression for each scale-space slice
supprSize = 3;
maxSpace = zeros(h, w, n);
for i = 1:n
    maxSpace(:,:,i) = ordfilt2(scaleSpace(:,:,i), supprSize^2, ones(supprSize));
end

% non-maximum suppression between scales and threshold

for i = 1:n
    maxSpace(:,:,i) = max(maxSpace(:,:,max(i-1,1):min(i+1,n)),[],3);
end
maxSpace = maxSpace .* (maxSpace == scaleSpace);

r = [];   
c = [];   
rad = [];
val = [];
for i=1:n
    [rows, cols,value] = find(maxSpace(:,:,i).*(maxSpace(:,:,i) >= 0.009));
    numBlobs = length(rows);
    if(numBlobs >0)
        radii =  sigma * k^(i-1) * sqrt(2); 
        radii = repmat(radii, numBlobs, 1);
        r = [r; rows];
        c = [c; cols];
        val = [val;value];
        rad = [rad; radii];
    end
end

blobs = [c,r,rad,val];
