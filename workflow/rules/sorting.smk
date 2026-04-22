rule novosort:
    input:
        aligned= "results/alignment/{sample}_{lane}.bam"
    output:
        sorted= temp("results/alignment/{sample}_{lane}_sorted.bam")
    params:
        extra = config["parameters"]["novosort"]["extra"]
    threads:
        get_resource(config, "novosort", "threads")
    resources:
        mem_mb=get_resource(config, "novosort", "mem_mb"),
        tmp_dir= config["TMPDIR"],
        runtime=get_resource(config, "novosort", "runtime")
    log:
        "log/alignment/{sample}_{lane}_novosort.log",
    benchmark:
        "benchmarks/alignment/{sample}_{lane}_novosort.bmk",
    shell:
        """
        novosort \
            {input.aligned} \
            -c {threads} \
            --tmpdir {resources.tmp_dir} \
            --ram {resources.mem_mb}M \
            {params.extra} \
            > {output.sorted} 2>> {log}
        """