import logging
import sys
from pathlib import Path

input_file = snakemake.input.get("config_tpl")
output_file = snakemake.output.get("config_filled")
genomes_db_path = snakemake.params.get("db")
log_file = snakemake.log[0]

logging.basicConfig(
    filename=log_file,
    level=logging.INFO
)

logging.info("Starting Fastq screen config rendering...")

template = Path(input_file).read_text()
rendered = template.replace("{db}", genomes_db_path)

Path(output_file).write_text(rendered)
logging.info("Finished config rendering")