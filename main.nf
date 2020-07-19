#!/usr/bin/env nextflow

/*
################
params
################
*/

params.trimmed= true
params.saveBy= 'copy'
params.refGbk = "NC000962_3.gbk"


inputUntrimmedRawFilePattern = "./*_{R1,R2}.fastq.gz"
inputTrimmedRawFilePattern = "./*_{R1,R2}.p.fastq.gz"

inputRawFilePattern = params.trimmed ? inputTrimmedRawFilePattern : inputUntrimmedRawFilePattern

Channel.fromFilePairs(inputRawFilePattern)
        .into { ch_in_snippy }

ch_refGbk = Channel.value(path("./$params.refGbk"))


/*
###############
snippy_command
###############
*/

process snippy {
    container 'quay.io/biocontainers/snippy:4.6.0--0'
    //container 'ummidock/snippy_tseemann:4.6.0-02'
    publishDir 'results/snippy', mode: params.saveBy

    input:
    file refGbk from ch_refGbk
    set genomeFileName, file(genomeReads) from ch_in_snippy

    output:
    path("""${genomeName}""") into ch_out_snippy

    script:
    genomeName= genomeFileName.toString().split("\\_")[0]

    """
    snippy --cpus 4 --outdir $genomeName --ref ${refGbk} --R1 ${genomeReads[0]} --R2 ${genomeReads[1]}
    """
}
