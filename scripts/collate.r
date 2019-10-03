library(dplyr)
library(jsonlite)

datadir <- scan("../config.txt", what="character")
pwd <- getwd()
setwd(datadir)
a <- list.files()
setwd(pwd)

# Get LDSC
d <- list()
i <- 1
for(id in a)
{
	message(id)
	x <- readLines(sprintf("%s/%s/ldsc.txt.log", datadir, id))
	out <- list()
	out$id <- id
	out$cutoff <- grep("cutoff", x, value=TRUE) %>% gsub("\\.", "", .) %>% strsplit(.," ") %>% first() %>% nth(7) %>% as.numeric()
	out$nsnp <- grep("regression SNP LD", x, value=TRUE) %>% gsub("\\.", "", .) %>% strsplit(.," ") %>% first() %>% nth(7) %>% as.numeric()
	out$h2 <- grep("Total Observed", x, value=TRUE) %>% strsplit(.," ") %>% first() %>% nth(5) %>% as.numeric
	out$h2_se <- grep("Total Observed", x, value=TRUE) %>% strsplit(.," ") %>% first() %>% last %>% gsub("\\(","",.) %>% gsub("\\)","",.) %>% as.numeric()
	out$lambda <- grep("Lambda GC", x, value=TRUE) %>% strsplit(.," ") %>% first() %>% nth(3) %>% as.numeric
	out$meanchisq <- grep("Mean Chi", x, value=TRUE) %>% strsplit(.," ") %>% first() %>% nth(3) %>% as.numeric
	out$intercept <- grep("Intercept:", x, value=TRUE) %>% strsplit(.," ") %>% first() %>% nth(2) %>% as.numeric
	out$intercept_se <- grep("Intercept:", x, value=TRUE) %>% strsplit(.," ") %>% first() %>% last %>% gsub("\\(","",.) %>% gsub("\\)","",.) %>% as.numeric()
	out$ratio <- grep("Ratio", x, value=TRUE)
	d[[i]] <- as_tibble(out)
	i <- i + 1
}
ldsc <- bind_rows(d)

# Get clumped
d <- list()
for(id in a)
{
	message(id)
	d[[id]] <- tibble(rsid=scan(sprintf("%s/%s/clump.txt", datadir, id), what="character"), id=id)
}

clumped <- bind_rows(d)

# Merge hitcount to ldsc
hitcount <- group_by(clumped, id) %>% summarise(nclumped=n())
hitcount
ldsc <- left_join(ldsc, hitcount)

save(clumped, ldsc, file="../results/collate.rdata")
