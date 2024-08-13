import 'package:flutter/material.dart';
import 'package:gemini_chatbot/message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Chatroom extends StatefulWidget {
  const Chatroom({super.key});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  // Gemini 연결 전 테스트용
  // List<String> chatbotHistory = [
  //   'Hi there!',
  //   'How can I assist you today?',
  //   'Sure, I can help with that!',
  //   'Here is the information you requested.',
  //   'Hi there!',
  //   'How can I assist you today?',
  //   'Sure, I can help with that!',
  //   'Here is the information you requested.',
  //   'Hi there!',
  //   'How can I assist you today?',
  //   'Sure, I can help with that!',
  //   'Here is the information you requested.',
  // ];

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  // Gemini
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final String gemini_model = 'gemini-1.5-flash-latest';
  // API_KEY를 보호하기 위해 실행 시 직접 입력
  static const String _apiKey = String.fromEnvironment('API_KEY');

  Future<void> _sendMessage(String value) async {
    if (value.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      _textController.clear();
    });
    _scrollToBottom();

    final response = await _chatSession.sendMessage(Content.text(value));

    setState(() {
      isLoading = false;
    });
    _scrollToBottom();
    _focusNode.requestFocus();

    // Gemini 연결 전 테스트용
    // setState(() {
    //   isLoading = true;
    //   chatbotHistory.add(value);
    //   _textController.clear();
    // });
    // _scrollToBottom();

    // Future.delayed(const Duration(seconds: 1), () {
    //   setState(() {
    //     isLoading = false;
    //     chatbotHistory.add('I am a Gemini');
    //   });

    //   _scrollToBottom();

    //   // 채팅을 입력하고 input창에 자동으로 커서 이동
    //   _focusNode.requestFocus();
    // });
  }

  // 채팅이 스크롤 바깥으로 나갔을 때 자동으로 최신화
  void _scrollToBottom() {
    // widget이 렌더링 된 후에 작동 되게
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCirc);
    });
  }

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: gemini_model, apiKey: _apiKey);
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemBuilder: ((context, index) {
              final content = _chatSession.history.toList()[index];
              final text = content.parts
                  .whereType<TextPart>()
                  .map((part) => part.text)
                  .join();

              return MessageWidget(
                message: text,
                isUserMessage: content.role == 'user',
              );
            }),
            itemCount: _chatSession.history.length,
            controller: _scrollController,
          ),
        ),
        if (isLoading) const LinearProgressIndicator(),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onSubmitted: (value) {
                  if (!isLoading) {
                    _sendMessage(value);
                  }
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Type a message'),
              ),
            ),
            IconButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (!isLoading) {
                          _sendMessage(_textController.text);
                        }
                      },
                icon: const Icon(Icons.send)),
          ],
        )
      ],
    );
  }
}
