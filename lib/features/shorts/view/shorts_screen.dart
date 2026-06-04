import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();

  // List of YouTube Shorts video IDs
  final List<String> _videoIds = [
    'KLp4Cm-gQQU',
    'uvXcN-2nsbQ',
    'R96f730WEm8',
    'PM3jHnFQaqY',
    '44vmqwVeKzs',
    'jrxSF8b19R0',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: _videoIds.length,
          itemBuilder: (context, index) {
            return ShortVideoPlayer(videoId: _videoIds[index]);
          },
        ),
      ),
    );
  }
}

class ShortVideoPlayer extends StatefulWidget {
  final String videoId;

  const ShortVideoPlayer({super.key, required this.videoId});

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: true,
        hideControls: true, // Hide controls for a reel-like experience
        disableDragSeek: true,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    )..addListener(listener);
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Pauses video while swiping
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_isPlayerReady) {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: false,
              onReady: () {
                _isPlayerReady = true;
                setState(() {});
              },
              topActions: const [],
              bottomActions: const [],
            ),
          ),
          if (_isPlayerReady && !_controller.value.isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),

          // Transparent overlay to reliably intercept taps over PlatformView
          Positioned.fill(child: Container(color: Colors.transparent)),
        ],
      ),
    );
  }
}
