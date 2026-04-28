// decontamination or removal of human reads from RNAseq using STAR. 
// a ? b: c means if (a) b else c (ternary if special operator)  
process MINIMAP_RRNA {
	label "process_high"
	tag "${sample_id}"
	publishDir { !params.dedupe && !params.remove_rRNA ? "${params.outdir}/decont/RNA" : "${params.outdir}/decont/RNA/tmp_fastq" }, mode: 'copy', pattern: '*_unmapped_{1,2}.fastq.gz'
	
	
	input:
	path rrna_ref_fa
	tuple val(sample_id), path(reads_file)
	
	output:
	tuple val(sample_id), path("${sample_id}_unmapped_{1,2}.fastq.gz"), emit: microbereads
	
	when:
	!params.decont_off && params.process_rna && params.process_nanopore
	
	script:
	"""
        minimap2 -ax map-ont ${rrna_ref_fa} ${reads_file} -t $task.cpus | samtools view -bS - | samtools fastq -f 4 - > ${sample_id}_unmapped.fastq
	"""
}

