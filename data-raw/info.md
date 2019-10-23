# Info 
Databases and associated scripts compiled by Nathan Williams  
Please email nwilliams@svi.edu.au for info

#### Contents
- Databases
- How to Update
- Update Dependencies

## Databases
**Disrupt Score**  
Each graph has a corresponding disrupt score for each node. The disrupt score is an estimate of the impact a protein will have on destabilising network structure. A higher score indicates more destabilisation.

The disrupt score is (more or less) citation-penalised betweenness centrality. Standard variances from average betweenness is scaled by normalised rank-order citations. The intuition behind this is as follows; more citations allows greater confidence in the measured betweennness centrality.  

 **singleProtStats**  
 This database contains the sequence identity of the best model for each protein as well as the druggability of that models best pocket (as estimated by fPocket)
 
 **disease2Gene**  
 Compiled databases sourced from  https://diseases.jensenlab.org/. Contains known disease to gene correlations with confidence scores from various sources.
 
 **uniprot2name**  
 Simple conversion from uniprotID to full protein name as provided by uniprot.org 
 
## How to update
Updates should be performed using the updateDatabases.py script (with the exception of betweennesss). Before running, edit the number of cores and set the specified boolean variables to configure which databases should be updated.  

Disease2Gene should only be updated if new ".tsv" files have been downloaded from https://diseases.jensenlab.org/Downloads

Similarly, proteinNames should only be updated if a new ".tab" file has been downloaded from uniprot.org. More info in ./uniprot2proteinName/info.md

**Important!**  
An api key must be added to "disruptScore/citationScore/citationMine.py" in the postProtList function. For information on how to obtain key: https://ncbiinsights.ncbi.nlm.nih.gov/2017/11/02/new-api-keys-for-the-e-utilities/  

**Updating Betweenness**  
If graphs are updated, please run  "betweenExtract.R" in "./disruptScore/betweennessScore/". 

 ## Update Dependencies
 **Required Python Modules**  
 - csv
 - json
 - requests
 - xmltodict
 - threading
 - os
 - wget
 - shutil
 - numpy
 - difflib
 

 

 