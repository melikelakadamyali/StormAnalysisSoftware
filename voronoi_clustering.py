# -*- coding: utf-8 -*-
"""
Created on Sun May  9 18:06:56 2021

@author: araba
"""
import numpy as np
from scipy.spatial import Delaunay
from scipy.spatial import Voronoi
import math
from itertools import compress
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
import matplotlib.pyplot as plt
from matplotlib import cm
import struct

def binLoad(FileLoc):
    with open(FileLoc, "rb") as binary_file:
        binary_file.seek(0)
        first_word = binary_file.read(4).decode('utf-8')
        nFrames = int.from_bytes(binary_file.read(4),byteorder='little')
        junk_value = int.from_bytes(binary_file.read(4),byteorder='little')
        nMolecules = int.from_bytes(binary_file.read(4),byteorder='little')
        LocalizationResults = np.zeros([nMolecules,18])
        for ii in range(0,nMolecules):
            LocalizationResults[ii,:] = struct.unpack('<'+'f'*11+'I'*5+'f'*2,
                                        binary_file.read(72))
        FrameResults = np.zeros(nFrames)
        for ii in range(0,nFrames):
            FrameResults[ii] = int.from_bytes(binary_file.read(4),byteorder='little')

    LocNames = dict([("X",0),("Y",1),("Xc",2),("Yc",3),("Height",4),("Area",5),
                    ("Width",6),("Phi",7),("Aspect",8),("Bg",9),("I",10),
                    ("Channel",11),("FitIter",12),("Frame",13),("TrackL",14),
                    ("Link",15),("Z",16),("Zc",17)])

    OutDictionary = dict([("Localizations",LocalizationResults), ("Frames",FrameResults),("Localization_Matrix_Mapping",LocNames)])
    return OutDictionary

DictOut = binLoad('C:/Users/araba/OneDrive/Desktop/microscopy_bin_file.bin')
DictOut = DictOut['Localizations']
points = DictOut[:,0:2]

area_threshold = 90
min_number_of_localizations = 10

def PolyArea(x,y):
    return 0.5*np.abs(np.dot(x,np.roll(y,1))-np.dot(y,np.roll(x,1)))

def neighbors_delauay(points):
    dt = Delaunay(points)
    vertices = dt.vertices
    
    vertices_hstack = np.hstack(vertices)
    vertices_hstack_sorted = np.sort(vertices_hstack) 
    vertices_hstack_sorted_arg = np.argsort(vertices_hstack) 
    unique_vals, indices = np.unique(vertices_hstack_sorted , return_index=True)
    vertices = vertices[divmod(vertices_hstack_sorted_arg,3)[0],:]

    neighbors = []
    for i in range(len(indices)):
        if i<len(indices)-1:
            neighbors.append(np.unique(vertices[indices[i]:indices[i+1]]))
        else:
            neighbors.append(np.unique(vertices[indices[i]:vertices.shape[0]]))
    neighbors = [list(i) for i in neighbors]
    [val.remove(idx) for idx,val in enumerate(neighbors)]
    return neighbors

def find_voronoi(points):
    vor = Voronoi(points)
    point_to_cell_index = list(vor.point_region)
    regions = vor.regions
    vertices = vor.vertices

    inf_empty_index = [regions.index(i) for i in regions if -1 in i or i ==[]]

    voronoi_cells = [vertices[i] for i in regions]

    voronoi_areas = [PolyArea(i[:,0],i[:,1]) for i in voronoi_cells]
  
    for i in inf_empty_index:
        voronoi_areas[i] = math.inf
        
    voronoi_areas = [voronoi_areas[i] for i in point_to_cell_index]  
    voronoi_cells = [voronoi_cells[i] for i in point_to_cell_index] 
    return voronoi_areas, voronoi_cells

