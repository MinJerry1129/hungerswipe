import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
// import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/gradientButton.dart';
import 'package:hungerswipe/screens/authorized/messages/group_swipe.dart';

class GroupSwipeButton extends StatelessWidget {
  const GroupSwipeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    void pushToGroupSwipe() {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => GroupSwipe()));
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: gradientButton(context, pushToGroupSwipe, 'Group Swiping'),
    );
  }
}
