import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:real_estate/data.dart';
import 'package:provider/provider.dart';
import 'package:real_estate/providers/property_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Detail extends StatefulWidget {
  final Property property;

  Detail({required this.property});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteStatus();
  }

  Future<void> _fetchFavoriteStatus() async {
    try {
      setState(() {
        isFavorite = widget.property.favorite;
      });
    } catch (e) {
      print('Error fetching favorite status: $e');
    }
  }

  void _launchCaller(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Hero(
            tag: widget.property.frontImage,
            child: Container(
              height: size.height * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.property.frontImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            height: size.height * 0.40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isFavorite = !isFavorite;
                            widget.property.favorite = isFavorite;
                          });
                          if (isFavorite) {
                            await Provider.of<PropertyProvider>(context, listen: false).favorite(widget.property.property_id);
                          } else {
                            await Provider.of<PropertyProvider>(context, listen: false).removeFavorite(widget.property.property_id);
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: isFavorite ? Colors.yellow[700] : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: isFavorite ? Colors.white : Colors.yellow[700],
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    width: 80,
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: Text(
                        "FOR " + widget.property.label,
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.property.name,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            widget.property.location,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.zoom_out_map, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[700], size: 16),
                          SizedBox(width: 4),
                          Text(
                            widget.property.review,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 65,
                                width: 65,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(widget.property.ownerImage),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.property.ownerName,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Propriétaire",
                                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.phone, size: 40, color: Colors.yellow[700]),
                                          SizedBox(height: 10),
                                          Text(
                                            'Contacter Le Propriétaire',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            widget.property.phone,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.yellow[700]),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                  ),
                                                ),
                                                child: Text('Close', style: TextStyle(color: Colors.white)),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _launchCaller(widget.property.phone);
                                                  Navigator.of(context).pop();
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.green),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                  ),
                                                ),
                                                child: Text('Call', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.yellow[700]?.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.yellow[700],
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 24, left: 24, bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildEquipmentList(context, widget.property.equipments, widget.property.number_of_rooms),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 24, left: 24, bottom: 16),
                      child: Text(
                        "Description",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 24, left: 24, bottom: 24),
                      child: SizedBox(
                        height: 100,
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              widget.property.description,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 24, left: 24, bottom: 16),
                      child: Text(
                        "Photos",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: buildPhotos(context, widget.property.images),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildPhotos(BuildContext context, List<String> images) {
    List<Widget> list = [];
    list.add(SizedBox(width: 24));
    for (var i = 0; i < images.length; i++) {
      list.add(buildPhoto(context, images, i));
    }
    list.add(SizedBox(width: 24));
    return list;
  }

  void showImageDialog(BuildContext context, List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: PageView.builder(
            itemCount: imageUrls.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: false,
                boundaryMargin: EdgeInsets.all(80),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(imageUrls[index], fit: BoxFit.contain),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildPhoto(BuildContext context, List<String> images, int index) {
    return GestureDetector(
      onTap: () {
        showImageDialog(context, images, index);
      },
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Container(
          margin: EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            image: DecorationImage(
              image: NetworkImage(images[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEquipmentList(BuildContext context, List<Equipment> equipments, String? nbr_of_rooms) {
    List<Equipment> allEquipments = List.from(equipments); // Clone the original list to avoid modifying it.
    if (nbr_of_rooms != null) {
      int? roomCount = int.tryParse(nbr_of_rooms); // Attempt to parse the number of rooms
      if (roomCount != null) { // Ensure the parsing was successful
        String roomText = roomCount > 1 ? "chambres" : "chambre"; // Decide singular or plural
        Equipment roomsEquipment = Equipment(
          id: 1000,
          name: "$nbr_of_rooms $roomText",
          iconSvg: '''
            <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" 
              viewBox="0 0 511.999 511.999" xml:space="preserve">
            <g>
              <polygon style="fill:#1D1D1B;" points="207.853,271.997 192.146,271.997 192.146,296.145 167.853,296.145 167.853,231.853 
                192.146,231.853 192.146,239.995 207.853,239.995 207.853,216.146 152.146,216.146 152.146,311.852 207.853,311.852   "/>
              <rect x="176" y="248.146" style="fill:#1D1D1B;" width="56" height="15.707"/>
              <path style="fill:#1D1D1B;" d="M103.854,56.146H24.147v127.707h79.707V56.146z M88.147,168.146H39.853V71.853h48.293V168.146z"/>
              <rect x="47.999" y="144.146" style="fill:#1D1D1B;" width="32" height="15.707"/>
              <rect x="56.147" y="87.999" style="fill:#1D1D1B;" width="15.707" height="40"/>
              <rect x="32" y="192.146" style="fill:#1D1D1B;" width="16" height="15.707"/>
              <rect x="56" y="192.146" style="fill:#1D1D1B;" width="16" height="15.707"/>
              <rect x="80" y="192.146" style="fill:#1D1D1B;" width="16" height="15.707"/>
              <path style="fill:#1D1D1B;" d="M511.999,471.927V456.22H391.852V0.147H120.146v456.074H0v15.707h120.146v24.218H0v15.707h511.999
                v-15.707H391.852v-24.219H511.999z M376.145,496.144H135.853V15.853h240.293L376.145,496.144L376.145,496.144z"/>
            </g>
            </svg>
          ''',
        );
        allEquipments.insert(0, roomsEquipment);
      }
    }
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width - 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allEquipments.length,
        itemBuilder: (context, index) {
          return buildEquipmentWidget(allEquipments[index]);
        },
      ),
    );
  }

  Widget buildEquipmentWidget(Equipment equipment) {
    return Container(
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(
            equipment.iconSvg,
            width: 28,
            height: 28,
            placeholderBuilder: (context) => CircularProgressIndicator(),
          ),
          SizedBox(height: 4),
          Text(
            equipment.name,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