def find_clusters(keep_points,neighbors):
    used_points = [False]*len(keep_points)
    clusters = []
    for i in range(len(keep_points)):
        if keep_points[i] and not used_points[i]:
            seed = []
            idx = []
            seed = list(compress(neighbors[i],[keep_points[j] for j in neighbors[i]]))
            if seed:
                while True:
                    size_one = len(seed)
                    idx = list(np.unique(np.concatenate([neighbors[i] for i in seed])))
                    idx = list(compress(idx,[keep_points[j] for j in idx]))
                    seed  = list(np.unique(np.asarray(seed+idx)))
                    size_two = len(seed)
                    if size_one==size_two:
                        break
            else:
                seed = [i]
            for j in seed:
                used_points[j] = True
            clusters.append(seed)
    return clusters

def plot_clusters(clusters_voronoi_cells,clusters_voronoi_areas):
    fig, ax = plt.subplots()
    patches = []
    color = []
    for counter,i in enumerate(clusters_voronoi_cells):
        color.append([counter]*len(i))
        for j in i:
            patches.append(Polygon(j))
    color = np.asarray([np.asarray(i) for i in color])
    color = np.hstack(color)
    collection = PatchCollection(patches, alpha = 1, edgecolor = None, cmap=cm.hsv)
    collection.set_array(color)
    # collection.set_clim(cmin, cmax)
    ax.add_collection(collection)
    fig.colorbar(collection, ax=ax)
    plt.show()
    plt.xlim(min(points[:,0]),max(points[:,0]))
    plt.ylim(min(points[:,1]),max(points[:,1]))

def plot_voronoi(points,voronoi_cells,voronoi_areas,keep_points):
    fig, ax = plt.subplots()
    patches = []
    for counter,cell in enumerate(voronoi_cells):
        if voronoi_areas[counter] != math.inf:            
            patches.append(Polygon(cell))            
    collection = PatchCollection(patches, alpha = 0.1, edgecolor = 'r', cmap=cm.hsv)    
    color = [i for i in voronoi_areas if i!=math.inf]
    collection.set_array(np.log(np.array(color)))
    ax.add_collection(collection)    
    plt.scatter(points[:,0], points[:,1], s=1, color = 'b')
    plt.show()
    plt.xlim(min(points[:,0]),max(points[:,0]))
    plt.ylim(min(points[:,1]),max(points[:,1]))
    
    voronoi_cells = list(compress(voronoi_cells,keep_points))
    voronoi_areas = list(compress(voronoi_areas,keep_points))
    fig, ax = plt.subplots()
    patches = []
    for counter,cell in enumerate(voronoi_cells):
        if voronoi_areas[counter] != math.inf:            
            patches.append(Polygon(cell))            
    collection = PatchCollection(patches, alpha = 0.1, edgecolor = 'r', cmap=cm.hsv)    
    color = [i for i in voronoi_areas if i!=math.inf]
    collection.set_array(np.log(np.array(color)))
    ax.add_collection(collection)    
    plt.scatter(points[:,0], points[:,1], s=1, color = 'b')
    plt.show()
    plt.xlim(min(points[:,0]),max(points[:,0]))
    plt.ylim(min(points[:,1]),max(points[:,1]))
    
neighbors = neighbors_delauay(points)
voronoi_areas, voronoi_cells =  find_voronoi(points)   
area_threshold = np.percentile(voronoi_areas,area_threshold)    
keep_points = [True if i<=area_threshold else False for i in voronoi_areas]
clusters = find_clusters(keep_points,neighbors)
clusters = list(filter(lambda x: len(x)>=min_number_of_localizations,clusters))
clusters_voronoi_cells = [[voronoi_cells[k] for k in i] for i in clusters]
clusters_voronoi_areas = [[voronoi_areas[k] for k in i] for i in clusters]
clusters_points = [points[i,:] for i in clusters]

# plot_voronoi(points,voronoi_cells,voronoi_areas,keep_points) 
# plot_clusters(clusters_voronoi_cells,clusters_voronoi_areas)