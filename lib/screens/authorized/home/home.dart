import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hungerswipe/helpers/widgets/swipeCard.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Content {
  final String text;

  Content({required this.text});
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late MatchEngine engine;
  double _yumOpacity = 0;
  double _yuckOpacity = 0;
  double _hungerswipeOpacity = 0;

  @override
  void initState() {
    super.initState();
    // api call for restaurant info
    print(
        'this wont work. i know it wont, but im crying internally bc it is stressful. man i wanna fucking get high so bad but ive been high the past 4 days lmfao');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final List<RestaurantItem> _restaurants =
        AppStateScope.of(context).restaurants;
    engine = MatchEngine(restaurantItems: _restaurants);
    print('this wont work. i knot high so bad but ive been high the past 4 days lmfao');
    print(_restaurants);
 
  }

  @override
  void dispose() {
    super.dispose();
  }

  var cardOffset = Offset(0.0, 0.0);
  @override
  Widget build(BuildContext context) {
    final Map _userData = AppStateScope.of(context).userData;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    void _showFilter(context) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              scrollable: true,
              title: new Text('Filter:'),
              content: new Text(
                  'this is where a checklist of all options of cuisines goes, but we do not have that information as of now'),
              actions: <Widget>[
                new TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('back'),
                ),
              ],
            );
          });
    }

    // call to api, snapshots.data!.docs.map((doc) { _swipeItem.add(doc) }), replace content to fit api return
    return Scaffold(
      body: Container(
        color: CupertinoTheme.of(context).primaryColor,
        alignment: Alignment.center,
        child: Column(
          children: [
            Expanded(
              child: SwipeCards(
                matchEngine: engine,
                
                panDidEnd: () {
                  setState(() {
                    if (_yumOpacity != 0) _yumOpacity = 0;
                    if (_yuckOpacity != 0) _yuckOpacity = 0;
                    if (_hungerswipeOpacity != 0) _hungerswipeOpacity = 0;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  var _restaurant = engine.currentItem!.content;
                  var _next = engine.nextItem!.content;
                  int distanceFromCurrent = (Geolocator.distanceBetween(
                              _restaurant['lat'],
                              _restaurant['lng'],
                              _userData['location']['latitude'],
                              _userData['location']['longitude']) /
                          1609.344)
                      .round();

                  int distanceFromNext = (Geolocator.distanceBetween(
                              _next['lat'],
                              _next['lng'],
                              _userData['location']['latitude'],
                              _userData['location']['longitude']) /
                          1609.344)
                      .round();

                  void _showLocale(context) {
                    // print('$_restaurant');
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            scrollable: true,
                            title: new Text('${_restaurant["name"]}'),
                            content: new Text('$_restaurant'),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: new Text('back'),
                              ),
                            ],
                          );
                        });
                  }

                  void _showInfo(context) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text('Info title'),
                            content: new Text('this is where stuff goes'),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: new Text('back'),
                              ),
                            ],
                          );
                        });
                  }

                  return engine.getCurrentItem() == index
                      ? Container(
                          //
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.black54,
                                  offset: Offset(0, 0),
                                  spreadRadius: -5)
                            ],
                            image: DecorationImage(
                              image: NetworkImage(
                                  _restaurant['photos'][engine.currentItem!.imageIndex]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                        style: ButtonStyle(
                                            splashFactory:
                                                NoSplash.splashFactory),
                                        onPressed: engine.currentItem!.cycleImageBack,
                                        child: Container(
                                            height: height * .8,
                                            width: width * .4,
                                            color: Colors.transparent)),
                                    TextButton(
                                        style: ButtonStyle(
                                            splashFactory:
                                                NoSplash.splashFactory),
                                        onPressed: engine.currentItem!.cycleImageForward,
                                        child: Container(
                                            height: height * .8,
                                            width: width * .4,
                                            color: Colors.transparent)),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                      _restaurant['photos'].length, (index) {
                                    print(
                                        'index: $index, image index: ${engine.currentItem!.imageIndex}, ');
                                    return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.5, vertical: 10),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                color: index == engine.currentItem!.imageIndex
                                                    ? Colors.white
                                                    : Colors.grey
                                                        .withOpacity(0.45),
                                                boxShadow: index == engine.currentItem!.imageIndex
                                                    ? [
                                                        BoxShadow(
                                                            color: Colors.black,
                                                            spreadRadius: -1,
                                                            blurRadius: 1,
                                                            offset:
                                                                Offset(0, 0))
                                                      ]
                                                    : null),
                                            height: 5,
                                            width: 50));
                                  })),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: height * 0.18,
                                  left: width * 0.15,
                                ),
                                child: Opacity(
                                  opacity: _yumOpacity,
                                  child: Transform.rotate(
                                    angle: -.5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 4,
                                          color: Color(0xFF55E864),
                                        ),
                                      ),
                                      child: Text(
                                        "YUM",
                                        style: TextStyle(
                                            color: Color(0xFF55E864),
                                            fontSize: 38,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: height * 0.25,
                                  left: width * 0.16,
                                ),
                                child: Opacity(
                                  opacity: _hungerswipeOpacity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 4,
                                        color: Color(0xFF7DCEFB),
                                      ),
                                    ),
                                    child: Text(
                                      "HUNGERSWIPE",
                                      style: TextStyle(
                                          color: Color(0xFF7DCEFB),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: height * 0.18,
                                  left: width * 0.5,
                                ),
                                child: Opacity(
                                  opacity: _yuckOpacity,
                                  child: Transform.rotate(
                                    angle: .5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 4,
                                          color: Color(
                                            0xFFFF5F5F,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "YUCK",
                                        style: TextStyle(
                                          color: Color(0xFFFF5F5F),
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: EdgeInsets.only(
                              //     top: height * 0.55,
                              //     left: width * 0.0135,
                              //   ),
                              Column(
                                children: [
                                  Spacer(),
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 10,
                                                offset: Offset(0, -5),
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                spreadRadius: .25)
                                          ]),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 20,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: AutoSizeText(
                                                    _restaurant['name'].length >
                                                            25
                                                        ? '${_restaurant['name'].substring(0, 20)}...'
                                                        : _restaurant['name'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    RichText(
                                                        text: TextSpan(
                                                            children: List.generate(
                                                                _restaurant[
                                                                        'rating']
                                                                    .round(),
                                                                (index) {
                                                      return _restaurant[
                                                                  'rating'] !=
                                                              null
                                                          ? WidgetSpan(
                                                              child: Icon(
                                                                  Icons.star,
                                                                  color: Color(
                                                                      0xFFFEC600)))
                                                          : TextSpan();
                                                    }))),
                                                    AutoSizeText(
                                                        '${_restaurant['city']['long_name']}, ${_restaurant['state']['short_name']}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ))
                                                  ],
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10),
                                                    child: Row(
                                                      children: [
                                                        // locator icons
                                                        Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            size: 18),
                                                        AutoSizeText(
                                                          ' $distanceFromCurrent mile(s) away',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                                Container(
                                                  width: width / 1.45,
                                                  child: AutoSizeText(
                                                    _restaurant['location'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 0,
                                                    ),
                                                    child: IconButton(
                                                        icon: Icon(
                                                            Icons.pin_drop,
                                                            size: 32),
                                                        onPressed: () {
                                                          _showLocale(context);
                                                        })),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 0,
                                                    ),
                                                    child: IconButton(
                                                        icon: Icon(
                                                            Icons.filter_list,
                                                            size: 32),
                                                        onPressed: () {
                                                          _showFilter(context);
                                                        })),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 0,
                                                    ),
                                                    child: IconButton(
                                                        icon: Icon(Icons.info,
                                                            size: 32),
                                                        onPressed: () {
                                                          _showInfo(context);
                                                        })),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(
                          //
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.black54,
                                  offset: Offset(0, 0),
                                  spreadRadius: -5)
                            ],
                            image: DecorationImage(
                              image: NetworkImage(_next['photos'][0]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                        style: ButtonStyle(
                                            splashFactory:
                                                NoSplash.splashFactory),
                                        onPressed: () {
                                          setState(() {
                                            // if index is not equal to 0, decrement index,
                                            engine.currentItem!.imageIndex = engine.currentItem!.imageIndex != 0
                                                ? engine.currentItem!.imageIndex -= 1
                                                : engine.currentItem!.imageIndex;
                                          });
                                          print(engine.currentItem!.imageIndex);
                                          print(_next['photos'].length);
                                        },
                                        child: Container(
                                            height: height * .8,
                                            width: width * .4,
                                            color: Colors.transparent)),
                                    TextButton(
                                        style: ButtonStyle(
                                            splashFactory:
                                                NoSplash.splashFactory),
                                        onPressed: () {
                                          setState(() {
                                            // if index is not equal to last photo index, increment index
                                            engine.currentItem!.imageIndex = engine.currentItem!.imageIndex !=
                                                    _next['photos'].length
                                                ? engine.currentItem!.imageIndex += 1
                                                : engine.currentItem!.imageIndex;
                                          });
                                          print(engine.currentItem!.imageIndex);
                                          print(_next['photos'].length);
                                        },
                                        child: Container(
                                            height: height * .8,
                                            width: width * .4,
                                            color: Colors.transparent)),
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                      _next['photos'].length, (index) {
                                    print(
                                        'index: $index, image index: $engine.currentItem!.imageIndex, ');
                                    return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.5, vertical: 10),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                color: index == engine.currentItem!.imageIndex
                                                    ? Colors.white
                                                    : Colors.grey
                                                        .withOpacity(0.45),
                                                boxShadow: index == engine.currentItem!.imageIndex
                                                    ? [
                                                        BoxShadow(
                                                            color: Colors.black,
                                                            spreadRadius: -1,
                                                            blurRadius: 1,
                                                            offset:
                                                                Offset(0, 0))
                                                      ]
                                                    : null),
                                            height: 5,
                                            width: 50));
                                  })),
                              Column(
                                children: [
                                  Spacer(),
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 10,
                                                offset: Offset(0, -5),
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                spreadRadius: .25)
                                          ]),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 20,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: AutoSizeText(
                                                    _next['name'].length > 25
                                                        ? '${_next['name'].substring(0, 20)}...'
                                                        : _next['name'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    RichText(
                                                        text: TextSpan(
                                                            children: List.generate(
                                                                _next['rating']
                                                                    .round(),
                                                                (index) {
                                                      return _next['rating'] !=
                                                              null
                                                          ? WidgetSpan(
                                                              child: Icon(
                                                                  Icons.star,
                                                                  color: Color(
                                                                      0xFFFEC600)))
                                                          : TextSpan();
                                                    }))),
                                                    AutoSizeText(
                                                        '${_next['city']['long_name']}, ${_next['state']['short_name']}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ))
                                                  ],
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10),
                                                    child: Row(
                                                      children: [
                                                        // locator icons
                                                        Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            size: 18),
                                                        AutoSizeText(
                                                          ' $distanceFromNext mile(s) away',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                                Container(
                                                  width: width / 1.45,
                                                  child: AutoSizeText(
                                                    _next['location'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 0,
                                                    ),
                                                    child: IconButton(
                                                        icon: Icon(
                                                            Icons.pin_drop,
                                                            size: 32),
                                                        onPressed: () {})),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 0,
                                                    ),
                                                    child: IconButton(
                                                        icon: Icon(
                                                            Icons.filter_list,
                                                            size: 32),
                                                        onPressed: () {})),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 0,
                                                    ),
                                                    child: IconButton(
                                                        icon: Icon(Icons.info,
                                                            size: 32),
                                                        onPressed: () {})),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        );
                },
                onStackFinished: () {
                  // possibly ask/force a larger search radius
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Stack Finished"),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                },
                onStackUpdate: (x, y) {
                  x = 0.7 * (x / 100.0);
                  y = 0.7 * (y / 100.0);
                  setState(
                    
                    () {
                      if (y < 0 && y.abs() < 1) _hungerswipeOpacity = y.abs();
                      if (x > 0 && x.abs() < 1) {
                        _yumOpacity = x.abs();
                      } else if (x.abs() < 1) {
                        _yuckOpacity = x.abs();
                      }
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: 1,
                          blurRadius: 7.5,
                          offset: Offset(0, 7.5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        engine.rewindMatch();
                      },
                      icon: Image.asset("images/Icons/BackArrow.png"),
                      iconSize: 36,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: 1,
                          blurRadius: 7.5,
                          offset: Offset(0, 7.5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        engine.currentItem?.yuck();
                      },
                      icon: Image.asset("images/Icons/Dislike.png"),
                      iconSize: 36,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: 1,
                          blurRadius: 7.5,
                          offset: Offset(0, 7.5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        engine.currentItem?.yum();
                      },
                      icon: Image.asset("images/Icons/Like.png"),
                      iconSize: 36,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: 1,
                          blurRadius: 7.5,
                          offset: Offset(0, 7.5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        engine.currentItem?.hungerswipe();
                      },
                      icon: Image.asset("images/Icons/HungerSwipe.png"),
                      iconSize: 36,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
