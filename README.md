# SmartPort over SLIP

This project is based on [A2Pico](https://github.com/oliverschmidt/a2pico).

This project is just a blueprint!

## Firmware protocol

* $C0n8 - Data port
* $C0n9 - Status port

1. The request content is written to the data port
2. The request is finalized with a write to the status port
3. The response availability is checked with reads from the status port
4. The response content is read from the data port

### Request

| Size  | Content                  |
|:-----:|--------------------------|
|   1   | ProDOS command number    |
|   1   | ProDOS unit number       |
|   2   | Block number             |
| [512] | Block data (for cmd = 2) |

ProDOS command number:
* 0 - Status
* 1 - Read
* 2 - Write

### Response

| Size  | Content                   |
|:-----:|---------------------------|
|   1   | ProDOS return code        |
|  [2]  | Block count (for cmd = 0) |
| [512] | Block data (for cmd = 1)  |

ProDOS return code:
* $00 - Success
* $27 - I/O error
* $28 - No device connected
* $2B - Write protected
