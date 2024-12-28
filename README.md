# Howl

**Howl** is an iOS application that allows users to interact with an AI assistant through a simple chat interface. The app uses a CoreML model to generate responses to user input. Here's how it works:

## Features

- **Chat Interface**: The app provides an input field where users can type their messages. Once a message is entered, the user can send it to the assistant by tapping the send button.
  
- **AI Responses**: The app uses a pre-trained CoreML model, which is downloaded from a remote URL. Once the model is loaded, the app generates responses to the user's input. The responses are displayed in a message list, showing both the user's messages and the assistant's replies.

- **Dynamic Messaging**: Each message is timestamped for better tracking of the conversation flow. Both user and system messages are displayed in the app's UI, with each type having its own formatting.

- **Real-Time Interaction**: The app processes the input text, uses the CoreML model to generate a response, and then updates the UI with the result.

- **Clear Messages**: Users can clear the message list with a single tap, removing all previous messages from the conversation.

## How It Works

1. **Model Download**: Upon launching the app, it downloads a pre-trained CoreML model from a remote server. The app tracks the download status and displays appropriate messages like "Downloading model..." or "Model Ready!" once the model is successfully downloaded and loaded.

2. **User Input**: The user types a message and taps the send button. The app processes the input and sends it to the CoreML model for generating a response.

3. **Model Processing**: The CoreML model takes the user input and generates a response. The response is then displayed as a system message in the chat.

4. **Message History**: All messages (both user and system) are stored and displayed in a message list, making it easy to see the entire conversation.

5. **Message Formatting**: Both the user and system messages are formatted with timestamps, making the conversation easy to follow.

---

This app is designed for a conversational experience with a smart assistant, leveraging CoreML and Vision to process input and provide AI-generated responses.
