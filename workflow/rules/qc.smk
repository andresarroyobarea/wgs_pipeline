rule fastqc_raw:
    input:
        fastq = "data/{sample}_{read}.fastq.gz",
    output:
        html = "results/qc/fastqc/{sample}_{read}_fastqc.html",
        zip = "results/qc/fastqc/{sample}_{read}_fastqc.zip",
    threads:
        get_resource(config, "fastqc", "threads"),
    resources:
        mem_mb=get_resource(config, "fastqc", "mem_mb"),
        runtime=get_resource(config, "fastqc", "runtime")
    params:
        outdir=lambda wildcards, output: os.path.dirname(output.html),
        extra = config["parameters"]["fastqc"]["extra"],
    conda:
        config["conda_envs"]["fastqc"]
    log:
        "logs/qc/fastqc/{sample}_{read}.log"
    benchmark:
        "benchmarks/qc/fastqc/{sample}_{read}.bmk"
    shell:
        """
        mkdir -p {params.outdir} &&
        fastqc --outdir {params.outdir} \
            --threads {threads} \
            {input.fastq} \
            {params.extra} 2> {log} 
        """

rule fastq_screen:
    input: 
        fastq = "data/{sample}_{read}.fastq.gz"
    output: 
        txt = "results/qc/fastq_screen/{sample}_{read}_screen.txt",
        png = "results/qc/fastq_screen/{sample}_{read}_screen.png"
    conda: 
        config["conda_envs"]["fastq_screen"]
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
        "logs/qc/fastq_screen/{sample}_{read}_screen.log"
    benchmark:
        "benchmarks/qc/fastq_screen/{sample}_{read}_screen.bmk"
    shell:
        """
        fastq_screen {input.fastq} \
            --aligner {params.aligner} \
            --conf {params.config} \
            --outdir {params.outdir} \
            {params.extra} \
            --threads {threads} 2> {log}
        """

rule fastqc_alignment:
    input:
        bam = "results/alignment_processed/{sample}.bam"
    output:
        html = "results/qc/alignment/fastqc/{sample}/{sample}_fastqc.html",
        zip = "results/qc/alignment/fastqc/{sample}/{sample}_fastqc.zip"
    conda:
        config["conda_envs"]["fastqc"]
    threads: 
        get_resource(config, "fastqc", "threads")
    resources:
        mem_mb = get_resource(config, "fastqc", "mem_mb"),
        runtime = get_resource(config, "fastqc", "runtime"),
    params: 
        outdir = lambda wildcards, output : os.path.dirname(output.html),
        extra = config["parameters"]["fastqc"]["extra"],
    log:
        "logs/qc/alignment/fastqc/{sample}_alignment_fastqc.log"
    benchmark:
        "benchmarks/qc/alignment/fastqc/{sample}_alignment_fastqc.bmk"
    shell:
        """
        mkdir -p {params.outdir} &&
        fastqc --outdir {params.outdir} \
            --threads {threads} \
            {input.bam} \
            {params.extra} 2> {log} 
        """

rule qualimap_bamqc:
    input:
        bam = "results/alignment_processed/{sample}.bam"
    output:
        qmap_report="results/qc/alignment/qualimap/bamqc/{sample}/qualimapReport.html",
        qmap_res="results/qc/alignment/qualimap/bamqc/{sample}/genome_results.txt"
    conda:
        config["conda_envs"]["qualimap"]
    threads: 
        get_resource(config, "qualimap", "threads")
    resources:
        mem_mb = get_resource(config, "qualimap", "mem_mb"),
        runtime = get_resource(config, "qualimap", "runtime")
    params:
        genome = config["parameters"]["qualimap"]["genome"],
        annotation = config["parameters"]["qualimap"]["annotation"],
        mem = f"{get_resource(config, 'qualimap', 'mem_mb') // 1024}G",
        outdir = lambda wildcards, output: os.path.dirname(output.qmap_report),
        extra_single = config["parameters"]["qualimap"]["extra_single"],
    log: 
        "logs/QC/alignment/qualimap/bamqc/{sample}_qualimap_bamqc.log"
    benchmark:
        "benchmarks/{sample}_qualimap_bamqc.bmk"
    shell: 
        """
        qualimap bamqc \
         -bam {input.bam} \
         -gd {params.genome} \
         -gff {params.annotation} \
         -nt {threads} \
         --outdir {params.outdir} \
         {params.extra_single} \
         --java-mem-size={params.mem} 2> {log}
        """

