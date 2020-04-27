# PACOTES
install.packages("devtools")
devtools::install_github("rstudio/keras")


#CARREGAR
library(keras)
library(magrittr)

# https://www.kaggle.com/zalando-research/fashionmnist
fashion_mnist <- dataset_fashion_mnist()

c(train_images, train_labels) %<-% fashion_mnist$train
c(test_images, test_labels) %<-% fashion_mnist$test

class_names = c('Camiseta',
                'Calça',
                'Suéter',
                'Vestido',
                'Casaco', 
                'Sandália',
                'Camisa',
                'Tênis',
                'Mochila',
                'Ankle boot')


library(tidyr)
library(ggplot2)


image_1 <- as.data.frame(train_images[1, , ])
colnames(image_1) <- seq_len(ncol(image_1))
image_1$y <- seq_len(nrow(image_1))
image_1 <- gather(image_1, "x", "value", -y)
image_1$x <- as.integer(image_1$x)


ggplot(image_1, aes(x = x, y = y, fill = value)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "black", na.value = NA) +
  scale_y_reverse() +
  theme_minimal() +
  theme(panel.grid = element_blank())   +
  theme(aspect.ratio = 1) +
  xlab("") +
  ylab("")


train_images <- train_images / 255
test_images <- test_images / 255


# Exibição das 25 primeiras imagens do conjunto de treinamento e a "class_name" abaixo de cada imagem. 
# Verifique se os dados estão no formato correto e se estamos prontos para criar e treinar a rede.

par(mfcol=c(5,5))
par(mar=c(0, 0, 1.5, 0), xaxs='i', yaxs='i')
for (i in 1:25) { 
  img <- train_images[i, , ]
  img <- t(apply(img, 2, rev)) 
  image(1:28, 1:28, img, col = gray((0:255)/255), xaxt = 'n', yaxt = 'n',
        main = paste(class_names[train_labels[i] + 1]))
}


model <- keras_model_sequential()
model %>%
  layer_flatten(input_shape = c(28, 28)) %>%
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dense(units = 10, activation = 'softmax')


model %>% compile(
  optimizer = 'adam', 
  loss = 'sparse_categorical_crossentropy',
  metrics = c('accuracy')
)


model %>% fit(train_images, train_labels, epochs = 5, verbose = 2)

score <- model %>% evaluate(test_images, test_labels, verbose = 0)

cat('Test loss:', score$loss, "\n")
cat('Test accuracy:', score$acc, "\n")

predictions <- model %>% predict(test_images)

which.max(predictions[1, ])

class_pred <- model %>% predict_classes(test_images)
class_pred[1:20]


par(mfcol=c(5,5))
par(mar=c(0, 0, 1.5, 0), xaxs='i', yaxs='i')
for (i in 1:25) { 
  img <- test_images[i, , ]
  img <- t(apply(img, 2, rev)) 

  predicted_label <- which.max(predictions[i, ]) - 1
  true_label <- test_labels[i]
  if (predicted_label == true_label) {
    color <- '#008800' 
  } else {
    color <- '#bb0000'
  }
  image(1:28, 1:28, img, col = gray((0:255)/255), xaxt = 'n', yaxt = 'n',
        main = paste0(class_names[predicted_label + 1], " (",
                      class_names[true_label + 1], ")"),
        col.main = color)
}


img <- test_images[1, , , drop = FALSE]
dim(img)

predictions <- model %>% predict(img)
predictions


prediction <- predictions[1, ] - 1
which.max(prediction)

class_pred <- model %>% predict_classes(img)
class_pred

