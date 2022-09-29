# -*- coding:utf-8 -*-

import numpy as np
import pandas as pd


def euclideanDistance(v1, v2):
    v1, v2 = np.array(v1), np.array(v2)
    return np.sqrt(np.sum(np.square(v1 - v2)))


if __name__ == "__main__":
    # 读取数据集
    data = pd.DataFrame(pd.read_csv('corel', header=None, index_col=0, sep=' '))
    allDataSet = np.array(data.iloc[:].values)
    dataSet = allDataSet

    right_nums = np.zeros((1000, 10))

    # 将1000个查询找出正确的十个最近样本，用于计算精度和召回率
    for i in range(10):
        query = allDataSet[i]  # 查询内容
        # ————————————————————————————————————
        # 所有数据中最近的10个样本，不包括自身
        dist_all = []
        for j in range(len(dataSet)):
            temp = euclideanDistance(dataSet[j], query)
            dist_all.append(temp)

        sorted_nums_all = sorted(enumerate(dist_all), key=lambda x: x[1])
        idx_all = [i[0] for i in sorted_nums_all]
        nums_all = [i[1] for i in sorted_nums_all]
        right_nums[i] = nums_all[1:11]

    output = pd.DataFrame(right_nums)
    output.to_csv("right_num.csv")
