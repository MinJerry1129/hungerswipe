import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum SlideDirection { left, right, up }
enum SlideRegion { inNopeRegion, inLikeRegion, inSuperLikeRegion }

// restaurant card
class ProfileCard extends StatefulWidget {
  final Widget? child;

  const ProfileCard({Key? key, this.child}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}

// draggable card
class DraggableCard extends StatefulWidget {
  final Widget? card;
  final bool isDraggable;
  final SlideDirection? slideTo;
  final Function(double distance)? onSlideUpdate;
  final Function(SlideRegion? slideRegion)? onSlideRegionUpdate;
  final Function(SlideDirection? direction)? onSlideOutComplete;
  final Function(double xOpacity, double yOpacity)? onSlideUpdateOpacity;
  final Function()? panDidEnd;

  DraggableCard(
      {this.card,
      this.isDraggable = true,
      this.onSlideUpdate,
      this.panDidEnd,
      this.onSlideOutComplete,
      this.onSlideUpdateOpacity,
      this.slideTo,
      this.onSlideRegionUpdate});

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  GlobalKey profileCardKey = GlobalKey(debugLabel: 'profile_card_key');
  Offset? cardOffset = const Offset(0.0, 0.0);
  Offset? dragStart;
  Offset? dragPosition;
  Offset? slideBackStart;
  SlideDirection? slideOutDirection;
  SlideRegion? slideRegion;
  late AnimationController slideBackAnimation;
  Tween<Offset>? slideOutTween;
  late AnimationController slideOutAnimation;

  RenderBox? box;
  var topLeft, bottomRight;
  Rect? anchorBounds;

  bool isAnchorInitialized = false;

