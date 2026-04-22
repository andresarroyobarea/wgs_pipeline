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
pipe_mode = config["alignment_sorting_strategy"]

if pipe_mode == "combined":

    include: "workflow/rules/alignment_sorting.smk"

elif pipe_mode == "separate":

    include: "workflow/rules/alignment.smk"
    include: "workflow/rules/sorting.smk"

else:
    raise ValueError(f"Unknown alignment_sorting_strategy: {pipe_mode}")

include: "workflow/rules/bam_processing.smk"


# ---- Target rules ---- #
rule all:
    input:
        expand(
            "results/alignment/{sample}_merged.bam",
            sample=samples
        )