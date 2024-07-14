import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Ui/screens/chat/chatAudio/widgets/chat_widget.dart';
import '../Extensions/extensions.dart';
import '../ui_utils.dart';
import 'package:flutter/material.dart';

int sentMessages = 0;

class ChatMessageHandler {
  static List<Widget> messages = [];
  static final List<Widget> _chat = [];
  static final StreamController<List<Widget>> _chatMessageStream =
      StreamController<List<Widget>>.broadcast();

/*  static void add(Widget chat) {

    List<Widget> msgs = (messages);

    _chat.insert(0, chat);


    ///don't change this line
    msgs = [..._chat, ...msgs];

    _chatMessageStream.sink.add(msgs);
  } */

  static void add(Widget chat) {
    _chat.insert(0, chat);

    /*  ///don't change this line
    List<Widget> msgs = (messages);*/
    messages = [..._chat, ...messages];

    print("Adding messages to stream: ${messages.length}");
    _chatMessageStream.sink.add(messages);
    print("Messages added to stream");
    print("Current _chat length: ${_chat.length}*****${messages.length}");
  }

  /* static void add(Widget chat) {
    print("Adding chat message: $chat");
    _chat.insert(0, chat);
    print("Current _chat length: ${_chat.length}");
    _chatMessageStream.sink.add([..._chat, ...messages]);
   // _chatMessageStream.sink.add([chat]);
    print("Current _chat length: ${_chatMessageStream.stream.length}");
    print("Messages added to stream");
  }*/

  static void loadMessages(List<Widget> chats, BuildContext context) {
    List<Widget> messagesWithDate = [];
    String previousDate = "";
    // Get the current date and time
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    for (int i = chats.length - 1; i >= 0; i--) {
      DateTime date =
          DateTime.parse((chats[i] as ChatMessage).createdAt).toLocal();
      String formattedDate;

      if (date.isAfter(today)) {
        formattedDate = "today".translate(context);
      } else if (date.isAfter(yesterday)) {
        formattedDate = "yesterday".translate(context);
      } else {
        formattedDate = (date.toString()).formatDate();
      }

      // Add date widget if date has changed
      if (formattedDate != previousDate) {
        messagesWithDate.insert(0, messageDateChip(context, formattedDate));
        previousDate = formattedDate;
      }

      // Add message widget
      messagesWithDate.insert(0, chats[i]);
    }

    // Update the messages list and sink the new messages to the stream
    messages = messagesWithDate;
    // messages = chats; //uncomment and comment above code if problem in chat
    _chatMessageStream.sink.add(messages);
    //getChatStream();
  }

  static Widget messageDateChip(BuildContext context, String formattedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
          child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: context.color.territoryColor.withOpacity(0.3)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(formattedDate),
        ),
      )),
    );
  }

  static void flushMessages() {
    messages.clear();
    _chat.clear();
  }

  static Stream<List<Widget>> getChatStream() {
    return _chatMessageStream.stream;
  }

  static attachListener(void Function(dynamic)? onData) {
    _chatMessageStream.stream.listen(onData);
  }

  static removeMessage(int id) {
    List<Widget> msgs = (messages);
    msgs.removeWhere((element) {
      if (element is! Padding) {
        return ((element as ChatMessage).key as ValueKey).value == id;
      }
      return false;
    });

    _chatMessageStream.sink.add(msgs);
  }

  ///This will replace message's key with server key so we will be able to delete message if we want
  static updateMessageId(String identifier, int id) {
    try {
      List<Widget> msgs = _chat;
      for (var i = 0; i < _chat.length; i++) {
        //We will only need to change its key when it is bloc provider because we added it locally and its key was also locally so we have to replace it with server key when message send complete
        if (msgs[i] is BlocProvider) {
          ///Extracting chate message from bloc provider
          Widget? bloc = (msgs[i] as BlocProvider).child;
          ChatMessage chat = (bloc as ChatMessage);

          ///Extracting its key [which we were added locally]
          String chatKey = (chat.key as ValueKey).value;

          ///This identifier will come from ChatMessage's key when message send success.
          ///this identifier must be same as chatKey because we want exact element to change
          if (identifier == chatKey) {
            ///Converting chat class to map and replace its key and again convert it to ChatMessage class
            var map = chat.toJson();
            map['key'] = ValueKey(id);

            try {
              ChatMessage chatMessage = ChatMessage.fromJson(map);

              ///Replace it with old one
              _chat[i] = chatMessage;
            } catch (e) {}

            ///This will add chats in first and old messages in last...
            msgs = [..._chat, ...messages];
            _chatMessageStream.sink.add(msgs);
          }
        }
      }
    } catch (e) {}
  }
}

