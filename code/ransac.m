function [inliers, transf] = ransac(matches, c1, c2, method)

[inputM,cols,baseM] = find(matches);
maxInliers = 0;
originalIndices = find(matches);
Msize = size(inputM,1);
if nargin< 4
    method = 'affine';
end

if strcmp(method,'affine')
    basePoints = zeros(Msize,2);
    inputPoints = zeros(Msize,2);
    threshold = 4;
    iterations = 35;
    best_model = zeros(2,3);  
    inliersInfo = zeros(Msize,2);
    transInfo = zeros(2,3,Msize);
    for ind= 1:Msize
        basePoints(ind,1) = c1(inputM(ind),1);
        basePoints(ind,2) = c1(inputM(ind),2);
        inputPoints(ind,1) = c2(baseM(ind),1);
        inputPoints(ind,2) = c2(baseM(ind),2);
    end
    
    for itr = 1:iterations
        T = computeAffine(basePoints,inputPoints);
        trans = [reshape(T,[3,2])';0,0,1];
        inputPt = [basePoints';ones(1,Msize)];
        inputptF =  trans*inputPt;
        calPoints = inputptF(1:2,:);
        dist = calculateError(calPoints,inputPoints');
        [rows,cols,error] = find(dist.*(dist < threshold));
        inliersCount = size(cols,2); 
        total_error = sum(error,2);
        if inliersCount > round(0.10*Msize) && inliersCount >= maxInliers && inliersCount ~= Msize
           
           best_model = reshape(T,[3,2])';           
           if(inliersCount == maxInliers)
                 maxIndex = find(inliersInfo(:,1) == maxInliers);
                 if(total_error < inliersInfo(maxIndex,2))
                    best_model = reshape(T,[3,2])';
                 end
           end
           inliersC = cols';
           maxInliers= inliersCount;
           inliersInfo(itr,1)=maxInliers ;
           inliersInfo(itr,2)= total_error;
           transInfo(:,:,itr) = best_model;
        end      
    end
    fprintf('Maximum Inliers %d and Msize is %d',maxInliers,Msize);
    transf = [inv(best_model(:,1:2)),-1*best_model(:,3)];
    inliers = originalIndices(inliersC);
    disp('Affine Transformation is:')
    disp(transf)   
end

if strcmp(method, 'homography')
    xBase = zeros(Msize,1);
    yBase = zeros(Msize,1);
    xInput = zeros(Msize,1);
    yInput = zeros(Msize,1);
    for i= 1:Msize
        xBase(i,1) = c1(inputM(i),1);
        yBase(i,1) = c1(inputM(i),2);
    end
    
    for i= 1:Msize
        xInput(i,1) = c2(baseM(i),1);
        yInput(i,1) = c2(baseM(i),2);
    end
    for i = 1:10000
        
        randBase = zeros(4,2);
        randInput = zeros(4,2);
        
        for j = 1:4
            index = ceil(rand*(Msize-1))+1;
            randBase(j,1) = xBase(index);
            randBase(j,2) = yBase(index);
            randInput(j,1) = xInput(index);
            randInput(j,2) = yInput(index);
            
        end
        
        h = computeHomography(randInput(:,1),randInput(:,2), ...
            randBase(:,1),randBase(:,2));
        
        [x,y] = applyHomography(inv(h),xBase,yBase);
        total = 0;
        for j = 1:numel(x)
            sigma = 100;
            error = sum(sum(([xInput(j) yInput(j)] - [x(j) y(j)]).^2));
            
            if  error < sigma
                total = total + 1;
            end
            
        end
        
        if total > maxInliers
            
            maxInliers = total;
            H = h;
            
        end
    end
    transf = H;
    inliers = [];
end
end
function [x2, y2] = applyHomography(H, x1,y1)
p(1,:) = x1(:);
p(2,:) = y1(:);
p(3,:) = 1;

x2 = H(1,:) * p;
y2 = H(2,:) * p;
thd  = H(3,:) * p;

x2 = x2 ./ thd;
y2 = y2 ./ thd;
end
function [H] = computeHomography(x1,y1,x2,y2)
num = numel(x1);
H = ones(3);
eq = zeros(num*2, 8);
sol = zeros(num*2,1);
for i =1:num
    pts1 = [x1(i),y1(i),1];
    z = [0, 0, 0];
    rem = (-1 * [x2(i);y2(i)]) * [x1(i),y1(i)];
    sol((i-1)*2+1:(i-1)*2+2) = [x2(i); y2(i)];
    eq ((i-1)*2+1:(i-1)*2+2,:) = [[pts1, z;z, pts1] rem];
end

H = eq\sol;

H(9) = 1;
H = reshape(H,3,3)';
end
function [dist]= calculateError(calPoints,FinputPoints)
dist = sum((calPoints-FinputPoints).^2);
end

function [Transform] = computeAffine(basePoints,transPoints)
baseP = zeros(6,6); % input points 
transP = zeros(6,1); % points after transformation of input points.
for j = 1:3
    index = ceil(rand*(size(basePoints,1)-1))+1;
    baseP(2*j-1,:) = [basePoints(index,1),basePoints(index,2),1,0,0,0];
    baseP(2*j,:) = [0,0,0,basePoints(index,1),basePoints(index,2),1];
    transP(2*j-1,:) = transPoints(index,1);
    transP(2*j,:) = transPoints(index,2);
end
Transform = baseP\transP;
end
