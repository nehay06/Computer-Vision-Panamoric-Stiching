# Computer-Vision-Panamoric-Stiching
The input to the algorithm are two images which are related by an unknown transformation. Blobs detector  is implemented
to extract keypoints and extract feature descriptors on them. The goal is to estimate an affine transformation using feature matching and RANSAC to produce a combined image.
The overall steps in the alignment algorithm are:
1. Detect keypoints in each image 
2. Extract SIFT features at each detected keypoints.
3. Match features based on pairwise distance.
4. Use RANSAC to estimate the best affine transformation.
5. Stitch the two images using the estimated transformation.


There are few difficult test images where affine transformation will not produce perfect results. There
are certain kinds of 2D transformation cannot be modeled as affine (See section 2.1 in Richard Szeliski’s
book). Implemented method to align two images with homography transformation, which is more general than affine,
to improve the results.

Download the repository and execute evalStiching.m The file provides provision to  estimate both affine and homography transformation. You can change the arguments to function call ransac and mergerImages. 
