ch_refGbk = Channel.value("$baseDir/NC000962_3.gbk")


Channel.fromFilePairs("./*_{R1,R2}.p.fastq.gz")
        .into {  ch_in_snippy }


/*
###############
snippy_command
###############
*/

process snippy {
    container 'quay.io/biocontainers/snippy:4.6.0--0'
    publishDir 'results/snippy'

    input:
    path refGbk from ch_refGbk
    set genomeFileName, file(genomeReads) from ch_in_snippy

    output:
    path("""${genomeName}""") into ch_out_snippy

    script:
    genomeName= genomeFileName.toString().split("\\_")[0]

    """
    snippy --cpus 4 --outdir $genomeName --ref $refGbk --R1 ${genomeReads[0]} --R2 ${genomeReads[1]}
    """
}
