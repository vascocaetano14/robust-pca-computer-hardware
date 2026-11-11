Projeto1
Questão 1

library(rrcov)      
library(psych)      
library(car)        
library(ggplot2)    
library(WRS2)       

data(machines)
start_index <- which(rownames(machines) == "hp-3000/64")
end_index   <- which(rownames(machines) == "ibm-4331-2")
meus_dados  <- machines[start_index:end_index, ]

#Estatísticas Descritivas Comparativas
Resumo_Estatistico <- describe(meus_dados)

# Comparação Média Clássica vs Winsorizada vs Mediana
winsorized_means <- apply(meus_dados, 2, winmean, tr=0.2)
medianas <- apply(meus_dados, 2, median)
comp_medias <- round(rbind(
  Media_Classica = colMeans(meus_dados), 
  Media_Winsor   = winsorized_means, 
  Mediana        = medianas
), 2)
# Comparação Dispersão SD vs MAD
sds  <- apply(meus_dados, 2, sd)
mads <- apply(meus_dados, 2, mad)
Comp_Disper <- round(rbind(SD = sds, MAD = mads), 2)

# Variância Multivariada
S <- cov(meus_dados)
paste("Variância Generalizada (|S|):", det(S))
paste("Variância Total (tr(S)):", sum(diag(S)))
Var_Multivariada <- round(rbind(Var_Generalizada = det(S), Var_Total = sum(diag(S))), 2)


#Deteção Específica de Outliers Univariados
vars_interesse <- c("MMIN", "PRP", "CACH")

for(var in vars_interesse) {
  z_score_rob <- (meus_dados[[var]] - median(meus_dados[[var]])) / mad(meus_dados[[var]])
  outliers <- rownames(meus_dados)[abs(z_score_rob) > 3]
  
  if(length(outliers) > 0) {
    cat(paste("\nOutliers em", var, ":\n"))
    print(meus_dados[outliers, var, drop=FALSE])
  }
}


#Visualização Avançada

#Boxplots
dev.new() 
par(mfrow=c(2,3)) 
for(col in names(meus_dados)) {
  boxplot(meus_dados[[col]], main=col, col="lightblue", border="darkblue")
}
par(mfrow=c(1,1)) 

#Histogramas e QQ-Plots
dev.new()
par(mfrow=c(2,3)) 
for(col in vars_interesse) {
  qqPlot(meus_dados[[col]], main=paste("QQ:", col), col="red", id=list(n=2))
}
par(mfrow=c(1,1))

#Scatterplot
dev.new()
print(
  ggplot(meus_dados, aes(x = MMAX, y = PRP)) +
    geom_point(aes(colour=CACH), size=3) +
    scale_color_gradient(low="blue", high="red") +
    labs(title="Relação Performance vs Memória", 
         subtitle="Cor = Tamanho da Cache (Vermelho = Maior)",
         x="Memória Máxima (MMAX)", y="Performance (PRP)") +
    theme_minimal()
)


#Distâncias de Mahalanobis
rob_est <- covMcd(meus_dados)
md_robust <- mahalanobis(meus_dados, center = rob_est$center, cov = rob_est$cov)
cutoff <- qchisq(0.975, df=ncol(meus_dados))

#Plot Mahalanobis
dev.new()
plot(md_robust, pch=19, col="blue", main="Distâncias de Mahalanobis (Robustas)", ylab="Distância^2")
abline(h=cutoff, col="red", lwd=2)
text(x=1:length(md_robust), y=md_robust, 
     labels=ifelse(md_robust > cutoff, rownames(meus_dados), ""), 
     pos=3, cex=0.7, col="red")


# PCA Padronizada
pca_cor <- prcomp(meus_dados, scale. = TRUE)
pca_cov <- prcomp(meus_dados, scale. = FALSE) # Só para comparação visual

# Gráficos Biplot para comparação
dev.new()
par(mfrow=c(1,2))
biplot(pca_cov, cex=0.6, main="(i) PCA Covariância (Errado)", col=c("grey", "red"))
biplot(pca_cor, cex=0.6, main="(ii) PCA Correlação (Correto)", col=c("grey", "blue"))
par(mfrow=c(1,1))

# Seleção de Componentes
resumo <- summary(pca_cor)
cum_var <- resumo$importance[3, ]
k_95 <- which(cum_var >= 0.95)[1]

cat("Componentes necessárias para 95% variância:", k_95, "\n")

# Visualização dos Scores Finais
dev.new()
plot(pca_cor$x[, 1:2], 
     main=paste0("PCA Scores (Explica ", round(cum_var[2]*100,1), "%)"),
     xlab="PC1 (Dimensão Geral)", ylab="PC2 (Contrastes)", 
     pch=19, col="blue")
abline(h=0, v=0, lty=2, col="gray")
text(pca_cor$x[, 1:2], labels=rownames(meus_dados), cex=0.7, pos=3)

# Loadings
print(round(pca_cor$rotation[, 1:k_95], 3))



Questão 2

library(rrcov)     
library(psych)     
library(car)       
library(ggplot2)    
library(WRS2)      


data(machines)
start_index <- which(rownames(machines) == "hp-3000/64")
end_index   <- which(rownames(machines) == "ibm-4331-2")
meus_dados  <- machines[start_index:end_index, ]


#Estatísticas Descritivas Comparativas
Resumo_Estatístico <- describe(meus_dados)


