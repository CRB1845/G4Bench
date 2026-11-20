#!/usr/bin/env Rscript


args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 3) {
  stop("用法: Rscript deepg4_train.R <阳性BED文件> <阴性BED文件> <输出模型路径>")
}

positive_bed <- args[1]
negative_bed <- args[2]
output_model <- args[3]





library(Biostrings)
library(DeepG4)
library(rsample)
library(rtracklayer)
library(BSgenome.Hsapiens.UCSC.hg38)
library(reticulate)


use_condaenv("DeepG4")




bed.pos <- import.bed(positive_bed)
bed.neg <- import.bed(negative_bed)
BED <- c(bed.pos, bed.neg)
Y <- c(rep(1, length(bed.pos)), rep(0, length(bed.neg)))




ATAC_fake <- BED
mcols(ATAC_fake)$score <- rep(0, length(ATAC_fake))



Input_DeepG4 <- DeepG4InputFromBED(
  BED = BED,
  ATAC = ATAC_fake,
  GENOME = BSgenome.Hsapiens.UCSC.hg38,
  use.bg = FALSE  
)



training <- DeepG4(
  X = Input_DeepG4[[1]],
  X.atac = NULL,
  Y = Y,
  retrain = TRUE,
  retrain.path = output_model
)

cat("DeepG4模型训练完成! 模型保存到:", output_model, "\n")
