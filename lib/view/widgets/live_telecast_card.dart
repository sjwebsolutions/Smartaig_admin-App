import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:smart_aig_admins_app/models/active_event_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class LiveTelecastCard extends StatefulWidget {
  final ActiveEventModel event;

  const LiveTelecastCard({super.key, required this.event});

  @override
  State<LiveTelecastCard> createState() => _LiveTelecastCardState();
}

class _LiveTelecastCardState extends State<LiveTelecastCard> {
  YoutubePlayerController? _controller;
  String? _videoId;
  bool _hasPlayerError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final String? videoId = _extractVideoId();
    if (videoId != null && videoId.isNotEmpty) {
      _videoId = videoId;
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
          controlsVisibleAtStart: true,
        ),
      )..addListener(() {
          if (_controller != null &&
              _controller!.value.hasError &&
              !_hasPlayerError) {
            if (mounted) {
              setState(() {
                _hasPlayerError = true;
              });
            }
          }
        });
    }
  }

  String? _extractVideoId() {
    final telecast = widget.event.liveTelecast;
    final candidates = [
      telecast?.youtubeVideoId,
      telecast?.youtubeUrl,
      telecast?.embedUrl,
    ];

    for (final raw in candidates) {
      if (raw == null || raw.trim().isEmpty) continue;
      final val = raw.trim();

      // If already an 11-char ID
      if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(val)) {
        return val;
      }

      // Try convertUrlToId
      final converted = YoutubePlayer.convertUrlToId(val);
      if (converted != null && converted.isNotEmpty) {
        return converted;
      }

      // Regex for /live/VIDEO_ID, /embed/VIDEO_ID, v=VIDEO_ID
      final regExp = RegExp(
        r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=|live\/))([\w-]{11})',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(val);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _openYoutube() async {
    final telecast = widget.event.liveTelecast;
    final String? urlStr = telecast?.youtubeUrl ??
        telecast?.embedUrl ??
        (_videoId != null ? 'https://www.youtube.com/watch?v=$_videoId' : null);
    if (urlStr != null) {
      final Uri uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLive = widget.event.liveTelecast?.isLive ?? false;

    // If isLive is false or videoId is null or empty, do not show card or player
    if (!isLive || _videoId == null || _videoId!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_controller == null || _hasPlayerError) {
      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: AppColors.cardBorderRadius,
            border: Border.all(color: Colors.white, width: 1.8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFF0F172A),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _openYoutube,
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text("Watch Video on YouTube"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 10,
          shadowColor: const Color(0xFF90A4AE).withValues(alpha: 0.20),
          textStyle: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFFEF4444),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFFEF4444),
            handleColor: Color(0xFFEF4444),
          ),
        ),
        builder: (context, player) {
          return Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: AppColors.cardBorderRadius,
                border: Border.all(color: Colors.white, width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF90A4AE).withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row: Small Red Card for "Live Telecast"
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.20),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLive ? Icons.sensors_rounded : Icons.play_circle_fill_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "Live Telecast",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                  ),

                  // Video Player
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: player,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
