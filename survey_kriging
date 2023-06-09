# Import modules
import arcpy
from arcpy import env
from arcpy.sa import *

#Workspace and environemnt
env.workspace = "C:/data"
env.overwriteOutput = True

#User Params
target_question = "Question1"
raster_cell_size = 100
interpolation = "SPHERICAL"

# Create a feature class from survey data saved as a CSV
in_table = "survey_data.csv"
address_fields = "Address"
out_feature_class = "survey_points.shp"
arcpy.GeocodeAddresses_geocoding(in_table, address_fields, out_feature_class)

# Create a new field for responses (quantitative, assuming 5-point)
question_field = target_question
arcpy.AddField_management(out_feature_class, question_field, "SHORT")

# Code qualitative responses as 1-5
with arcpy.da.UpdateCursor(out_feature_class, [question_field]) as cursor:
    for row in cursor:
        # Replace "response_field" with the name of the field containing the Likert scale response
        response = row[0]
        if response == "Strongly Agree":
            row[0] = 5
        elif response == "Agree":
            row[0] = 4
        elif response == "Neutral":
            row[0] = 3
        elif response == "Disagree":
            row[0] = 2
        elif response == "Strongly Disagree":
            row[0] = 1
        cursor.updateRow(row)
        
# Replace "cell_size" with the desired cell size for the output raster
cell_size = 100
out_raster = Kriging(out_feature_class, question_field, interpolation, raster_cell_size)
out_raster.save("survey_surface_01.tif")
