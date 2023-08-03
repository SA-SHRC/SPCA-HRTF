按空间方向做PCA，即SPCA方法，得到少量的空间基函数。

本方法涉及三个网络：
--first
输入：主成分的基（reference theta=0 phi=0）+ theta + phi
输出：theta、phi方向的主成分的基

--second
输入：8个测量参数
输出：主成分的系数
由于频谱的对称性，共101个网络

--third
输入：Hav + theta + phi
输出：theta、phi方向的Hav