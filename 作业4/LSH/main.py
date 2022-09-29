# -*- coding:utf-8 -*-

import LSH
import numpy as np
import pandas as pd
import time


def euclideanDistance(v1, v2):
    v1, v2 = np.array(v1), np.array(v2)
    return np.sqrt(np.sum(np.square(v1 - v2)))


if __name__ == "__main__":
    # 读取数据集
    data = pd.DataFrame(pd.read_csv('corel', header=None, index_col=0, sep=' '))
    allDataSet = np.array(data.iloc[:].values)
    dataSet = allDataSet
    # 读取前1000个查询的正确查询
    df = pd.DataFrame(pd.read_csv('right_num.csv', header=None, index_col=0))
    dist_all = np.array(df.iloc[:].values)[1:1001]
    for i in range(1000):
        for j in range(10):
            dist_all[i][j] = format(dist_all[i][j], '.15f')

    # 设置LSH参数
    k, L, r, tableSize = 10, 3, 2, 20

    hashTable, hashFuncGroups, LbRand = LSH.LSH(dataSet, k, L, r, tableSize)
    C = pow(2, 32) - 5

    time_sum = 0
    right_num = 0
    length_sum = 0

    # LSH搜索过程
    for i1 in range(1000):
        print(i1)
        query = allDataSet[i1]  # 查询内容
        # ————————————————————————————————————
        # LSH算法求得的最近的10个样本，不包括自身
        # 与查询近似的桶内样本
        indexes = set()
        for hashFuncGroup in hashFuncGroups:
            # 获取查询的标签
            queryLb = LSH.Label(LSH.get_HashVals(hashFuncGroup, query, r), LbRand, k, C)
            # 获取哈希表中查询的索引
            queryIndex = queryLb % tableSize
            # 在字典中找到bucket
            if queryLb in hashTable[queryIndex].buckets:
                indexes.update(hashTable[queryIndex].buckets[queryLb])

        # 时间测量
        start = time.perf_counter()

        dist_lsh = []
        for j in indexes:
            temp = euclideanDistance(dataSet[j], query)
            dist_lsh.append(temp)
        end = time.perf_counter()
        length_sum += len(dist_lsh)
        sorted_nums_lsh = sorted(enumerate(dist_lsh), key=lambda x: x[1])
        idx_lsh = [i[0] for i in sorted_nums_lsh]
        nums_lsh = [float(format(i[1], '.15f')) for i in sorted_nums_lsh]

        time_sum += (end - start)
        print(set(dist_all[i1]))
        print(set(nums_lsh[1:11]))
        print(len(set(nums_lsh[1:11]) & set(dist_all[i1])))
        print()
        right_num += len(set(nums_lsh[1:11]) & set(dist_all[i1]))

    # ————————————————————————————————————
    # 计算用时
    print("平均查找长度 = ")
    print(float(length_sum / 1000))
    print('Running time: %s Seconds' % time_sum)

    # ————————————————————————————————————
    # 计算精度,召回率
    print("精度 = 召回率= ")
    print(right_num/10000)




