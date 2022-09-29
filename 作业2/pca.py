# -*- coding:utf-8 -*-

import numpy as np
import pandas as pd


def calulateVar(dataMatrix):
    # 计算每一维方差，,无偏估计
    arraySize = len(dataMatrix)
    arrayLen = len(dataMatrix[0])
    mean = np.zeros(arrayLen)
    var = np.zeros(arrayLen)
    for i in range(arrayLen):
        mean[i] = np.sum(dataMatrix[:, i])/arraySize;
        var[i] = np.sum((dataMatrix[:, i]-mean[i])**2)/(arraySize-1)
    print(var)


def calulateCovar(dataMatrix):
    # 计算协方差矩阵，以列为变量,无偏估计
    arraySize = len(dataMatrix)
    arrayLen = len(dataMatrix[0])
    mean = np.zeros(arrayLen)
    covar = np.zeros((arrayLen, arrayLen))
    for i in range(arrayLen):
        mean[i] = np.sum(dataMatrix[:, i])/arraySize;

    for i in range(arrayLen):
        for j in range(arrayLen):
            covar[i][j] = np.sum((dataMatrix[:, i]-mean[i])*(dataMatrix[:, j]-mean[j]))/(arraySize-1)
    # print('协方差矩阵为:')
    # print(covar)
    return covar


def dataStd(dataMatrix): # 标准化，但后续处理应计算correlation matrix的eigenvector
    Mmean = np.mean(dataMatrix, axis=0)
    Mstd = np.std(dataMatrix, axis=0)
    stdMatrix = (dataMatrix-Mmean)/Mstd
    return stdMatrix


def dataStd2(dataMatrix): # 仅中心化
    Mmean = np.mean(dataMatrix, axis=0)
    stdMatrix = (dataMatrix-Mmean)
    return stdMatrix

if __name__ == '__main__':
    # 数据读取 32 * 68040
    data = pd.DataFrame(pd.read_csv('colorHistogram.asc ', header=None, index_col=0, sep=' '))
    dataMatrix = np.array(data.iloc[:].values)

    # (1).PCA之前数据方差
    #
    # Mmean1 = np.var(dataMatrix, axis=0)  # numpy库函数为非无偏估计
    # print(Mmean1)
    print("PCA之前数据方差:")
    calulateVar(dataMatrix)  # 无偏估计
    print()

    # 计算协方差矩阵
    # calulateCovar(dataMatrix)
    # print()
    # print(np.cov(dataMatrix, rowvar=False))  # PCA中需要的cov是一种无偏估计,除数为 arraysize-1

    # (2).PCA之后数据(5 维)
    # 1.数据中心化
    stdMatrix = dataStd2(dataMatrix)
    # 2.计算协方差矩阵
    # covStdMatrix = np.cov(stdMatrix, rowvar=False)
    covStdMatrix = calulateCovar(stdMatrix)
    # 3.计算协方差矩阵的特征值与特征向量
    c1, c2 = np.linalg.eig(covStdMatrix)  # 获得特征值与特征向量

    # 4.对特征值从大到小排序
    # 5.保留最大的5个特征向量
    ordered_list = sorted(range(len(c1)), key=lambda k: c1[k], reverse=True)
    P = c2[:, ordered_list[0:5]]

    # 6.将数据转换到k个特征向量构建的新空间中
    # 矩阵X是m行n列的矩阵，矩阵P是n行k列的矩阵,Y=X∗P即为降维到k维后的数据矩阵
    dataMatrix2 = np.dot(dataMatrix, P)
    print("PCA之后数据(5 维):")
    print(dataMatrix2)
    print()

    # (3).PCA之后数据方差
    print("PCA之后数据方差:")
    calulateVar(dataMatrix2) # 无偏估计
    print()
