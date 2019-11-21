#!/usr/bin/env python3
# Extract environmental values for points
# Checks for pixelwise duplicates (can turn this off by removing the relevant two lines)
# Could also use this script to count pixel-wise duplicates
# Modified to load rasters into memory only once and loop through occurrences

# Iterate over species and layers by bash iteration; see associated loop script
# We DO NOT sort data values numerically; for some applications we need to preserve this order (non-simulating distance method)

import csv # To process tab-delimited files
import sys
import argparse # Parse arguments
import os
import gdal,osr
from osgeo import ogr
import re
import struct

from gdalconst import *

# Actual extraction routine; convert GPS coordinates to pixel coordinates and query the layer
def extract_point_from_raster(x, y, source_layer): 
	#Convert from map to pixel coordinates.
	px = int((float(x) - geotransform[0]) / geotransform[1]) # Get X pixel coordinate
	py = int((float(y) - geotransform[3]) / geotransform[5]) # Get Y pixel coordinate
	structval = rasterband.ReadRaster(px, py, 1, 1, buf_type=gdal.GDT_Float32) # Result of this is binary
	intval = struct.unpack('f' , structval)
	val=intval[0] # Now get integer
	return val, px, py # Also returning pixel coordinates to check for pixel-wise duplicates
    
parser = argparse.ArgumentParser(description='Script to automatically extract climatic values from occurrence records.')
parser.add_argument('input_raster', action='store', help='List of names of the rasters; missing data should be -9999.')
parser.add_argument('-l','--list', nargs='+', help='List of occurrence files; should be CSV.', required=True)
args = parser.parse_args()

# In this version, bash only loops through the rasters. 
# We look through the records in python, loading each raster once and repeatedly querying it.
# Once the raster is queried, it is in memory and the query is very rapid.
print("Opening raster layer.")
source_layer=gdal.Open(args.input_raster) # Open layer (can be asc)
print("Determining raster layer projection.")
geotransform = source_layer.GetGeoTransform() # Infer projection
print("Loading raster layer into memory.")
rasterband = source_layer.GetRasterBand(1) # Open raster band



for points_raw in args.list:
	print("On records in {0}.".format(points_raw))
	points = []
	with open(points_raw, 'r') as datafile:
		reader=csv.reader((line.replace('\0','') for line in datafile),delimiter=',',quoting=csv.QUOTE_NONE) 
		for r in reader:
			points.append([r[1], r[2]])
	points_no_duplicates = set(map(tuple, points)) # No exact duplicates
	climate_values = []
	try:
		for point in points_no_duplicates: # Run the value extraction on each point
			climate_value = extract_point_from_raster(point[0], point[1], source_layer)

# This code only applies if entire pixels that have missing data should be removed
#			if int(climate_value[0]) == -9999: # We assume missing data is set correctly for Maxent
#				print("Found missing data.")
#			else: # Id est, we will not save missing data for our PNO
#				climate_values.append(climate_value) # Get list of lists, each containing the value and its pixel coordinates

			climate_values.append(climate_value) # KEEP MISSING DATA FOR NOW
	except:
		print("Skipped incorrectly formatted record.")
		pass # For any issues such as an empty field
	
	climate_values_no_duplicates = set(map(tuple, climate_values)) # No pixel-wise duplicates; this syntax is for lists of lists
	print(climate_values_no_duplicates)

	final_climate_values = []
	climate_values_no_duplicates = list(climate_values_no_duplicates) # Tuple to list
	for i in climate_values_no_duplicates:
		final_climate_values.append(i[0]) # Now remove the pixel coordinates since we don't need them
		
# IN THIS VERSION, MISSING DATA IS NOT AND POINT-VALUE ASSOCIATIONS MAY NOT BE VALID
# This code only applies if only individual missing data should be removed, but the overall pixel keps
	# Delete any -9999 at this point -- will break positional associations among variable PNO files
	for i in final_climate_values[:]: # Implicitly copy list to avoid iterating over list to be modified
		if i == -9999:
			print(i)
			final_climate_values.remove(i) 
			print("Removed missing data; line positions among PNO files may differ.")

	print(final_climate_values)

	# final_climate_values.sort() # Sort climate values in ascending order (purely aesthetic)
	# The above line is commented out since we want to preserve point-value associations between files
	
	variable = re.sub(".*/", "", args.input_raster) # Manipulate with regex for nice file name
	variable = re.sub("\.asc", "", variable)
	
	#with open(points_raw, 'r') as datafile:
		#reader=csv.reader((line.replace('\0','') for line in datafile),delimiter=',',quoting=csv.QUOTE_NONE) 
		#r = next(reader)
		#species = r[0]
	species = points_raw.split('.')[0]
		
	# Write the layer
	try:
		os.mkdir("./rosid_no_missing_data_point_associations")
	except: 
		pass
	with open("./rosid_no_missing_data_point_associations/{0}_pno_{1}.csv".format(variable, species), 'w+') as writefile:
		writer = csv.writer(writefile, delimiter=',')
		writer.writerows([['""',"variable","Model_avg"]]) 
		z = 1 # Counter is to imitate the numbering of normal PNO output, likely not necessary
		for i in final_climate_values:
			row = ['"{0}"'.format(z), i, (1/len(final_climate_values))] # The last value is the sampling probability 
			# Since we allow duplicate values (but not pixel duplicates), we sample proportionally to pixel-wise frequency observed
			writer.writerows([row]) # The syntax on this line was problematic in terms of iteration behavior
			z+=1