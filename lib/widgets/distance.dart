 import 'dart:math';
 
 getDistance({Latitude1, Latitude2, Longitude1, Longitude2}) {
    Latitude1 = Latitude1 * (3.14 / 180.0);
    Latitude2 = Latitude2 * (3.14 / 180.0);
    Longitude1 = Longitude1 * (3.14 / 180.0);
    Longitude2 = Longitude2 * (3.14 / 180.0);
    double R = 6371;
    double latitudeDifferece = Latitude2 - Latitude1;
    double longitudeDifferece = Longitude2 - Longitude1;
    double a = pow(sin((latitudeDifferece / 2)), 2) +
        cos(Latitude1) * cos(Latitude2) * pow(sin(longitudeDifferece / 2), 2);
    double sqrtOfA = sqrt(a);
    double n = 1 - sqrtOfA;
    double sqrtOfA_1 = sqrt(n);
    double c = 2 * atan2(sqrtOfA, sqrtOfA_1);
    double distance = R * c;
    distance = distance;
    return distance;
  }