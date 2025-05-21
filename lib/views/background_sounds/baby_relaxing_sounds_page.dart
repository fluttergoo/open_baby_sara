import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/constant/sounds_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class BabyRelaxingSoundsPage extends StatefulWidget {
  const BabyRelaxingSoundsPage({super.key});

  @override
  State<BabyRelaxingSoundsPage> createState() => _BabyRelaxingSoundsPageState();
}

class _BabyRelaxingSoundsPageState extends State<BabyRelaxingSoundsPage> {
  final AudioPlayer _player = AudioPlayer();
  int? _currentPlayingIndex;
  double _volume = 1.0;
  Timer? _timer;


  Future<void> _toggleSound(int index) async {
    try {
      if (_currentPlayingIndex == index) {
        await _player.stop();
        _timer?.cancel();
        setState(() {
          sounds[index].isPlaying = false;
          _currentPlayingIndex = null;
        });
      } else {
        await _player.stop();
        await _player.play(AssetSource(sounds[index].assetPath.replaceFirst('assets/', '')));
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.setVolume(_volume);
        _timer?.cancel();
        _timer = Timer(Duration(minutes: 15), () async {
          await _player.stop();
          setState(() {
            sounds[index].isPlaying = false;
            _currentPlayingIndex = null;
          });
        });
        setState(() {
          if (_currentPlayingIndex != null) {
            sounds[_currentPlayingIndex!].isPlaying = false;
          }
          sounds[index].isPlaying = true;
          _currentPlayingIndex = index;
        });
      }
    } catch (e) {
      print('🔴 Hata: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Baby Relaxing Sounds",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.builder(
                  itemCount: sounds.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final sound = sounds[index];
                    final isActive = sound.isPlaying;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isActive
                            ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ]
                            : [],
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Image.asset(sound.iconAssetPath, width: 40.w, height: 40.h),
                              title: Text(
                                sound.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  sound.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                  color: Theme.of(context).primaryColor,
                                  size: 32.sp,
                                ),
                                onPressed: () => _toggleSound(index),
                              ),
                            ),
                            if (isActive) ...[
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Theme.of(context).primaryColor),
                                    onPressed: () {
                                      setState(() {
                                        _volume = (_volume - 0.1).clamp(0.0, 1.0);
                                        _player.setVolume(_volume);
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _volume,
                                      onChanged: (value) {
                                        setState(() => _volume = value);
                                        _player.setVolume(_volume);
                                      },
                                      min: 0.0,
                                      max: 1.0,
                                      activeColor: Theme.of(context).primaryColor,
                                      inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                                    onPressed: () {
                                      setState(() {
                                        _volume = (_volume + 0.1).clamp(0.0, 1.0);
                                        _player.setVolume(_volume);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
