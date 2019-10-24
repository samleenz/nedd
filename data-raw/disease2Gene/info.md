# Info 

Generates .json dict with diseases as keys and a hierarchical structure showing associated genes with their respective source, confidence and type

Type can be text (via text mining), knowledge (curated) or Experimental (Gene Wide Association Studies)

Source refers to the source of the information. For text this is simply just "text"

Confidence is out of 5 and consistent across all types
 
Input must be 3 .tsv files obtained from 3 (USE FILTERED VERSIONS)
 
Output .json saved as "disease2gene.json" in current directory

Bonus Search function also provided but not used (for future applications)