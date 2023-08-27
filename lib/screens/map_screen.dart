import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_finder/themes/colors/colors.dart';
import 'package:location_finder/widgets/distance.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Checks if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  static const initialposition = CameraPosition(target: LatLng(37.773972, -122.431297), zoom: 18);

  late GoogleMapController googleMapController;
  final Map<String, Marker> _markers = {};
  
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double distance = 0;
  bool isVisible = false;

  // String googleAPiKey = "AIzaSyA3xZFjs3VsCW9D2lBbL1vzKIT8G-JvvNc";
  String googleAPiKey = "AIzaSyDJu89H8BuFgVRPmlEAEhO4RJ8ym7Wf85I";

  @override
  void initState() {
    // initialize();
    polylinePoints;
    super.initState();
  }

// This function does gets the coordinates from the addressed passed to it
  Future<Location> getCoordinate(value) async {
    List<Location> locations = await locationFromAddress(value);
    Location location = locations[0];

    return location;
  }

// This saves the value from the search field.
  final _controller = TextEditingController();

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        title: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: searchBar,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            textAlign: TextAlign.center,
            controller: _controller,
            decoration: InputDecoration(
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                  IconButton(
                    color: Colors.green.shade900,
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      dynamic con = _controller;
                      var con1 = con.toString();

                      // passing in the value from the search field as an argument into 
                      // the getCoordinate function, to get the coordinates.

                      Location location = await getCoordinate(con1);
                      dynamic newlat = location.latitude;
                      dynamic newlong = location.longitude;
                      Position position = await _determinePosition();

                      // passes the coordinates gotten from getCoordinate() as arguments
                      // into the getDistance() function to calculate the distance.

                      distance = getDistance(
                          Latitude1: position.latitude,
                          Latitude2: location.latitude,
                          Longitude1: position.longitude,
                          Longitude2: location.longitude);
                      setState(() {
                        if (distance != 0) {
                          isVisible = true;
                        }
                        
                        // calling the showMarkers() function [found at the end of the code].
                        // calling it twice to get two markers, with the current position
                        // coordinates and the destination coordinates 

                        showMarkers(LatLng(newlat, newlong), 'id1', 'snippet',
                            BitmapDescriptor.hueGreen);
                        showMarkers(
                            LatLng(position.latitude, position.longitude),
                            'id',
                            'snippet',
                            BitmapDescriptor.hueAzure);

                        // when the search button is clicked, the camera animates to the new position
                        // i.e the destination position.

                        googleMapController
                            .animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: LatLng(newlat, newlong), zoom: 18),
                        ));
                      });
                    },
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.all(10),
              hintText: 'Search for places',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: borderEnabled)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: borderFocused, width: 2),
              ),
            ),
          ),
        ),
      ),

      // using a stack so as to overlap the "distance_container" on the map

      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            initialCameraPosition: initialposition,
            mapType: MapType.normal,
            polylines: Set<Polyline>.of(polylines.values),
            markers: _markers.values.toSet(),
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                googleMapController = controller;
              });
            },
          ),

          // wrapping the "distance_container" with a Visibility widget
          // so that I can toggle between 'hidden': when the user has not
          // searched for a destination and 'visible' when the user searches.

         /// The above code is creating a widget that displays the distance between two points on a map.
         /// The widget is only visible if the `isVisible` variable is true. The distance is displayed
         /// in a container with a rounded border and a background color specified by the
         /// `distContainer` variable. The text color is specified by the `distText` variable and the
         /// distance value is displayed with a bold font. The container is positioned at 30% of the
         /// screen width from the left and 20% of the screen height from the top.
          Visibility(
            visible: isVisible,
            child: Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  // color: const Color.fromARGB(209, 198, 186, 229),
                  color: distContainer,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                child: Text(
                  'Distance: ${distance.floor()}km',
                  style: const TextStyle(
                      color: distText, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {

              // calling my showPolylines() function on the button press
              // so as to get the directions and show the polyline

              showPolylines();
            },
            label: const Text('Directions'),
            icon: const Icon(Icons.directions),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            onPressed: () async {

              // onbuttonpress, the _determinePosition() function runs, gets
              // the coordinates and animates the map to the location.

              Position position = await _determinePosition();
              googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 18),
                ),
              );

              // creates a marker at the current location
              showMarkers(LatLng(position.latitude, position.longitude), 'id',
                  'snippet', BitmapDescriptor.hueAzure);
            },
            label: const Text('Location'),
            icon: const Icon(Icons.location_city),
          ),
        ],
      ),
    );
  }

  // function that creates a marker
  showMarkers(LatLng pos, id, snippet, color) {
    setState(() {
      var marker = Marker(
        markerId: MarkerId(id),
        position: pos,
        infoWindow: InfoWindow(snippet: snippet),
        icon: BitmapDescriptor.defaultMarkerWithHue(color),
      );
      _markers[id] = marker;
    });
  }

  // function that creates the polyline details
 /// This function adds a polyline to a map in Dart programming language.
  addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, 
        color: polylineRed, 
        width: 5,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  // function that draws the polyline, between the two points
  // [current and destination locations]
 /// The function shows polylines between the current location and a destination location using Google
 /// Maps API.
  showPolylines() async {

    // still calling the _determinePosition() and getCoordinates() to have 
    // access to the current and destination locations

    Position position = await _determinePosition();
    dynamic con = _controller;
    var con1 = con.toString();
    Location location = await getCoordinate(con1);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(position.latitude, position.longitude),
        PointLatLng(location.latitude, location.longitude),
        travelMode: TravelMode.walking);
    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    addPolyLine();
  }
}
