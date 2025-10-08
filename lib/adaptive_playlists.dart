import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';

import 'app_state.dart';
import 'playlist_details.dart';
import 'playlists.dart';

class AdaptivePlaylists extends StatelessWidget {
  const AdaptivePlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      return const NarrowDisplayPlaylists();
    } else {
      return const WideDisplayPlaylists();
    }
  }
}

class NarrowDisplayPlaylists extends StatelessWidget {
  const NarrowDisplayPlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Playlists'),
      ),
      body: Playlists(
        onPlaylistSelected: (playlist) {
          context.go(
            '/playlist/${playlist.id}',
            extra: {'title': playlist.snippet!.title!},
          );
        },
      ),
    );
  }
}

class WideDisplayPlaylists extends StatefulWidget {
  const WideDisplayPlaylists({super.key});

  @override
  State<WideDisplayPlaylists> createState() => _WideDisplayPlaylistsState();
}

class _WideDisplayPlaylistsState extends State<WideDisplayPlaylists> {
  Playlist? selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Playlists'),
      ),
      body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        onWeightChanged: (w) {
          // Note: The SplitView package requires this callback.
        },
        children: [
          // By nesting a new provider, the Playlists widget can be updated
          // with a new callback without affecting other parts of the widget tree.
          ChangeNotifierProvider<AuthedUserPlaylists>.value(
            value: context.read<AuthedUserPlaylists>(),
            builder: (context, child) {
              return Playlists(
                onPlaylistSelected: (playlist) {
                  setState(() {
                    selectedPlaylist = playlist;
                  });
                },
              );
            },
          ),
          if (selectedPlaylist != null)
            PlaylistDetails(
              playlistId: selectedPlaylist!.id!,
              playlistName: selectedPlaylist!.snippet!.title!,
              // No appbar in wide display
              showAppBar: false,
            )
          else
            const Center(
              child: Text('Select a playlist'),
            ),
        ],
      ),
    );
  }
}