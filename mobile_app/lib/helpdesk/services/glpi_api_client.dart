import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_app/helpdesk/models/helpdesk_models.dart';

class GlpiAuthResult {
  const GlpiAuthResult({
    required this.accessToken,
    required this.username,
    required this.role,
  });

  final String accessToken;
  final String username;
  final AppRole role;
}

class GlpiApiClient {
  GlpiApiClient({
    required String baseUrl,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl.replaceAll(RegExp(r'/$'), ''),
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<GlpiAuthResult> login({
    required String username,
    required String password,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final payload = _decodeMap(response.body);
    if (response.statusCode != 200) {
      throw Exception(_extractApiError(payload, fallback: 'Unable to authenticate.'));
    }

    final accessToken = (payload['accessToken'] ?? payload['access_token']) as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No access token returned by backend.');
    }

    return GlpiAuthResult(
      accessToken: accessToken,
      username: (payload['username'] as String?) ?? username,
      role: _toAppRole((payload['role'] as String?) ?? 'user'),
    );
  }

  Future<List<Ticket>> fetchTickets(String accessToken) async {
    final response = await _httpClient.get(
      _uri('/api/tickets'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    final decoded = _decodeDynamic(response.body);
    if (response.statusCode != 200) {
      final errorPayload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      throw Exception(_extractApiError(errorPayload, fallback: 'Failed to load tickets.'));
    }

    if (decoded is! List) {
      throw Exception('Unexpected response format from backend.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_mapTicket)
        .toList(growable: false);
  }

  Future<Ticket> createTicket({
    required String accessToken,
    required String title,
    required String description,
    required TicketPriority priority,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/tickets'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'priority': _priorityToApi(priority),
      }),
    );

    final payload = _decodeMap(response.body);
    if (response.statusCode != 201) {
      throw Exception(_extractApiError(payload, fallback: 'Failed to create ticket.'));
    }
    return _mapTicket(payload);
  }

  Future<Ticket> updateTicketStatus({
    required String accessToken,
    required String ticketId,
    required TicketStatus status,
  }) async {
    final response = await _httpClient.patch(
      _uri('/api/tickets/${Uri.encodeComponent(ticketId)}/status'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': _statusToApi(status)}),
    );

    final payload = _decodeMap(response.body);
    if (response.statusCode != 200) {
      throw Exception(_extractApiError(payload, fallback: 'Failed to update status.'));
    }
    return _mapTicket(payload);
  }

  Future<void> addComment({
    required String accessToken,
    required String ticketId,
    required String content,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/tickets/${Uri.encodeComponent(ticketId)}/comments'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    final payload = _decodeMap(response.body);
    if (response.statusCode != 201) {
      throw Exception(_extractApiError(payload, fallback: 'Failed to add comment.'));
    }
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = _decodeDynamic(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  dynamic _decodeDynamic(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    return jsonDecode(body);
  }

  String _extractApiError(Map<String, dynamic> payload, {required String fallback}) {
    final detail = payload['error_description'] ?? payload['detail'] ?? payload['title'] ?? payload['error'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    return fallback;
  }

  Ticket _mapTicket(Map<String, dynamic> item) {
    final dateRaw = (item['date'] ?? '').toString();
    return Ticket(
      id: (item['id'] ?? '#INC-?').toString(),
      title: (item['title'] ?? 'Untitled ticket').toString(),
      description: (item['description'] ?? '').toString(),
      status: _toStatus((item['status'] ?? 'open').toString()),
      priority: _toPriority((item['priority'] ?? 'medium').toString()),
      date: _humanDate(dateRaw),
      assignedUser: (item['assignedUser'] ?? 'Unassigned').toString(),
      comments: const [],
    );
  }

  TicketStatus _toStatus(String value) {
    return switch (value) {
      'closed' => TicketStatus.closed,
      'inProgress' => TicketStatus.inProgress,
      _ => TicketStatus.open,
    };
  }

  TicketPriority _toPriority(String value) {
    return switch (value) {
      'low' => TicketPriority.low,
      'high' => TicketPriority.high,
      'urgent' => TicketPriority.urgent,
      _ => TicketPriority.medium,
    };
  }

  AppRole _toAppRole(String value) {
    final role = value.toLowerCase();
    if (role.contains('admin')) return AppRole.admin;
    if (role.contains('techn') || role.contains('tech') || role.contains('itil') || role.contains('agent')) {
      return AppRole.technicien;
    }
    return AppRole.user;
  }

  String _statusToApi(TicketStatus status) {
    return switch (status) {
      TicketStatus.open => 'open',
      TicketStatus.inProgress => 'inProgress',
      TicketStatus.closed => 'closed',
    };
  }

  String _priorityToApi(TicketPriority priority) {
    return switch (priority) {
      TicketPriority.low => 'low',
      TicketPriority.medium => 'medium',
      TicketPriority.high => 'high',
      TicketPriority.urgent => 'urgent',
    };
  }

  String _humanDate(String iso) {
    if (iso.isEmpty) return 'Unknown date';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final now = DateTime.now();
    final diff = now.difference(parsed);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
