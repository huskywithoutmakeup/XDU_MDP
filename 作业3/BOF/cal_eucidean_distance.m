function [distance] = cal_eucidean_distance( object1, object2 )
% DO_EUCIDEAN_DISTANCE  ������������ά������ŷ�Ͼ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT  --������ά����
% OUTPUT --ŷ�Ͼ���

results = (object1-object2).^2;
distance = sqrt(sum(results));


