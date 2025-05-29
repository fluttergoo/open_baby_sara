import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/sound_relaxing/sound_relaxing_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/constant/sounds_constants.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/locator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class BabyRelaxingSoundsPage extends StatefulWidget {
  const BabyRelaxingSoundsPage({super.key});

  @override
  State<BabyRelaxingSoundsPage> createState() => _BabyRelaxingSoundsPageState();
}

class _BabyRelaxingSoundsPageState extends State<BabyRelaxingSoundsPage> {
  final AudioPlayer _player = getIt<AudioPlayer>();
  int? _currentPlayingIndex;
  double _volume = 0.5;


  Future<void> _toggleSound(int index) async {
    try {
      if (_currentPlayingIndex == index) {
        await _player.stop();
        setState(() {
          sounds[index].isPlaying = 0;
          _currentPlayingIndex = null;
        });
      } else {
        await _player.stop();
        await _player.play(AssetSource(sounds[index].assetPath.replaceFirst('assets/', '')));
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.setVolume(_volume);

        setState(() {
          if (_currentPlayingIndex != null) {
            sounds[_currentPlayingIndex!].isPlaying = 0;
          }
          sounds[index].isPlaying = 1;
          _currentPlayingIndex = index;
        });
      }
    } catch (e) {
      print('🔴 Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<SoundRelaxingBloc>().add(LoadSound());
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SoundRelaxingBloc, SoundRelaxingState>(
        listener: (context, state) {
          if (state is FetchSoundRelaxing) {
            if (_currentPlayingIndex != state.runningIndexSound) {
              _toggleSound(state.runningIndexSound);
            }
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: _buildContent(context),
          ),
        ),
      ),
    );

  }
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Baby Relaxing Sounds",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
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
              return _buildSoundTile(index, isActive);
            },
          ),
        ],
      ),
    );
  }
  Widget _buildSoundTile(int index, int isActive) {
    final sound = sounds[index];
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isActive ==1 ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive==1
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
                  isActive==1 ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Theme.of(context).primaryColor,
                  size: 32.sp,
                ),
                onPressed: () => _toggleSound(index),
              ),
            ),
            if (isActive==1) _buildVolumeSlider(),
          ],
        ),
      ),
    );
  }
  Widget _buildVolumeSlider() {
    return Row(
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
    );
  }

}
