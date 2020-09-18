# COMMAND LINE awk -f RoadLink.awk RoadLink.out > RoadLink.csv

BEGIN {
	printf("id,highway,name,alt_name,ref,oneway,_length,_grade_separation,wkt\n")
}

{
	i = split($0,highwaysStr,"#")

	featureMember = highwaysStr[1]
	id = highwaysStr[2]
	localId = highwaysStr[3]
	beginLifespanVersion = highwaysStr[4]
	validFrom = highwaysStr[5]
	fictitious = highwaysStr[6]
	roadClassification = highwaysStr[7]
	routeHierarchy = highwaysStr[8]
	formOfWay = highwaysStr[9]
	trunkRoad = highwaysStr[10]
	primaryRoute = highwaysStr[11]
	roadClassificationNumber = highwaysStr[12]
	roadName = highwaysStr[13]
	alternateName = highwaysStr[14]
	operationalState = highwaysStr[15]
	provenance = highwaysStr[16]
	directionality = highwaysStr[17]
	lnklength = highwaysStr[18]
	matchStatus = highwaysStr[19]
	alternateIdentifier = highwaysStr[20]
	startNode = highwaysStr[21]
	startGradeSeparation = highwaysStr[22]
	endNode = highwaysStr[23]
	endGradeSeparation = highwaysStr[24]
	roadStructure = highwaysStr[25]
	cycleFacility = highwaysStr[26]
	roadWidth_averageWidth = highwaysStr[27]
	roadWidth_minimumWidth = highwaysStr[28]
	roadWidth_confidenceLevel = highwaysStr[29]
	numberOfLanes = highwaysStr[30]
	elevationGain_inDirection = highwaysStr[31]
	elevationGain_inOppositeDirection = highwaysStr[32]
	formsPartOf = highwaysStr[33]
	relatedRoadArea = highwaysStr[34]
	reasonForChange = highwaysStr[35]
	centrelineGeometry = highwaysStr[36]

	# routeHierarchy
	# + Motorway
	# + A Road Primary
	# + A Road
	# + B Road Primary
	# + B Road
	# + Minor Road
	# + Local Road
	# + Local Access Road
	# + Restricted Local Access Road
	# + Secondary Access Road
	# + Restricted Secondary Access Road

	# OSM Highway
	# + motorway (motorway_link)
	# + trunk (trunk_link)
	# + primary (primary_link)
	# + secondary (secondary_link)
	# + tertiary (tertiary_link)
	# + unclassified
	# + residential
	# + service

	switch (routeHierarchy) {
		case "Motorway":
			highway = formOfWay == "Slip Road" ? "motorway_link" : "motorway"
			break
		case "A Road Primary":
		case "B Road Primary":
			highway = formOfWay == "Slip Road" ? "trunk_link" : "trunk"
			break
		case "A Road":
			highway = formOfWay == "Slip Road" ? "primary_link" : "primary"
			break
		case "B Road":
			highway = formOfWay == "Slip Road" ? "secondary_link" : "secondary"
			break
		case "Minor Road":
			highway = formOfWay == "Slip Road" ? "tertiary_link" : "tertiary"
			break
		case "Local Road":
			highway = "residential"
			break
		default:
			highway = "service"
			break
	}

	j = split(roadName,roadNameStr,";")
	name = roadNameStr[1]

	j = split(alternateName,alternateNameStr,";")
	alt_name = alternateNameStr[1]

	ref = roadClassificationNumber

# 	junction = formOfWay == "Rounabout" ? "roundabout" : ""

	oneway = directionality == "both directions" ? "no" : directionality == "in direction" ? "yes" : "-1"

	if (oneway == -1) {
		wktStr = reverseLineStringToWKT(centrelineGeometry)
		oneway = "yes"
	} else {
		wktStr = lineStringToWKT(centrelineGeometry)
	}

	grade_separation = "{" startGradeSeparation "," endGradeSeparation "}"

	printf("%s,%s,%s,%s,%s,%s,%s,\"%s\",\"%s\"\n",
		id,highway,name,alt_name,ref,oneway,lnklength,grade_separation,wktStr)
}

function lineStringToWKT(coords) {
	wktStr = "LINESTRING ("
	j = split(coords,coordsStr,",")
	dim = coordsStr[1]
	count = coordsStr[2]
	geom = coordsStr[3]
	j = split(geom,xyStr," ")
	if (dim == 2) {
		for (k=1; k<j; k+=2) {
			wktStr = wktStr xyStr[k] " " xyStr[k+1] ","
		}
	} else {
		for (k=1; k<j; k+=3) {
			wktStr = wktStr xyStr[k] " " xyStr[k+1] " " xyStr[k+2] ","
		}
	}
	lenStr = length(wktStr)-1
	wktStr = substr(wktStr,1,lenStr)
	wktStr = wktStr ")"
	return wktStr
}

function reverseLineStringToWKT(coords) {
	wktStr = "LINESTRING ("
	j = split(coords,coordsStr,",")
	dim = coordsStr[1]
	count = coordsStr[2]
	geom = coordsStr[3]
	j = split(geom,xyStr," ")
	if (dim == 2) {
		for (k=j; k>0; k-=2) {
			wktStr = wktStr xyStr[k-1] " " xyStr[k] ","
		}
	} else {
		for (k=j; k>0; k-=3) {
			wktStr = wktStr xyStr[k-2] " " xyStr[k-1] " " xyStr[k] ","
		}
	}
	lenStr = length(wktStr)-1
	wktStr = substr(wktStr,1,lenStr)
	wktStr = wktStr ")"
	return wktStr
}
