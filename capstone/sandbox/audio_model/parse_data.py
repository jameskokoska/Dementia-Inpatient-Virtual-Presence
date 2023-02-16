import os
import csv

data_dir = "datasets/weather"

count = 0

lines = []

for filename in os.listdir(data_dir):
    debugPrint(filename)
    if filename.endswith(".tsv"):
        with open(data_dir + "/" + filename) as file:
            reader = csv.reader(file, delimiter="\t", quotechar='"')
            for row in reader:
                debugPrint(row[1])
                lines.append(row[1] + "\n")
                count += 1

debugPrint(count)
# debugPrint(lines)
with open(data_dir + "/" + "weather.txt", "w") as new_data:
    new_data.writelines(lines)
