function matches = computeMatches(f1,f2)
feature1Size = size(f1,1);
feature2Size = size(f2,1);

%% Computing Matches using SSD
matches = zeros(feature1Size,1);
tic
if 0
fprintf('Computing matching using SSD...\n');
for i= 1:feature1Size
   bestMatch = inf;
   for j =1:feature2Size
        match = sum(sum((f1(i,:)-f2(j,:)).^2));
        if(match<bestMatch)
           matches(i) = j;
           bestMatch = match;
        end
   end
end
toc
end
%% Computing Matches using ratio
if 1
% For each descriptor in the first image, select its match to second image.
for i = 1 : feature1Size
    bestMatch = inf;
    secondMatch = inf;
    index = inf;
    for j = 1:feature2Size
        match = sum(sum((f1(i,:)-f2(j,:)).^2));
        if(match < bestMatch)
            secondMatch = bestMatch;
            bestMatch = match;
            index = j;
        else if(match < secondMatch && match ~= bestMatch)
                secondMatch = match;
            end
        end
    end
    ratio = bestMatch/secondMatch;
    if(~isequal(index,inf) && ratio < 0.8)
        matches(i)= index;
    else
        matches(i) = 0;
    end
end
end