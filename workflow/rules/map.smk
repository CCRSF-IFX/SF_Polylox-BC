# map rules.
rule map:
    input: "{sample}.title_tag.fasta"
    output: "{sample}.mapped.txt"
    conda: "envs/minimap2.yaml"
    threads: 16
    log: "logs/map/{sample}.log"
    shell: "minimap2 -t 16 {input} -o {output}"
