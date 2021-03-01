#Working with Social Graphs
import networkx as nx
import unicodecsv as csv

data_file = "D:\Google Drive\projects\practical-datascience-cookbook-tony-ojeda\chapter8\hero-comic-network.csv"

def graph_from_csv(path):
    
    graph = nx.Graph(name="Heroic Social Network")
    with open(path, 'rU') as data:
        reader = csv.reader(data)
        for row in reader:
            graph.add_edge(*row)
    
    return graph



graph = graph_from_csv(data_file)

graph.order()
graph.size()

