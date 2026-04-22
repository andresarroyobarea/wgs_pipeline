rule add_replace_rg:
    input:
        aligned= "results/alignment/{sample}_{lane}_sorted.bam"
    output:
        fixed_rg= temp("results/alignment/{sample}_{lane}_rg.bam")
    conda: config["envs"]["picard"]
    params:
        label=lambda wildcards: f"{wildcards.sample}_{config['hg_version']}",
        hg_version = config["hg_version"],
        panel = config["panel"],
        seq_platform = config["seq_platform"],
        extra = config["parameters"]["add_replace_rg"]["extra"]
    resources:
        mem_mb=get_resource(config, "add_replace_rg", "mem_mb"), 
        tmp_dir = config['TMPDIR'],
        runtime=get_resource(config, "add_replace_rg", "runtime")
    log:
        "log/alignment/{sample}_{lane}_add_or_replace.log",
    benchmark:
        "benchmarks/alignment/{sample}_{lane}_add_replace_rg.bmk",
    shell: 
        """
        picard -Xmx{resources.mem_mb}m AddOrReplaceReadGroups \
            INPUT={input.aligned} \
            OUTPUT={output.fixed_rg} \
            RGLB={params.panel} \
            RGPL={params.seq_platform} \
            RGPU={params.label} \
            RGSM={params.label} \
            RGID={params.label} \
            TMP_DIR={resources.tmp_dir} \
            {params.extra} \
            2>> {log}
        """

rule merge_bams: 
    input:
        bam_set = lambda wc: expand(
            "results/alignment/{sample}_{lane}_rg.bam",
            sample=wc.sample,
            lane=lanes
        )
    output:
        bam_merged = "results/alignment/{sample}_merged.bam"
    conda:
        config["envs"]["samtools"]
    params:
        extra = config["parameters"]["merge_bams"]["extra"]
    threads:
        get_resource(config, "merge_bams", "threads")
    resources:
        mem_mb=get_resource(config, "merge_bams", "mem_mb"),
        tmp_dir=config['TMPDIR'],
        runtime=get_resource(config, "merge_bams", "runtime")
    log:
        "log/alignment/{sample}_merge_bams.log",
    benchmark:
        "benchmarks/alignment/{sample}_merge_bams.bmk"
    shell:
        """
        samtools merge \
            -@ {threads} \
            {params.extra} \
            {output.bam_merged} \
            {input.bam_set} &> {log}
        """