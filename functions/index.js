/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendMessageNotification = onDocumentCreated(
    "chats/{chatId}/messages/{messageId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;

      const messageData = snap.data();
      const chatId = event.params.chatId;
      const senderId = messageData.sender_id;
      const messageText = messageData.message;

      // Retrieve the chat document to get participants
      const chatDoc = await admin.firestore()
          .collection("chats").doc(chatId).get();
      if (!chatDoc.exists) return;

      const chatData = chatDoc.data();
      const participants = chatData.participants || [];

      // Exclude sender
      const recipientIds = participants.filter((id) => id !== senderId);

      // Send notifications
      for (const recipientId of recipientIds) {
        const userDoc = await admin.firestore()
            .collection("users").doc(recipientId).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          const fcmToken = userData.fcmToken;
          if (fcmToken) {
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
              console.error("Error sending notification:", error);
            }
          }
        }
      }
    });
