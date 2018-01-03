import tensorflow as tf

x_data = [[1,2], [2,3], [3,1], [4,3],[5,3],[6,2]]
y_data = [[0], [0], [0], [1], [1], [1]]

# Set placeholders
X = tf.placeholder(tf.float32, shape=[None, 2])
Y = tf.placeholder(tf.float32, shape=[None, 1])

W = tf.Variable(tf.random_normal([2,1]), name = 'weight')
b = tf.Variavle(tf.random_normal([1]), name = 'bias')

# Hypothesis using sigmoid
hypothesis = tf.sigmoid(tf.matmul(X,W)+b)

# Cost/loss function
cost = -tf.reduce_mean(Y * tf.log(hypothesis) + (1 - Y)*tf.log(1-hypothesis))
train = tf.train.GradientDescentOptimizer(learning_rate=0.01).minimize(cost)

# Accuracy check
# True if hypothesis > 0.5 else false

predicted = tf.cast(hypothesis > 0.5, dtype = tf.float32)
accuracy = tf.reduce_mean(tf.cast(tf.equal(predicted, Y), dtype = tf.float32))
