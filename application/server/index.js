const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
const authRoutes = require("./routes/auth");
const messageRoutes = require("./routes/messages");
const app = express();
const socket = require("socket.io");
require("dotenv").config();

app.use(
  cors({
    origin: process.env.FRONTEND_URL, // frontend vm listen
  })
);
app.use(express.json());

async function connectWithRetry() {
  try {
    await mongoose.connect(process.env.MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000, // ลองรอ 5 วิ แล้วค่อย fail
    });
    console.log("DB Connection Successful");
  } catch (err) {
    console.error("MongoDB connection failed:", err.message);
    const retrySeconds = 5;
    console.log(`Retrying in ${retrySeconds} seconds...`);
    setTimeout(connectWithRetry, retrySeconds * 1000);
  }
}

// เริ่ม connect รอบแรก
connectWithRetry();

// ฟัง event เวลา connection หลุดกลางทาง
mongoose.connection.on("disconnected", () => {
  console.warn("MongoDB disconnected! Trying to reconnect...");
  connectWithRetry();
});

app.get("/ping", (_req, res) => {
  return res.json({
    msg: "Ping Successful",
    status: "success",
    timestamp: Date.now(),
    version: "1.0.0",
  });
});

app.get("/health", (_req, res) => {
  return res.json({
    status: 200,
    msg: "OK",
    timestamp: Date.now(),
    service: "backend",
    version: "1.0.0",
    address: req.ip,
    your_host: req.hostname,
    request_url: req.originalUrl,
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/messages", messageRoutes);

const server = app.listen(process.env.PORT, () =>
  console.log(`Server started on ${process.env.PORT}`)
);
const io = socket(server, {
  cors: {
    origin: process.env.FRONTEND_URL,
    credentials: true,
  },
});

global.onlineUsers = new Map();
io.on("connection", (socket) => {
  global.chatSocket = socket;

  socket.on("add-user", (userId) => {
    onlineUsers.set(userId, socket.id);
  });

  socket.on("send-msg", (data) => {
    const sendUserSocket = onlineUsers.get(data.to);
    if (sendUserSocket) {
      socket.to(sendUserSocket).emit("msg-recieve", {
        from: data.from,
        msg: data.msg,
      });
    }
  });
});
