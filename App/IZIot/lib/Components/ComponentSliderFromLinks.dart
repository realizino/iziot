import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../Data/Colors/App_Colors.dart';
import '../Data/Strings/Strings.dart';
import '../api/api.dart';

class ComponentSliderFromLinks extends StatefulWidget {
  final String rawData;
  final double height;
  final Duration autoPlayInterval;
  final bool showIndicator;
  final bool autoPlay;

  const ComponentSliderFromLinks({
    Key? key,
    required this.rawData,
    this.height = 200,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showIndicator = true,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<ComponentSliderFromLinks> createState() => _ComponentSliderFromLinksState();
}

class _ComponentSliderFromLinksState extends State<ComponentSliderFromLinks> {
  late List<SlideItem> _slides;
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _parseRawData();
    _pageController = PageController(initialPage: 0);
    if (widget.autoPlay && _slides.length > 1) {
      _startAutoPlay();
    }
  }

  void _parseRawData() {
    _slides = [];
    if (widget.rawData.trim().isEmpty) return;

    List<String> slidesRaw = widget.rawData.split('~');
    for (String slide in slidesRaw) {
      if (slide.trim().isEmpty) continue;

      List<String> parts = slide.split('×');
      if (parts.length == 2) {
        String imageUrl = parts[0].trim();
        String linkUrl = parts[1].trim();
        _slides.add(SlideItem(imageUrl: imageUrl, linkUrl: linkUrl));
      }
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_pageController.hasClients && _slides.isNotEmpty) {
        int nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _openLink(String url) async {
    url = url + "?token="+Strings.UserData.loginToken;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {

    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) {
      return Container(
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(child: Text('-')),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIndicator) _buildIndicator(),
        SizedBox(
          height: widget.height,
          child: GestureDetector(
            onTapDown: (_) => _stopAutoPlay(),
            onTapUp: (_) {
              if (widget.autoPlay && _slides.length > 1) _startAutoPlay();
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return _buildSlide(_slides[index]);
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSlide(SlideItem slide) {
    return GestureDetector(
      onTap: () => _openLink(slide.linkUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          slide.imageUrl,
          width: double.infinity,
          height: widget.height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: App_Colors.Theme_Color,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_slides.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

class SlideItem {
  final String imageUrl;
  final String linkUrl;

  SlideItem({required this.imageUrl, required this.linkUrl});
}