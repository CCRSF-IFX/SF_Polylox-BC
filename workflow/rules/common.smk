from snakemake.utils import validate
import pandas as pd

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
singularity: "docker://continuumio/miniconda3"

##### load config and sample sheets #####

configfile: "config/config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

samplepd = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
samplepd.index.names = ["sample_id"]
#validate(samplepd, schema="../schemas/samples.schema.yaml")

analysis = config.analysispath
samples = samplepd["filename"].to_list()

primers = config.primers
whitelist = config.whitelist