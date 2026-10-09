# VHDL Parametric UART Transceiver (TX & RX) on Basys 3 FPGA

**[TR]** Digilent Basys 3 FPGA kartı üzerinde bilgisayar veya harici cihazlarla seri haberleşme (RS-232/USB-UART) sağlayan, FSM tabanlı, parazit filtreli ve parametrik UART Alıcı (RX) ve Verici (TX) tasarımı.  
**[EN]** A robust, parameterizable UART Transceiver (TX & RX) core in VHDL implemented on the Digilent Basys 3 FPGA board for serial communication (RS-232/USB-UART) with PCs and microcontrollers.

---

## Özellikler / Features

| Parametre / Parameter | Değer / Value | Açıklama (TR) | Description (EN) |
| :--- | :--- | :--- | :--- |
| **Target Board** | Digilent Basys 3 |
| **Clock Input** | 100 MHz | Dahili sistem osilatörü | On-board system oscillator |
| **Default Baudrate** | 9600 bps | Generic parametre ile ayarlanabilir | Configurable via generic parameter |
| **RX Oversampling** | Mid-Bit (x1) | Bit ortasından kararlı örnekleme | Mid-bit center sampling for noise margin |
| **Noise Filtering** | False Start Check | 2 Kademeli Senkronizör + Glitch Filtresi | 2-Stage Synchronizer + Glitch Rejection |
| **Hardware I/O** | 8 Switches, 16 LEDs | Switch'lerle TX verisi, LED'lerde RX tamponu | Switches for TX, 16 LEDs for RX history |

---

## Sistem Mimarisi / System Architecture

