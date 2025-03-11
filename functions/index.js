/* eslint-disable max-len */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

exports.sendMessageNotification = onDocumentCreated(
    "chats/{chatId}/messages/{messageId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;

      // Extract message details
      const messageData = snap.data();
      const chatId = event.params.chatId;
      const senderId = messageData.sender_id;
      const messageText = messageData.message;

      console.log(`New message in chat ${chatId} from user ${senderId}: ${messageText}`);

      // Fetch chat participants (2 users only)
      const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
      if (!chatDoc.exists) {
        console.warn(`Chat document ${chatId} not found.`);
        return;
      }

      const participants = chatDoc.data().participants;
      if (!participants || participants.length !== 2) {
        console.warn(`Invalid chat participants for chat ${chatId}`);
        return;
      }

      // Identify the recipient (the other user)
      const recipientId = participants.find((id) => id !== senderId);
      if (!recipientId) return;

      // Fetch recipient's FCM token
      const userDoc = await admin.firestore().collection("users").doc(recipientId).get();
      if (!userDoc.exists) {
        console.warn(`User document ${recipientId} not found.`);
        return;
      }

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) {
        console.warn(`No valid FCM token for user ${recipientId}`);
        return;
      }

      console.log(`Sending notification to ${recipientId}, Token: ${fcmToken}`);

      const payload = {
        notification: {
          title: "New Message",
          body: messageText,
          sound: "default",
        },
        data: {
          chatId: chatId,
          senderId: senderId,
        },
      };

      try {
        await admin.messaging().sendToDevice(fcmToken, payload);
        console.log(`Notification sent to ${recipientId}`);
      } catch (error) {
        console.error(`Error sending notification to ${recipientId}:`, error);
      }
    },
);
