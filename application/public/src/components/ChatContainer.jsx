import React, { useEffect, useRef, useState } from "react";
import styled from "styled-components";
import { v4 as uuidv4 } from "uuid";
import axios from "axios";
import { IoArrowBack } from "react-icons/io5";

import ChatInput from "./ChatInput";
import Logout from "./Logout";
import { sendMessageRoute, recieveMessageRoute } from "../utils/APIRoutes";

export default function ChatContainer({ currentChat, socket, onBack, onRead }) {
  const [messages, setMessages] = useState([]);
  const [arrivalMessage, setArrivalMessage] = useState(null);
  const scrollRef = useRef();

  // โหลดข้อความเก่า
  useEffect(() => {
    (async () => {
      const data = JSON.parse(
        localStorage.getItem(process.env.REACT_APP_LOCALHOST_KEY)
      );
      const response = await axios.post(recieveMessageRoute, {
        from: data._id,
        to: currentChat._id,
      });
      setMessages(response.data || []);
      // เข้าห้องนี้แล้วถือว่าอ่าน -> เคลียร์ badge
      if (typeof onRead === "function") onRead();
    })();
  }, [currentChat, onRead]);

  // ฟังข้อความเข้าแบบ realtime
  useEffect(() => {
    if (!socket.current) return;
    const handler = (msg) =>
      setArrivalMessage({ fromSelf: false, message: msg.msg || msg });
    socket.current.on("msg-recieve", handler);
    return () => socket.current.off("msg-recieve", handler);
  }, [socket]);

  useEffect(() => {
    if (arrivalMessage) setMessages((prev) => [...prev, arrivalMessage]);
  }, [arrivalMessage]);

  useEffect(() => {
    scrollRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSendMsg = async (msg) => {
    const data = JSON.parse(
      localStorage.getItem(process.env.REACT_APP_LOCALHOST_KEY)
    );
    // ส่งผ่าน socket
    socket.current.emit("send-msg", {
      to: currentChat._id,
      from: data._id,
      msg,
    });
    // บันทึกลง DB
    await axios.post(sendMessageRoute, {
      from: data._id,
      to: currentChat._id,
      message: msg,
    });
    // อัปเดต UI
    setMessages((prev) => [...prev, { fromSelf: true, message: msg }]);
  };

  return (
    <Container>
      <div className="chat-header">
        <div className="user-details">
          {onBack && (
            <button className="back-btn" onClick={onBack} aria-label="Go back">
              <IoArrowBack />
            </button>
          )}
          <div className="avatar">
            <img
              src={`data:image/svg+xml;base64,${currentChat.avatarImage}`}
              alt={currentChat.username}
            />
          </div>
          <div className="username">
            <h3>{currentChat.username}</h3>
          </div>
        </div>
      </div>

      <div className="chat-messages">
        {messages.map((message, idx) => (
          <div
            ref={idx === messages.length - 1 ? scrollRef : null}
            key={uuidv4()}
          >
            <div
              className={`message ${message.fromSelf ? "sended" : "recieved"}`}
            >
              <div className="content">
                <p>{message.message}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="chat-input">
        <ChatInput handleSendMsg={handleSendMsg} />
      </div>
    </Container>
  );
}

/* ===== styles ===== */

const Container = styled.div`
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  padding-bottom: calc(
    0.5rem + env(safe-area-inset-bottom)
  ); /* กันชิดขอบล่างบนมือถือ */

  .chat-header {
    flex: 0 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.85rem 1rem; /* เพิ่ม breathing space */
    .user-details {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      .back-btn {
        display: none;
        border: none;
        background: transparent;
        cursor: pointer;
        svg {
          font-size: 1.6rem;
          color: #fff;
        }
      }
      .avatar img {
        height: 3rem;
        border-radius: 50%;
      }
      .username h3 {
        color: #fff;
        font-weight: 600;
      }
    }
  }

  @media (max-width: 720px) {
    .chat-header {
      padding: 1rem 1rem;
      .user-details .back-btn {
        display: inline-flex;
      }
    }
  }

  .chat-messages {
    flex: 1 1 auto;
    min-height: 0; /* สำคัญ เพื่อให้ overflow ทำงานใน flex */
    overflow-y: auto;
    padding: 1.2rem 1rem 1.2rem; /* เว้นระยะบน-ล่าง-ข้าง */
    display: flex;
    flex-direction: column;
    gap: 0.75rem;

    &::-webkit-scrollbar {
      width: 0.2rem;
      &-thumb {
        background-color: #ffffff39;
        border-radius: 1rem;
      }
    }

    .message {
      display: flex;
      align-items: center;
      .content {
        max-width: 75%;
        overflow-wrap: break-word;
        padding: 0.85rem 1rem;
        font-size: 1.05rem;
        border-radius: 1rem;
        color: #d1d1d1;
      }
    }
    .sended {
      justify-content: flex-end;
      .content {
        background: #4f04ff21;
      }
    }
    .recieved {
      justify-content: flex-start;
      .content {
        background: #9900ff20;
      }
    }

    @media (max-width: 720px) {
      .message .content {
        max-width: 85%;
      }
    }
  }

  .chat-input {
    flex: 0 0 auto;
    padding: 0.6rem 0.75rem;
    padding-bottom: calc(
      0.9rem + env(safe-area-inset-bottom)
    ); /* กันชิดล่าง + รองรับ notch */
    background-color: #080420;
  }
`;
