rule fastqc_concat:
    input:
        concatenated_fastq = "data/{sample}_{read}.fastq.gz",
    output:
        html = "results/qc/fastqc/{sample}_{read}_fastqc.html",
        zip = "results/qc/fastqc/{sample}_{read}_fastqc.zip",
    resources:
        mem_mb=get_resource(config, "qc", "mem_mb"),
        runtime=get_resource(config, "qc", "runtime")
    params:
        lambda wc: "-t {}".format(get_resource(config, "qc", "threads")),
        outdir=lambda wildcards, output: os.path.dirname(output.html),
    log:
        "logs/qc/fastqc/{sample}_{read}.log"
    benchmark:
        "benchmarks/qc/fastqc/{sample}_{read}.bmk"
    wrapper: # TODO: Think about adding this wrapper as conda env.
        config["wrapper"]["qc"]


rule fastq_screen:
    input: 
        fastq = "data/{sample}_{read}.fastq.gz"
    output: 
        fastq_screen_txt = "results/qc/fastq_screen/{sample}_{read}_screen.txt",
        fastq_screen_png = "results/qc/fastq_screen/{sample}_{read}_screen.png"
    conda: # TODO: Add fastq screen as a conda env.
        config["conda_envs"]["fastq_screen"]
    # TODO: Add threads and resources to config file
    threads: 
        get_resource("fastq_screen", "threads")
    resources:
        mem_mb = get_resource("fastq_screen", "mem_mb"),
        runtime = get_resource("fastq_screen", "runtime")
    params: # TODO: Look into aligner and config files info in CNIO Cluster.
        fastq_screen_config = config["fastq_screen_conf"],
        aligner = config["fastq_screen_aling"],
        outdir = lambda wildcards, output: os.path.dirname(output.fastq_screen_txt)
    log:
        "log/qc/fastq_screen/{sample}_{read}_screen.log"
    benchmark:
        "benchmarks/qc/fastq_screen/{sample}_{read}_screen.bmk"
    shell:"""
        fastq_screen {input.fastq} --aligner {params.aligner} \
            --conf {params.fastq_screen_config} --outdir {params.outdir} \
            -threads {threads} 2> {log}
    """

# Añadir output de FASTQ screen aqui
rule multiqc_concat:
    input:
        fastqc=expand("results/fastqc/{sample}_{read}_fastqc.html", sample=samples, read=config["read"]),
    output:
        multiqc_report="results/fastqc/multiqc_report.html",
    params:
        extra="--verbose",
        outdir=lambda wc, output: os.path.dirname(output.multiqc_report),
    log:
        "logs/fastqc/multiqc.log",
    benchmark:
        "benchmarks/fastqc/multiqc.bmk"
    wrapper:
        config["wrapper"]["multiqc"]