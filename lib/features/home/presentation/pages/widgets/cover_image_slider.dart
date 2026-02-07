import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../../core/theme/app_colors.dart';

class CoverImageSlider extends StatefulWidget {
  const CoverImageSlider({super.key});

  @override
  State<CoverImageSlider> createState() => _CoverImageSliderState();
}

class _CoverImageSliderState extends State<CoverImageSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  Timer? _autoSlideTimer;

  // Unsplash URLs for plant-related images
  // Using direct Unsplash image URLs (no API key needed)
  final List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=400&fit=crop&q=80', // Indoor plants
    'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=800&h=400&fit=crop&q=80', // Succulents
    'https://images.unsplash.com/photo-1463946027124-0d5c0c9c8b3b?w=800&h=400&fit=crop&q=80', // Garden plants
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&h=400&fit=crop&q=80', // Tropical plants
    'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=800&h=400&fit=crop&q=80', // House plants
    'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?w=800&h=400&fit=crop&q=80', // Plant care
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _carouselController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: _imageUrls.length,
            itemBuilder: (context, index, realIndex) {
              return _buildImageCard(_imageUrls[index]);
            },
            options: CarouselOptions(
              height: 200,
              viewportFraction: 1.0,
              autoPlay: false, // We handle auto-play manually
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _imageUrls.length,
              (index) => _buildIndicator(index == _currentIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with gradient overlay
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.secondary.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.secondary.withOpacity(0.1),
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.secondary,
                  size: 48,
                ),
              ),
            ),
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // Optional: Add text overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getImageTitle(_imageUrls.indexOf(imageUrl)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getImageSubtitle(_imageUrls.indexOf(imageUrl)),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                        ),
                      ],
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

  Widget _buildIndicator(bool isActive) {
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? AppColors.primary : AppColors.secondary.withOpacity(0.4),
      ),
    );
  }

  String _getImageTitle(int index) {
    final titles = [
      'Indoor Plants',
      'Succulents',
      'Garden Plants',
      'Tropical Plants',
      'House Plants',
      'Plant Care',
    ];
    return titles[index % titles.length];
  }

  String _getImageSubtitle(int index) {
    final subtitles = [
      'Bring nature indoors',
      'Low maintenance beauty',
      'Grow your garden',
      'Exotic greenery',
      'Perfect for home',
      'Expert tips & guides',
    ];
    return subtitles[index % subtitles.length];
  }
}

