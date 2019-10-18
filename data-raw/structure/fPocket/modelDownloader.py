import os
import json
from threading import Thread
import wget

def process_id(p,models):
    # process a single ID
    out = os.path.abspath("structures/")
    pdbURL = "https://files.rcsb.org/download/"  # + "4hhb.pdb"
    swissURL = "https://swissmodel.expasy.org/repository/uniprot/"  # + "P07900.pdb"

    if (models[p]["identity"] >= 40):
        # PDB
        if (models[p]["provider"] == "PDB"):
            tail = models[p]["template"] + ".pdb"
            newURL = pdbURL + tail
            fname = wget.download(newURL, out)
            newTail = p + ".pdb"
            os.rename(os.path.join(out, tail), os.path.join(out, newTail))
            return True
        # swiss
        elif (models[p]["provider"] == "SWISSMODEL"):
            tail = p + ".pdb"
            newURL = swissURL + tail
            fname = wget.download(newURL, out)
            return True
    return False

def process_range(id_range, models, store=None, ):
    """process a number of ids, storing the results in a dict"""
    if store is None:
        store = {}
    for id in id_range:
        store[id] = process_id(id,models)
    return store


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

def downloadUpdates(old, new):
    toDo = {}

    #add new or better structures to list
    for prot in new:
        if(prot in curr):
            if(new[prot]["identity"] > curr[prot]["identity"]):
                toDo[prot] = new[prot]
        else:
            toDo[prot] = new[prot]

    #download over N threads
    output = threaded_process_range(list(toDo.keys()), toDo, 25)

    json.dump(output, open("output.json",'w'))

curr = json.load(open("currentModels.json",'r'))
new = json.load(open("../structureIdentity/structureIdentities.json",'r'))

print("begin")

downloadUpdates(curr,new)

print("program complete")

