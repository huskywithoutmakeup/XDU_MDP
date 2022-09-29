function [ Vocabulary ] = K_Means( Feats, K , initMeans )
%K_MEANS 聚类，根据给的所有特征，聚类个数以及初始类心，对所有特征进行聚类，并返回结果

% 设定初始质心 value，第K类的数据data，第K类共有的数据个数count
for n = 1:K
    Vocabulary(n).value = initMeans(n,1:128); 
    Vocabulary(n).data = initMeans(n,:);
    Vocabulary(n).count = 1;
end

% 对于图片中所有的SIFT特征进行K均值聚类
for N=1:size(Feats,1) % 401896
    min = cal_eucidean_distance(Feats(N,(1:128)),Vocabulary(1).value); % 计算与第1类质心的欧式距离
    num = 1;
    for M=2:K
        distance = cal_eucidean_distance(Feats(N,(1:128)),Vocabulary(M).value); % 计算与第K类质心的欧式距离
        if(distance<min)
            min = distance;
            num = M;
        end
    end
    Vocabulary(num).data = [Vocabulary(num).data;Feats(N,:)];
    Vocabulary(num).value = Vocabulary(num).value * Vocabulary(num).count+ Feats(N,1:128);
    Vocabulary(num).count = Vocabulary(num).count+1;
    Vocabulary(num).value = Vocabulary(num).value / Vocabulary(num).count; 
end

end

