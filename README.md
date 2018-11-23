# An improved genetic algorithm based on harmony algorith
![Image text](https://github.com/KenyonZhao233/An-improved-genetic-algorithm-based-on-harmony-algorithm/blob/master/图片/1.png)
  
  遗传算法是一种借鉴生物界自然选择和自然遗传机制的随机化搜索算法。
  由于其适应不同任务的泛化能力较强，被广泛应用于非线性、多目标、多变量、复杂的自适应系统中。
  在马尔可夫决策过程中，遗传算法负责解决由动作奖励（R）优化转移概率（P）的过程。遗传算法有三个的基本操作：
  选择、交叉和变异。选择的目的是从当前种群中选出优良的个体，即动作奖励高的转移概率，使他们有机会作为父代繁衍子孙。
  交叉过程中，由于在当前状态约束下的动作空间较小，为了更好地保留最优解，遗传算法使用完全交叉方式， 同时也提高了模型的收敛速度。变异即是转移概率在当前状态约束下的动作空间内，进行有约束的变异。

  但是传统遗传算法收敛速度慢、容易陷入局部最优解，尤其在复杂问题中，收敛时间长且很难得到全局最优解。
  为了解决这两个问题，我们采取了两种不同的改进优化方案：自适应遗传算法优化与基于和声算法的遗传算法优化。
  1.自适应遗传算法优化，即是通过计算种群中心区域密度，判断种群是否接近或者到达了某个局部最优解区域。
  此时如果种群内部已经相对稳定，难以发生实质进化和走出局部最优解。我们选择设置类似于自然界中的“天灾”设定，一定程度上将旧种群初始化为新的种群，从而走出此处局部最优解，并试图寻找下一个可能的局部最优解，从而使模型更有希望与能力达到全局最优解。
  同时我们也设置在正常的种群中心区域密度下，密度越高时，变异概率也会随之上升，尽量减少种群“灭亡与重生”的次数。
  
![Image text](https://github.com/KenyonZhao233/An-improved-genetic-algorithm-based-on-harmony-algorithm/blob/master/图片/2.png)![Image text](https://github.com/KenyonZhao233/An-improved-genetic-algorithm-based-on-harmony-algorithm/blob/master/图片/3.png)

![Image text](https://github.com/KenyonZhao233/An-improved-genetic-algorithm-based-on-harmony-algorithm/blob/master/图片/4.PNG)
2.基于和声算法的遗传算法优化
（1）和声搜索算法（HS）
  简介：是一种新的启发式全局搜索算法，智能模拟了音乐演奏的原理。
  HS采用一套新的随机导数用于离散变量，通过反复调整记忆库中的解变量，使函数值随着迭代次数的增加不断收敛，以确保算法的快速收敛性，从而来完成优化。
  当HS算法处于局部最优时，同时此局部最优恰好也是全局最优时，HS算法也可以提取最优解。它能够最大程度克服遗传算法多次震荡不能达到局部最优点的理论缺陷。
  算法原理：HS算法将乐器i（i=1，2，……，m）类比于优化问题中的第i个设计变量，各乐器声调的和声Rj（j=1，2，……，M）相当于优化问题的第j个解向量，评价类比于目标函数。
  算法首先产生M个初始解（和声）放入和声记忆库HM（harmony memory)内，以概率HMCR在HM内搜索新解，以概率1-HMCR在HM外变量可能值域中搜索。
  然后算法以概率PAR对新解产生局部扰动。判断新解目标函数值是否优于HM内的最差解，若是，则替换之；然后不断迭代，直至达到预定迭代次数Tmax为止。
 ![Image text](https://github.com/KenyonZhao233/An-improved-genetic-algorithm-based-on-harmony-algorithm/blob/master/图片/5.png)
 
（2）和声算法的推广
  自适应遗传算法在接近局部最优解区域时存在可能并未达到局部最优解点便被“灭亡与重生”为新的种群，进而错过某个可能的全局最优解。
  而结合和声算法，其记忆库中的优秀和声不断参加迭代，保证着最优解的收敛速度，使种群有能力在“灭亡与重生”前达到局部最优。
  同时其带来的容易陷入局部最优解的劣势可以被自适应遗传算法一定程度上的弥补，二者的结合，使改良后的遗传算法具有更强的寻找全局最优解能力与较快的收敛速度。
