t2dm_dtp_slap <- read.delim("~/Dropbox/projects/T2DM/data/t2dm_dtp_slap_out.txt", header=F)
colnames(t2dm_dtp_slap) <- c("CID","TID","AS","Pscore","class")
as <- t2dm_dtp_slap$AS
ps <- t2dm_dtp_slap$Pscore
plot(as,ps,xlab="",ylab="")
abline(v = 100, col="red")
abline(h = 0.05, col="blue")
title(main="SLAP P-Score vs. Association Score",sub="T2DM links")

plot(as,ps,xlim=c(0,300),ylim=c(0,0.2),xlab="",ylab="")
abline(v = 100, col="red")
abline(h = 0.05, col="blue")
title(main="SLAP P-Score vs. Association Score (Zoom)",sub="T2DM links")

plot(as,1.0/ps,xlab="",ylab="")
abline(v = 100, col="red")
abline(h = 1/0.05, col="blue")
title(main="SLAP 1/P-Score vs. Association Score",sub="T2DM links")

plot(as,sqrt(1.0/ps),xlab="",ylab="")
abline(v = 100, col="red")
abline(h = sqrt(1/0.05), col="blue")
title(main="SLAP sqrt(1/P-Score) vs. Association Score",sub="T2DM links")

### Cases with AS>100 AND p<0.05, etc.
print(sprintf("total cases: %d",nrow(t2dm_dtp_slap)))

max_ok_ps <- 0.05
print(sprintf("cases where PScore <= %.4f: %d",max_ok_ps,nrow(t2dm_dtp_slap[t2dm_dtp_slap$Pscore <= max_ok_ps,])))
min_ok_as <- 100
print(sprintf("cases where AScore >= %d: %d",min_ok_as,nrow(t2dm_dtp_slap[t2dm_dtp_slap$AS >= min_ok_as,])))
print(sprintf("cases where PScore <= %.4f AND AScore >= %d: %d",max_ok_ps,min_ok_as,nrow(t2dm_dtp_slap[(t2dm_dtp_slap$Pscore <= max_ok_ps) & (t2dm_dtp_slap$AS >= min_ok_as),])))

### Adjust max_ok_ps.  Can we achieve same cutoff with one score?
max_ok_ps <- max(t2dm_dtp_slap[t2dm_dtp_slap$AS >= min_ok_as,]$Pscore)
print(sprintf("max PScore where AS >= %d: %.4f",min_ok_as,max_ok_ps))
print(sprintf("cases where PScore <= %.4f: %d",max_ok_ps,nrow(t2dm_dtp_slap[t2dm_dtp_slap$Pscore <= max_ok_ps,])))
print(sprintf("cases where AScore ok and NOT PScore ok: %d", nrow(t2dm_dtp_slap[t2dm_dtp_slap$AS >= min_ok_as && t2dm_dtp_slap$Pscore > max_ok_ps,])))
