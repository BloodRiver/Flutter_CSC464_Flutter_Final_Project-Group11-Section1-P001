# AI Language Tutor

A simple language tutor app where users select a language and chat with an AI tutor powered by the Gemini API.
This is a simple project for the Course CSE464 (Mobile Application), **Section 1**

## Developed By
<table width="100%">
    <thead>
        <tr><th colspan="2" scope="row"><center>Group-11</center></th></tr>
        <tr><th scope="col">ID</th> <th scope="col">Name</th></tr>
    </thead>
    <tbody>
        <tr><td>2121104</td> <td>Sajeed Ahmed Galib Arnob</td></tr>
        <tr><td>2222213</td> <td>Nabanita Das Prapti </td></tr>
        <tr><td>2221668</td> <td>Md. Fuad Hasan</td></tr>
    </tbody>
</table>


## Functionalities

1. **Home Page**
    - Select Language
    - Navigate to chat screen
2. **Chat Interface**
    - Message List (User + AI)
    - Text Input + Send Button
    - Loading indicator while AI responds
3. **API Integration**
    - Send user message → Gemini API
    - Parse response
    - Update UI
4. **Session Memory**  
    - Store chat messages in Firestore  
---

### Firebase Structure (Firestore)

```
/chats
    /chatId
       language: string
       createdAt: timestamp

       /messages
           /messageId
               sender: "user" | "ai"
               message: string
               timestamp: timestamp

```