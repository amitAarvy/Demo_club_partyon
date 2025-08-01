import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

import '../signup_organiser/signup_organiser_view.dart';

class OnBoardingPromoter extends StatefulWidget {
  final String email;
  final bool isPhone;
  final String phone;

  const OnBoardingPromoter({super.key, required this.email, required this.isPhone, required this.phone});

  @override
  State<OnBoardingPromoter> createState() => _OnBoardingPromoterState();
}

class _OnBoardingPromoterState extends State<OnBoardingPromoter> {
  List<String> videoPaths = [
    'assets/video/1.mp4',
    'assets/video/2.mp4',
    'assets/video/4.mp4',
    'assets/video/5.mp4',
    'assets/video/6.mp4',
  ];

  ValueNotifier<int> currentIndex = ValueNotifier(0);
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeAndPlay(videoPaths[currentIndex.value]);
  }

  void _initializeAndPlay(String videoPath) async {
    _controller = VideoPlayerController.asset(videoPath);

    await _controller.initialize();
    setState(() {});
    _controller.play();

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration &&
          !_controller.value.isPlaying) {
        _playNextVideo();
      }
    });
  }

  void _playNextVideo() {
    if (currentIndex.value < videoPaths.length - 1) {
      currentIndex.value++;
      _controller.dispose();
      _initializeAndPlay(videoPaths[currentIndex.value]);
    } else {
      Get.off(SignUpOrganiser(
        email: widget.email,
        isPhone: widget.isPhone,
        phone: widget.phone,
      ));
      print("All videos completed.");
    }
  }

  void _playPreviousVideo() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      _controller.dispose();
      _initializeAndPlay(videoPaths[currentIndex.value]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _controller.value.isInitialized
                ? GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  // Swipe Left → Previous Video
                  _playNextVideo();
                } else if (details.primaryVelocity! > 0) {
                  // Swipe Right → Next Video

                  _playPreviousVideo();
                }
              },
              child: SizedBox(
                height: 1.sh,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
                : const CircularProgressIndicator(color: Colors.orangeAccent),

            Positioned(
              bottom: 10,
              child: ValueListenableBuilder(
                valueListenable: currentIndex,
                builder: (context, int value, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedSmoothIndicator(
                      activeIndex: value,
                      count: videoPaths.length,
                      effect: JumpingDotEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          activeDotColor: Colors.orangeAccent,
                          dotColor: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
