import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/outlinedButton.dart';
import 'package:hungerswipe/helpers/widgets/listPicker.dart';
import 'package:hungerswipe/screens/unauthorized/signup/cuisines.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class Favorites extends StatefulWidget {
  final String? type;
  final Function? handleFavoritesUpdate;
  Favorites({Key? key, this.type, this.handleFavoritesUpdate})
      : super(key: key);
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final List restaurants = [
    {
      "name": "McDonald's",
      "img": "images/Icons/mcdonalds.png",
      "selected": false,
    },
    {
      "name": "Chipotle",
      "img": "images/Icons/chipotle.png",
      "selected": false,
    },
    {
      "name": "Applebee's",
      "img": "images/Icons/applebees.png",
      "selected": false,
    },
    {
      "name": "Chick-fil-A",
      "img": "images/Icons/chickfila.png",
      "selected": false,
    },
    {
      "name": "Cheesecake Factory",
      "img": "images/Icons/cheesecakefactory.png",
      "selected": false,
    },
    {
      "name": "Panera",
      "img": "images/Icons/panerabread.png",
      "selected": false,
    },
  ];
  bool isActive = false;

  void _handleRemoveSelected(int index) {
    setState(() {
      Map item = restaurants[index];
      item.update("selected", (val) => true);
      print(item);
      this.isActive = true;
    });
  }

  void _handleAddSelected(int index) {
    setState(() {
      double count = 0;
      Map item = restaurants[index];
      item.update("selected", (val) => false);
      restaurants.asMap().forEach((key, value) {
        if (value['selected']) count += 1;
      });
      if (count == 0) this.isActive = false;
      print(item);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final Map _userData = AppStateScope.of(context).userData;

    var statusBarHeight = MediaQuery.of(context).padding.top;
    // var width = MediaQuery.of(context).size.width;

    void _handleUpdate() {
      List favorites = [];
      this.restaurants.forEach((element) {
        element['selected'] == true ? favorites.add(element) : null;
      });
      AppStateWidget.of(context).updateUserData("favorites", favorites);
      widget.type == 'from-edit'
          ? Navigator.of(context).pop()
          : Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => Cuisines()));

      widget.type == 'from-edit'
          ? widget.handleFavoritesUpdate!(favorites)
          : null;
      print('we on it made pip cheerio $favorites');
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: widget.type == 'from-edit'
                ? EdgeInsets.only(top: 20)
                : EdgeInsets.only(top: statusBarHeight + 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: LightModeColors["primary"], size: 24.0)),
                      widget.type == 'from-edit'
                          ? Container(width: 35)
                          : customIndicator(context, 35),
                      TextButton(
                          child: Text("Skip",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400)),
                          onPressed: () {
                            widget.type == 'from-edit'
                                ? Navigator.of(context).pop()
                                : Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Cuisines()));
                          })
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text('Favorites',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Container(
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Select your favorite restaurants.",
                            style: TextStyle(
                                color: LightModeColors["helperText"],
                                fontSize: 16)),
                      ],
                    )),
                Expanded(
                    child: ListPicker(this.restaurants, _handleAddSelected,
                        _handleRemoveSelected)),
                Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: this.isActive
                        ? gradientButton(context, _handleUpdate, "Next")
                        : outlinedButton(context, 36))
              ],
            )));
  }
}
