import json
import numpy as np

def dictStand(dic):
    newDic = {}
    vals = np.fromiter(dic.values(), dtype=float)

    mean = np.mean(vals)
    std = np.std(vals)

    for key in dic.keys():
        newDic[key] = (dic[key] - mean) / std

    return newDic

def rescale(dic):
    # rescales dict values within range
    maxV = max(dic.values())
    minV = min(dic.values())
    new = {}
    for k in dic.keys():
        val = dic[k]
        new[k] = ((val - minV) / (maxV - minV))

    return new

def cDict():
    #returns dict with normalised citations between 0-1
    rawCites = json.load(open("./citationScore/proteinCitations.json",'r'))

    #redefine citations in rank order
    r = {key: rank for rank, key in enumerate(sorted(set(rawCites.values()), reverse=True), 1)}
    ranked = {k: r[v] for k, v in rawCites.items()}

    #rescale 0-1
    new = rescale(ranked)
    return new

#input JUST the name of the graph e.g. "ascher", "huri" or "STRING"
def makeDisrupt(graphName):
    #load betweenness
    between = json.load(open("./betweennessScore/" + graphName + "_rawBetween.json",'r'))
    between = dictStand(between) #standardize

    cites = cDict() #load citations

    new = {}
    for prot in between:
        new[prot] = between[prot] * cites[prot]
    #dump
    json.dump(new,open(graphName + "_disrupt.json","w"))

    return new

makeDisrupt("ascher")
makeDisrupt("huri")
makeDisrupt("STRING")