**[TR]** 
1. **UART Verici (`uart_tx.vhd`):** Buton tetiklemesiyle (`tx_start`) 8 bitlik veriyi (`din_i`) alır; Start biti ('0'), veriler (LSB'den başlayarak) ve Stop bitini ('1') ayarlanan baudrate süresince sırayla hatta iletir.
2. **UART Alıcı (`uart_rx.vhd`):**
   * **Senkronizör:** Dış dünyadan gelen asenkron `rx_i` hattını metastabiliteye karşı 2 saat vuruşu boyunca senkronize eder.
   * **Sahte Start Biti Koruması:** Start bitinin tam ortasında (`c_bittimerlim / 2`) hattı tekrar kontrol eder; parazit/gürültü varsa okumayı iptal edip bekleme durumuna döner.
   * **Veri Örnekleme:** Her veri bitini tam ortasından örnekleyerek kaydırmalı yazmaca (`shreg`) alır ve 1 saat vuruşluk `rx_done_tick_o` bayrağı üretir.
3. **Üst Modül Entegrasyonu (`top.vhd`):**
   * Butondan gelen iletim komutu `debounce` filtresinden geçirilerek tek darbe üretilir.
   * Bilgisayardan gelen her yeni byte alt 8 LED'e yazılırken, bir önceki byte üst 8 LED'e kaydırılır (16-bit FIFO geçmişi).

**[EN]** 
1. **UART Transmitter (`uart_tx.vhd`):** Transmits an 8-bit word upon a debounced pulse. Drives Start bit ('0'), data bits (LSB first), and Stop bits ('1') at the configured baud rate.
2. **UART Receiver (`uart_rx.vhd`):**
   * **Synchronizer:** Resolves metastability on the asynchronous `rx_i` pin using a 2-stage flip-flop chain.
   * **False Start Bit Rejection:** Inspects the line at the middle of the Start bit (`c_bittimerlim / 2`); aborts immediately if a transient glitch is detected.
   * **Mid-Bit Sampling:** Samples each data bit strictly at the center of the bit duration, storing them in a shift register and generating a clean `rx_done_tick_o` pulse.
3. **Top-Level Integration (`top.vhd`):**
   * Transmit trigger pushbutton is debounced and edge-detected.
   * Received bytes are stored and shifted across 16 board LEDs (`LED[15:0]`), forming a two-byte visual history buffer.

---

## Simülasyon Doğrulaması / Simulation Verification

Tasarım Vivado Simulator kullanılarak iki bağımsız birim testiyle doğrulanmıştır:  
*(The transceiver was verified through two modular testbenches in Vivado Simulator):*

---

### 1. UART TX Doğrulaması / Transmitter Verification (`tb_uart_tx.vhd`)
**[TR]** $10\text{ MBaud}$ hızında yapılan simülasyonda; her bitin tam $100\text{ ns}$ sürdüğü, `x"51"` ve `x"A3"` paketlerinin bit sınırları, 2 Stop biti ($200\text{ ns}$) ve iletim bittiğinde üretilen `tx_done_tick_o` darbesi doğrulanmıştır.  
**[EN]** Simulated at $10\text{ MBaud}$ ($100\text{ ns}$ per bit). Verified frame transitions for `x"51"` and `x"A3"`, 2 Stop bits ($200\text{ ns}$ duration), and the single-cycle `tx_done_tick_o` completion pulse.

<img width="2560" height="465" alt="image" src="https://github.com/user-attachments/assets/af2a7044-017a-451a-853f-fee0281d587d" />

---

### 2. UART RX Doğrulaması / Receiver Verification (`tb_uart_rx.vhd`)
**[TR]** $115200\text{ baud}$ hızında testbench tarafından gönderilen `x"43"` ve `x"A5"` paketlerinin tam ortalarından örneklenerek hatasız çözüldüğü ve her paket sonunda `rx_done_tick_o` darbesinin kalktığı doğrulanmıştır.  
**[EN]** Verified at $115200\text{ baud}$. Testbench frames containing `x"43"` and `x"A5"` are accurately sampled at bit centers and asserted via `rx_done_tick_o` with zero framing errors.

<img width="2560" height="469" alt="image" src="https://github.com/user-attachments/assets/01ffda92-044d-40a3-b906-4c8a9e6403db" />

---

## Donanım Doğrulaması (FPGA Demo) / Hardware Verification

**[TR]** Basys 3 kartı USB kablosu ile bilgisayara bağlanmış; Seri Terminal (hterm) üzerinden 9600 baud hızında çift yönlü haberleşme test edilmiştir:
* **Bilgisayardan FPGA'e (RX):** Klavyeden basılan karakterler kart üzerindeki 16 LED üzerinde ikilik tabanda anında görüntülenmiştir.
* **FPGA'den Bilgisayara (TX):** Kart üzerindeki 8 switch ile belirlenen byte değeri butona basıldığında terminal ekranına hatasız yazdırılmıştır.

**[EN]** Implemented on Basys 3 and connected to a PC via USB-UART running at 9600 baud:
* **PC to FPGA (RX):** Keystrokes sent from the serial terminal (hterm) are displayed on the 16 on-board LEDs in binary.
* **FPGA to PC (TX):** Byte values configured on the 8 slide switches are transmitted to the PC terminal upon pressing the trigger button.

[uart.webm](https://github.com/user-attachments/assets/a2d27f3a-b945-4c80-bed7-6d71ef61b789)

---

## Dosya Yapısı / Project Structure

```text
├── constrs_1/
│   └── Basys-3-Master.xdc    # FPGA pin bağlantıları / Constraints file
├── sim_1/
│   ├── tb_uart_tx.vhd        # UART TX birim testi / TX Unit testbench
│   └── tb_uart_rx.vhd        # UART RX birim testi / RX Unit testbench
├── sources_1/
│   ├── uart_tx.vhd           # UART Verici modülü / Transmitter core
│   ├── uart_rx.vhd           # UART Alıcı modülü / Receiver core
│   ├── debounce.vhd          # Buton filtre modülü / Button debouncer
│   └── top.vhd               # Sistem entegrasyonu / Top-level wrapper
└── README.md                 # Proje dokümantasyonu / Project documentation
