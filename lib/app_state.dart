import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:http/http.dart' as http;

class AuthedUserPlaylists extends ChangeNotifier {
  set authClient(http.Client client) {
    _api = YouTubeApi(client);
    _loadPlaylists();
  }

  bool get isLoggedIn => _api != null;

  Future<void> _loadPlaylists() async {
    String? nextPageToken;
    _playlists.clear();

    try {
      print('🔍 Cargando playlists de YouTube...');
      
      do {
        final response = await _api!.playlists.list(
          ['snippet', 'contentDetails', 'id'],
          mine: true,
          maxResults: 50,
          pageToken: nextPageToken,
        );
        
        print('📊 Respuesta de API: ${response.items?.length ?? 0} playlists encontradas');
        
        if (response.items != null) {
          _playlists.addAll(response.items!);
          _playlists.sort((a, b) =>
              a.snippet!.title!.toLowerCase().compareTo(b.snippet!.title!.toLowerCase()));
        }
        
        notifyListeners();
        nextPageToken = response.nextPageToken;
      } while (nextPageToken != null);
      
      print('✅ Playlists cargadas exitosamente: ${_playlists.length} total');
      
    } catch (e) {
      print('❌ Error cargando playlists: $e');
      rethrow;
    }
  }

  YouTubeApi? _api;

  final List<Playlist> _playlists = [];
  List<Playlist> get playlists => UnmodifiableListView(_playlists);

  final Map<String, List<PlaylistItem>> _playlistItems = {};
  List<PlaylistItem> playlistItems({required String playlistId}) {
    if (!_playlistItems.containsKey(playlistId)) {
      _playlistItems[playlistId] = [];
      _retrievePlaylist(playlistId);
    }
    return UnmodifiableListView(_playlistItems[playlistId]!);
  }

  Future<void> _retrievePlaylist(String playlistId) async {
    String? nextPageToken;
    do {
      var response = await _api!.playlistItems.list(
        ['snippet', 'contentDetails'],
        playlistId: playlistId,
        maxResults: 25,
        pageToken: nextPageToken,
      );
      var items = response.items;
      if (items != null) {
        _playlistItems[playlistId]!.addAll(items);
      }
      notifyListeners();
      nextPageToken = response.nextPageToken;
    } while (nextPageToken != null);
  }
}