# -*- coding:utf-8 -*-

import random
import numpy as np


class TableNode(object):
    def __init__(self, index):
        self.val = index
        self.buckets = {}


# 随机生成hash函数的a，b参数
def getPara(n, r):
    a = []
    for i in range(n):
        a.append(random.gauss(0, 1))
    b = random.uniform(0, r)

    return a, b


# 随机生成k个hash函数族的a，b参数
def get_k_para(n, k, r):
    result = []
    for i in range(k):
        result.append(getPara(n, r))

    return result


# 利用公式 H = (av+b)/r 求得k个hash值
def get_HashVals(k_para, v, r):
    hashVals = []

    for h_para in k_para:
        hashVal = (np.inner(h_para[0], v) + h_para[1]) // r
        hashVals.append(hashVal)

    return hashVals


def Label(hashVals, LbRand, k, C):
    return int(sum([(hashVals[i] * LbRand[i]) for i in range(k)]) % C)


# 生成hash表,L个hash函数族，以及生成一个用于生成label的随机数数组
def LSH(dataSet, k, L, r, tableSize):
    hashTable = [TableNode(i) for i in range(tableSize)]

    n = len(dataSet[0])  # 32
    m = len(dataSet)     # 68040

    C = pow(2, 32) - 5
    hashFuncs = []
    LbRand = [random.randint(-10, 10) for i in range(k)]  # 生成随机整数

    # 从LSH函数族中，随机选取L组这样的函数组，每个函数组都由k个随机选取的函数构成，当然L个函数组之间不一定是一样的。
    # 现在这L组函数分别对数据处理，只要有一组完全相等，就认为两条数据是相近的。
    for times in range(L):
        k_para = get_k_para(n, k, r)
        # hashFuncs 包含L个哈希函数组，每组包含k个哈希函数
        hashFuncs.append(k_para)

        for dataIndex in range(m):  # 68040个数据

            # 对当前hash函数族生成k个hash值
            hashVals = get_HashVals(k_para, dataSet[dataIndex], r)
            # 生成标签
            Lb = Label(hashVals, LbRand, k, C)
            # 生成索引
            index = Lb % tableSize
            # 找到节点的hash表
            node = hashTable[index]
            if Lb in node.buckets: # 若桶已存在，该节点加入桶子
                bucket = node.buckets[Lb]
                bucket.append(dataIndex)

            else:  # 否在新建一个桶
                node.buckets[Lb] = [dataIndex]

    return hashTable, hashFuncs, LbRand

