import glob
import os
import sys
from workflow.utils.common import get_resource

configfile: "config/config.yaml"

# ---- Config and global variables ---- #
# Samples
samples = config["SAMPLES"]

# Lanes
lanes = config["LANES"]


# ---- RULE MODULES ---- #
include: "workflow/rules/alignment.smk"
include: "workflow/rules/sorting.smk"
include: "workflow/rules/bam_processing.smk"


# ---- Target rules ---- #
rule all:
    input:
        expand(
            "results/alignment/{sample}_merged.bam",
            sample=samples
        )