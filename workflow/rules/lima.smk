# An example collection of Snakemake rules imported in the main Snakefile.
rule lima:
    input: sample + ".hifi.bam"
    output: sample + ".5p--3p.bam",sample + ".lima.clips"
    conda: "envs/lima.yaml"
    params: p = primers, prefix = sample
    threads: 16
    log: "logs/lima/{sample}.log"
    shell: "lima -j {threads} --per-read --isoseq {input} {params.p} {params.prefix}"
    