# Comparação Média Clássica vs Winsorizada vs Mediana
winsorized_means <- apply(meus_dados, 2, winmean, tr=0.2)
medianas <- apply(meus_dados,2,median)
comp_medias <- round(rbind(
  Media_Classica = colMeans(meus_dados), 
  Media_Winsor   = winsorized_means, 
  Mediana        = medianas
), 2)
# Comparação Dispersão SD vs MAD
sds  <- apply(meus_dados, 2, sd)
mads <- apply(meus_dados, 2, mad)
Comp_Disper <- round(rbind(SD = sds, MAD = mads), 2)

# Variância Multivariada
S <- cov(meus_dados)
paste("Variância Generalizada (|S|):", det(S))
paste("Variância Total (tr(S)):", sum(diag(S)))
Var_Multivariada <- round(rbind(Var_Generalizada = det(S), Var_Total = sum(diag(S))), 2)

# Deteção Específica de Outliers Univariados
vars_interesse <- c("MMIN", "PRP", "CACH")


for(var in vars_interesse) {
  z_score_rob <- (meus_dados[[var]] - median(meus_dados[[var]])) / mad(meus_dados[[var]])
  outliers <- rownames(meus_dados)[abs(z_score_rob) > 3]
  
  if(length(outliers) > 0) {
    cat(paste("\nOutliers em", var, ":\n"))
    print(meus_dados[outliers, var, drop=FALSE])
  }
}


# Visualização Avançada

# Boxplots 
dev.new() 
par(mfrow=c(2,3)) 
for(col in names(meus_dados)) {
  boxplot(meus_dados[[col]], main=col, col="lightblue", border="darkblue")
}
par(mfrow=c(1,1)) 

#Histogramas e QQ-Plots 
dev.new()
par(mfrow=c(2,3))
for(col in vars_interesse) {
  qqPlot(meus_dados[[col]], main=paste("QQ:", col), col="red", id=list(n=2))
}
par(mfrow=c(1,1))

#Scatterplot
dev.new()
print(
  ggplot(meus_dados, aes(x = MMAX, y = PRP)) +
    geom_point(aes(colour=CACH), size=3) +
    scale_color_gradient(low="blue", high="red") +
    labs(title="Relação Performance vs Memória", 
         subtitle="Cor = Tamanho da Cache (Vermelho = Maior)",
         x="Memória Máxima (MMAX)", y="Performance (PRP)") +
    theme_minimal()
)


#Distâncias de Mahalanobis
rob_est <- covMcd(meus_dados)
md_robust <- mahalanobis(meus_dados, center = rob_est$center, cov = rob_est$cov)
cutoff <- qchisq(0.975, df=ncol(meus_dados))

# Plot Mahalanobis
dev.new()
plot(md_robust, pch=19, col="blue", main="Distâncias de Mahalanobis (Robustas)", ylab="Distância^2")
abline(h=cutoff, col="red", lwd=2)
text(x=1:length(md_robust), y=md_robust, 
     labels=ifelse(md_robust > cutoff, rownames(meus_dados), ""), 
     pos=3, cex=0.7, col="red")




# PCA Padronizada (Correlação)
pca_cor <- prcomp(meus_dados, scale. = TRUE)
pca_cov <- prcomp(meus_dados, scale. = FALSE) # Só para comparação visual

# Gráficos Biplot para comparação 
dev.new()
par(mfrow=c(1,2))
biplot(pca_cov, cex=0.6, main="(i) PCA Covariância (Errado)", col=c("grey", "red"))
biplot(pca_cor, cex=0.6, main="(ii) PCA Correlação (Correto)", col=c("grey", "blue"))
par(mfrow=c(1,1))

# Seleção de Componentes
resumo <- summary(pca_cor)
cum_var <- resumo$importance[3, ]
k_95 <- which(cum_var >= 0.95)[1]

cat("Componentes necessárias para 95% variância:", k_95, "\n")

# Visualização dos Scores Finais
dev.new()
plot(pca_cor$x[, 1:2], 
     main=paste0("PCA Scores (Explica ", round(cum_var[2]*100,1), "%)"),
     xlab="PC1 (Dimensão Geral)", ylab="PC2 (Contrastes)", 
     pch=19, col="blue")
abline(h=0, v=0, lty=2, col="gray")
text(pca_cor$x[, 1:2], labels=rownames(meus_dados), cex=0.7, pos=3)

# Loadings
print(round(pca_cor$rotation[, 1:k_95], 3))



#copia do dataset original 'meus_dados' 
dados_sujos <- meus_dados

# Vetor do enunciado para a máquina 'hp-3000/64':
novo_valor <- c(75, 2000, 0.8, 8000, 300, 24, 62, 47)

# Substituir a linha correspondente
dados_sujos["hp-3000/64", ] <- novo_valor


#PCA Clássica 
pca_suja_classica <- prcomp(dados_sujos, scale. = FALSE)

#PCA Robusta 
pca_suja_robusta <- PcaCov(dados_sujos, scale = FALSE)


dev.new() 
par(mfrow=c(1,2)) 

# Gráfico 1: PCA Clássica 
biplot(pca_suja_classica, 
       main="Clássica", 
       cex=0.7, 
       col=c("grey", "red"))

# Gráfico 2: PCA Robusta 
biplot(pca_suja_robusta, 
       main="Robusta (MCD)", 
       cex=0.7, 
       col=c("grey", "blue"))

par(mfrow=c(1,1)) 




# Clássica
prop_classica <- summary(pca_suja_classica)$importance[2,1]
cat(paste("PCA Clássica (PC1):", round(prop_classica*100, 4), "%\n"))

# Robusta
eigen_rob <- pca_suja_robusta$eigenvalues
prop_robusta <- eigen_rob[1] / sum(eigen_rob)
cat(paste("PCA Robusta  (PC1):", round(prop_robusta*100, 4), "%\n"))