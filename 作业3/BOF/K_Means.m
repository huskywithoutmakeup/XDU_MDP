function [ Vocabulary ] = K_Means( Feats, K , initMeans )
%K_MEANS ���࣬���ݸ���������������������Լ���ʼ���ģ��������������о��࣬�����ؽ��

% �趨��ʼ���� value����K�������data����K�๲�е����ݸ���count
for n = 1:K
    Vocabulary(n).value = initMeans(n,1:128); 
    Vocabulary(n).data = initMeans(n,:);
    Vocabulary(n).count = 1;
end

% ����ͼƬ�����е�SIFT��������K��ֵ����
for N=1:size(Feats,1) % 401896
    min = cal_eucidean_distance(Feats(N,(1:128)),Vocabulary(1).value); % �������1�����ĵ�ŷʽ����
    num = 1;
    for M=2:K
        distance = cal_eucidean_distance(Feats(N,(1:128)),Vocabulary(M).value); % �������K�����ĵ�ŷʽ����
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

