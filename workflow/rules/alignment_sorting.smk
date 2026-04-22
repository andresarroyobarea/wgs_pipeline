rule novoalign_paired_novosort:
    input:
        fq1 ="data/{sample}_{lane}_R1.fastq.gz",
        fq2 ="data/{sample}_{lane}_R2.fastq.gz",
        genome_idx = config["genome_index"]
    output:
        aligned= temp("results/alignment/{sample}_{lane}_sorted.bam")
    params:
        novoalign_extra = config["parameters"]["novoalign"]["extra"],
        novosort_extra = config["parameters"]["novosort"]["extra"],
    threads: 
        get_resource(config, "novoalign", "threads")    
    resources:
        mem_mb=get_resource(config, "novoalign", "mem_mb"),
        tmp_dir=config['TMPDIR'],
        runtime=get_resource(config, "novoalign", "runtime")
    log:
        "log/alignment/{sample}_{lane}_alignment.log",
    benchmark:
        "benchmarks/alignment/{sample}_{lane}_alignment.bmk",
    shell:
        """
        (novoalign -d {input.genome_idx} \
            -f {input.fq1} {input.fq2} \
            -r All 5 \
            -c {threads} \
            -o BAM \
            {params.novoalign_extra} 2>> {log} \
        | novosort \
            -c {threads} \
            --tmpdir {resources.tmp_dir} \
            --ram {resources.mem_mb}M \
            {params.novosort_extra} - \
            ) \
            > {output.aligned} 2>> {log}
        """