import React, { useState } from "react";
import styled from "styled-components";
import Logout from "./Logout";
import Logo from "../assets/logo.svg"; // เปลี่ยนตามโปรเจกต์คุณ

export default function Contacts({
  contacts = [],
  changeChat,
  currentChat,
  unreadSenders, // Set ของ userId ที่มีข้อความใหม่
  currentUser,
}) {
  const [currentSelected, setCurrentSelected] = useState(undefined);

  const changeCurrentChat = (index, contact) => {
    setCurrentSelected(index);
    changeChat(contact);
  };

  return (
    <Container>
      {/* แถบบน: แบรนด์ซ้าย + Logout ขวา (sticky) */}
      <div className="topbar">
        <div className="brand">
          <img src={Logo} alt="logo" />
          <h3>SNAPPY</h3>
        </div>
        <div className="logout">
          <Logout />
        </div>
      </div>

      {/* รายชื่อเพื่อน (เลื่อนเองได้) */}
      <div className="contacts">
        {contacts.map((contact, index) => {
          const isActive = currentChat?._id === contact._id;
          const showDot = unreadSenders?.has?.(contact._id) && !isActive; // แสดงเฉพาะมีข้อความใหม่ และยังไม่ใช่ห้องที่เปิดอยู่
          return (
            <div
              className={`contact ${isActive ? "selected" : ""}`}
              key={contact._id}
              onClick={() => changeCurrentChat(index, contact)}
            >
              <div className="avatar-wrap">
                <img
                  src={`data:image/svg+xml;base64,${contact.avatarImage}`}
                  alt={contact.username}
                />
                {showDot && <span className="unread-dot" />}
              </div>
              <div className="username">
                <h3>{contact.username}</h3>
              </div>
            </div>
          );
        })}
      </div>

      {/* ผู้ใช้ปัจจุบัน (อยู่ล่างสุด) */}
      {currentUser && (
        <div className="current-user">
          <div className="avatar">
            <img
              src={`data:image/svg+xml;base64,${currentUser.avatarImage}`}
              alt={currentUser.username}
            />
          </div>
          <div className="username">
            <h2>{currentUser.username}</h2>
          </div>
        </div>
      )}
    </Container>
  );
}

/* ===== styles ===== */

const Container = styled.div`
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
  background-color: #080420;
  overflow: hidden;

  .topbar {
    position: sticky;
    top: 0;
    z-index: 2;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: calc(0.5rem + env(safe-area-inset-top)) 0.75rem 0.5rem;
    background-color: #080420;
    border-bottom: 1px solid #0b0b25;
  }
  .brand {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    img {
      height: 2rem;
    }
    h3 {
      color: #fff;
      text-transform: uppercase;
    }
  }
  .logout {
    display: flex;
    align-items: center;
  }

  .contacts {
    flex: 1 1 auto;
    min-height: 0;
    overflow: auto;
    padding: 0.5rem 0.75rem 0.75rem;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.8rem;

    &::-webkit-scrollbar {
      width: 0.2rem;
      &-thumb {
        background-color: #ffffff39;
        border-radius: 1rem;
      }
    }

    .contact {
      background-color: #ffffff34;
      min-height: 5rem;
      cursor: pointer;
      width: 92%;
      border-radius: 0.5rem;
      padding: 0.55rem 0.8rem;
      display: flex;
      gap: 1rem;
      align-items: center;
      transition: 0.2s ease;

      .username h3 {
        color: #fff;
        font-weight: 600;
      }
    }
    .contact:hover {
      transform: translateY(-1px);
    }
    .selected {
      background-color: #9a86f3;
    }

    .avatar-wrap {
      position: relative;
      width: 3rem;
      height: 3rem;
      display: inline-flex;
      align-items: center;
      justify-content: center;
    }
    .avatar-wrap img {
      height: 3rem;
      width: 3rem;
      border-radius: 50%;
    }
    .unread-dot {
      position: absolute;
      top: -0.2rem;
      right: -0.2rem;
      width: 0.9rem;
      height: 0.9rem;
      border-radius: 50%;
      background: #ff3b30;
      box-shadow: 0 0 0 2px #080420;
    }
  }

  .current-user {
    position: sticky;
    bottom: 0;
    z-index: 1;
    background-color: #0d0d30;
    border-top: 1px solid #0b0b25;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.9rem;
    padding: 0.75rem 0.75rem;
    .avatar img {
      height: 3.6rem;
      border-radius: 50%;
    }
    .username h2 {
      color: #fff;
      font-size: 1.15rem;
      font-weight: 700;
    }
  }

  @media (max-width: 720px) {
    .contacts .contact {
      width: 94%;
    }
  }
`;
