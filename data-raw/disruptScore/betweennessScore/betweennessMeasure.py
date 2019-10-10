import networkx as nx
import json
import numpy as np

#standardizes dictionary values
#input dictionary with numerical values
#output: Standardized dict
def dictStand(dic):
    newDic = {}
    vals = np.fromiter(dic.values(), dtype=float)

    mean = np.mean(vals)
    std = np.std(vals)

    for key in dic.keys():
        newDic[key] = (dic[key] - mean) / std

    return newDic

# Generates betweenness dictionary of input graph and saves raw + variance .json files
# Input: filename of graphml file
# Output: variance betweennesss dictionary
def betweenDict(graphFile):
    #read in graph
    G = nx.read_graphml(graphFile)

    #find betweenness
    bDict = nx.betweenness_centrality(G)

    #dump raw dictionary
    json.dump(bDict,open(graphFile + "_rawBetween",'w'))

    #standardise
    stdDict = dictStand(bDict)

    #dump standardised dict
    json.dump(bDict, open(graphFile + "_stdBetween", 'w'))




