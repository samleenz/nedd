import os
import json
from threading import Thread, get_ident
import wget
import shutil

#Download a single model if identity > 40%
#Input: uniprotID, dictionary of structure identities
#Output: Boolean dictating whether model was downloaded or not
def process_id(p,models):
    #Hard code addresses
    out = "./structure/fPocket/structures/"
    pdbURL = "https://files.rcsb.org/download/"  # + "4hhb.pdb"
    swissURL = "https://swissmodel.expasy.org/repository/uniprot/"  # + "P07900.pdb"

    #check if identity > 40%
    if (models[p]["identity"] >= 40):
        # PDB
        if (models[p]["provider"] == "PDB"):
            tail = models[p]["template"] + ".pdb" #find templtate name
            newURL = pdbURL + tail #complete URL
            wget.download(newURL, out) #download
            newTail = p + ".pdb"
            os.rename(os.path.join(out, tail), os.path.join(out, newTail)) #standardise naming convention
            return True
        # swiss
        elif (models[p]["provider"] == "SWISSMODEL"):
            tail = p + ".pdb"
            newURL = swissURL + tail #complete url
            wget.download(newURL, out) #download
            return True
    return False

#download range of uniprot IDs
def process_range(id_range, models, store=None):
    """process a number of ids, storing the results in a dict"""
    if store is None:
        store = {}
    for id in id_range:
        store[id] = process_id(id,models)
    return store

#start several threads for downloading models
def threaded_process_range(id_range, models, nthreads=1):
    """process the id range in a specified number of threads"""
    store = {}
    threads = []
    # create the threads
    for i in range(nthreads):
        ids = id_range[i::nthreads]
        t = Thread(target=process_range, args=(ids, models, store))
        threads.append(t)

    # start the threads
    [t.start() for t in threads]
    # wait for the threads to finish
    [t.join() for t in threads]
    return store

#Checks which models have had identity updated and launches threads to download new models
# Input: Current identities, Updated Identities, # of threads to launch (default 30)
def downloadUpdates(old, new, threads = 30):
    toDo = {}

    #add new or better structures to list
    for prot in new:
        if(prot in old):
            if(new[prot]["identity"] > old[prot]["identity"]):
                toDo[prot] = new[prot]
        else:
            toDo[prot] = new[prot]

    #download over N threads
    output = threaded_process_range(list(toDo.keys()), toDo, threads)
    return output

# Runs fpocket on input targets
def process_models(targets):
    for x in targets:
        os.system('fpocket -f ./structure/fPocket/structures/' + str(x).upper() + '.pdb')

#Splits targets into threads and runs fpocket over all threads
#input; Target models, number of threads
def fPock(targets, nthreads=1):
    threads = []
    #split targets evenly between threads
    for i in range(nthreads):
        ids = targets[i::nthreads]
        t = Thread(target=process_models, args=(ids,))
        threads.append(t)

    # start the threads
    [t.start() for t in threads]
    # wait for the threads to finish
    [t.join() for t in threads]

#Parses results of fPocket by traversing directory
def extractDruggabiliy():
    curr = os.path.abspath("structure/fPocket/structures/")  #guide to structures
    resDict = {}

    #traverse directory for fPocket results
    for filename in os.listdir(curr):
        if (filename.endswith("_out")): #== fPock result folder
            txt = os.path.abspath("structure/fPocket/structures/" + filename + '/' + filename[:-4] + '_info.txt')
            txtLs = open(txt, 'r').read().splitlines() #open file and split each line

            drugScores = []
            for line in txtLs:
                if (line.startswith("	Druggability Score :")): #find line estimating druggability
                    drugScores.append(float(line[22:28])) #store result

            if (len(drugScores) > 0): #take max pocket score
                resDict[filename[:-4]] = max(drugScores)
            else: #no pocket found
                resDict[filename[:-4]] = 0

    #delete all models and fpocket results  in directory once processed
    folder = './structure/fPocket/structures/'
    for the_file in os.listdir(folder):
        file_path = os.path.join(folder, the_file)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path) #delete .pdb files
            elif os.path.isdir(file_path): shutil.rmtree(file_path) #delete _out folders
        except Exception as e: #error catch
            print(e)

    return resDict #return druggability dictionary

#Compiles master dictionary to save all new stats
#Input: druggability results, updated sequence identities
#Output: Single compiled dictionary
def compileMaster(drugResults, updates):
    #hard coded addresses
    identities = json.load(open("./structure/structureIdentity/structureIdentities.json",'r'))
    json.dump(identities,open("./structure/fPocket/structures/currentModels.json",'w')) #update current models with new
    master = json.load(open("./structure/singleProtStats.json","r"))

    #check all prots in updates
    for prot in updates:
        if(prot not in master):
            master[prot] = {} #initialise

        if(prot in drugResults):
            master[prot]["druggability"] = drugResults[prot]
        else:
            master[prot]["druggability"] = False #i.e. identity < 40
        master[prot]["identity"] = identities[prot]["identity"]

    json.dump(master,open("./structure/singleProtStats.json","w")) #update master file
    return master #return if needed

#Master function to update identity and druggability
#Input: number of cores to utilise
def updateModels(cores):
    #open hardcoded addresses
    curr = json.load(open("./structure/fPocket/currentModels.json",'r'))
    new = json.load(open("./structure/structureIdentity/structureIdentities.json",'r'))

    #download updates
    out = downloadUpdates(curr,new)

    fPockTargets = [x for x in out if out[x]] #compile fpocket targets

    fPock(fPockTargets, cores) #run fPocket on all targets

    druggability = extractDruggabiliy() #parse the druggability scores

    #find updates
    updates = []
    for x in new:
        if (x in curr):
            if(new[x]["identity"] > curr[x]["identity"]):
                updates.append(x)
        else:
            updates.append(x)

    #compileMaster
    compileMaster(druggability, updates)


