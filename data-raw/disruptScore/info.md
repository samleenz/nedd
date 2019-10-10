# Info 

Generates a .json dictionary containing each protein and a disrupt score

The disrupt score is an estimate of the impact a protein will have on destabilising network structure. A higher score indicates more destabilisation. 

The disrupt score is (more or less) citation-penalised betweenness centrality. Standard variances from average betweenness is scaled by normalised rank-order citations. 

The intuition  behind this is as follows; more citations allows greater confidence in the measured betweennness centrality. 

## Directories

BetweennessScore - contains scripts to measure betweenness and save in .json file. A raw betweennesss dictionary and a dictionary containing standard deviations from mean are saved.

CitationScore - contains a script to measure citations of each protein. Saves 2 .json files for raw citations as well as rank-order normalised. 
