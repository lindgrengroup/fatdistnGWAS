### Generating phenotypes for all of the samples in UKBB (not just the white British samples)
### Adapted from a script from Tugce Karaderi

# Read data in for 502,206 samples
# This file is in: /path/to/ukbiobank/sample/bridge/file/ukb10844.extract.bridgeID.txt
data<-read.table("ukb10844.extract.bridgeID.txt", header=T, as.is=T)

# Create waist to hip ratio column by dividing waist circumference (WC) by hip circumference (HC)
data$WHR<-(as.numeric(data$WC)/as.numeric(data$HC))

# Split the data by sex so that phenotypes can be generated in sex-specific groups
data.xx <- subset(data, data$sex==0, drop=FALSE) # 273,049 samples
data.xy <- subset(data, data$sex==1, drop=FALSE) # 229,157 samples

# Generate the different phenotypes using regressions per the GIANT approach for generating these phenotypes

#
# BMI -- COMBINED, FEMALES, MALES
#

# Here's age-squared (age at assessment)
data$AgeSq <- data$age_at_assess*data$age_at_assess
data.xx$AgeSq <- data.xx$age_at_assess^2
data.xy$AgeSq <- data.xy$age_at_assess^2

### Here's the BMI regression on all samples
# Regression
bmi <- lm(BMI ~ age_at_assess + AgeSq + sex + assesCentre, data=data, na.action=na.exclude)

# Extract the residuals
data$res_bmi <- residuals(bmi)

# Inverse normalize the residuals and append to the existing data
data$res_bmi_inv <- qnorm((rank(data$res_bmi, na.last="keep")-0.5)/sum(!is.na(data$res_bmi)))

### Now repeat, but do this in females only

# Regression
bmi.xx <- lm(BMI ~ age_at_assess + AgeSq + assesCentre, data=data.xx, na.action=na.exclude)

# Residual extraction
data.xx$res_bmi <- residuals(bmi.xx)

# Inverse normalize
data.xx$res_bmi_inv <- qnorm((rank(data.xx$res_bmi, na.last="keep")-0.5)/sum(!is.na(data.xx$res_bmi)))

# And the same, but for males
bmi.xy <- lm(BMI ~ age_at_assess + AgeSq + assesCentre, data=data.xy, na.action=na.exclude)
data.xy$res_bmi <- residuals(bmi.xy)
data.xy$res_bmi_inv <- qnorm((rank(data.xy$res_bmi, na.last="keep")-0.5)/sum(!is.na(data.xy$res_bmi)))

#
# WHR -- COMBINED, FEMALES, MALES
#

# Combined
whr <- lm(WHR ~ age_at_assess + AgeSq + sex + assesCentre, data=data, na.action=na.exclude)
data$res_whr <- residuals(whr)
data$res_whr_inv <- qnorm((rank(data$res_whr, na.last="keep")-0.5)/sum(!is.na(data$res_whr)))

# Females
whr.xx <- lm(WHR ~ age_at_assess + AgeSq + assesCentre, data=data.xx, na.action=na.exclude)
data.xx$res_whr <- residuals(whr.xx)
data.xx$res_whr_inv <- qnorm((rank(data.xx$res_whr, na.last="keep")-0.5)/sum(!is.na(data.xx$res_whr)))

# Males
whr.xy <- lm(WHR ~ age_at_assess + AgeSq + assesCentre, data=data.xy, na.action=na.exclude)
data.xy$res_whr <- residuals(whr.xy)
data.xy$res_whr_inv<-qnorm((rank(data.xy$res_whr, na.last="keep")-0.5)/sum(!is.na(data.xy$res_whr)))

#
# WHRadjBMI
#

# Same as WHR, but now also conditioning on BMI
whrBMI <- lm(WHR ~ age_at_assess + AgeSq + sex + BMI + assesCentre, data=data, na.action=na.exclude)
data$res_whrAdjBMI <- residuals(whrBMI)
data$res_whrAdjBMI_inv <- qnorm((rank(data$res_whrAdjBMI, na.last="keep")-0.5)/sum(!is.na(data$res_whrAdjBMI)))

# And in females
whrBMI.xx <- lm(WHR ~ age_at_assess + AgeSq + BMI + assesCentre, data=data.xx, na.action=na.exclude)
data.xx$res_whrAdjBMI <- residuals(whrBMI.xx)
data.xx$res_whrAdjBMI_inv <- qnorm((rank(data.xx$res_whrAdjBMI, na.last="keep")-0.5)/sum(!is.na(data.xx$res_whrAdjBMI)))

# And in males
whrBMI.xy <- lm(WHR ~ age_at_assess + AgeSq + BMI + assesCentre, data=data.xy, na.action=na.exclude)
data.xy$res_whrAdjBMI <- residuals(whrBMI.xy)
data.xy$res_whrAdjBMI_inv <- qnorm((rank(data.xy$res_whrAdjBMI, na.last="keep")-0.5)/sum(!is.na(data.xy$res_whrAdjBMI)))

# Save the data for combined, females and males
write.table(data, file="UKBiobank.BMI_WHR_WHRadjBMI.inv_residuals.combined.v2.txt", quote=FALSE, row.names=FALSE, col.names=TRUE, sep="\t")
write.table(data.xx, file="UKBiobank.BMI_WHR_WHRadjBMI.inv_residuals.females.v2.txt", quote=FALSE, row.names=FALSE, col.names=TRUE, sep="\t")
write.table(data.xy, file="UKBiobank.BMI_WHR_WHRadjBMI.inv_residuals.males.v2.txt", quote=FALSE, row.names=FALSE, col.names=TRUE, sep="\t")
