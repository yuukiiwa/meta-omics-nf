// Add UMI to header from RNAseq data using fastp

process FASTPLONG {
	label "process_medium"
	tag "${sample_id}"
	publishDir "${params.outdir}/decont/RNA", mode: 'copy'
	
	input:
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}_fastplong.fastq.gz"), emit: reads
	tuple path("${sample_id}.html"), path("${sample_id}.json") , emit: logs
	
	when:
	params.process_rna && params.process_nanopore
	
	script:
	"""
	fastplong --in ${reads_file} ${sample_id}_fastplong.fastq.gz --json ${sample_id}.json --html ${sample_id}.html \\
        --failed_out ${sample_id}.fail.fastq.gz --thread $task.cpus 2> >(tee ${sample_id}.fastplong.log >&2)
	"""
}
