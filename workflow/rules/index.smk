# THIS RULE SHOULD BE CONDITIONAL.
rule novoutil_iupac:
    input:
        fasta = ancient(config["reference"]["fasta"]),
        dbsnp = ancient(config["reference"]["dbsnp"]),
    output:
        #Think about output name and location.
         #fasta_snp_aware = temp("workflow/resources/reference/hg38/v1/hg38_dbsnp146_M5.fa")
    params:
        extra = config["parameters"]["novoutil_iupac"]["extra"]
    resources:
        mem_mb=get_resource(config, "novoutil_iupac", "mem_mb"),
        tmp_dir=config['TMPDIR'],
        runtime=get_resource(config, "novoutil_iupac", "runtime")
    log:
        "logs/novoutil_iupac/genome_snp_aware.log",
    benchmark:
        "benchmarks/novoutil_iupac/genome_snp_aware.bmk",
    shell:
        """
        novoutil iupac \
            {input.dbsnp} \
            {input.fasta} \
            {params.extra} | gzip 
            > {output.snp_aware} 2>> {log}
        """

# THIS RULE SHOULD BE CONDITIONAL.
# TODO: Add rule to remove specific sequences from the genome. Eg: "alt"

# THIS RULE IS MANDATORY.
rule novoindex:
    input:
        rules.novoutil_iupac.output.fasta_snp_aware,
    output:
        index = config["reference"]["index"]
    params:
        extra = config["parameters"]["novoindex"]["extra"]
    resources:
        mem_mb=get_resource(config, "novoindex", "mem_mb"),
        tmp_dir=config['TMPDIR'],
        runtime=get_resource(config, "novoindex", "runtime")
    log:
        "logs/novoindex/genome_indexing.log",
    benchmark:
        "benchmarks/novoindex/genome_indexing.bmk",
    shell:
        """
        novoindex \
            {params.extra} \
            {output.index} \
            {input} \
            2>> {log}
        """


# TODO: Add resources and params of indexing rules in config.yaml.
