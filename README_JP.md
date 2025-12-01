# LöveOS: The Bare Metal Simulation

**LöveOS** は、LÖVE (Love2D) エンジン上で動作する、シミュレーションです。単なるUIスキンではなくてカーネル、プリエンプティブ・マルチタスク、仮想メモリ管理、仮想ファイルシステムなど、OSの中核概念を実装してみました～！

![LöveOS Desktop](https://raw.githubusercontent.com/placeholder/screenshot.png)

## 🚀 機能 (Features)

### 🧠 The Singularity Kernel (Bare Metal)
*   **仮想メモリマネージャ (VMM)**: LuaJIT FFI (`uint8_t` 配列) を使用して 64MB の生RAMを管理します。システムメモリに関してはLuaのガベージコレクタをバイパスしてます。
*   **メモリマップドI/O (MMIO)**: 特定のメモリアドレス (`0x04000000` 範囲) への書き込みによるハードウェア制御（ビデオ、オーディオ）を実現。
*   **プリエンプティブ・スケジューラ**: `debug.sethook` を使用してタイムスライスを強制し、無限ループに陥ったアプリをOSが中断・強制終了できるようにします（アンチフリーズ）。
*   **Kernel Panic**: 回復不能なエラーが発生した場合、クラシックな「ブルースクリーン (BSOD)」で安全に停止します。

### 💾 ストレージ & ネットワーク
*   **仮想ディスクシステム**: 単一の `disk.img` バイナリファイル上で動作するブロックベースのファイルシステム (SimpleFS)。
*   **リアル・ネットワーキング**: `luasocket` とスレッドを使用した非同期HTTPスタック。実際のWebサイトからHTMLを取得可能。
*   **仮想ファイルシステム (VFS)**: `disk.img`、ホストのファイル、`/dev` デバイスを統合してマウントする階層構造。

### 🎨 デスクトップ環境
*   **グラスモーフィズム UI**: リアルタイムの背景ぼかしシェーダーを採用。
*   **ウィンドウマネージャ**: ドラッグ＆ドロップ、フォーカス管理、影の描画を備えたコンポジット型WM。
*   **システムアプリ**:
    *   **Terminal**: パイプ処理をサポートするBash風シェル。
    *   **Browser**: 実際のWebブラウジングが可能なHTMLレンダラー。
    *   **Paint**: 仮想ディスクに保存可能なビットマップエディタ。
    *   **Filer**: グラフィカルなファイルエクスプローラー。

## 🛠 インストールと使い方

1.  **必須要件**: [LÖVE 11.x](https://love2d.org/)
2.  **実行**:
    ```bash
    love .
    ```
3.  **ログイン**:
    *   User: `admin`
    *   Pass: `love`

## 💻 技術アーキテクチャ

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

## ⚠️ 警告
このプロジェクトは LuaJIT FFI とデバッグフックを低レイヤーで使用しています。Lua VMの限界に挑戦しているため、予期せぬクラッシュが発生する可能性があります。
**"This is not a game. It's an Operating System."**

---
*Created with ❤️ by Antigravity & User*
