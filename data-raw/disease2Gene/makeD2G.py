import csv
import json
import difflib
import pandas as pd
import feather

#change these to updated files when necessary
textMineFile = "./disease2Gene/human_disease_textmining_filtered.tsv"
knowledgeFile = "./disease2Gene/human_disease_knowledge_filtered.tsv"
experimentsFile = "./disease2Gene/human_disease_experiments_filtered.tsv"

# Generates list of diseases in dictionary close to input query
# Input: Search query (str), disease dict from makeDict(), maximum search results to output (default 3)
# Output: List of matching queries (length up to set max) [MAY BE EMPTY IF NO MATCHES]
def search(query, dic, maxResults=3):
    keys = list(dic.keys())
    return difflib.get_close_matches(query,keys,n=maxResults)

# Generates central dictionary containing disease to gene associations with highest confidence source for each gene
# Input: 3 filenames of filtered .tsv files from https://diseases.jensenlab.org/Downloads
# Output: Dictionary with diseases as keys
def makeDict(text,knowledge,experiments):
    dic = {}

    # add text file to dict with correct indexes
    with open(text, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        for r in reader:
            disease = r[3]
            if disease in dic:
                dic[disease][r[0]] = {}
            else:
                dic[disease] = {}
                dic[disease][r[0]] = {}
            dic[disease][r[0]]["confidence"] = r[5]
            dic[disease][r[0]]["type"] = "text"
            dic[disease][r[0]]["source"] = "textMine"

    #add experiments file to dictionary with correct indexes and checking for previous entries
    with open(experiments, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        for r in reader:
            disease = r[3]
            if disease in dic:
                #take the higher score if conflict
                if (r[1] in dic[disease] and r[6] < dic[disease][r[1]]["confidence"]):
                    continue
                dic[disease][r[1]] = {}
            else:
                dic[disease] = {}
                dic[disease][r[1]] = {}
            dic[disease][r[1]]["confidence"] = r[6]
            dic[disease][r[1]]["type"] = "experiments"
            dic[disease][r[1]]["source"] = r[4]

    #add knowledge file to dictionary with correct indexes and checking for previous entries
    with open(knowledge, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        for r in reader:
            disease = r[3]
            if disease in dic:
                # take the higher score if conflict
                if (r[1] in dic[disease] and r[6] < dic[disease][r[1]]["confidence"]):
                    continue
                dic[disease][r[1]] = {}

            else:
                dic[disease] = {}
                dic[disease][r[1]] = {}
            dic[disease][r[1]]["confidence"] = r[6]
            dic[disease][r[1]]["type"] = "knowledge"
            dic[disease][r[1]]["source"] = r[4]

    #return the processed dictionary
    return dic

#convenience function to make disease2Gene database
def makeD2G():
    # Create central dict
    master = makeDict(textMineFile, knowledgeFile, experimentsFile)

    data = []
    for d in master:
        for gene in master[d]:
            data.append([d,gene,master[d][gene]["type"],master[d][gene]["source"],master[d][gene]["confidence"]])

    df = pd.DataFrame(data, columns=['Disease','Gene','Type','Source','Confidence'])

    # save file to .feather file in current directory
    df.to_feather("./disease2Gene/disease2gene.feather")


