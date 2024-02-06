# map rules.
rule map:
    input: sample + ".title_tag.fasta"
    output: sample + ".mapped.txt"
    conda: "envs/map.yaml"
    threads: 16
    log: "logs/map/{sample}.log"
    params: seg = segements
	shell: "minimap2 -t 16 {params.seg} {input} -o {output}"
    