  @override
  void initState() {
    super.initState();

    slideBackAnimation = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )
      ..addListener(() => setState(() {
            cardOffset = Offset.lerp(
              slideBackStart,
              const Offset(0.0, 0.0),
              Curves.elasticOut.transform(slideBackAnimation.value),
            );

            if (null != widget.onSlideUpdate) {
              widget.onSlideUpdate!(cardOffset!.distance);
            }

            if (null != widget.onSlideRegionUpdate) {
              widget.onSlideRegionUpdate!(slideRegion);
            }
          }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            slideBackStart = null;
            dragPosition = null;
          });
        }
      });

    slideOutAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          cardOffset = slideOutTween!.evaluate(slideOutAnimation);

          if (null != widget.onSlideUpdate) {
            widget.onSlideUpdate!(cardOffset!.distance);
          }

          if (null != widget.onSlideRegionUpdate) {
            widget.onSlideRegionUpdate!(slideRegion);
          }
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            dragPosition = null;
            slideOutTween = null;

            if (widget.onSlideOutComplete != null) {
              widget.onSlideOutComplete!(slideOutDirection);
            }
          });
        }
      });
  }

  @override
  void didUpdateWidget(DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card!.key != oldWidget.card!.key) {
      cardOffset = const Offset(0.0, 0.0);
    }

    if (oldWidget.slideTo == null && widget.slideTo != null) {
      switch (widget.slideTo) {
        case SlideDirection.left:
          _slideLeft();
          break;
        case SlideDirection.right:
          _slideRight();
          break;
        case SlideDirection.up:
          _slideUp();
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    slideBackAnimation.dispose();
    super.dispose();
  }

  Offset _chooseRandomDragStart() {
    final cardContext = profileCardKey.currentContext!;
    final cardTopLeft = (cardContext.findRenderObject() as RenderBox)
        .localToGlobal(const Offset(0.0, 0.0));
    final dragStartY =
        cardContext.size!.height * (Random().nextDouble() < 0.5 ? 0.25 : 0.75) +
            cardTopLeft.dy;
    return Offset(cardContext.size!.width / 2 + cardTopLeft.dx, dragStartY);
  }

  void _slideLeft() async {
    await Future.delayed(Duration(milliseconds: 1)).then((_) {
      final screenWidth = context.size!.width;
      dragStart = _chooseRandomDragStart();
      slideOutTween = Tween(
          begin: const Offset(0.0, 0.0), end: Offset(-2 * screenWidth, 0.0));
      slideOutAnimation.forward(from: 0.0);
    });
  }

  void _slideRight() async {
    await Future.delayed(Duration(milliseconds: 1)).then((_) {
      final screenWidth = context.size!.width;
      dragStart = _chooseRandomDragStart();
      slideOutTween = Tween(
          begin: const Offset(0.0, 0.0), end: Offset(2 * screenWidth, 0.0));
      slideOutAnimation.forward(from: 0.0);
    });
  }

  void _slideUp() async {
    await Future.delayed(Duration(milliseconds: 1)).then((_) {
      final screenHeight = context.size!.height;
      dragStart = _chooseRandomDragStart();
      slideOutTween = Tween(
          begin: const Offset(0.0, 0.0), end: Offset(0.0, -2 * screenHeight));
      slideOutAnimation.forward(from: 0.0);
    });
  }

  void _onPanStart(DragStartDetails details) {
    dragStart = details.globalPosition;

    if (slideBackAnimation.isAnimating) {
      slideBackAnimation.stop(canceled: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    widget.onSlideUpdateOpacity!(cardOffset!.dx, cardOffset!.dy);
    final isInLeftRegion = (cardOffset!.dx / context.size!.width) < -0.4;
    final isInRightRegion = (cardOffset!.dx / context.size!.width) > 0.4;
    final isInTopRegion = (cardOffset!.dy / context.size!.height) < -0.35;

    setState(() {
      if (isInLeftRegion || isInRightRegion) {
        slideRegion = isInLeftRegion
            ? SlideRegion.inNopeRegion
            : SlideRegion.inLikeRegion;
      } else if (isInTopRegion) {
        slideRegion = SlideRegion.inSuperLikeRegion;
      } else {
        slideRegion = null;
      }

      dragPosition = details.globalPosition;
      cardOffset = dragPosition! - dragStart!;

      if (null != widget.onSlideUpdate) {
        widget.onSlideUpdate!(cardOffset!.distance);
      }

      if (null != widget.onSlideRegionUpdate) {
        widget.onSlideRegionUpdate!(slideRegion);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dragVector = cardOffset! / cardOffset!.distance;
    widget.panDidEnd!();
    final isInLeftRegion = (cardOffset!.dx / context.size!.width) < -0.35;
    final isInRightRegion = (cardOffset!.dx / context.size!.width) > 0.35;
    final isInTopRegion = (cardOffset!.dy / context.size!.height) < -0.35;

    setState(() {
      if (isInLeftRegion || isInRightRegion) {
        slideOutTween = Tween(
            begin: cardOffset, end: dragVector * (2 * context.size!.width));
        slideOutAnimation.forward(from: 0.0);

        slideOutDirection =
            isInLeftRegion ? SlideDirection.left : SlideDirection.right;
      } else if (isInTopRegion) {
        slideOutTween = Tween(
            begin: cardOffset, end: dragVector * (2 * context.size!.height));
        slideOutAnimation.forward(from: 0.0);

        slideOutDirection = SlideDirection.up;
      } else {
        slideBackStart = cardOffset;
        slideBackAnimation.forward(from: 0.0);
      }

      slideRegion = null;
      if (null != widget.onSlideRegionUpdate) {
        widget.onSlideRegionUpdate!(slideRegion);
      }
    });
  }

  double _rotation(Rect? dragBounds) {
    if (dragStart != null) {
      final rotationCornerMultiplier =
          dragStart!.dy >= dragBounds!.top + (dragBounds.height / 2) ? -1 : 1;
      return (pi / 8) *
          (cardOffset!.dx / dragBounds.width) *
          rotationCornerMultiplier;
    } else {
      return 0.0;
    }
  }

  Offset _rotationOrigin(Rect? dragBounds) {
    if (dragStart != null) {
      return dragStart! - dragBounds!.topLeft;
    } else {
      return const Offset(0.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAnchorInitialized) {
      _initAnchor();
    }

    return Transform(
      transform: Matrix4.translationValues(cardOffset!.dx, cardOffset!.dy, 0.0)
        ..rotateZ(_rotation(anchorBounds)),
      origin: _rotationOrigin(anchorBounds),
      child: Container(
        key: profileCardKey,
        width: anchorBounds?.width,
        height: anchorBounds?.height,
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: widget.card,
        ),
      ),
    );
  }

  _initAnchor() async {
    await Future.delayed(Duration(milliseconds: 3));
    box = context.findRenderObject() as RenderBox?;
    topLeft = box!.size.topLeft(box!.localToGlobal(const Offset(0.0, 0.0)));
    bottomRight =
        box!.size.bottomRight(box!.localToGlobal(const Offset(0.0, 0.0)));
    anchorBounds = new Rect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      bottomRight.dx,
      bottomRight.dy,
    );

    setState(() {
      isAnchorInitialized = true;
    });
  }
}

class SwipeCards extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final MatchEngine matchEngine;
  final Function onStackFinished;
  final Function(double x, double y) onStackUpdate;
  final Function() panDidEnd;

  const SwipeCards(
      {Key? key,
      required this.matchEngine,
      required this.panDidEnd,
      required this.onStackFinished,
      required this.onStackUpdate,
      required this.itemBuilder})
      : super(key: key);

  @override
  _SwipeCardsState createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards> {
  Key? _frontCard;
  RestaurantItem? _currentItem;
  double _nextCardScale = 0.9;
  SlideRegion? slideRegion;

  @override
  void initState() {
    widget.matchEngine.addListener(_onMatchEngineChange);
    _currentItem = widget.matchEngine.currentItem;
    _currentItem?.addListener(_onMatchChange);
    _frontCard = Key(widget.matchEngine._currentItemIndex.toString());
    super.initState();
  }

  @override
  void dispose() {
    if (_currentItem != null) {
      _currentItem!.removeListener(_onMatchChange);
    }
    widget.matchEngine.removeListener(_onMatchEngineChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matchEngine != oldWidget.matchEngine) {
      oldWidget.matchEngine.removeListener(_onMatchEngineChange);
      widget.matchEngine.addListener(_onMatchEngineChange);
    }
    if (_currentItem != null) {
      _currentItem!.removeListener(_onMatchChange);
    }
    _currentItem = widget.matchEngine.currentItem;
    if (_currentItem != null) {
      _currentItem!.addListener(_onMatchChange);
    }
  }

  void _onMatchEngineChange() {
    setState(() {
      if (_currentItem != null) {
        _currentItem!.removeListener(_onMatchChange);
      }
      _currentItem = widget.matchEngine.currentItem;
      if (_currentItem != null) {
        _currentItem!.addListener(_onMatchChange);
      }
      _frontCard = Key(widget.matchEngine._currentItemIndex.toString());
    });
  }

  void _onMatchChange() {
    setState(() {
      //match has been changed
    });
  }

  Widget _buildFrontCard() {
    return ProfileCard(
      child: widget.itemBuilder(context, widget.matchEngine._currentItemIndex!),
      key: _frontCard,
    );
  }

  Widget _buildBackCard() {
    return Transform(
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: ProfileCard(
        child: widget.itemBuilder(context, widget.matchEngine._nextItemIndex!),
      ),
    );
  }

  void _onSlideUpdate(double distance) {
    // widget.onStackUpdate(0.5 * (distance / 100.0));
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideRegion(SlideRegion? region) {
    setState(() {
      slideRegion = region;
    });
  }

  void _onSlideOutComplete(SlideDirection? direction) {
    RestaurantItem? currentMatch = widget.matchEngine.currentItem;
    switch (direction) {
      case SlideDirection.left:
        currentMatch!.yuck();
        break;
      case SlideDirection.right:
        currentMatch!.yum();
        break;
      case SlideDirection.up:
        currentMatch!.hungerswipe();
        break;
      default:
        break;
    }

    widget.matchEngine.cycleMatch();
    if (widget.matchEngine.currentItem == null) {
      widget.onStackFinished();
    }
  }

  SlideDirection? _desiredSlideOutDirection() {
    switch (widget.matchEngine.currentItem!.decision) {
      case Decision.yuck:
        return SlideDirection.left;
      case Decision.yum:
        return SlideDirection.right;
      case Decision.hungerswipe:
        return SlideDirection.up;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (widget.matchEngine.nextItem != null)
          DraggableCard(
            isDraggable: false,
            card: _buildBackCard(),
          ),
        if (widget.matchEngine.currentItem != null)
          DraggableCard(
            card: _buildFrontCard(),
            slideTo: _desiredSlideOutDirection(),
            onSlideUpdate: _onSlideUpdate,
            onSlideRegionUpdate: _onSlideRegion,
            onSlideOutComplete: _onSlideOutComplete,
            onSlideUpdateOpacity: widget.onStackUpdate,
            panDidEnd: widget.panDidEnd,
          ),
      ],
    );
  }
}

class MatchEngine extends ChangeNotifier {
  final List<RestaurantItem>? restaurantItems;
  int? _currentItemIndex;
  int? _nextItemIndex;

  MatchEngine({
    List<RestaurantItem>? restaurantItems,
  }) : restaurantItems = restaurantItems {
    _currentItemIndex = 0;
    _nextItemIndex = 1;
  }

  RestaurantItem? get previousItem =>
      _currentItemIndex! < restaurantItems!.length
          ? restaurantItems![_currentItemIndex! - 1]
          : null;

  RestaurantItem? get currentItem =>
      _currentItemIndex! < restaurantItems!.length
          ? restaurantItems![_currentItemIndex!]
          : null;

  RestaurantItem? get nextItem => _nextItemIndex! < restaurantItems!.length
      ? restaurantItems![_nextItemIndex!]
      : null;

  void cycleMatch() {
    if (currentItem!.decision != Decision.undecided) {
      currentItem!.resetMatch();
      _currentItemIndex = _nextItemIndex;
      _nextItemIndex = _nextItemIndex! + 1;
      notifyListeners();
    }
  }

  int? getCurrentItem() => _currentItemIndex;

  void rewindMatch() {
    if (_currentItemIndex != 0) {
      currentItem!.resetMatch();
      _nextItemIndex = _currentItemIndex;
      _currentItemIndex = _currentItemIndex! - 1;
      currentItem!.resetMatch();
      notifyListeners();
    }
  }
}

class RestaurantItem extends ChangeNotifier {
  final Map content;
  final Function? yumAction;
  final Function? hungerswipeAction;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Function? yuckAction;
  Decision decision = Decision.undecided;
  int imageIndex = 0;

  RestaurantItem(
      {required this.content,
      this.yumAction,
      this.hungerswipeAction,
      this.yuckAction});

  void cycleImageBack() {
    imageIndex = imageIndex != 0 ? imageIndex -= 1 : imageIndex;
    notifyListeners();
  }

  void cycleImageForward() {
    imageIndex =
        imageIndex != content['photos'].length ? imageIndex += 1 : imageIndex;
    notifyListeners();
  }

  void yum() {
    if (decision == Decision.undecided) {
      decision = Decision.yum;
      try {
        var id = this.content['id'];
        _firestore
            .collection("swipes")
            .doc(_auth.currentUser!.phoneNumber)
            .collection("yum")
            .doc(id)
            .get()
            .then((doc) {
          if (doc.exists) {
            doc.reference.update({"yum": true});
          } else {
            doc.reference.set({"yum": true});
          }
        });
        yumAction!();
      } catch (e) {}
      notifyListeners();
    }
  }

  void yuck() {
    if (decision == Decision.undecided) {
      decision = Decision.yuck;
      try {
        var id = this.content['id'];
        _firestore
            .collection("swipes")
            .doc(_auth.currentUser!.phoneNumber)
            .collection("yuck")
            .doc(id)
            .get()
            .then((doc) {
          if (doc.exists) {
            doc.reference.update({"yuck": true});
          } else {
            doc.reference.set({"yuck": true});
          }
        });
        yuckAction!();
      } catch (e) {}
      notifyListeners();
    }
  }

  void hungerswipe() {
    if (decision == Decision.undecided) {
      decision = Decision.hungerswipe;
      try {
        var id = this.content['id'];
        _firestore
            .collection("swipes")
            .doc(_auth.currentUser!.phoneNumber)
            .collection("hungerswipe")
            .doc(id)
            .get()
            .then((doc) {
          if (doc.exists) {
            doc.reference.update({"hungerswipe": true});
          } else {
            doc.reference.set({"hungerswipe": true});
          }
        });
        hungerswipeAction!();
      } catch (e) {}
      notifyListeners();
    }
  }

  void resetMatch() {
    if (decision != Decision.undecided) {
      decision = Decision.undecided;
      imageIndex = 0;
      notifyListeners();
    }
  }
}

enum Decision { undecided, yuck, yum, hungerswipe }
