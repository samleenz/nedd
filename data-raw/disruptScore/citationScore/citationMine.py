import json
import requests
import xmltodict

def postProtList(prots):
    protStr = ",".join(prots)
    apiKey = "71d9e183e47693926dd1673d407f5bad0608"
    emailAddr = "nwilliams@svi.edu.au"
    data = {'db': 'protein', 'id': protStr, 'retmode': 'xml', 'email': emailAddr, "api_key": apiKey}
    url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    store = {}

    while True:
        print("posting")
        try:
            r = requests.post(url,data)
        except:
            print("Error posting proteins, retrying...")
            continue
        print("parsing")
        try:
            parsed = xmltodict.parse(r.content)
            print(r.status_code, r.reason)
            mark = parsed["GBSet"]["GBSeq"]
        except:
            print("error parsing returned data, retrying...")
            continue
        break

    for n in range(0,len(prots)):
        store[prots[n]] = len(mark[n]["GBSeq_references"]["GBReference"])

    return store

def idListRead(fName):
    idList = open(fName).read().splitlines()
    return idList

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]


def citeMine(fileName):
    nSize = 100
    ProtIds = idListRead(fileName)

    pChunk = list(chunks(ProtIds,nSize))

    master = {}

    count = 0

    for x in pChunk:
        master.update(postProtList(x))
        count += 1
        complete = (count/len(pChunk)) * 100
        print("\n" + "{:.4f}".format(complete) + "% Citations Complete\n")

    json.dump(master,open("proteinCitations.json","w"))

    return master
