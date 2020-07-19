#!/usr/bin/env nextflow

/*
################
params
################
*/

params.trimmed= true
params.saveBy= 'copy'
params.ram= 4
params.cpus= 4

params.refGbk = "NC000962_3.gbk"

inputUntrimmedRawFilePattern = "./*_{R1,R2}.fastq.gz"
inputTrimmedRawFilePattern = "./*_{R1,R2}.p.fastq.gz"

inputRawFilePattern = params.trimmed ? inputTrimmedRawFilePattern : inputUntrimmedRawFilePattern

Channel.fromFilePairs(inputRawFilePattern)
        .into { ch_in_snippy }

Channel.value("$workflow.launchDir/NC000962_3.gbk")
       .into {ch_refGbk}

/*
###############
snippy_command
###############
*/

process snippy {
    container 'quay.io/biocontainers/snippy:4.6.0--0'
    publishDir 'results/snippy', mode: params.saveBy
    stageInMode 'symlink'
    echo true

    input:
    path refGbk from ch_refGbk
    set genomeFileName, file(genomeReads) from ch_in_snippy

    output:
    path("""${genomeName}""") into ch_out_snippy

    script:
    genomeName= genomeFileName.toString().split("\\_")[0]

    """

    snippy --cpus ${params.cpus} --ram ${params.ram} --outdir $genomeName --ref $refGbk --R1 ${genomeReads[0]} --R2 ${genomeReads[1]}
    """
    
}

// alternative container 
//container 'ummidock/snippy_tseemann:4.6.0-02'
