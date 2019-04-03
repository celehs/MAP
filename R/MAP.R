#' Internal function to do inverse logit transformation
#' @noRd
g.logit = function(xx=NULL){exp(xx)/(exp(xx)+1)}

#' Internal function to do logit transformation
#' @noRd
logit = function(xx=NULL){log(xx/(1-xx))}

#' Internal function to get the probabilities that match the prevalence
#' @noRd
Prob.Scale = function(pp=NULL, prev=NULL){
    logit_pp = logit(pp)
    logit_pp[logit_pp == -Inf] = min(logit_pp[logit_pp > -Inf], na.rm=TRUE)
    logit_pp[logit_pp ==  Inf] = max(logit_pp[logit_pp < Inf], na.rm=TRUE)
    cc = uniroot(function(xx){mean(g.logit(logit_pp-xx), na.rm=TRUE)-prev},interval=c(-10,10))$root
    g.logit(logit_pp-cc)
}

#' Internal function to get the summary table
#' @noRd
IDtab = function(mat=NULL,note=NULL){
    mat = cbind(mat, note)
    colnames(mat)[ncol(mat)]= "note"
    df = matrix(c("NO","YES")[as.matrix(!is.na(mat))+1],ncol=ncol(mat))
    df = as.data.frame(df)
    colnames(df) = colnames(mat)
    as.data.frame(table(df))
}


