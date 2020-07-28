#!/usr/bin/env nextflow


/*
#==============================================
code documentation
#==============================================
*/

/*
#==============================================
params
#==============================================
*/

params.resultsDir = 'results/snippy'
params.filePattern = "./*_{R1,R2}.fastq.gz"
params.saveMode = 'copy'
params.ram = 4
params.cpus = 4

params.refGbk = "NC000962_3.gbk"

Channel.fromFilePairs(params.filePattern)
        .set { ch_in_snippy }

Channel.value("$workflow.launchDir/NC000962_3.gbk")
        .set { ch_refGbk }

/*
#==============================================
snippy
#==============================================
*/

process snippy {
    container 'quay.io/biocontainers/snippy:4.6.0--0'
    publishDir params.resultsDir, mode: params.saveMode
    stageInMode 'symlink'
    errorStrategy 'retry'
    maxRetries 3


    input:
    path refGbk from ch_refGbk
    set genomeFileName, file(genomeReads) from ch_in_snippy

    output:
    path("""${genomeName}""") into ch_out_snippy

    script:
    genomeName = genomeFileName.toString().split("\\_")[0]

    """
    snippy --cpus ${params.cpus} --ram ${params.ram} --outdir $genomeName --ref $refGbk --R1 ${genomeReads[0]} --R2 ${genomeReads[1]}
    """

}

/*
#==============================================
# extra
#==============================================
*/


// alternative container
//container 'ummidock/snippy_tseemann:4.6.0-02'

