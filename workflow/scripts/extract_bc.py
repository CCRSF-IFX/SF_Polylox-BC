import pysam
import argparse
import logging

def reverse_complement(seq):
    complement = {'A': 'T', 'C': 'G', 'G': 'C', 'T': 'A'}
    return ''.join(complement[base] for base in reversed(seq))

def process_bam(input_file, output_file):
    with pysam.AlignmentFile(input_file, "rb", check_sq=False) as bam_file, open(output_file, 'w') as fasta_file:
        for read in bam_file:
            # Check if the tags exist
            try:
                xm_tag = reverse_complement(read.get_tag('XM'))
                cb_tag = reverse_complement(read.get_tag('CB'))
            except KeyError:
                logging.warning(f"Skipping read {read.query_name}: missing XM or CB tags")
                continue  # Skip the read if the XM or CB tags are missing

            # Extract the read name and sequence
            read_name = read.query_name
            sequence = read.query_sequence

            # Write the information to the FASTA file
            fasta_title = f"{read_name}#{cb_tag}#{xm_tag}"
            fasta_file.write(f">{fasta_title}\n{sequence}\n")
        logging.info(f"Processing complete. Output written to {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Process a BAM file and output barcode tagged FASTA file.')
    parser.add_argument('input_file', help='Input BAM file')
    parser.add_argument('output_file', help='Output FASTA file')
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
    
    process_bam(args.input_file, args.output_file)

if __name__ == '__main__':
    main()