---
layout: post
title: Neural Networks And Deep Learning Chap6
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>

[原文地址](http://neuralnetworksanddeeplearning.com/chap5.html)

### Introducing convolutional networks

- Local receptive fields

局部采样

- shared weights

分享权重

  To see why this makes sense, suppose the weights and bias are such that the hidden neuron can pick out, say, a vertical edge in a particular local receptive field. That ability is also likely to be useful at other places in the image. And so it is useful to apply the same feature detector everywhere in the image. 

分享权重为什么会有用？因为一般来说一套w和b，对应于获取图像的某一种特征，那么这种特征应该是全图像都需要的，所以对于图像的各个局部，都需要一样的权重。

  The network structure I've described so far can detect just a single kind of localized feature. To do image recognition we'll need more than one feature map. And so a complete convolutional layer consists of several different feature maps

一个正常的卷积层应该包含多个feature，也就是多组参数。

  A big advantage of sharing weights and biases is that it greatly reduces the number of parameters involved in a convolutional network.

下面比较的就是卷积和全连接的参数数量，卷积可以有效缩减参数数量：

  If we have 20 feature maps that's a total of 20×26=520 parameters defining the convolutional layer.这是卷积的参数数量

  That's a total of 784×30 weights, plus an extra 30 biases, for a total of 23,550 parameters.这是全连接的参数数量

  对比520和23550，全连接的参数数量大概是卷积的40倍。

- pooling
    - max-pooling
    - L2 pooling

### Convolutional neural networks in practice

That's a satisfying point of view, but gives rise to a second question. The output from the previous layer involves 20 separate feature maps, and so there are 20×12×12 inputs to the second convolutional-pooling layer. It's as though we've got 20 separate images input to the convolutional-pooling layer, not a single image, as was the case for the first convolutional-pooling layer. How should neurons in the second convolutional-pooling layer respond to these multiple input images? In fact, we'll allow each neuron in this layer to learn from all 20×5×5 input neurons in its local receptive field. More informally: the feature detectors in the second convolutional-pooling layer have access to all the features from the previous layer, but only within their particular local receptive field

这里每个神经元，要连接所有input的20个feature的5*5区域

However, across all my experiments I found that networks based on rectified linear units consistently outperformed networks based on sigmoid activation functions

relu要全面好过sigmoid

这些一步步提高了测试成绩
- 增加额外的卷积和池化层
- 改用relu激活函数
- 扩展数据集
- 增加全连接层神经元数量，或者增加一个全连接层（效果不明显）
- 使用dropout
- 使用多个网络，共同决定分类（作者的意思是，这种方式其实是一种阻碍，且效果不明显）


### Why we only applied dropout to the fully-connected layers

the convolutional layers have considerable inbuilt resistance to overfitting. The reason is that the shared weights mean that convolutional filters are forced to learn from across the entire image. This makes them less likely to pick up on local idiosyncracies in the training data. And so there is less need to apply other regularizers, such as dropout.

卷积已经有正则的效果了，因为卷积由于权值共享，实际上学习的是整个图像，这样过拟合的现象就比较不容易发生。


### Why are we able to train?

上章的最后的问题是，如何避免梯度消失和爆炸

这里的答案是，**我们现在也没解决，只是多做了一些优化**

(1) Using convolutional layers greatly reduces the number of parameters in those layers, making the learning problem much easier; 

(2) Using more powerful regularization techniques (notably dropout and convolutional layers) to reduce overfitting, which is otherwise more of a problem in more complex networks; 

(3) Using rectified linear units instead of sigmoid neurons, to speed up training - empirically, often by a factor of 3-5; 

(4) Using GPUs and being willing to train for a long period of time.

- making use of sufficiently large data sets (to help avoid overfitting); 
- using the right cost function (to avoid a learning slowdown); 
- using good weight initializations (also to avoid a learning slowdown, due to neuron saturation); 
- algorithmically expanding the training data. 


### Recent progress in image recognition

增加一些扰动，可能就无法识别，比如：

![]({{site.baseurl}}/images/md/chap6_1.jpg)

The existence of the adversarial negatives appears to be in contradiction with the network’s ability to achieve high generalization performance. Indeed, if the network can generalize well, how can it be confused by these adversarial negatives, which are indistinguishable from the regular examples? The explanation is that the set of adversarial negatives is of extremely low probability, and thus is never (or rarely) observed in the test set, yet it is dense (much like the rational numbers), and so it is found near virtually every test case.

这种扰动为什么正则没有用处？实际上，这种扰动在测试和学习集中，出现的几率非常低，所以没有学习到，而常规的正则解决不了这样问题，这种或许智能通过人为扩展数据集才行。


### Other approaches to deep neural nets

- Recurrent neural networks

Indeed, a neuron's activation might be determined in part by its own activation at an earlier time.

Or perhaps the activations of hidden and output neurons won't be determined just by the current input to the network, but also by earlier inputs.

神经元本身会受到之前的激发状态的影响或者受到之前的输入的影响

they're particularly useful in analysing data or processes that change over time. Such data and processes arise naturally in problems such as speech or natural language, for example.

用来识别有时间流逝的数据或者进程，比如谈话或自然语言。

- Long short-term memory units (LSTMs)

One challenge affecting RNNs is that early models turned out to be very difficult to train, harder even than deep feedforward networks. The reason is the unstable gradient problem discussed in Chapter 5. Recall that the usual manifestation of this problem is that the gradient gets smaller and smaller as it is propagated back through layers. This makes learning in early layers extremely slow. The problem actually gets worse in RNNs, since gradients aren't just propagated backward through layers, they're propagated backward through time. 

在RNN内，梯度不稳定的问题，更加明显，因为梯度不只是通过层来传播，还有时间。
LSTM的加入会对这个有所帮助

- Deep belief nets, generative models, and Boltzmann machines

DBN

 In this, a generative model is much like the human brain: not only can it read digits, it can also write them

 A second reason DBNs are interesting is that they can do unsupervised and semi-supervised learning.

- reinforcement learning

加强学习，比如学习如何打游戏，下面是作者推荐的两篇文章
这个我以后可能会用到

http://www.cs.toronto.edu/~vmnih/docs/dqn.pdf

https://www.nature.com/articles/nature14236


### On the future of neural networks

- Intention-driven user interfaces
- Machine learning, data science, and the virtuous circle of innovation
- The role of neural networks and deep learning


### Will neural networks and deep learning soon lead to artificial intelligence?

it's too early to say