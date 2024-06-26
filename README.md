# SF High-Res Cell Lineage Mapping: Integrating Polylox Barcodes with Pacbio Cell Barcodes

This repository contains workflows/scripts for processing Pacbio reads integrated with cell barcodes to Polylox barcodes, generating comprehensive reports and visualizations for Polylox barcode analysis.
![Polylox Barcode Analysis](/resources/analysis.PNG)
## Description
The project utilizes the innovative Polylox barcode system in conjunction with PacBio sequencing and 10X cell barcodes for high-resolution lineage tracing and cell tracking. Polylox barcodes enable detailed fate mapping within the hematopoietic system through Cre-dependent recombination, creating an extensive array of unique barcodes. PacBio's long-read sequencing captures comprehensive barcode information, ensuring accurate lineage tracing. Additionally, 10X cell barcoding allows single-cell resolution, linking each read to its cell of origin, thus providing a robust platform for dissecting cellular dynamics and understanding the complex interplay of cell differentiation and development at an individual cell level. This integrated approach offers unprecedented insights into cell lineage and fate, crucial for advancing research in developmental biology, stem cell research, and related fields.
![Experiment design](/resources/design.PNG)
![Pacbio reads](/resources/pcr.PNG)

The SF Polylox Barcode Processor is designed to read mapped data, perform data transformation and aggregation, and visualize the results in a meaningful way. It supports operations such as reading from BAM files, extracting specific tags, generating FASTA files, and creating visual reports like heatmaps and bar plots to represent the processed data effectively.

## PacBio Tools Used in the Pipeline

The Snakemake pipeline utilizes a series of PacBio tools designed for the processing and refinement of high-fidelity (HiFi) sequencing data:

1. **Lima**: For demultiplexing HiFi reads, Lima takes a `.bam` file and separates the reads based on provided primer sequences, producing demultiplexed `.bam` files and clip information.

2. **Iso-Seq3 tag**: A component of the Iso-Seq3 suite, this tool tags reads with library preparation information, such as cDNA primers or barcodes, using the output from Lima.

3. **Iso-Seq3 refine**: This Iso-Seq3 tool processes the tagged `.bam` files to trim primers and artifacts, and to select for reads with poly-A tails, yielding a set of full-length non-chimeric (FLNC) reads.

4. **Iso-Seq3 correct**: It corrects barcodes within FLNC reads against a whitelist of known barcodes, ensuring accurate barcode assignments for data interpretation.

Additionally, the pipeline integrates custom scripts and external tools:

- **Custom Python Script (extract_bc.py)**: Extracts title tags from the corrected `.bam` file, producing a `.fasta` file for downstream mapping and data aggregation.
- **Minimap2**: Aligns sequences to a reference genome, crucial for identifying the genomic origin of each read.
- **Custom Python Script (table_plots.py)**: Generates aggregated data in CSV format from the mapped text file, facilitating detailed analysis and visualization.

Each of these components plays a vital role in ensuring the quality and accuracy of the sequencing data for in-depth lineage mapping and barcode analysis.


## Features
This repository presents a streamlined Snakemake pipeline for advanced cell lineage tracing, integrating Polylox barcodes with PacBio and 10X Genomics sequencing. Key features include:

- **Reads Processing**: Utilizes Lima for precise demultiplexing and IsoSeq for read tagging and refinement, ensuring high-quality input data.
- **Barcode Management**: Incorporates IsoSeq for barcode correction and a custom script for extracting and annotating barcodes, guaranteeing accurate lineage tracing.
- **Efficient Mapping and Aggregation**: Employs minimap2 for robust read mapping and a custom script for organized data aggregation, facilitating comprehensive analysis.
- **Comprehensive Outputs**: Generates an array of outputs including BAM, FASTQ, and CSV files, offering both raw and processed data for in-depth analysis.
- **Parallel Processing and Logging**: Optimized for high-throughput data and parallel processing with dedicated error logging for each step, ensuring efficiency and ease of troubleshooting.

This pipeline provides a complete solution for high-resolution lineage analysis, from sequence processing to data visualization, tailored for efficiency and accuracy.

## Usage

### Step 1: Obtain a Copy of the Workflow

 **Clone the Repository**: Clone the new repository to your local machine, choosing the directory where you want to perform data analysis. Instructions for cloning can be found [here](https://help.github.com/en/articles/cloning-a-repository).

### Step 2: Configure the Workflow
Tailor the workflow to your project's requirements:
- Edit `config.yaml` in the `config/` directory to set up the workflow execution parameters.
- Modify `samples.tsv` to outline your sample setup, ensuring it reflects your specific data structure and requirements.

### Step 3: Install Snakemake
Install Snakemake via conda with the following command:
```bash
conda create -c bioconda -c conda-forge -n snakemake snakemake
```
### Step 4: Execute the Workflow

1. **Activate the Conda Environment**:
    ```bash
    conda activate snakemake
    ```

2. **Test the Configuration**:
    Perform a dry-run to validate your setup:
    ```bash
    snakemake --use-conda -n
    ```

3. **Local Execution**:
    Execute the workflow on your local machine using `$N` cores:
    ```bash
    snakemake --use-conda --cores $N
    ```
    Here, `$N` represents the number of cores you wish to allocate for the workflow.

4. **Cluster Execution**:
    For cluster environments, submit the workflow as follows:
    ```bash
    snakemake --use-conda --cluster slurm --jobs 100
    ```
    Replace `100` with the number of jobs you intend to submit simultaneously. Ensure your cluster environment is correctly configured to handle Snakemake jobs.

## Output

Upon successful execution, the integrated pipeline comprising the two scripts generates a comprehensive set of files, encapsulating both raw and processed data alongside insightful visualizations. Specifically, the output includes:

### FASTA File:
- Generated from the BAM file, this file contains the extracted barcode data, providing a foundation for downstream mapping and analysis.

### CSV Files:
- **Aggregated Data**: A detailed summary of the processed data, including counts, unique Polylox barcodes, and other relevant metrics for each cell barcode.
- **Cell Counts**: Quantitative data on the occurrence of each cell barcode within the dataset.
- **Polylox Counts**: A summary of the frequency of each Polylox barcode, offering insights into the distribution and prevalence of lineages.
- **Segment Assembly**: Aggregated data from the BAM processing and mapping steps, serving as a comprehensive overview of the sequencing output and barcode distribution.

### Visualizations (PNG Format):
- **Heatmap**: A graphical representation of the relationship between cell barcodes and Polylox barcodes, highlighting the distribution and co-occurrence patterns.
- **Stacked Bar Plot**: A visual breakdown of Polylox barcode counts per cell barcode, providing a clear, comparative view of lineage contributions across different cells.

Each output file is designed to offer both detailed, granular data for in-depth analysis and summarized, visual representations for quick insights and comparative studies. This balanced approach ensures that researchers can delve into the specifics of their data while also gaining a broader understanding of their experimental results.

## Contact
CCRSF_IFX@nih.gov
