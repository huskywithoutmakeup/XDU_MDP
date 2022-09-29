
%选择待检索图片
testImg_file = './corel/4';
testImg_name = '/402.jpg';
image = imread([testImg_file testImg_name]);
figure(1);
imshow(image);

%提取待检索图片SIFT特征
[~,q_descr,~,~ ] = do_sift([testImg_file testImg_name], 'Verbosity', 1, 'NumOctaves', 4, 'Threshold',  0.1/3/2 ) ;

%选择聚类个数
K=70;

% 提取图片库中所有图片的SIFT特征
[img_paths,Feats] = get_sifts('./img_paths.txt');

% 在所有SIFT特征种随机选取K个初始类心
initMeans = Feats(randi(size(Feats,1),1,K),:);

% 根据生成的初始类心对所有SIFT特征进行聚类,生成视觉词典
[Vocabulary] = K_Means2(Feats,K,initMeans);

% 统计图片库每张图片每个聚类中特征点个数，每张图片对应一个K维向量，频率直方图
[countVectors] = get_countVectors(Vocabulary,K,size(img_paths,1));

% 统计待检索图片每个聚类中特征点个数，得到一个K维向量
[queryVector] = get_distVector(Vocabulary,K,q_descr');

% 根据余弦相似定理，求带检索图片与图片库中所有图片的余弦相似度
cosValues = zeros(1,size(img_paths,1));
for N =1:size(img_paths,1)
        dotprod = sum(queryVector .* countVectors(N,:));
        dis = sqrt(sum(queryVector.^2))*sqrt(sum(countVectors(N,:).^2));
        cosin = dotprod/dis;
        cosValues(N) = cosin;
end

% 对余弦相似性进行排序
[vals,index] = sort(acos(cosValues));


% 输出匹配度最高的10张图片
figure(2);
c=0;
% show picture at host
for id = 1:10
    path = img_paths{index(id)};
    image = imread(path);
    subplot(1,10,id);
    imshow(image);
end

disp(index(1:10))
        
        