/*import 'package:eClassify/utils/Extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/cupertino.dart';
import '../../Ui/screens/chat/chatAudio/widgets/chat_widget.dart';

import 'package:flutter/material.dart';

import '../../exports/main_export.dart';

class ChatMessageHandlerCubit extends Cubit<List<Widget>> {
  ChatMessageHandlerCubit() : super([]);

  void addMessage(Widget message) {
    emit([message, ...state]);
  }

  void loadMessages(List<Widget> chats, BuildContext context) {
    List<Widget> messagesWithDate = [];
    String previousDate = "";
    // Get the current date and time
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    for (int i = chats.length - 1; i >= 0; i--) {
      DateTime date =
          DateTime.parse((chats[i] as ChatMessage).createdAt).toLocal();
      String formattedDate;

      if (date.isAfter(today)) {
        formattedDate = "today".translate(context);
      } else if (date.isAfter(yesterday)) {
        formattedDate = "yesterday".translate(context);
      } else {
        formattedDate = (date.toString()).formatDate();
      }

      // Add date widget if date has changed
      if (formattedDate != previousDate) {
        messagesWithDate.insert(0, messageDateChip(context, formattedDate));
        previousDate = formattedDate;
      }

      // Add message widget
      messagesWithDate.insert(0, chats[i]);
    }

    //value = messagesWithDate;
    print("messagewithsdate***${messagesWithDate.length}");
    emit(messagesWithDate.reversed.toList());
  }

  static Widget messageDateChip(BuildContext context, String formattedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
          child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: context.color.territoryColor.withOpacity(0.3)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(formattedDate),
        ),
      )),
    );
  }

  void flushMessages() {
    emit([]);
  }

  void removeMessage(int id) {
    emit(state.where((message) {
      if (message is! Padding) {
        return ((message as ChatMessage).key as ValueKey).value != id;
      }
      return true;
    }).toList());
  }
}*/

/*class ChatMessageHandler extends ValueNotifier<List<Widget>> {
  static final List<Widget> _chat = [];

  ChatMessageHandler() : super([]);

*/ /*  void add(Widget chat) {
    List<Widget> msgs = (value);

    _chat.insert(0, chat);

    ///don't change this line
    msgs = [..._chat, ...msgs];
    value.addAll(msgs);
    notifyListeners();
  }*/ /*

  void add(Widget chat) {
    value.insert(0, chat);
    notifyListeners();
  }

  void loadMessages(List<Widget> chats, BuildContext context) {
    List<Widget> messagesWithDate = [];
    String previousDate = "";
    // Get the current date and time
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    for (int i = chats.length - 1; i >= 0; i--) {
      DateTime date =
          DateTime.parse((chats[i] as ChatMessage).createdAt).toLocal();
      String formattedDate;

      if (date.isAfter(today)) {
        formattedDate = "today".translate(context);
      } else if (date.isAfter(yesterday)) {
        formattedDate = "yesterday".translate(context);
      } else {
        formattedDate = (date.toString()).formatDate();
      }

      // Add date widget if date has changed
      if (formattedDate != previousDate) {
        messagesWithDate.insert(0, messageDateChip(context, formattedDate));
        previousDate = formattedDate;
      }

      // Add message widget
      messagesWithDate.insert(0, chats[i]);
    }

    //value = messagesWithDate;
    print("messagewithsdate***${messagesWithDate.length}");
    value = messagesWithDate;
    print("value len****${value.length}");
    notifyListeners();
  }

  static Widget messageDateChip(BuildContext context, String formattedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
          child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: context.color.territoryColor.withOpacity(0.3)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(formattedDate),
        ),
      )),
    );
  }

  void flushMessages() {
    value.clear();
    _chat.clear();
    notifyListeners();
  }

  void removeMessage(int id) {
    value.removeWhere((element) {
      if (element is! Padding) {
        return ((element as ChatMessage).key as ValueKey).value == id;
      }
      return false;
    });
    notifyListeners();
  }
}*/
