# isoseq rules.
rule tag:
    input: sample + ".5p--3p.bam"
    output: sample + ".tagged.bam"
    conda: "envs/isoseq.yaml"
    threads: 36
    log: "logs/isoseq/{sample}.tag.log"
    shell: "isoseq tag --design {config.lib} {input} {output} -j {threads}"

rule refine:
    input: sample + ".tagged.bam"
    output: sample + ".flnc.bam"
    conda: "envs/isoseq.yaml"
    params: p = primers
    threads: 36
    log: "logs/isoseq/{sample}.refine.log"
    shell: "isoseq refine {input} {params.p} {output} -j 36 --require-polya 2>refine.err"

rule correct:
    input: sample + ".flnc.bam"
    output: sample + ".corrected.bam"
    conda: "envs/isoseq.yaml"
    params: whitelist = whitelist
    threads: 16
    log: "logs/isoseq/{sample}.log"
    shell: "isoseq3 correct --barcodes {params.whitelist} {input} {output} -j 36"
    