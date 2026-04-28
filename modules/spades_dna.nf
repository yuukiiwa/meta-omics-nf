process SPADES_DNA {
    label "process_high"
	tag "${sample_id}"
	publishDir "${params.outdir}/decont/DNA/spades/", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    path '*.scaffolds.fa.gz'     , optional:true, emit: scaffolds
    path '*.contigs.fa.gz'       , optional:true, emit: contigs
    path '*.transcripts.fa.gz'   , optional:true, emit: transcripts
    path '*.gene_clusters.fa.gz' , optional:true, emit: gene_clusters
    path '*.assembly.gfa.gz'     , optional:true, emit: gfa
    path '*.warnings.log'        , optional:true, emit: warnings
    path '*.spades.log'          , emit: log

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def maxmem = task.memory.toGiga()
    """
    spades.py \\
        $args \\
        --threads $task.cpus \\
        --memory $maxmem \\
        -1 ${reads[0]} -2 ${reads[1]} \\
        -o ./
    mv spades.log ${sample_id}.spades.log

    if [ -f scaffolds.fasta ]; then
        mv scaffolds.fasta ${sample_id}.scaffolds.fa
        gzip -n ${sample_id}.scaffolds.fa
    fi
    if [ -f contigs.fasta ]; then
        mv contigs.fasta ${sample_id}.contigs.fa
        gzip -n ${sample_id}.contigs.fa
    fi
    if [ -f transcripts.fasta ]; then
        mv transcripts.fasta ${sample_id}.transcripts.fa
        gzip -n ${sample_id}.transcripts.fa
    fi
    if [ -f assembly_graph_with_scaffolds.gfa ]; then
        mv assembly_graph_with_scaffolds.gfa ${sample_id}.assembly.gfa
        gzip -n ${sample_id}.assembly.gfa
    fi

    if [ -f gene_clusters.fasta ]; then
        mv gene_clusters.fasta ${sample_id}.gene_clusters.fa
        gzip -n ${sample_id}.gene_clusters.fa
    fi

    if [ -f warnings.log ]; then
        mv warnings.log ${sample_id}.warnings.log
    fi
    """

    stub:
    """
    echo "" | gzip > ${sample_id}.scaffolds.fa.gz
    echo "" | gzip > ${sample_id}.contigs.fa.gz
    echo "" | gzip > ${sample_id}.transcripts.fa.gz
    echo "" | gzip > ${sample_id}.gene_clusters.fa.gz
    echo "" | gzip > ${sample_id}.assembly.gfa.gz
    touch ${sample_id}.spades.log
    touch ${sample_id}.warnings.log
    """
}
