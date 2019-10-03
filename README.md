# Analysing GWAS of 20k UKBB traits

GWAS using bolt-lmm, clumping and ldsc have been performed. 

## Setup

Create config file that has path to data directory

```
echo "path/to/datadir" > config.txt
```


## Collate clump and ldsc results

Collate the ldsc and clumping results:

```
cd scripts/
Rscript collate.r
```

