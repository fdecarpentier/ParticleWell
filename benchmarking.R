library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(ggbeeswarm)
library(data.table)
library(ggpubr)
library(scales)
library(ggpubr)

setwd("~/19-ShinyParticles/ParticleWell")

df <- fread("benchmaking_mean_log.txt", 
            header = F,
            sep = ";")
names(df) <- c("method", "image","time")

df <- df %>% 
  mutate(method = replace(method, method == "ImageJ", "CPU")) %>%
  mutate(method = replace(method, method == "CLIJ2", "GPU"))

summary <- df %>%
  group_by(method) %>%
  summarise(time = mean(time))

wide <- df %>%
  pivot_wider(names_from = method, values_from = time)

plot <- ggpaired(wide, cond1 = "CPU", cond2 = "GPU",
                 line.color = "gray", line.size = 0.4,
                 color = "condition",
                 palette = "jco") +
  xlab("Method") + 
  ylab("time (ms)")

plot <- ggpar(plot, legend = "none")

plot

blur <- fread("benchmaking_blur.txt", 
            header = F,
            sep = ";")
names(blur) <- c("method", "image","time")
blur <- mutate(blur, time = time/1000)

blurmmary <- blur %>%
  group_by(method) %>%
  summarise(time = mean(time))

blurPlot <- ggbarplot(data = blur, 
                     x = "method", 
                     y = "time", 
                     add = "mean_se",
                     error.plot = "linerange",
                     fill = "method",
                     palette = "jco") +
  geom_jitter(aes(x = method, y = time), colour = "black", width = .2, show.legend = F) +
  geom_text(data=blurmmary, 
            aes(label = sprintf("%0.2f", round(time, digits = 2))),
            nudge_y = 8)+
  theme_classic() +
  xlab("Method") + 
  ylab("time (s)")

blurPlot <- ggpar(blurPlot, legend = "none")

blurPlot
