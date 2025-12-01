# LöveOS: The Bare Metal Simulation

**LöveOS** is a fully functional, experimental Operating System simulation running on top of the LÖVE (Love2D) engine. It is not just a UI skin; it implements core OS concepts including a kernel, preemptive multitasking, virtual memory management, and a virtual file system.

![LöveOS Desktop](https://raw.githubusercontent.com/placeholder/screenshot.png)

## 🚀 Features

### 🧠 The Singularity Kernel (Bare Metal)
*   **Virtual Memory Manager (VMM)**: Manages 64MB of raw RAM using LuaJIT FFI (`uint8_t` array), bypassing Lua's garbage collector for system memory.
*   **Memory Mapped I/O (MMIO)**: Hardware control (Video, Audio) via direct memory address writing (`0x04000000` range).
*   **Preemptive Scheduler**: Uses `debug.sethook` to enforce time slices, allowing the OS to interrupt and kill infinite loops (Anti-Freeze).
*   **Kernel Panic**: Handles unrecoverable errors with a classic Blue Screen of Death (BSOD).

### 💾 Storage & Networking
*   **Virtual Disk System**: A block-based file system (SimpleFS) running on a single `disk.img` binary file.
*   **Real Networking**: Async HTTP stack using `luasocket` and threads, capable of fetching real-world HTML.
*   **Virtual File System (VFS)**: Unified hierarchy mounting `disk.img`, host files, and `/dev` devices.

### 🎨 Desktop Environment
*   **Glassmorphism UI**: Real-time background blurring shaders.
*   **Window Manager**: Compositing WM with drag-and-drop, focus management, and shadows.
*   **System Apps**:
    *   **Terminal**: Bash-like shell with pipe support.
    *   **Browser**: HTML renderer for real web browsing.
    *   **Paint**: Bitmap editor saving to virtual disk.
    *   **Filer**: Graphical file explorer.

## 🛠 Installation & Usage

1.  **Requirements**: [LÖVE 11.x](https://love2d.org/)
2.  **Run**:
    ```bash
    love .
    ```
3.  **Login**:
    *   User: `admin`
    *   Pass: `love`

## 💻 Technical Architecture

```mermaid
graph TD
    Hardware[Love2D Engine] --> Boot[Bootloader]
    Boot --> Kernel
    
    subgraph Kernel Space
        Kernel --> VMM[Virtual Memory (FFI)]
        Kernel --> Scheduler[Preemptive Scheduler]
        Kernel --> VFS[Virtual File System]
        Kernel --> Syscall[Syscall Interface]
    end
    
    subgraph User Space (Sandboxed)
        Syscall --> App1[Terminal]
        Syscall --> App2[Browser]
        Syscall --> App3[Virus (Test)]
    end
```

## ⚠️ Warning
This project uses low-level LuaJIT FFI and debug hooks. It pushes the Lua VM to its limits.
**"This is not a game. It's an Operating System."**

---
*Created with ❤️ by Antigravity & User*
