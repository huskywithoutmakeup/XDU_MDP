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
    k, L, r, tableSize = 5, 3, 1, 15

    print(len(dataSet[0]))
    print(len(dataSet))

    # hashTable, hashFuncGroups, fpRand = LSH.e2LSH(dataSet, k, L, r, tableSize)
    # C = pow(2, 32) - 5
