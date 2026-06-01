#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

/*
 * Polylox-BC — Iso-Seq barcode extraction pipeline (Nextflow DSL2 port)
 * Chain: lima -> tag -> refine -> correct -> extract -> map -> tables
 */

// ----------------------------- processes -----------------------------

process LIMA {
    tag "$sample_id"
    container 'quay.io/biocontainers/lima:2.7.1--h9ee0642_0'
    publishDir "${params.outdir}/${sample_id}/lima", mode: 'copy'
    cpus 16

    input:
    tuple val(sample_id), path(hifi_bam)
    path primers

    output:
    tuple val(sample_id), path("${sample_id}.5p--3p.bam"), emit: bam
    path "${sample_id}.lima.clips"

    script:
    """
    lima -j ${task.cpus} --per-read --isoseq ${hifi_bam} ${primers} ${sample_id}
    """
}

process TAG {
    tag "$sample_id"
    container 'quay.io/biocontainers/isoseq:4.0.0--h9ee0642_0'
    publishDir "${params.outdir}/${sample_id}/isoseq", mode: 'copy'
    cpus 36

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}.tagged.bam")

    script:
    """
    isoseq tag --design ${params.lib} ${bam} ${sample_id}.tagged.bam -j ${task.cpus}
    """
}

process REFINE {
    tag "$sample_id"
    container 'quay.io/biocontainers/isoseq:4.0.0--h9ee0642_0'
    publishDir "${params.outdir}/${sample_id}/isoseq", mode: 'copy'
    cpus 36

    input:
    tuple val(sample_id), path(bam)
    path primers

    output:
    tuple val(sample_id), path("${sample_id}.flnc.bam")

    script:
    """
    isoseq refine ${bam} ${primers} ${sample_id}.flnc.bam -j ${task.cpus} --require-polya
    """
}

process CORRECT {
    tag "$sample_id"
    container 'quay.io/biocontainers/isoseq:4.0.0--h9ee0642_0'
    publishDir "${params.outdir}/${sample_id}/isoseq", mode: 'copy'
    cpus 16

    input:
    tuple val(sample_id), path(bam)
    path whitelist

    output:
    tuple val(sample_id), path("${sample_id}.corrected.bam")

    script:
    """
    isoseq correct --barcodes ${whitelist} ${bam} ${sample_id}.corrected.bam -j ${task.cpus}
    """
}

process EXTRACT {
    tag "$sample_id"
    container "${params.python_container}"
    publishDir "${params.outdir}/${sample_id}/extract", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)
    path extract_script

    output:
    tuple val(sample_id), path("${sample_id}.title_tag.fasta")

    script:
    """
    python ${extract_script} ${bam} ${sample_id}.title_tag.fasta
    """
}

process MAP {
    tag "$sample_id"
    container 'quay.io/biocontainers/minimap2:2.26--he4a0461_2'
    publishDir "${params.outdir}/${sample_id}/map", mode: 'copy'
    cpus 16

    input:
    tuple val(sample_id), path(fasta)

    output:
    tuple val(sample_id), path("${sample_id}.mapped.txt")

    script:
    """
    minimap2 -t ${task.cpus} ${fasta} -o ${sample_id}.mapped.txt
    """
}

process TABLES {
    tag "$sample_id"
    container "${params.python_container}"
    publishDir "${params.outdir}/${sample_id}/tables", mode: 'copy'

    input:
    tuple val(sample_id), path(mapped)
    path table_script

    output:
    tuple val(sample_id), path("${sample_id}._aggregated_data.csv")

    script:
    """
    python ${table_script} -i ${mapped} -o ${sample_id}
    """
}

// ----------------------------- workflow -----------------------------

workflow {

    // Samplesheet: CSV with header  sample,bam
    Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row -> tuple(row.sample, file(row.bam, checkIfExists: true)) }
        .set { ch_samples }

    primers_ch   = file(params.primers,   checkIfExists: true)
    whitelist_ch = file(params.whitelist, checkIfExists: true)
    extract_py   = file(params.extract_script, checkIfExists: true)
    table_py     = file(params.table_script,   checkIfExists: true)

    LIMA(ch_samples, primers_ch)
    TAG(LIMA.out.bam)
    REFINE(TAG.out, primers_ch)
    CORRECT(REFINE.out, whitelist_ch)
    EXTRACT(CORRECT.out, extract_py)
    MAP(EXTRACT.out)
    TABLES(MAP.out, table_py)
}
