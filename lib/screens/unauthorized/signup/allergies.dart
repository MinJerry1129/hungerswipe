import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/customIndicator.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/helpers/widgets/outlinedButton.dart';
import 'package:hungerswipe/helpers/widgets/listPicker.dart';
import 'package:hungerswipe/screens/unauthorized/signup/location.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class Allergies extends StatefulWidget {
  @override
  _AllergiesState createState() => _AllergiesState();
}

class _AllergiesState extends State<Allergies> {
  final List allergies = [
    {
      "name": "Gluten",
      "img": "images/Icons/gluten.png",
      "selected": false,
    },
    {
      "name": "Peanuts",
      "img": "images/Icons/peanuts.png",
      "selected": false,
    },
    {
      "name": "Seafood",
      "img": "images/Icons/seafood.png",
      "selected": false,
    },
    {
      "name": "Soybeans",
      "img": "images/Icons/soybeans.png",
      "selected": false,
    },
    {
      "name": "Dairy",
      "img": "images/Icons/dairy.png",
      "selected": false,
    },
    {
      "name": "Sesame",
      "img": "images/Icons/sesame.png",
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
    void _handleRemoveSelected(int index) {
      setState(() {
        Map item = allergies[index];
        item.update("selected", (val) => true);
        print(item);
        this.isActive = true;
      });
    }

    void _handleAddSelected(int index) {
      setState(() {
        double count = 0;
        Map item = allergies[index];
        item.update("selected", (val) => false);
        allergies.asMap().forEach((key, value) {
          if (value['selected']) count += 1;
        });
        if (count == 0) this.isActive = false;
        print(item);
      });
    }

    // final Map _userData = AppStateScope.of(context).userData;

    var statusBarHeight = MediaQuery.of(context).padding.top;
    // var width = MediaQuery.of(context).size.width;

    void _handleUpdate() {
      List userAllergies = [];
      this.allergies.forEach((element) {
        element['selected'] == true ? userAllergies.add(element) : null;
      });
      AppStateWidget.of(context).updateUserData("allergies", userAllergies);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => Location()));
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
                      customIndicator(context, 45),
                      TextButton(
                          child: Text("Skip",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400)),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => Location()));
                          })
                    ]),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text('Allergies',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold))),
                Container(
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Select any allergies you might have.",
                            style: TextStyle(
                                color: LightModeColors["helperText"],
                                fontSize: 16)),
                      ],
                    )),
                Expanded(
                    child: ListPicker(this.allergies, _handleAddSelected,
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
