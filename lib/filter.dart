import 'package:flutter/material.dart';

class Filter extends StatefulWidget {
  final Function(String, RangeValues, String) onApplyFilters;
  Filter({required this.onApplyFilters});
  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {

  var selectedRange = RangeValues(0.1, 9000);
  String selectedChambre = "Any";
  String selectedToilet = "Any";


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 24, left: 24, top: 32, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Text(
                "Filtrer",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(
                width: 8,
              ),

              Text(
                "votre recherche",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),

            ],
          ),

          SizedBox(
            height: 32,
          ),

          Row(
            children: [

              Text(
                "Fourchette de ",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),

              SizedBox(
                width: 8,
              ),

              Text(
                "prix",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),

          RangeSlider(
            values: selectedRange,
            onChanged: (RangeValues newRange) {
              setState(() {
                selectedRange = newRange;
              });
            },
            min: 0.1,
            max: 9000,
            activeColor: Colors.blue[900],
            inactiveColor: Colors.grey[300],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                r"100 DHs",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),

              Text(
                r"9000k Dhs",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),

            ],
          ),

          SizedBox(
            height: 16,
          ),

          Text(
            "Chambres",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 16,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Any", "1", "2", "3+"].map((option) => buildOption(option, 1)).toList(),
          ),

          SizedBox(
            height: 16,
          ),

          Text(
            "Toilettes",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            height: 16,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Any", "1", "2", "3+"].map((option) => buildOption(option, 2)).toList(),
          ),

          SizedBox(
            height: 25,
          ),

          Center(
            child: ElevatedButton(
              onPressed: () => applyFilters(),
              child: Text("Filtrer"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 36), // Sets the width to 80% of the view width
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildOption(String text, int selected) {
    bool isSelected = (selected == 1 ? selectedChambre : selectedToilet) == text;
    return GestureDetector(
      onTap: () => {
        if(selected == 1){
          setState(() => selectedChambre = text)
        }
        else{
          setState(() => selectedToilet = text)
        }
      },
      child: Container(
        height: 45,
        width: 65,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[900] : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(width: isSelected ? 0 : 1, color: Colors.grey),
        ),
        child: Center(
          child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 14)),
        ),
      ),
    );
  }

  void applyFilters() {
    widget.onApplyFilters(selectedChambre, selectedRange, selectedToilet);
    Navigator.pop(context);
  }

}