import 'package:chatrrr/service/database_Service.dart';
import 'package:chatrrr/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatrrr/pages/group_info.dart';
import 'package:chatrrr/widgets/message_tile.dart';


class ChatPage extends StatefulWidget {
  final String userName;
  final String groupID;
  final String groupName;

  const ChatPage(
      {Key? key,
      required this.groupID,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController(); // Add this
  String admin = "";

  @override
  void initState() {
    super.initState();
    getChatandAdmin();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupID).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupID).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                  context,
                  GroupInfo(
                    groupID: widget.groupID,
                    groupName: widget.groupName,
                    adminName: admin,
                  ),
                );
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(); // Scroll to bottom whenever the UI rebuilds
        });

        return snapshot.hasData
            ? ListView.builder(
          controller: scrollController, // Attach the scroll controller
          padding: const EdgeInsets.only(
            bottom: 80, // Add padding to prevent overlap with the input bar
          ),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
              message: snapshot.data.docs[index]['message'],
              sender: snapshot.data.docs[index]['sender'],
              sentByMe: widget.userName ==
                  snapshot.data.docs[index]['sender'],
            );
          },
        )
            : Container();
      },
    );
  }


  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupID, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}