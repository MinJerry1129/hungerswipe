import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/outlinedButton.dart';
import 'package:hungerswipe/helpers/widgets/listPicker.dart';
import 'package:hungerswipe/screens/unauthorized/signup/allergies.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class Cuisines extends StatefulWidget {
  @override
  _CuisinesState createState() => _CuisinesState();
}

class _CuisinesState extends State<Cuisines> {
  final List cuisines = [
    {
      "name": "Vegan",
      "img": "images/Icons/vegan.png",
      "selected": false,
    },
    {
      "name": "Japanese",
      "img": "images/Icons/japanese.png",
      "selected": false,
    },
    {
      "name": "Chinese",
      "img": "images/Icons/chinese.png",
      "selected": false,
    },
    {
      "name": "Mexican",
      "img": "images/Icons/mexican.png",
      "selected": false,
    },
    {
      "name": "Italian",
      "img": "images/Icons/italian.png",
      "selected": false,
    },
    {
      "name": "Indian",
      "img": "images/Icons/indian.png",
      "selected": false,
    },
  ];
  bool isActive = false;

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

    void _handleRemoveSelected(int index) {
      setState(() {
        Map item = cuisines[index];
        item.update("selected", (val) => true);
        print(item);
        this.isActive = true;
      });
    }

    void _handleAddSelected(int index) {
      setState(() {
        double count = 0;
        Map item = cuisines[index];
        item.update("selected", (val) => false);
        cuisines.asMap().forEach((key, value) {
          if (value['selected']) count += 1;
        });
        if (count == 0) this.isActive = false;
        print(item);
      });
    }

    var statusBarHeight = MediaQuery.of(context).padding.top;
    // var width = MediaQuery.of(context).size.width;

    void _handleUpdate() {
      List favorites = [];
      this.cuisines.forEach((element) {
        element['selected'] == true ? favorites.add(element) : null;
      });
      AppStateWidget.of(context).updateUserData("cuisines", cuisines);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => Allergies()));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: EdgeInsets.only(top: statusBarHeight + 20),
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
                      customIndicator(context, 40),
                      TextButton(
                          child: Text("Skip",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400)),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Allergies()));
                          })
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text('Cuisines',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Container(
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Select your favorite cuisines.",
                            style: TextStyle(
                                color: LightModeColors["helperText"],
                                fontSize: 16)),
                      ],
                    )),
                Expanded(
                    child: ListPicker(this.cuisines, _handleAddSelected,
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
