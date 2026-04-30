rule add_replace_rg:
    input:
        aligned= "results/sorted/{sample}.bam"
    output:
        fixed_rg= "results/alignment_processed/{sample}.bam"
    conda: 
        config["envs"]["picard"]
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
        "log/alignment_processed/{sample}_add_or_replace.log",
    benchmark:
        "benchmarks/alignment_processed/{sample}_add_replace_rg.bmk",
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