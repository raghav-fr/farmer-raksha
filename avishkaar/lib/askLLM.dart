import 'package:avishkaar/constants/locationhelper.dart';
import 'package:avishkaar/services/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String uid;

  const ChatPage({super.key, required this.uid});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _chatCtrl = TextEditingController();
  bool _sending = false;

  late final String sessionId;

  @override
  void initState() {
    super.initState();
    sessionId = "session_${widget.uid}";
  }

  Future<void> sendMessage() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);

    // 1️⃣ Save User Message
    FirebaseFirestore.instance
        .collection("chats")
        .doc(sessionId)
        .collection("messages")
        .add({
      "text": text,
      "sender": "user",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    try {
      final pos = await LocationHelper.getLocation();
      final lat = pos?.latitude;
      final lon = pos?.longitude;

      final response = await ApiService.callGemini(
        sessionId: sessionId,
        message: text,
        latitude: lat!,
        longitude: lon!,
        uid: widget.uid,
      );

      final botText =
          response["gemini_text"] ?? "I am not sure, could you rephrase that?";

      // 2️⃣ Save Bot Message
      FirebaseFirestore.instance
          .collection("chats")
          .doc(sessionId)
          .collection("messages")
          .add({
        "text": botText,
        "sender": "bot",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      FirebaseFirestore.instance
          .collection("chats")
          .doc(sessionId)
          .collection("messages")
          .add({
        "text": "⚠️ Error: $e",
        "sender": "bot",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
    }

    _chatCtrl.clear();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(sessionId)
        .collection("messages")
        .orderBy("timestamp", descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Agri AI Assistant")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                // 🔄 Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ❗ First-time chat → no messages
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.agriculture,
                              size: 90, color: Colors.green.shade700),
                          const SizedBox(height: 20),
                          Text(
                            "👋 Welcome Farmer!",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Ask me anything about crops, soil, fertilizers,\nor farming support to get started.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "Type a message below ↓",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 📨 Messages exist
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isBot = data["sender"] == "bot";

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      alignment: isBot
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        constraints:
                            const BoxConstraints(maxWidth: 260),
                        decoration: BoxDecoration(
                          color: isBot
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(data["text"] ?? ""),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 📝 Input Box
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatCtrl,
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _sending
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: sendMessage,
                        icon: const Icon(Icons.send, size: 28),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
