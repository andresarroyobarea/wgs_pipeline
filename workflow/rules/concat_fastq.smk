rule concat_R1_reads:
    input: lambda wc: get_R1_fastqs(units, wc),
    output: 
        R1_concat = "data/{sample}_R1.fastq.gz"
    resources:
        mem_mb = get_resource(config, "default", "mem_mb"),
        runtime = get_resource(config, "default", "runtime")
    log:
        "log/concat/{sample}_concat_R1.log"
    shell:
        "cat {input} > {output.R1_concat} 2> {log}"

rule concat_R2_reads:
    input: lambda wc: get_R2_fastqs(units, wc),
    output: 
        R2_concat = "data/{sample}_R2.fastq.gz"
    resources:
        mem_mb = get_resource(config, "default", "mem_mb"),
        runtime = get_resource(config, "default", "runtime")
    log:
        "log/concat/{sample}_concat_R2.log"
    shell:
        "cat {input} > {output.R2_concat} 2> {log}"