import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatrrr/pages/chat_page.dart';
import 'package:chatrrr/widgets/widget.dart';

class GroupTile extends StatelessWidget {
  final String userName;
  final String groupID;
  final String groupName;

  const GroupTile({
    Key? key,
    required this.groupID,
    required this.groupName,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
          context,
          ChatPage(
            groupID: groupID,
            groupName: groupName,
            userName: userName,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 22,
              ),
            ),
          ),
          title: Text(
            groupName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          subtitle: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("groups")
                .doc(groupID)
                .collection("messages")
                .orderBy("time", descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // No messages yet
                return Text(
                  "Join the conversation as $userName",
                  style: const TextStyle(fontSize: 14),
                );
              }

              // Get the latest message data
              var latestMessage = snapshot.data!.docs.first;
              String message = latestMessage['message'];
              String sender = latestMessage['sender'];

              // Check if the user sent the latest message
              if (sender == userName) {
                return Text(
                  message, // Only show the message
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                );
              } else {
                return Text(
                  "$sender: $message", // Show sender and message
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
