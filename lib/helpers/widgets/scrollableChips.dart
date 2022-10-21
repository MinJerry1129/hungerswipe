import 'package:flutter/material.dart';
// import 'package:hungerswipe/helpers/colors.dart';
// import 'package:hungerswipe/helpers/widgets/gradientIcon.dart';

class ScrollableChips extends StatefulWidget {
  final List dynamicList;
  const ScrollableChips(this.dynamicList);
  @override
  _ScrollableChipsState createState() => _ScrollableChipsState();
}

class _ScrollableChipsState extends State<ScrollableChips> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List<Widget>.generate(
              widget.dynamicList.isNotEmpty ? widget.dynamicList.length : 0,
              (int index) {
            return Container(
                width: MediaQuery.of(context).size.width * .25,
                height: 70,
                child: Image(
                    image: AssetImage('${widget.dynamicList[index]["img"]}'),
                    fit: BoxFit.fitHeight));
          }),
        ));
  }
}
