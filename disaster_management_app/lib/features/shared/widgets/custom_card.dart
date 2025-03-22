import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool useGradient;
  final List<Color>? gradientColors;
  final void Function()? onTap;
  final bool isLoading;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.useGradient = false,
    this.gradientColors,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        gradient: useGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ??
                    [
                      AppTheme.primaryDarkBlue,
                      AppTheme.primaryDarkBlue.withOpacity(0.8),
                    ],
              )
            : null,
        color:
            useGradient ? null : backgroundColor ?? Theme.of(context).cardColor,
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : child,
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation ?? 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                child: cardChild,
              )
            : cardChild,
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String location;
  final int temperature;
  final String description;
  final String iconUrl;
  final int humidity;
  final double windSpeed;
  final void Function()? onTap;

  const WeatherCard({
    super.key,
    required this.location,
    required this.temperature,
    required this.description,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      useGradient: true,
      gradientColors: [
        AppTheme.primaryDarkBlue,
        AppTheme.primaryDarkBlue.withOpacity(0.8),
      ],
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                location,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.network(
                iconUrl,
                width: 50,
                height: 50,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$temperature°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeatherDetail(
                icon: Icons.water_drop,
                value: '$humidity%',
                label: 'Humidity',
              ),
              _WeatherDetail(
                icon: Icons.air,
                value: '${windSpeed.toStringAsFixed(1)} m/s',
                label: 'Wind',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherDetail({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BlogCard extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final int likes;
  final String? imageUrl;
  final List<String> tags;
  final void Function()? onTap;
  final void Function()? onLike;
  final bool isLiked;

  const BlogCard({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.likes,
    this.imageUrl,
    required this.tags,
    this.onTap,
    this.onLike,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppTheme.lightBlue,
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'By $author',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                          onPressed: onLike,
                        ),
                        Text(
                          likes.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
