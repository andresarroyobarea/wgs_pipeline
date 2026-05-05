rule fastqc_raw:
    input:
        fastq = "data/{sample}_{read}.fastq.gz",
    output:
        html = "results/qc/fastqc/{sample}_{read}_fastqc.html",
        zip = "results/qc/fastqc/{sample}_{read}_fastqc.zip",
    resources:
        mem_mb=get_resource(config, "fastqc", "mem_mb"),  # TODO: Check if this is useful when no mem parameter exists.
        runtime=get_resource(config, "fastqc", "runtime")
    params:
        lambda wc: "-t {}".format(get_resource(config, "fastqc", "threads")),
        outdir=lambda wildcards, output: os.path.dirname(output.html),
        extra = config["parameters"]["fastqc"]["extra"],
    conda:
        config["conda_envs"]["qc"]
    log:
        "logs/qc/fastqc/{sample}_{read}.log"
    benchmark:
        "benchmarks/qc/fastqc/{sample}_{read}.bmk"
    wrapper:
        "mkdir -p {params.outdir} &&"
        "fastqc --outdir {params.outdir} --threads {threads} {input.concat_fastq} 2> {log} "


rule fastq_screen:
    input: 
        fastq = "data/{sample}_{read}.fastq.gz"
    output: 
        txt = "results/qc/fastq_screen/{sample}_{read}_screen.txt",
        png = "results/qc/fastq_screen/{sample}_{read}_screen.png"
    conda: 
        config["conda_envs"]["qc"]
    threads: 
        get_resource(config, "fastq_screen", "threads"),
    resources:
        mem_mb = get_resource(config, "fastq_screen", "mem_mb"), # TODO: Check if this is useful when no mem parameter exists.
        runtime = get_resource(config, "fastq_screen", "runtime")
    params:
        config = config["parameters"]["fastq_screen"]["config"],
        aligner = config["parameters"]["fastq_screen"]["aligner"],
        outdir = lambda wildcards, output: os.path.dirname(output.txt),
        extra = config["parameters"]["fastq_screen"]["extra"],
    log:
        "log/qc/fastq_screen/{sample}_{read}_screen.log"
    benchmark:
        "benchmarks/qc/fastq_screen/{sample}_{read}_screen.bmk"
    shell:"""
        fastq_screen {input.fastq} --aligner {params.aligner} \
            --conf {params.config} --outdir {params.outdir} \
            {params.extra} -threads {threads} 2> {log}
    """

rule fastqc_alignment:
    input:
        bam = "results/alignment_processed/{sample}.bam"
    output:
        html = "results/qc/alignment/fastqc/{sample}/{sample}_fastqc.html",
        zip = "results/qc/alignment/fastqc/{sample}/{sample}_fastqc.zip"
    conda:
        config["conda_envs"]["qc"]
    threads: 
        get_resource(config, "fastqc", "threads")
    resources:
        mem_mb = get_resource(config, "fastqc", "mem_mb"),
        runtime = get_resource(config, "fastqc", "runtime")
    params: 
        outdir = lambda wildcards, output : os.path.dirname(output.html)
    log:
        "log/qc/alignment/fastqc/{sample}_alignment_fastqc.log"
    shell:
        "mkdir -p {params.outdir} &&"
        "fastqc --outdir {params.outdir} --threads {threads} {input.bam} 2> {log} "

rule qualimap_bamqc:
    input:
        bam = "results/alignment/{sample}_Aligned.sortedByCoord.out.bam"
    output:
        "results/qc/alignment/qualimap/bamqc/{sample}/qualimapReport.html",
        "results/qc/alignment/qualimap/bamqc/{sample}/genome_results.txt"
    conda:
        config["conda_envs"]["qc"]
    threads: 
        get_resource(config, "qualimap", "threads")
    resources:
        mem_mb = get_resource("qualimap", "mem_mb"),
        runtime = get_resource("qualimap", "runtime")
    params:
        genome = config["parameters"]["qualimap"]["genome"],
        annotation = config["parameters"]["qualimap"]["annotation"],
        mem = f"{get_resource(config, 'qualimap', 'mem_mb') // 1024}G"
        outdir = lambda wildcards, output: os.path.dirname(output.qmap_report),
    log: 
        "log/QC/alignment/qualimap/bamqc/{sample}_qualimap_bamqc.log"
    benchmark:
        "benchmarks/{sample}_qualimap_bamqc.bmk"
    shell: """
        qualimap bamqc \
         -bam {input.bam} \
         -gd {params.genome} \
         -gff {params.annotation} \
         -nt {threads} \
         --outdir {params.outdir} \
         --java-mem-size={params.mem} 2> {log}
    """


rule multiqc_concat:
    input:
        fastqc=expand("results/fastqc/{sample}_{read}_fastqc.html", sample=samples, read=config["read"]),
        fastq_screen=expand("results/fastq_screen/{sample}_{read}_screen.txt", sample=samples, read=config["read"]),
        fastqc_alignment=expand("results/qc/alignment/fastqc/{sample}_fastqc.html", sample=samples),
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