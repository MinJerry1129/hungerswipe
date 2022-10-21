import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/widgets/gradientIcon.dart';
import 'package:hungerswipe/helpers/widgets/scrollableChips.dart';
import 'package:hungerswipe/screens/authorized/profile/ext/editprofile.dart';
import 'package:hungerswipe/screens/authorized/profile/selfProfile.dart';
import 'package:hungerswipe/screens/authorized/profile/userProfile.dart';
import 'package:hungerswipe/services/app_state/app_state.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, required this.type, this.profileInfo}) : super(key: key);
  final String type;
  final Map? profileInfo;
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var _userData = AppStateScope.of(context).userData;
    var size = MediaQuery.of(context).size;
    var favorites = _userData['favorites'];
    // var userFavorites = widget.profileInfo?
    return widget.type == 'self'
        ? SelfProfile(_userData, favorites)
        : UserProfile(widget.profileInfo);
  }
}
