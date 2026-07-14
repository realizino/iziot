import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Data/Strings/Strings.dart';
import '../../Models/Chat/ChatList_Model.dart';
import '../../Models/Chat/Chat_Model.dart';
import '../../Server/Server.dart';

class api_chat {

  // ───────────────────────────────────────────────
  // Get / Create Chat Room
  // ───────────────────────────────────────────────
  Future<bool> GetChatRoomId(
      BuildContext context,
      String username,
      ) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "GetNewChatRoom",
        {
          "username": username,
        },
        true,
        false,
      );

      if (result["status"] != 200) {
        return false;
      }

      final data = jsonDecode(result["data"]);

      if (data["status"].toString() != "200") {
        return false;
      }

      Strings.Chat_Id = data["chat_id"].toString();

      return true;
    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Chat List
  // ───────────────────────────────────────────────
  Future<List<ChatList_Model>> GetChatList(
      BuildContext context,
      ) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "GetChatList",
        {},
        true,
        false,
      );

      if (result["status"] != 200) {
        return [];
      }

      final decoded = jsonDecode(result["data"]);

      final List<dynamic> data = decoded["data"] ?? [];

      return data
          .map((e) => ChatList_Model.fromJson(e))
          .toList();

    } catch (_) {
      return [];
    }
  }

  // ───────────────────────────────────────────────
  // Delete Chat
  // ───────────────────────────────────────────────
  Future<bool> DeleteChat(
      BuildContext context,
      int chatId,
      ) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "DeleteChat",
        {
          "chat_id": chatId.toString(),
        },
        true,
        false,
      );

      if (result["status"] != 200) {
        return false;
      }

      final decoded = jsonDecode(result["data"]);

      return decoded["status"].toString() == "200";

    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Messages
  // ───────────────────────────────────────────────
  Future<List<Chat_Model>> GetChats(
      BuildContext context,
      ) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "GetChats",
        {
          "chat_id": Strings.Chat_Id,
        },
        true,
        false,
      );

      if (result["status"] != 200) {
        return [];
      }

      final decoded = jsonDecode(result["data"]);

      final List<dynamic> data = decoded["data"] ?? [];

      print(data.toString());

      return data
          .map((e) => Chat_Model.from_json(e))
          .toList();

    } catch (_) {
      return [];
    }
  }

  // ───────────────────────────────────────────────
  // Send Text Message
  // ───────────────────────────────────────────────
  Future<bool> AddNewChat(
      BuildContext context,
      String content, {
        int? replyToId,
      }) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "NewChat",
        {
          "chat_id": Strings.Chat_Id,
          "message_type": "text",
          "content": content,
          if (replyToId != null)
            "reply_to_id": replyToId.toString(),
        },
        true,
        false,
      );

      if (result["status"] != 200) {
        return false;
      }

      final decoded = jsonDecode(result["data"]);

      return decoded["status"].toString() == "200";

    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Send Image Message
  // ───────────────────────────────────────────────
  Future<bool> AddNewChatImage(
      BuildContext context,
      String fileHash, {
        int? replyToId,
      }) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "NewChat",
        {
          "chat_id": Strings.Chat_Id,
          "message_type": "image",
          "file_hash": fileHash,
          if (replyToId != null)
            "reply_to_id": replyToId.toString(),
        },
        true,
        false,
      );

      if (result["status"] != 200) {
        return false;
      }

      final decoded = jsonDecode(result["data"]);

      return decoded["status"].toString() == "200";

    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Upload Image
  // ───────────────────────────────────────────────
  Future<String?> UploadImage(
      BuildContext context,
      String imagePath,
      ) async {

    try {

      final uri = Uri.parse(
        "${Server.Api_Address}UploadImage",
      );

      final request = http.MultipartRequest(
        "POST",
        uri,
      );

      request.headers["Authorization"] =
      "Bearer ${Strings.Token}";

      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          imagePath,
        ),
      );

      final response = await request.send();

      final body =
      await response.stream.bytesToString();

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(body);

      if (decoded["status"].toString() != "200") {
        return null;
      }

      return decoded["file_hash"];

    } catch (_) {
      return null;
    }
  }

  // ───────────────────────────────────────────────
  // Edit Message
  // ───────────────────────────────────────────────
  Future<bool> EditMessage(
      BuildContext context,
      int messageId,
      String newContent,
      ) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "EditMessage",
        {
          "message_id": messageId.toString(),
          "new_content": newContent,
        },
        true,
        false,
      );

      if (result["status"] != 200) {
        return false;
      }

      final decoded = jsonDecode(result["data"]);

      return decoded["status"].toString() == "200";

    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Delete Message
  // ───────────────────────────────────────────────
  Future<bool> DeleteMessage(
      BuildContext context,
      int messageId,
      ) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "DeleteMessage",
        {
          "message_id": messageId.toString(),
        },
        true,
        false,
      );

      if (result["status"] != 200) {
        return false;
      }

      final decoded = jsonDecode(result["data"]);

      return decoded["status"].toString() == "200";

    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // Mark Seen
  // Requires Route
  // ───────────────────────────────────────────────
  Future<bool> MarkSeen(
      BuildContext context,
      ) async {

    try {
      final result = await Server().Fetch_Post(
        context,
        "MarkSeen",
        {
          "chat_id": Strings.Chat_Id,
        },
        true,
        false,
      );

      if (result["status"] != 200) {
        return false;
      }

      final decoded = jsonDecode(result["data"]);

      return decoded["status"].toString() == "200";

    } catch (_) {
      return false;
    }
  }
}