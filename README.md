# Classical Channel

## Overview
The classical channel facilitates message exchange between the post-processing modules and the network central controller using `dataTX_msg` and `dataRX_msg` signals. Messages are encapsulated into Ethernet frames by the **FrameGenerator** module and transmitted via the `gmii_txd` interface to the 1 G PHY. Conversely, the **FrameSniffer** module extracts messages from received frames and forwards them to the post-processing module.

The 1 G PHY, built using the AMD LogiCORE™ IP 1G/2.5G Ethernet PCS/PMA or SGMII core, manages data transmission and reception through the `txn`, `txp`, `rxn`, and `rxp` interfaces of the FPGA's gigabit transceiver (GT). An SFP module converts electronic signals to optical signals for transmission over 1 G fiber and vice versa, ensuring robust communication.

Message access rates target **600 Mbps**, as per [Stanco et al.](#), with the packet transmission rate adhering to the AMD LogiCORE™ IP specifications. To ensure reliable communication, TCP with a payload limit of **1460 bytes** [Kurose et al.](#) avoids segmentation by routers. In this implementation, a packet size of **1036 bytes** minimizes hardware overhead and supports future flexibility. Acknowledgment packets are used to simplify packet loss management.

| Specification             | Value        |
|---------------------------|--------------|
| Message Access Rate       | > 600 Mbps  |
| Packet Transmission Rate  | 1 Gbps       |

![圖片](https://github.com/user-attachments/assets/d43a12ab-8c2f-40aa-a3fd-e1ed0637728a)


---

## networkCentCtrl
The **networkCentCtrl** module manages the classical channel, enabling TCP-based communication between post-processing modules. Key components include:

- **FrameGenerator**: Handles message encapsulation, checksum calculation, and data transmission.
- **FrameSniffer**: Validates received frames, extracts TCP payloads, and confirms data integrity.

### Key Features
- **TCP Handshake and Acknowledgment**: Ensures reliable communication with minimal data loss. The module transitions through handshake states to establish stable data transfer and confirms message receipt with acknowledgment packets.
- **Timeout Protocol**: Monitors transmission time, initiating retransmissions if acknowledgment signals are not received within a predefined window.

This robust architecture ensures efficient and secure message transfer in the QKD system while leveraging FPGA-based components for precise control and data handling.

---

## FrameGenerator
The **FrameGenerator** module prepares and transmits Ethernet frames. Functions include:

- Computing checksums (IP header and TCP segment).
- Appending protocol headers.
- Transmitting frames via PHY and converting signals for optical communication using an SFP module.
- Ensuring data integrity with Frame Check Sequence (FCS) validation.

---

## FrameSniffer
The **FrameSniffer** module processes incoming Ethernet frames:

- Validates headers, addresses, and checksums.
- Computes FCS for data integrity.
- Extracts TCP payloads and stores them for post-processing.
- Raises signals to confirm valid packet reception.

---

### I/O Descriptions
#### Receiving Path
| Signal Name         | Direction | Description                                   |
|---------------------|-----------|-----------------------------------------------|
| `msg_accessed`      | Out       | Indicates the current message batch is stored.|
| `busy_PP2Net_RX`    | In        | Indicates post-processing module access to BRAMMsgRX. |
| `busy_Net2PP_RX`    | Out       | Indicates FrameSniffer access to BRAMMsgRX.   |
| `addrRX_msg[10:0]`  | Out       | Address used to store dataRX_msg.            |
| `clkRX_msg`         | Out       | Clock for accessing BRAMMsgRX.               |
| `sizeRX_msg[10:0]`  | Out       | Size of the received message (257, 514, 771, 1028). |
| `dataRX_msg[31:0]`  | Out       | Received message prepared for BRAMMsgRX.     |
| `gmii_rx_clk`       | In        | Clock for `gmii_rxd` synchronization.        |

#### Transmitting Path
| Signal Name         | Direction | Description                                   |
|---------------------|-----------|-----------------------------------------------|
| `msg_stored`        | In        | Indicates the current message batch is stored.|
| `busy_PP2Net_TX`    | In        | Indicates post-processing module access to BRAMMsgTX. |
| `busy_Net2PP_TX`    | Out       | Indicates FrameGenerator access to BRAMMsgTX. |
| `addrTX_msg[10:0]`  | Out       | Address used to access dataTX_msg.           |
| `clkTX_msg`         | Out       | Clock for accessing BRAMMsgTX.               |
| `sizeTX_msg[10:0]`  | In        | Size of the transferred message (257, 514, 771, 1028). |
| `gmii_tx_clk`       | In        | Clock for `gmii_txd` synchronization.        |
