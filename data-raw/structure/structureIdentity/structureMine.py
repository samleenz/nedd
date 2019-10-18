# Swiss Data Mine
# 27-06-19
# By Nathan Williams
# Version 1.0

import json
import requests
import xmltodict
import sys
from threading import Thread

#Convenience function to retrieve swiss url
def swissUrl(qualifier):
    return "https://swissmodel.expasy.org/repository/uniprot/" + qualifier + ".json"

def process_id(id):
    #process a single uniprot ID
    url = swissUrl(id)
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
    high = 0.0
    tempDic = {}
    provider = ""
    templateID = ""
    for model in structures:
        if (model["provider"] == "SWISSMODEL"):
            if(float(model["identity"]) > high):
                high = float(model["identity"])
                templateID = model["template"]
                provider = model["provider"]
        elif (model["provider"] == "PDB"):
            if((float(model["coverage"]) * 100) > high):
                high = float(model["coverage"]) * 100
                templateID = model["template"]
                provider = model["provider"]
    tempDic = {"identity": high, "provider": provider, "template":templateID}
    return tempDic

def process_range(id_range, store=None):
    """process a number of ids, storing the results in a dict"""
    if store is None:
        store = {}
    for id in id_range:
        store[id] = process_id(id)
    return store

def threaded_process_range(id_range, nthreads = 1):
    """process the id range in a specified number of threads"""
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
    return store

def mineStructures(proteinFile, threads = 4):
    print("Program Start \n")
    #import all proteins into list and create a dict
    pList = open(proteinFile).read().splitlines()

    result = threaded_process_range(pList,threads)

    #write to file
    json.dump(result, open("structureIdentities.json", 'w'))

    print("\nFinished: Dict saved to .json file")
    return result

dic = mineStructures("../nedd_3graph_protein_union.txt",40)

