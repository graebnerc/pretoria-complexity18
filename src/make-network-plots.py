"""
This file creates the graphs as shown on slide 14 to illustrate
the concept of structural complexity. It will save the figures in a 
subfolder 'figs', which must be present in the working directory.

Author: Claudius Graebner
Email: claudius@claudius-graebner.com

This script is part of the material for the methodological workshop
'Measures of economic complexity - Potentials and limitations for development studies'
held on September 11 by Claudius Graebner during the DAAD Workshop
'Sustainable growth and diversification' in Pretoria

"""

import networkx as nx
import matplotlib.pyplot as plt 


# The star 

star_network = nx.star_graph(9)

fig, ax = plt.subplots(1, figsize=(4,3))
nx.draw(star_network, ax=ax, node_size=75, node_color='#A0CBE2', with_labels=False)
plt.tight_layout(True) 
plt.savefig("output/star.pdf", bbox_inches="tight") 


# The tree

tree_network = nx.balanced_tree(2, 4)

fig, ax = plt.subplots(1, figsize=(4,3))
nx.draw(tree_network, ax=ax, node_size=75, node_color='#A0CBE2', with_labels=False)
plt.tight_layout(True) 
plt.savefig("output/tree.pdf", bbox_inches="tight") 


# The small world

smallworld_network = nx.newman_watts_strogatz_graph(35, 2, 0.4)

fig, ax = plt.subplots(1, figsize=(4,3))
nx.draw_circular(smallworld_network, ax=ax, node_size=75, node_color='#A0CBE2', with_labels=False)
plt.tight_layout(True) 
plt.savefig("output/smallworld.pdf", bbox_inches="tight") 


# The random graph

random_network = nx.erdos_renyi_graph(25, 0.4)

fig, ax = plt.subplots(1, figsize=(4,3))
nx.draw(random_network, ax=ax, node_size=75, node_color='#A0CBE2', edge_color="lightgrey", with_labels=False)
plt.tight_layout(True) 
plt.savefig("output/random.pdf", bbox_inches="tight") 


# A complete figure for the handout

fig, axes = plt.subplots(2, 2, figsize = (10, 6))

star_network = nx.star_graph(9)
tree_network = nx.balanced_tree(2, 4)
smallworld_network = nx.newman_watts_strogatz_graph(35, 2, 0.4)
random_network = nx.erdos_renyi_graph(25, 0.4)

nx.draw(star_network, ax=axes[0,0], 
        node_size=75, node_color='#A0CBE2', 
        edge_color="lightgrey", with_labels=False)
axes[0,0].set_title("Star (simple)")

nx.draw(tree_network, ax=axes[0,1], 
        node_size=75, node_color='#A0CBE2', 
        edge_color="lightgrey", with_labels=False)
axes[0,1].set_title("Tree (rather simple)")

nx.draw_circular(smallworld_network, ax=axes[1,0], 
        node_size=75, node_color='#A0CBE2', 
        edge_color="lightgrey", with_labels=False)
axes[1,0].set_title("Small-world graph (rather complex)")

nx.draw(random_network, ax=axes[1,1], 
        node_size=75, node_color='#A0CBE2', 
        edge_color="lightgrey", with_labels=False)
axes[1,1].set_title("Random graph (very complex)")

plt.tight_layout(True) 

plt.savefig("output/all-graphs.pdf", bbox_inches="tight") 

