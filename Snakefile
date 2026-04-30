import glob
import os
import sys
import pandas as pd
from workflow.utils.common import get_resource, get_R1_fastqs, get_R2_fastqs

configfile: "config/config.yaml"

wildcard_constraints:
    sample="[^/]+"

# ---- Config and global variables ---- #
# Load samples
units = pd.read_table(config["units"], dtype=str).set_index(["sample", "lane"], drop=False)
units.index = units.index.set_levels([i.astype(str) for i in units.index.levels])

# Samples
samples=units['sample'].unique()

# Lanes
lanes=units['lane'].unique()

# ---- RULE MODULES ---- #
include: "workflow/rules/concat_fastq.smk"
include: "workflow/rules/alignment.smk"
include: "workflow/rules/sorting.smk"
include: "workflow/rules/bam_processing.smk"


# ---- Target rules ---- #
rule all:
    input:
        expand(
            "results/alignment_processed/{sample}.bam",
            sample=samples
        )