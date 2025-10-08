import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:provider/provider.dart';

import 'adaptive_image.dart';
import 'app_state.dart';

typedef PlaylistSelectedCallback = void Function(Playlist playlist);

class Playlists extends StatelessWidget {
  const Playlists({this.onPlaylistSelected, super.key});

  final PlaylistSelectedCallback? onPlaylistSelected;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthedUserPlaylists>(
      builder: (context, flutterDev, _) {
        final playlists = flutterDev.playlists;
        if (playlists.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _PlaylistsListView(
          items: playlists,
          onPlaylistSelected: onPlaylistSelected,
        );
      },
    );
  }
}

class _PlaylistsListView extends StatefulWidget {
  const _PlaylistsListView({required this.items, this.onPlaylistSelected});

  final List<Playlist> items;
  final PlaylistSelectedCallback? onPlaylistSelected;

  @override
  State<_PlaylistsListView> createState() => _PlaylistsListViewState();
}

class _PlaylistsListViewState extends State<_PlaylistsListView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        var playlist = widget.items[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: AdaptiveImage.network(
              playlist.snippet!.thumbnails!.default_!.url!,
            ),
            title: Text(playlist.snippet!.title!),
            subtitle: Text(playlist.snippet!.description!),
            onTap: () {
              widget.onPlaylistSelected?.call(playlist);
            },
          ),
        );
      },
    );
  }
}