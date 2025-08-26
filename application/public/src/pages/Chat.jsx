import React, { useEffect, useRef, useState } from "react";
import styled from "styled-components";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { io } from "socket.io-client";

import { allUsersRoute, host } from "../utils/APIRoutes";
import Contacts from "../components/Contacts";
import ChatContainer from "../components/ChatContainer";
import Welcome from "../components/Welcome";

export default function Chat() {
  const navigate = useNavigate();
  const socket = useRef(null);

  const [currentUser, setCurrentUser] = useState(undefined);
  const [contacts, setContacts] = useState([]);
  const [currentChat, setCurrentChat] = useState(undefined);

  // 🔴 เก็บชุด userId ที่ "มีข้อความใหม่เข้ามา" (ยังไม่ได้เข้าไปอ่าน)
  const [unreadSenders, setUnreadSenders] = useState(() => new Set());

  // 🔎 ตรวจจับโหมดมือถือ
  const [isMobile, setIsMobile] = useState(() => window.innerWidth <= 720);
  useEffect(() => {
    const onResize = () => setIsMobile(window.innerWidth <= 720);
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);

  // โหลด currentUser
  useEffect(() => {
    (async () => {
      const local = localStorage.getItem(process.env.REACT_APP_LOCALHOST_KEY);
      if (!local) {
        navigate("/login");
        return;
      }
      setCurrentUser(JSON.parse(local));
    })();
  }, [navigate]);

  // ตั้ง socket และฟังข้อความเข้า -> ติด badge
  useEffect(() => {
    if (!currentUser) return;

    socket.current = io(host);
    socket.current.emit("add-user", currentUser._id);

    const onReceive = (payload) => {
      const senderId = payload?.from;
      if (!senderId) return;
      // ถ้ากำลังคุยกับห้องนั้นอยู่ -> ไม่ถือว่า unread
      if (currentChat?._id === senderId) return;

      setUnreadSenders((prev) => {
        const next = new Set(prev);
        next.add(senderId);
        return next;
      });
    };

    socket.current.on("msg-recieve", onReceive);
    return () => {
      socket.current?.off("msg-recieve", onReceive);
      socket.current?.disconnect();
    };
  }, [currentUser, currentChat]);

  // โหลดรายชื่อเพื่อน
  useEffect(() => {
    (async () => {
      if (!currentUser) return;
      if (!currentUser.isAvatarImageSet) {
        navigate("/setAvatar");
        return;
      }
      const res = await axios.get(`${allUsersRoute}/${currentUser._id}`);
      setContacts(res.data);
    })();
  }, [currentUser, navigate]);

  // เมื่อผู้ใช้กดเข้าแชทกับใคร -> เคลียร์ badge ของคนนั้น
  const clearUnreadFor = (userId) => {
    setUnreadSenders((prev) => {
      const next = new Set(prev);
      next.delete(userId);
      return next;
    });
  };

  const handleChatChange = (chat) => {
    setCurrentChat(chat);
    if (chat?._id) clearUnreadFor(chat._id);
  };

  // มือถือ: สลับเต็มจอระหว่าง Contacts <-> Chat
  if (isMobile) {
    return (
      <MobileContainer>
        {!currentChat ? (
          <div className="screen">
            <Contacts
              contacts={contacts}
              changeChat={handleChatChange}
              currentChat={currentChat}
              unreadSenders={unreadSenders}
              currentUser={currentUser}
            />
          </div>
        ) : (
          <div className="screen">
            <ChatContainer
              currentChat={currentChat}
              socket={socket}
              onBack={() => setCurrentChat(undefined)}
              onRead={() => clearUnreadFor(currentChat?._id)}
            />
          </div>
        )}
      </MobileContainer>
    );
  }

  // เดสก์ท็อป: 2 คอลัมน์เหมือนเดิม
  return (
    <DesktopContainer>
      <div className="container">
        <Contacts
          contacts={contacts}
          changeChat={handleChatChange}
          currentChat={currentChat}
          unreadSenders={unreadSenders}
          currentUser={currentUser}
        />
        {currentChat ? (
          <ChatContainer
            currentChat={currentChat}
            socket={socket}
            onRead={() => clearUnreadFor(currentChat?._id)}
          />
        ) : (
          <Welcome />
        )}
      </div>
    </DesktopContainer>
  );
}

/* ===== styles ===== */

const MobileContainer = styled.div`
  height: 100vh;
  width: 100vw;
  background-color: #131324;
  .screen {
    height: 100%;
    width: 100%;
    display: flex;
    flex-direction: column; /* ให้ลูก (Contacts/Chat) ยืดเต็มสูง */
    background-color: #00000076;
  }
`;

const DesktopContainer = styled.div`
  height: 100vh;
  width: 100vw;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 1rem;
  align-items: center;
  background-color: #131324;

  .container {
    height: 85vh;
    width: 85vw;
    background-color: #00000076;
    display: grid;
    grid-template-columns: 25% 75%;
  }

  @media screen and (min-width: 720px) and (max-width: 1080px) {
    .container {
      grid-template-columns: 35% 65%;
    }
  }
`;
