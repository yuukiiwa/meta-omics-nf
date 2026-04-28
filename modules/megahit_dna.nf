process MEGAHIT_DNA {
    label "process_high"
	tag "${sample_id}"
	publishDir "${params.outdir}/decont/DNA/megahit/", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*.contigs.fa.gz"                             , emit: contigs
    path "intermediate_contigs/k*.contigs.fa.gz"       , emit: k_contigs
    path "intermediate_contigs/k*.addi.fa.gz"          , emit: addi_contigs
    path "intermediate_contigs/k*.local.fa.gz"         , emit: local_contigs
    path "intermediate_contigs/k*.final.contigs.fa.gz" , emit: kfinal_contigs
    path '*.log'                                       , emit: log

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    """
    megahit \\
        ${args} \\
        -t ${task.cpus} \\
        -1 ${reads[0]} -2 ${reads[1]} \\
        --out-prefix ${sample_id}

    pigz \\
        --no-name \\
        -p ${task.cpus} \\
        ${args2} \\
        megahit_out/*.fa \\
        megahit_out/intermediate_contigs/*.fa

    mv megahit_out/* .
    """

    stub:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def reads_command = meta.single_end || !reads2 ? "-r ${reads1}" : "-1 ${reads1.join(',')} -2 ${reads2.join(',')}"
    """
    mkdir -p intermediate_contigs
    echo "" | gzip > ${sample_id}.contigs.fa.gz
    echo "" | gzip > intermediate_contigs/k21.contigs.fa.gz
    echo "" | gzip > intermediate_contigs/k21.addi.fa.gz
    echo "" | gzip > intermediate_contigs/k21.local.fa.gz
    echo "" | gzip > intermediate_contigs/k21.final.contigs.fa.gz
    touch ${sample_id}.log
    """
}