rule qualimap_multi_bamqc:
    input:
        expand("results/qc/alignment/qualimap/bamqc/{sample}/qualimapReport.html", sample = samples)
    output:
        qmap_report = "results/qc/alignment/qualimap/multi_bamqc/multisampleBamQcReport.html"
    conda:
        config["conda_envs"]["qualimap"]
    threads:
        # TODO: Check if this rule needs the same resources as the single-sample bamqc rule, or if it can be run with less resources. 
        get_resource(config, "qualimap", "threads") 
    resources:
        mem_mb = get_resource(config, "qualimap", "mem_mb"),
        runtime = get_resource(config, "qualimap", "runtime")
    params: 
        # TODO: Preparare metadata input txt file.
        qmap_input = "metadata/qualimap_multi_bamqc_input.txt",
        outdir = lambda wildcards, output: os.path.dirname(output.qmap_report),
        extra_multi = config["parameters"]["qualimap"]["extra_multi"]
    log: 
        "logs/qc/alignment/qualimap/multi_bamqc/qualimap_multi_bamqc.log"
    benchmark:
        "benchmarks/qualimap_multi_bamqc.bmk"
    shell:
        "qualimap multi-bamqc \
            -d {params.qmap_input} \
            --outdir {params.outdir} \
            {params.extra_multi} 2> {log} "

rule samtools_qc:
    input:
        bam = "results/alignment_processed/{sample}.bam"
    output:
        samtools_stats = "results/qc/alignment/samtools_qc/{sample}/{sample}.bam.stats",
        samtools_flagstat = "results/qc/alignment/samtools_qc/{sample}/{sample}.bam.flagstat"
    conda:
        config["conda_envs"]["samtools"]
    threads: 
        get_resource(config, "samtools_qc", "threads")
    resources:
        mem_mb = get_resource(config, "samtools_qc", "mem_mb"),
        runtime = get_resource(config, "samtools_qc", "runtime")
    params:
        extra_stats = config["parameters"]["samtools_qc"]["extra_stats"]
    log:
        log_stats = "log/qc/alignment/samtools_qc/{sample}_samtools_stats.log",
        log_flagstat = "log/qc/alignment/samtools_qc/{sample}_samtools_flagstat.log"
    shell:"""
        samtools stats {input.bam} -@ {threads} {params.extra_stats} > {output.samtools_stats} 2> {log.log_stats} &&
        samtools flagstat {input.bam} -@ {threads} > {output.samtools_flagstat} 2> {log.log_flagstat}
    """

rule multiqc_concat:
    input:
        fastqc=expand("results/qc/fastqc/{sample}_{read}_fastqc.html", sample=samples, read=config["read"]),
        fastq_screen=expand("results/qc/fastq_screen/{sample}_{read}_screen.txt", sample=samples, read=config["read"]),
        fastqc_alignment=expand("results/qc/alignment/fastqc/{sample}/{sample}_fastqc.html", sample=samples),
        qmap_report = "results/qc/alignment/qualimap/multi_bamqc/multisampleBamQcReport.html",
        samtools_stats=expand("results/qc/alignment/samtools_qc/{sample}/{sample}.bam.stats", sample=samples),
        samtools_flagstat=expand("results/qc/alignment/samtools_qc/{sample}/{sample}.bam.flagstat", sample=samples)
    output:
        multiqc_report="results/qc/multiqc_report.html",
    conda:
        config["conda_envs"]["multiqc"]
    params:
        extra="--verbose",
        outdir=lambda wc, output: os.path.dirname(output.multiqc_report),
    log:
        "logs/fastqc/multiqc.log",
    benchmark:
        "benchmarks/fastqc/multiqc.bmk"
    shell: 
        "multiqc {params.outdir} -o {params.outdir} {params.extra} 2> {log} "
