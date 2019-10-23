import os
import json
from threading import Thread, get_ident
import wget
import shutil

def process_id(p,models):
    # process a single ID
    out = os.path.abspath("structures/")
    pdbURL = "https://files.rcsb.org/download/"  # + "4hhb.pdb"
    swissURL = "https://swissmodel.expasy.org/repository/uniprot/"  # + "P07900.pdb"

    print(p)

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

def process_range(id_range, models, store=None):
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

    json.dump(output, open("output.json",'w'))

    return output

def process_models(targets):
    for x in targets:
        print(x + " ", end='')
        print(str(get_ident()))
        os.system('fpocket -f ./structures/' + str(x).upper() + '.pdb')

def fPock(targets, nthreads):
    threads = []
    for i in range(nthreads):
        ids = targets[i::nthreads]
        t = Thread(target=process_models, args=(ids,))
        threads.append(t)

    # start the threads
    [t.start() for t in threads]
    # wait for the threads to finish
    [t.join() for t in threads]

def extractDruggabiliy():
    curr = os.path.abspath("structures/")
    resDict = {}

    for filename in os.listdir(curr):
        if (filename.endswith("_out")):
            txt = os.path.abspath("structures/" + filename + '/' + filename[:-4] + '_info.txt')
            txtLs = open(txt, 'r').read().splitlines()
            drugScores = []
            for line in txtLs:
                if (line.startswith("	Druggability Score :")):
                    drugScores.append(float(line[22:28]))

            if (len(drugScores) > 0):
                resDict[filename[:-4]] = max(drugScores)
            else:
                resDict[filename[:-4]] = 0

    #delete all models
    folder = './structures/'
    for the_file in os.listdir(folder):
        file_path = os.path.join(folder, the_file)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path): shutil.rmtree(file_path)
        except Exception as e:
            print(e)

    return resDict

def compileMaster(drugResults, updates):
    identities = json.load(open("../structureIdentity/structureIdentities.json",'r'))
    json.dump(identities,open("currentModels.json",'w')) #update
    master = json.load(open("../singleProtStats.json","r"))

    for prot in updates:
        if(prot not in master):
            master[prot] = {}

        if(prot in drugResults):
            master[prot]["druggability"] = drugResults[prot]
        else:
            master[prot]["druggability"] = False
        master[prot]["identity"] = identities[prot]["identity"]

    json.dump(master,open("../singleProtStats.json","w"))
    return master



curr = json.load(open("currentModels.json",'r'))
new = json.load(open("../structureIdentity/structureIdentities.json",'r'))

print("begin")

out = downloadUpdates(curr,new)

fPockTargets = [x for x in out if out[x]]

fPock(fPockTargets, 4)

druggability = extractDruggabiliy()

updates = []


for x in new:
    if (x in curr):
        if(new[x]["identity"] > curr[x]["identity"]):
            updates.append(x)
    else:
        updates.append(x)

#compileMaster
compileMaster(druggability, updates)

print("program complete")

