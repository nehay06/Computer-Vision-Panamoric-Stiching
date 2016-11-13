
imageName = 'sunflowers.jpg';
numBlobsToDraw = 1000;
imName = imageName(1:end-4);

dataDir = fullfile('..','data','blobs');
outDir = fullfile('..', 'outputblob');

if ~exist(outDir, 'file')
    mkdir(outDir);
end
im = imread(fullfile(dataDir, imageName));


%% Implement the code to detect blobs here
blobs = detectBlobs(im);
%% Draw blobs on the image
[H]= drawBlobs(im, blobs, numBlobsToDraw);
title(strcat('Blob detection ->>',imageName));
saveas(H,fullfile(outDir, strcat(imageName)));