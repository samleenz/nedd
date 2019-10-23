import json
import requests
import xmltodict

#input: list of uniprot IDs
#output: dictionary contain uniprot keys and citation values
def postProtList(prots):
    #initialise hard code variables
    protStr = ",".join(prots)
    apiKey = "71d9e183e47693926dd1673d407f5bad0608"
    emailAddr = "nwilliams@svi.edu.au"
    data = {'db': 'protein', 'id': protStr, 'retmode': 'xml', 'email': emailAddr, "api_key": apiKey}
    url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    store = {}

    #attempt to post all proteins and parse citations
    while True:
        #try post
        try:
            r = requests.post(url,data)
        except:
            print("Error posting proteins, retrying...")
            continue

        #try parse returned content
        try:
            parsed = xmltodict.parse(r.content)
            print(r.status_code, r.reason)
            mark = parsed["GBSet"]["GBSeq"]
        except:
            print("error parsing returned data, retrying...")
            continue
        break
    #record number of citations returned
    for n in range(0,len(prots)):
        store[prots[n]] = len(mark[n]["GBSeq_references"]["GBReference"])

    return store

#input: Filename with strings separated by new lines
#output: list with each line as an element
def idListRead(fName):
    idList = open(fName).read().splitlines()
    return idList

#splits list of proteins into chunks to not exceed posting limits and catch errors earlier
def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]

#master function to update citations
#input: filename of text file containing all proteins
def citeMine(fileName):
    nSize = 1000 #batch size to post

    ProtIds = idListRead(fileName) #return as list

    pChunk = list(chunks(ProtIds,nSize)) #nested list now chunked

    master = {}
    count = 0 #for progress tracking

    for x in pChunk:
        master.update(postProtList(x)) #update master with parsed citations
        count += 1 #update for progress
        complete = (count/len(pChunk)) * 100 #calculate progress
        print("\n" + "{:.4f}".format(complete) + "% Citations Complete\n") #print progress

    json.dump(master,open("proteinCitations.json","w")) #dump citations to file

    return master #returned but not used
