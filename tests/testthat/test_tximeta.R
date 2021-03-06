context("tximeta")
test_that("tximeta works as expected", {

  dir <- system.file("extdata/salmon_dm", package="tximportData")
  files <- file.path(dir, "SRR1197474_cdna", "quant.sf.gz") 
  coldata <- data.frame(files, names="SRR1197474", condition="A", stringsAsFactors=FALSE)
  
  dir <- system.file("extdata", package="tximeta")
  indexDir <- file.path(dir, "Drosophila_melanogaster.BDGP6.cdna.v92_salmon_0.10.2")
  fastaFTP <- "ftp://ftp.ensembl.org/pub/release-92/fasta/drosophila_melanogaster/cdna/Drosophila_melanogaster.BDGP6.cdna.all.fa.gz"
  
  dir2 <- system.file("extdata/salmon_dm", package="tximportData")
  gtfPath <- file.path(dir2,"Drosophila_melanogaster.BDGP6.92.gtf.gz")
  makeLinkedTxome(indexDir=indexDir, source="Ensembl", organism="Drosophila melanogaster",
                  release="92", genome="BDGP6", fasta=fastaFTP, gtf=gtfPath, write=FALSE)

  expect_warning({se <- tximeta(coldata)}, "missing from the GTF")

  # just a vector of file paths is ok
  expect_warning({se <- tximeta(files)})

  expect_error({se <- tximeta(coldata, txOut=FALSE)}, "transcript-level output")

  # skip metadata
  se <- tximeta(coldata, skipMeta=TRUE)
  expect_error({summarizeToGene(se)}, "transcriptome metadata")
  expect_error({addIds(se)}, "transcriptome metadata")
  
})

test_that("tximeta can import kallisto", {

  dir <- system.file("extdata", package="tximportData")
  samples <- read.table(file.path(dir,"samples.txt"), header=TRUE)
  files <- file.path(dir,"kallisto", samples$run, "abundance.tsv.gz")
  coldata <- data.frame(files, names=paste0("sample",1:6))
  se <- tximeta(coldata, type="kallisto", txOut=TRUE)

  # inferential replicates as well
  library(SummarizedExperiment)
  files <- file.path(dir,"kallisto_boot", samples$run, "abundance.h5")
  coldata <- data.frame(files, names=paste0("sample",1:6))
  se <- tximeta(coldata, type="kallisto", txOut=TRUE)
  expect_true("infRep1" %in% assayNames(se))
  se <- tximeta(coldata, type="kallisto", txOut=TRUE, varReduce=TRUE)
  expect_true("variance" %in% assayNames(se))
  
})

test_that("tximeta can import inferential replicates", {

  # don't want to rely on internet connection for tests...
  if (FALSE) {
    library(SummarizedExperiment)
    dir <- system.file("extdata", package="tximportData")
    samples <- read.table(file.path(dir,"samples.txt"), header=TRUE)
    files <- file.path(dir,"salmon_gibbs", samples$run, "quant.sf.gz")
    coldata <- data.frame(files, names=paste0("sample",1:6))
    se <- tximeta(coldata)
    expect_true("infRep1" %in% assayNames(se))

    se2 <- tximeta(coldata, varReduce=TRUE)
    expect_true("variance" %in% assayNames(se2))

    gse <- summarizeToGene(se)
    expect_true("infRep1" %in% assayNames(gse))

    gse <- summarizeToGene(se, varReduce=TRUE)
    expect_true("variance" %in% assayNames(gse))
    
  }
  
})

test_that("tximeta can import alevin", {

  dir <- system.file("extdata", package="tximportData")
  files <- file.path(dir,"alevin/neurons_900/alevin/quants_mat.gz")
  file.exists(files)
  coldata <- data.frame(files, names="neurons")
  #se <- tximeta(coldata, type="alevin")

})
