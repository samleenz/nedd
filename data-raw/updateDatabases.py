#updateDatabase.py
#Author: Nathan Williams
#email: nwilliams@svi.edu.au
# Description: Script to automatically update all specified nedd databases

#imports
from disruptScore.makeDisruptScore import makeAllDisrupts
from disruptScore.citationScore.citationMine import citeMine
from disease2Gene.makeD2G import makeD2G
from uniprot2proteinName.protNameMapMake import nameMapMake
from structure.fPocket.modelDownloader import updateModels
from structure.structureIdentity.structureMine import mineStructures

#configuration
cores = 4 #set cores to utilise for druggability estimation

proteinUnionFile = "nedd_3graph_protein_union.txt" #file containing union of all proteins

updateDisrupt = False #update citations before making new disrupt score
updateDruggability = False #update sequence identities and estimate druggability of new models
updateDisease2Gene = True #set to True if new files have been manually downloaded and added to the directory
updateProteinNames = False #only set to True if new uniprot file has been manually downloaded and added to directory

#############################################################################################
# Begin Updating
#############################################################################################
#Mine citations and make new disrupt score with stored betweenness scores
if updateDisrupt:
    print("Updating citations for all proteins...")
    citeMine(proteinUnionFile)
    print("Updating Disrupt Score...")
    makeAllDisrupts()

#update disease2gene database
if updateDisease2Gene:
    print("Updating disease to gene from file...")
    makeD2G()

#update protein name database
if updateProteinNames:
    print("Updating protein name map...")
    nameMapMake()

if updateDruggability:
    print("Updating sequence identities from SwissModel...")
    mineStructures(proteinUnionFile)
    print("Downloading Models and estimating druggability...")
    updateModels(cores)

print("Update Complete!")
