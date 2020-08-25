if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("GenomicFeatures")
BiocManager::install("ChIPseeker")
BiocManager::install("GenomicRanges")
BiocManager::install("rtracklayer")

getwd()
setwd("C:/Users/99039/Desktop/atac/")
library("GenomicFeatures")
library("ChIPseeker")
library("GenomicRanges")
library("rtracklayer")
library("dplyr")
library("ggplot2")


######################## 1.�������� ###########################
# ��ȡ�������صĲο��������gff3�ļ����Լ�����txdb
# ����gff3�ļ�
GFF_file<-"C:/Users/99039/Desktop/atac/Arabidopsis_thaliana.TAIR10.gff3"
# ����txdb
txdb <- makeTxDbFromGFF(GFF_file)
# ����bed�ļ�������ط���macs2������peak�ļ���������Ǹ�����bed��׺����Ȼ��R��ת��Ϊ���ݿ��ʱ�򣬵�һ�е�̧ͷ�д�λ��Ŀǰ����֪����ʲôԭ��
peakSRR5874657 <- readPeakFile("C:/Users/99039/Desktop/atac/SRR5874657.single_peaks.narrowPeak.bed")



######################## 2.peak��Ϣ ###########################
peak_SRR5874657<-annotatePeak(SRR5874657,tssRegion = c(-2500,2500),TxDb = txdb,addFlankGeneInfo = T,flankDistance = 5000)
# ��R�������Ķ���peak_SRR5874657������Console����ʾChIPseq��λ�����ڻ�������ʲô�������򣬷ֲ������Ρ�
peak_SRR5874657
as.GRanges(peak_SRR5874657)
# ���as.GRanges(peak_SRR5874657)��peak��Ϣ
write.csv (as.GRanges(peak_SRR5874657), file ="peak_SRR5874657.csv")



################## 3.�۲�peaks��Ⱦɫ��ķֲ� #####################
# covplot��������ֱ�ӽ���macs2-callpeak�����bed�ļ����л�ͼ��
pdf('peakdistribution_SRR5874657.pdf')
covplot(peakSRR5874657, weightCol="V5") 
dev.off()



################## 4.�̶����ڵ�peaks�ֲ� ##################
#ѡ��promoter����Ϊ���ڣ�ʹ��ת¼��ʼλ�㣬Ȼ��ָ�������Σ�ʹ��getPromoters������ͨ����ȡ���ݿ�������ݣ��ҵ�promoters����������3000bp��Χ��׼���ô���
promoter <- getPromoters(TxDb=txdb, 
                         upstream=3000, downstream=3000)
#ʹ��getTagMatrix��������peak�ȶԵ�������ڣ������ɾ��󣬹����������ӻ�
tagMatrix <- getTagMatrix(peakSRR5874657,windows=promoter)
tagHeatmap(tagMatrix, xlim=c(-3000, 3000), 
           color="red")
#peakHeatmap����ֻҪ���ļ������Ϳ���ֱ�ӳ�peaks����ͼ�������promoter�������εĴ��ڽ��л�ͼ
pdf('peakHeatmap_SRR5874657.pdf')
peakHeatmap(peakSRR5874657,
            weightCol = NULL, 
            TxDb = txdb,
            upstream = 3000, downstream = 3000, 
            xlab = "", ylab = "", title = NULL, 
            color = "red",
            verbose = TRUE)
dev.off()



################## 5.��ͼ����ʽ��չʾ��ϵ�ǿ�� ##################
#ѡ��promoter����Ϊ���ڣ�ʹ��ת¼��ʼλ�㣬Ȼ��ָ�������Σ�ʹ��getPromoters������ͨ����ȡ���ݿ�������ݣ��ҵ�promoters����������3000bp��Χ��׼���ô���
promoter <- getPromoters(TxDb=txdb, 
                         upstream=3000, downstream=3000)
#ʹ��getTagMatrix��������peak�ȶԵ�������ڣ������ɾ��󣬹����������ӻ�
tagMatrix <- getTagMatrix(peakSRR5874657,windows=promoter)
pdf('plotAvgProf_SRR5874657.pdf')
plotAvgProf(tagMatrix, xlim=c(-3000, 3000),
            xlab="Genomic Region (5'->3')", 
            ylab = "Read Count Frequency")
#������������,���֤����ϵĽ���
plotAvgProf(tagMatrix, xlim=c(-3000, 3000), 
            conf = 0.95, resample = 1000)
dev.off()



################## 6.ע����Ϣ�Ŀ��ӻ� ##################
# ��Ҫ����ע��һ�£�peaks�����ڵ�����ķֲ�������������������
peakAnno <-annotatePeak(peakSRR5874657, 
                        tssRegion = c(-3000, 3000), 
                        TxDb = txdb, 
                        level = "transcript", 
                        assignGenomicAnnotation = TRUE, 
                        genomicAnnotationPriority = c("Promoter", "5UTR", "3UTR", "Exon", "Intron", "Downstream", "Intergenic"), 
                        annoDb = NULL, 
                        addFlankGeneInfo = FALSE, 
                        flankDistance = 5000, 
                        sameStrand = FALSE, 
                        ignoreOverlap = FALSE, 
                        ignoreUpstream = FALSE, 
                        ignoreDownstream = FALSE, 
                        overlap = "TSS", 
                        verbose = TRUE)
# 6.1 ��ͼ
pdf('plotAnnoPie_SRR5874657.pdf')
plotAnnoPie(peakAnno)
dev.off()
# 6.2 ��״�ֲ�ͼ
pdf('plotAnnoBar_SRR5874657.pdf')
plotAnnoBar(peakAnno)
dev.off()
# 6.2 vennpie
pdf('vennpie_SRR5874657.pdf')
vennpie(peakAnno)
dev.off()
# 6.3 UpSetR
pdf('upsetplot_SRR5874657.pdf')
upsetplot(peakAnno)
upsetplot(peakAnno, vennpie=TRUE)#�ں�vennpie
dev.off()



################## 7.���ӻ�TSS�����TF binding loci ##################
pdf('plotDistToTSS_SRR5874657.pdf')
plotDistToTSS(peakAnno,title="Distribution of transcription factor-binding loci\nrelative to TSS")
dev.off()



