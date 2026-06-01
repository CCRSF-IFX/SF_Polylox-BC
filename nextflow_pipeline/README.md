# Polylox-BC (Nextflow)

Iso-Seq barcode extraction pipeline, ported from the original Snakemake workflow.

## Pipeline steps

```
LIMA -> TAG -> REFINE -> CORRECT -> EXTRACT -> MAP -> TABLES
```

Each sample's HiFi BAM is demultiplexed (lima), tagged/refined/corrected
(isoseq), barcodes extracted to FASTA (extract_bc.py), mapped (minimap2),
and aggregated into a per-sample CSV (table_plots.py).

## Inputs

Edit `samplesheet.csv` (CSV, header `sample,bam`):

```
sample,bam
sample1,/abs/path/sample1.hifi.bam
sample2,/abs/path/sample2.hifi.bam
```

Set resource paths in `nextflow.config` (`params` block) or override on the
command line, e.g. `--primers /path/primers.fa`.

## Running

```bash
# Singularity (default)
nextflow run main.nf --input samplesheet.csv --outdir results

# Docker
nextflow run main.nf -profile docker --input samplesheet.csv

# On an HPC SLURM cluster
nextflow run main.nf -profile slurm,singularity --input samplesheet.csv
```

## Notes / things to verify

- **minimap2 reference**: the original Snakemake `map` rule called
  `minimap2 ... {input}` with no reference index — that command is incomplete.
  Add your reference (e.g. `minimap2 -a ref.mmi ${fasta}`) in the MAP process
  if alignment to a reference is intended.
- **isoseq subcommand**: the original used both `isoseq` and `isoseq3`.
  This port standardizes on `isoseq correct` (isoseq v4). Adjust if you pin v3.
- **Custom scripts** (`extract_bc.py`, `table_plots.py`) are assumed to take
  CLI arguments. They run in a generic pandas container — swap
  `params.python_container` for one that has Biopython/your deps if needed.
- Container tags are pinned to match your conda yamls (lima 2.7.1,
  isoseq 4.0.0, minimap2 2.26). Verify the exact biocontainer build hashes
  resolve in your environment.
