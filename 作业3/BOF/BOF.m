
%ѡ�������ͼƬ
testImg_file = './corel/4';
testImg_name = '/402.jpg';
image = imread([testImg_file testImg_name]);
figure(1);
imshow(image);

%��ȡ������ͼƬSIFT����
[~,q_descr,~,~ ] = do_sift([testImg_file testImg_name], 'Verbosity', 1, 'NumOctaves', 4, 'Threshold',  0.1/3/2 ) ;

%ѡ��������
K=70;

% ��ȡͼƬ��������ͼƬ��SIFT����
[img_paths,Feats] = get_sifts('./img_paths.txt');

% ������SIFT���������ѡȡK����ʼ����
initMeans = Feats(randi(size(Feats,1),1,K),:);

% �������ɵĳ�ʼ���Ķ�����SIFT�������о���,�����Ӿ��ʵ�
[Vocabulary] = K_Means2(Feats,K,initMeans);

% ͳ��ͼƬ��ÿ��ͼƬÿ�������������������ÿ��ͼƬ��Ӧһ��Kά������Ƶ��ֱ��ͼ
[countVectors] = get_countVectors(Vocabulary,K,size(img_paths,1));

% ͳ�ƴ�����ͼƬÿ��������������������õ�һ��Kά����
[queryVector] = get_distVector(Vocabulary,K,q_descr');

% �����������ƶ����������ͼƬ��ͼƬ��������ͼƬ���������ƶ�
cosValues = zeros(1,size(img_paths,1));
for N =1:size(img_paths,1)
        dotprod = sum(queryVector .* countVectors(N,:));
        dis = sqrt(sum(queryVector.^2))*sqrt(sum(countVectors(N,:).^2));
        cosin = dotprod/dis;
        cosValues(N) = cosin;
end

% �����������Խ�������
[vals,index] = sort(acos(cosValues));


% ���ƥ�����ߵ�10��ͼƬ
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
        
        