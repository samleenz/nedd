#updateDatabase.py
#Author: Nathan Williams
#email: nwilliams@svi.edu.au
# Description: Script to automatically update all specified nedd databases

#imports

#configuration
cores = 4 #set cores to utilise for druggability estimation

updateDisrupt = True #update citations before making new disrupt score
updateDruggability = True #update sequence identities and estimate druggability of new models
updateDisease2Gene = False #only set to True if new files have been manually downloaded and added to the directory
updateProteinNames = False #only set to True if new uniprot file has been manually downloaded and added to directory

#############################################################################################
# Begin Updating
#############################################################################################
#Mine citations and make new disrupt score with stored betweenness scores
if updateDisrupt:
