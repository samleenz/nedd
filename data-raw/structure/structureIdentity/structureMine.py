# Swiss Data Mine
# 27-06-19
# By Nathan Williams
# Version 2.0

import json
import requests
from threading import Thread

#Convenience function to retrieve swiss url
def swissUrl(qualifier):
    return "https://swissmodel.expasy.org/repository/uniprot/" + qualifier + ".json"

#process a single uniprot ID
def process_id(id):
    url = swissUrl(id)
    #try get for single URL and attempt parse
    while True:
        try:
            res = requests.get(url).json()
            structures = res["result"]["structures"]
        except:
            print(res)
            print("\n\nerror in request, retrying...\n\n")
            continue
        break

    #parse structures and store structure  with highest identity
    high = 0.0 #for comparison

    #initialise
    provider = ""
    templateID = ""

    #parse through returned models and extract details
    for model in structures:
        #swiss case
        if (model["provider"] == "SWISSMODEL"):
            if(float(model["identity"]) > high): #compare for better source
                high = float(model["identity"])
                templateID = model["template"]
                provider = model["provider"]
        #pdb case
        elif (model["provider"] == "PDB"):
            if((float(model["coverage"]) * 100) > high): #compare for better source
                high = float(model["coverage"]) * 100 #pdb needs x100
                templateID = model["template"]
                provider = model["provider"]

    #compile and return results
    tempDic = {"identity": high, "provider": provider, "template":templateID}
    return tempDic

#process range of uniprot ids assigned to this thread
#Output: return dictionary for processed IDS to be combined
def process_range(id_range, store=None):
    if store is None:
        store = {}
    for id in id_range:
        store[id] = process_id(id)
    return store

#splits processed between set threads and combines returned dictionaries upon threads joining
def threaded_process_range(id_range, nthreads = 1):
    store = {}
    threads = []
    # create the threads
    for i in range(nthreads):
        ids = id_range[i::nthreads]
        t = Thread(target=process_range, args=(ids,store))
        threads.append(t)

    # start the threads
    [ t.start() for t in threads ]
    # wait for the threads to finish
    [ t.join() for t in threads ]

    return store #return joined dictionary

#Master function to update structures
#Input: file containing all uniprot IDS
#Output: Returns structure identities if required
def mineStructures(proteinFile, threads = 40):
    #import all proteins into list and create a dict
    pList = open(proteinFile).read().splitlines()

    result = threaded_process_range(pList,threads) #Request structures over  specified # of threads

    #write to file
    json.dump(result, open("./structure/structureIdentity/structureIdentities.json", 'w'))

    return result #returned but not currently used


