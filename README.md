# Routing analysis using OS MasterMap Highways Network and GraphHopper

## Introduction

Step-by-step guide for converting OS MasterMap Highways Network data into a simple OpenStreetMap-like format for subsequent use with the GraphHopper routing API. 

## Requirements

- [GDAL (Geospatial Data Extraction Library)](https://gdal.org/)
- [geojsontoosm](https://www.npmjs.com/package/geojsontoosm)
- [Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis)
- [GraphHopper Web Service](https://github.com/graphhopper/graphhopper/blob/master/docs/web/quickstart.md)

## Process

1. Translate Highways data from its native GML format using https://github.com/tmnnrs/osmm-highways-network-translator.

2. Construct the Highways RoadLink attributes (subset only) to replicate an OpenStreetMap [Way](https://wiki.openstreetmap.org/wiki/Way) using AWK:

```
awk -f RoadLink.awk RoadLink.out > RoadLink.csv
```

3. Convert the restructured CSV into GeoJSON (WGS84 projection) using GDAL:

```
ogr2ogr -f "GeoJSON" -t_srs EPSG:4326 RoadLink.json RoadLink.vrt -lco RFC7946=YES -lco WRITE_NAME=NO
```

4. Convert the GeoJSON into OpenStreetMap XML using geojsontoosm (**command line tool**):

```
geojsontoosm RoadLink.json > highways.osm
```

Tidy up output:

```
sed -i '' $'s/>/>\\\n/g' highways.osm
sed -i '' 's/id="-/id="/g' highways.osm
sed -i '' 's/ref="-/ref="/g' highways.osm
```

5. Output the OpenStreetMap XML to PBF using Osmosis:

```
osmosis --read-xml highways.osm --write-pbf highways.osm.pbf
```

6. Run the GraphHopper Web Service:

```
java -Dgraphhopper.datareader.file=highways.osm.pbf  -jar *.jar server config-example.yml
```
