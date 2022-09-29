%测试精确度
sum_num = 10000;
num = 0;


for i =1:1000
    cosValues = zeros(1,1000);
    qVector = countVectors(i,:);
    for k =1:1000
        temp = countVectors(k,:);
        dotprod = sum(qVector.*temp);
        dis = sqrt(sum(qVector.^2))*sqrt(sum(temp.^2));
        cosin = dotprod/dis;
        cosValues(k) = cosin;
    end

    [vals,Index] = sort(acos(cosValues));

    index = Index(1:10);

    for j = 1:10
        if floor((index(j)-1)/100)==floor((i-1)/100)
            num = num+1;
        end
    end
end

ac = num/sum_num;


disp(ac);
