rule add_replace_rg:
    input:
        aligned= "results/sorted/{sample}.bam"
    output:
        bam_fixed_rg= "results/alignment_processed/{sample}.bam"
    conda: 
        config["envs"]["picard"]
    params:
        rg_sm = lambda wc: wc.sample,
        rg_id = lambda wc: wc.sample,
        rg_lb = config["library"],
        rg_pl = config["seq_platform"],
        rg_pu = config["seq_run"],
        extra = config["parameters"]["add_replace_rg"]["extra"]
    resources:
        mem_mb=get_resource(config, "add_replace_rg", "mem_mb"), 
        tmp_dir = config['TMPDIR'],
        runtime=get_resource(config, "add_replace_rg", "runtime")
    log:
        "logs/alignment_processed/{sample}_add_or_replace.log",
    benchmark:
        "benchmarks/alignment_processed/{sample}_add_replace_rg.bmk",
    shell: 
        """
        picard -Xmx{resources.mem_mb}m AddOrReplaceReadGroups \
            INPUT={input.aligned} \
            OUTPUT={output.bam_fixed_rg} \
            RGSM={params.rg_sm} \
            RGID={params.rg_id} \
            RGLB={params.rg_lb} \
            RGPL={params.rg_pl} \
            RGPU={params.rg_pu} \
            TMP_DIR={resources.tmp_dir} \
            {params.extra} \
            2>> {log}
        """