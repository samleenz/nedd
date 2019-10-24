import json
import numpy as np

#standardizes values of dictionary i.e. score is standard variations from mean
def dictStand(dic):
    newDic = {}
    vals = np.fromiter(dic.values(), dtype=float) #get all values into list

    #arithmetic
    mean = np.mean(vals)
    std = np.std(vals)

    #standardize
    for key in dic.keys():
        newDic[key] = (dic[key] - mean) / std

    return newDic #return the standardized dictionary

#Input dictionary with raw scores
#Output: Dictionary with scores rescaled between 0 and 1
def rescale(dic):
    maxV = max(dic.values())
    minV = min(dic.values())
    new = {}
    #rescale
    for k in dic.keys():
        val = dic[k]
        new[k] = ((val - minV) / (maxV - minV))

    return new #return rescaled

def cDict():
    #returns dict with normalised rank-order citations between 0-1
    rawCites = json.load(open("./disruptScore/citationScore/proteinCitations.json",'r'))

    #redefine citations in rank order
    r = {key: rank for rank, key in enumerate(sorted(set(rawCites.values()), reverse=True), 1)}
    ranked = {k: r[v] for k, v in rawCites.items()}

    #rescale 0-1
    new = rescale(ranked)
    return new

#input:  JUST the name of the graph e.g. "ascher", "huri" or "STRING"
#output: returns disrupt dictionary for input graph
def makeDisrupt(graphName):
    #load betweenness
    between = json.load(open("./disruptScore/betweennessScore/" + graphName + "_rawBetween.json",'r'))
    between = dictStand(between) #standardize

    cites = cDict() #load citations

    new = {}
    for prot in between:
        new[prot] = between[prot] * cites[prot]
    #dump
    json.dump(new,open("./disruptScore/" + graphName + "_disrupt.json","w"))

    return new

#convenience function to make disrupt file for all graphs
def makeAllDisrupts():
    makeDisrupt("ascher")
    makeDisrupt("huri")
    makeDisrupt("STRING")





