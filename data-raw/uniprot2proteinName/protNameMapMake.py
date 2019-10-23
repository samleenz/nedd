import csv
import json

# Generates dict with uniprot IDs as key and full protein name as value
# Input: filename of .tab file from uniprot.org
# Output: Dictionary with ID keys and name values
def id2name(filename):
    dic = {}

    with open(filename) as fd:
        rd = csv.reader(fd, delimiter="\t", quotechar='"')
        next(rd)
        for x in rd:
            dic[x[0]] = x[2]

    return dic

def nameMapMake():
# Call function to retrieve dictionaru
    file = "./uniprot2proteinName/uniprot-IDS.tab" #change to name of input file to update
    master = id2name(file)

    # Save file to .json in current directory
    json.dump(master, open("./uniprot2proteinName/uniprot2name.json",'w'))