#' @title MAP algorithm
#' @description  Main function to perform MAP algorithm to calculate predicted
#' probabilities of positive phenotype for each patient
#' based on NLP and ICD counts adjusted for healthcare utilization.
#' @param mat Count data (sparse matrix). One of the columns has to be ICD
#' data with name being ICD.
#' @param note Note count (sparse matrix) indicating health utilization.
#' @param yes.con A logical variable indicating if concomitant is desired. Not
#' used for now.
#' @param full.output A logical variable indicating if full outputs are desired.
#' @return Returns a list with following objects:
#' \item{scores}{indicates predicted probabilities.}
#' \item{cut.MAP}{the cutoff value that can be used to derive binary phenotype.}
#' @references High-throughput Multimodal Automated Phenotyping (MAP) with
#' Application to PheWAS. Katherine P. Liao, Jiehuan Sun,
#' Tianrun A. Cai, Nicholas Link, Chuan Hong, Jie Huang, Jennifer Huffman,
#' Jessica Gronsbell, Yichi Zhang, Yuk-Lam Ho, Victor Castro, Vivian Gainer,
#' Shawn Murphy, Christopher J. O’Donnell, J. Michael Gaziano, Kelly Cho,
#' Peter Szolovits, Isaac Kohane, Sheng Yu, and Tianxi Cai
#' with the VA Million Veteran Program (2019) <doi:10.1101/587436>.
#' @examples
#' ## simulate data to test the algorithm
#' n = 400
#' ICD = c(rpois(n/4,10), rpois(n/4,1), rep(0,n/2) )
#' NLP = c(rpois(n/4,10), rpois(n/4,1), rep(0,n/2) )
#' mat = Matrix(data=cbind(ICD,NLP),sparse = TRUE)
#' note = Matrix(rpois(n,10)+5,ncol=1,sparse = TRUE)
#' res = MAP(mat = mat,  note=note)
#' head(res$scores)
#' res$cut.MAP
MAP = function(mat=NULL, note=NULL,  yes.con = FALSE, full.output = FALSE){

    vname = colnames(mat)
    if(length(grep("ICD",vname,fixed=TRUE))==0){
        stop("Please provide ICD data in mat with colname being ICD!")
    }
    ICD = mat[,grep("ICD",vname,fixed=TRUE)]

    IDtab = IDtab(mat, note)
    vname.log = paste(vname,"_log",sep="")
    name.all = c(vname,vname.log)
    mat.log = mat
    mat.log@x = log(1+mat.log@x)
    mat = cbind(mat, mat.log)
    rm(mat.log)
    colnames(mat) = name.all
    note@x = log(note@x+1)

    post.all = Matrix(0, nrow=nrow(mat), ncol=ncol(mat))
    prob.all = Matrix(0, nrow=nrow(mat), ncol=ncol(mat))
    family = c( rep("poisson", length(vname)), rep("gaussian", length(vname.log)) )

    for(i in seq_along(name.all)){
        tmpfm = as.formula(paste(name.all[i],"~1"))
        if(yes.con){
            tmpfm2 = FLXPconstant()
        }else{
            tmpfm2 = FLXPconstant()
            zero.ind = is.element(mat[,i], c(0))
            na.ind = (is.element(mat[,i],c(NA)) | is.element(note[,1],c(0,NA)))
            exclude.ind = (zero.ind | na.ind)
            dat.tmp = data.frame(mat[!exclude.ind,i],note[!exclude.ind,1])
            colnames(dat.tmp) = c(name.all[i], "note")
        }
        totalN00 = nrow(dat.tmp)

        set.seed(1)
        n.clust = 1
        iter = 0
        while(n.clust < 2 & iter < 5){
            tmpfit = flexmix(tmpfm, k = 2,
                             model = FLXMRglmfix(fixed =~note,varFix=FALSE, family=family[i]),
                             concomitant=tmpfm2,control=list(tol = 1e-8), data=dat.tmp)
            n.clust = length(unique(tmpfit@cluster))
            iter = iter+1
        }

        ##if(name.all[i]=="nlp_log"){browser()}
        if(n.clust>1){
            avgcount = dat.tmp[,name.all[i]]
            tmpdiff = mean(avgcount[tmpfit@cluster==2]) - mean(avgcount[tmpfit@cluster==1])
            tmpind =  as.numeric( (tmpdiff > 0) + 1 )
            qprobtmp = qnorm(posterior(tmpfit))
            qprob = qprobtmp[,tmpind]
            qprob[is.infinite(qprob)] = -1*qprobtmp[is.infinite(qprob),3-tmpind]
            ### deal with some extreme clustering results ###
            if(sum(!is.infinite(qprob))>=2){
                qprob[qprob == Inf] = max(qprob[!is.infinite(qprob)])
                qprob[qprob == -Inf] = min(qprob[!is.infinite(qprob)])
            }else if(sum(!is.infinite(qprob))==1){
                if(qprob[!is.infinite(qprob)] >= 0){
                    qprob[qprob == Inf] = qprob[!is.infinite(qprob)]
                    qprob[qprob == -Inf] = qnorm(1/totalN00)
                }else{
                    qprob[qprob == Inf] = qnorm(1-1/totalN00)
                    qprob[qprob == -Inf] = qprob[!is.infinite(qprob)]
                }
            }else{
                qprob[qprob == Inf] = qnorm(1-1/totalN00)
                qprob[qprob == -Inf] = qnorm(1/totalN00)
            }
        }else{
            qprob = rep( qnorm(1-1/totalN00), nrow(dat.tmp))
            warning(paste("The clustering step does not converge for variable ",
                          name.all[i], "!", sep="") )
        }

        post.all[!exclude.ind,i] = qprob
        if(sum(na.ind)>0){
          post.all[na.ind,i] = NA
        }
        prob.all[!exclude.ind,i] = pnorm(qprob)
        if(sum(na.ind)>0){
          prob.all[na.ind,i] = NA
        }

    }

    colnames(post.all) = name.all
    colnames(prob.all) = name.all

    ## select eligible patients to estimate the prevalence
    ## and re-scale predicted prob.
    prob.all00 = prob.all
    na.id = (rowSums(is.na(prob.all00))==ncol(prob.all00))
    prob.all00[is.na(prob.all00)] = 0
    mu00 = rowMeans(prob.all00)
    exclude.ind = (mu00==0)
    post.all00 = as.matrix(post.all[!exclude.ind,])
    mat00 = mat[!exclude.ind,]
    rm(post.all)

    final.score00 = (rowMeans(pnorm(post.all00),na.rm=TRUE) +
                       pnorm(rowMeans(post.all00,na.rm=TRUE)))/2
    final.score00[is.na(final.score00)] = NA

    avgcount = rowMeans(mat00[,vname.log,drop=FALSE], na.rm=TRUE)
    avgpost = rowMeans(post.all00[,vname.log,drop=FALSE], na.rm=TRUE)
    avgcount = avgcount[!is.na(avgpost)]
    avgpost = avgpost[!is.na(avgpost)]

    cluster.ori = kmeans(cbind(avgcount,avgpost),centers=2)
    class.pos = 1 + 1*(cor(cluster.ori$cluster==2, avgcount)>0)
    prev.est0 = mean(cluster.ori$cluster==class.pos)
    prev.est = (mean(final.score00,na.rm=TRUE)+prev.est0)/2

    final.score00 = Prob.Scale(final.score00, prev.est)
    cut.MAP = as.numeric(quantile(final.score00,1-prev.est,na.rm = TRUE))
    final.score = Matrix(0,nrow=nrow(mat),ncol=1)
    final.score[!exclude.ind,1] = final.score00
    if(sum(na.id)>0){
      final.score[na.id,1] = NA
    }



    IDtab = IDtab[IDtab$Freq>0,]
    cat("####################### \n")
    cat("MAP only considers pateints who have note count data and
        at least one nonmissing variable!\n")
    cat("####\nHere is a summary of the input data:\n")
    cat("Total number of patients:", sum(IDtab$Freq), "\n")
    print(IDtab)
    cat("#### \n")

    final.score[ICD==0] = 0

    if(full.output){
        list("scores" = final.score, "cut.MAP" = cut.MAP, "scores.all" = prob.all)
    }else{
        list("scores" = final.score, "cut.MAP" = cut.MAP)
    }
}


