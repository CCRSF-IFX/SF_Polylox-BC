import argparse
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def read_mapped_file(file_path):
    with open(file_path, 'r') as file:
        return file.readlines()

def process_mapped_data(mapped_data):
    ccs_targets = {}
    for line in mapped_data:
        parts = line.strip().split("\t")
        ccs_read_id, target_id, start_pos, strand = parts[0], parts[5], int(parts[2]), parts[4]
        ccs_targets.setdefault(ccs_read_id, []).append((target_id, start_pos, strand))

    # Sort targets for each read_id based on start_pos
    for ccs_read_id in ccs_targets:
        ccs_targets[ccs_read_id] = sorted(ccs_targets[ccs_read_id], key=lambda x: x[1])

    return ccs_targets

def generate_output_dataframe(ccs_targets, output_csv_path):
    data_list = []
    for ccs_read_id, targets in ccs_targets.items():
        out = "".join(tp[0][1] if tp[2] == "+" else tp[0][0] for tp in targets)
        data_list.append([ccs_read_id, out])
    
    df_lox = pd.DataFrame(data_list, columns=["ccs", "polylox"])
    df_lox[['ccs', 'cb', 'xm']] = df_lox['ccs'].str.split('#', expand=True)

    df_lox.to_csv(output_csv_path, index=False)
    
    return df_lox

def generate_summary_tables(df_lox):
    summary_table = pd.crosstab(df_lox['cb'], df_lox['polylox'])
    return summary_table

def generate_visualizations(summary_table, top_num, heatmap_png_path, barplot_png_path):
    # Heatmap
    plt.figure(figsize=(12, 10))
    sns.heatmap(summary_table, annot=True, fmt='d', cmap='viridis')
    plt.title(f'Heatmap of Top {top_num} Polylox Barcodes per Cell Barcode')
    plt.xlabel('Polylox Barcodes')
    plt.ylabel('Cell Barcodes')
    plt.savefig(heatmap_png_path, dpi=300)

    # Stacked bar plot
    ax = summary_table.plot(kind='bar', stacked=True, figsize=(14, 10), legend=True)
    ax.legend(loc='center left', bbox_to_anchor=(1, 0.5), title='Polylox Barcodes')
    plt.title(f'Stacked Bar Plot of Top {top_num} Polylox Barcodes per Cell Barcode')
    plt.xlabel('Cell Barcodes')
    plt.ylabel('Counts of Polylox Barcodes')
    plt.tight_layout()
    plt.savefig(barplot_png_path, dpi=300)

def generate_aggregated_data(df_lox, cell_counts_csv_path, polylox_counts_csv_path, aggregated_data_csv_path):
    df_lox['cb'].value_counts().to_csv(cell_counts_csv_path)
    df_lox['polylox'].value_counts().to_csv(polylox_counts_csv_path)

    aggregated_data = df_lox.groupby('cb').agg(
        count=('cb', 'size'), 
        polylox_barcodes=('polylox', lambda x: ', '.join(set(x)))
    ).reset_index()
    aggregated_data.rename(columns={'count': 'barcode_count'}, inplace=True)
    aggregated_data.sort_values('barcode_count', ascending=False, inplace=True)
    aggregated_data.to_csv(aggregated_data_csv_path, index=False)


def get_arguments():
    parser = argparse.ArgumentParser(description='Process mapped data and generate reports.')
    parser.add_argument('-i', '--input_file', required=True, help='Input mapped file')
    parser.add_argument('-o', '--output_prefix', required=True, help='Output file prefix for all output files')
    return parser.parse_args()

def main():
    args = get_arguments()
    
    input_file = args.input_file
    output_prefix = args.output_prefix
    
    # File paths using the output prefix
    output_csv_path = f"{output_prefix}_seg_assemble.csv"
    heatmap_png_path = f"{output_prefix}_heatmap.png"
    barplot_png_path = f"{output_prefix}_barplot.png"
    cell_counts_csv_path = f"{output_prefix}_cell_counts.csv"
    polylox_counts_csv_path = f"{output_prefix}_polylox_counts.csv"
    aggregated_data_csv_path = f"{output_prefix}_aggregated_data.csv"

    all_mapped = read_mapped_file(input_file)
    ccs_targets = process_mapped_data(all_mapped)
    df_lox = generate_output_dataframe(ccs_targets, output_csv_path)
    summary_table = generate_summary_tables(df_lox)

    generate_visualizations(summary_table, TOP_NUM, heatmap_png_path, barplot_png_path)
    generate_aggregated_data(df_lox, cell_counts_csv_path, polylox_counts_csv_path, aggregated_data_csv_path)

if __name__ == '__main__':
    main()