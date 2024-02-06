# Python scripts to extract barcodes and output results.
rule extract:
    input: sample + ".corrected.bam"
    output: out = sample + ".title_tag.fasta"
    conda: "envs/myenv.yaml"
    log: "logs/extract/{sample}.log"
	scripts: "scripts/extract_bc.py {input} {output}"

rule tables:
    input: sample + ".mapped.txt"
    output: out = sample + "._aggregated_data.csv"
    params: prefix = sample
    conda: "envs/myenv.yaml"
    log: "logs/tables/{sample}.log"
	scripts: "scripts/table_plots.py -i {input} -o {params.prefix}"