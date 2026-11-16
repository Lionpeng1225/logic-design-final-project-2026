# Logic Design Final Project 2026

這是邏輯設計課程 2026 年期末專案，包含兩個 RTL 模組與課程提供的公開模擬資料：Part 1 實作 8-bit ALU；Part 2 逐筆計算 ALU 結果，並輸出結果序列中的第 K 大值。

> **目前狀態：已加入學生撰寫的 RTL，尚未在此環境執行課程 VCS 測試。** 公開測資或隱藏測資是否通過尚未確認。指令定義與邊界條件仍應以課程正式規格為準。

## 專案內容

| 路徑 | 說明 |
| --- | --- |
| `hdl/part1/alu.v` | Part 1：組合邏輯 ALU。 |
| `hdl/part2/top.v` | Part 2：ALU 串接與前五大結果追蹤。 |
| `sim/part1/tb1.v` | Part 1 公開測試平台，逐筆檢查 ALU 輸出。 |
| `sim/part1/part1_pattern.dat` | Part 1 公開測資（1,000 筆）。 |
| `sim/part1/part1_sim.f`, `part1_sim.sh` | Part 1 模擬檔案清單與 VCS 執行腳本。 |
| `sim/part2/tb2.v` | Part 2 公開測試平台，測試 `K=1` 到 `K=5`。 |
| `sim/part2/part2_pattern.dat` | Part 2 公開序列與預期答案。 |
| `sim/part2/part2_sim.f`, `part2_sim.sh` | Part 2 模擬檔案清單與 VCS 執行腳本。 |
| `sim/Makefile` | 執行模擬與清理輸出檔的便利目標。 |

## Part 1：ALU

`ALU` 接收 8-bit `A`、`B` 和 4-bit `instruction`，輸出 8-bit `F`。目前實作的指令如下：

| `instruction` | 運算 | 說明 |
| --- | --- | --- |
| `0000` | Right Rotate | 依程式中的 `A >> B` 與 `A << (8-B)` 組合結果。 |
| `0001` | Left Rotate | 依程式中的 `A << B` 與 `A >> (8-B)` 組合結果。 |
| `0010` | Population Count | 計算 `A` 中為 1 的位元數。 |
| `0011` | Absolute Difference | 輸出 `A` 與 `B` 的絕對差。 |
| `0100` | Leading Zero Count | 從 `A[7]` 開始計算最高位起連續的 0；`A=0` 時結果為 8。 |
| `0101` | Saturated Add | 計算 `A+B`；超過 255 時輸出 255。 |
| `0110` | ResetTailk | 令 `k=popcount(B)`，將 `A` 最低的 `k` 個位元清為 0。 |
| `0111` | SetTailk | 令 `k=popcount(B)`，將 `A` 最低的 `k` 個位元設為 1。 |
| `1000` | XOR | 輸出 `A ^ B`。 |
| `1001` | ADD | 8-bit 加法，結果只保留低 8 位。 |
| `1010` | SUB | 8-bit 減法，結果只保留低 8 位。 |
| `1011`–`1111` | 預設 | 輸出 0。 |

**旋轉位移量注意事項：**目前程式直接以 `B` 與 `8-B` 計算移位，沒有先把 `B` 對 8 取餘數。對 `B>8` 時，這段公式不保證符合標準 8-bit rotate。若課程規格要求位移量取 `B mod 8`，需再確認並處理該情況。

## Part 2：串流 ALU 與第 K 大值

`top` 保留課程定義的介面，參數預設為 `K=3`。每次 `valid` 有效時，`data_A`、`data_B` 和 `instruction` 送入內部 `ALU`，得到一個 8-bit 結果。模組以五個暫存器維持目前最大的五個結果（由大到小）；每筆新結果透過組合邏輯與這五個值比較，插入正確位置並將較小值往後移。收到 `count` 筆資料後，依 `K` 選出第 K 大值並拉高 `finish`。

### 控制訊號與時序

- `clk`：上升緣觸發的時脈。
- `rst_n`：低有效同步重設；在時脈上升緣取樣。
- `start`：開始新一組序列並鎖存 `count`，同時清除已追蹤的五個最大值與輸入筆數。`start` 優先於 `valid`。
- `valid`：本週期輸入的一組資料有效。操作流程預期先送出 `start` 再送資料；目前 RTL 沒有額外狀態旗標阻止 `start` 前的 `valid` 更新計數與排名。
- `kth_largest`：收到最後一筆有效資料時更新為第 K 大結果。
- `finish`：最後一筆輸入被接收的上升緣拉高，下一個上升緣預設清為 0。

目前實作明確選取 `K=1` 至 `K=5`；其他 `K` 輸出 0。每組開始時排名暫存器清為 0，因此當輸入筆數不足 `K` 時，尚未填入的位置會是 0。`count=0` 時目前沒有資料進入完成分支，`finish` 不會因此拉高。課程測試平台涵蓋的 K 值為 1 至 5；其他邊界情況請對照正式規格確認。

## 模擬方式

模擬腳本使用 Synopsys VCS，請在已安裝並設定好 VCS 的環境執行。先進入 `sim/`：

```sh
cd sim
make sim1
make sim2
```

也可以在 `sim/` 直接執行對應腳本：

```sh
bash ./part1/part1_sim.sh
bash ./part2/part2_sim.sh
```

Part 1 公開 testbench 使用 1,000 筆 pattern；Part 2 使用 50 組 pattern，並分別建立 `K=1`、`K=2`、`K=3`、`K=4`、`K=5` 的 DUT。Part 2 testbench 也會檢查 `finish` 是否在正緣拉高並維持一個週期。

`make clean` 可在 `sim/` 清除常見的模擬輸出：

```sh
make clean
```

模擬輸出（例如 `.vcd`、`.fsdb`、log、`simv` 與工具產生的目錄）不納入版本控制。

## 實作與提交注意事項

- 保留 `ALU`、`top` 的模組名稱與原有 I/O ports。
- 課程簡報要求 synthesizable RTL 不使用 `initial` block 或延遲敘述（例如 `#5`）；目前兩個設計模組未使用這些語法。Testbench 的延遲只供模擬使用。
- 公開測資通過不保證隱藏測資或課程 demo 通過。
- 請遵守課程的學術誠信與提交規範。本 repository 不包含課程簡報/PDF、工作站文件、安裝程式或隱藏測資。

## 來源

`hdl/`、`sim/` 的起始 RTL 介面、testbench、公開 pattern、檔案清單與腳本來自本機參考資料夾中的 `Logic_Design.zip` 解壓內容。`alu.v` 與 `top.v` 已更新為使用者提供的 RTL；README 的設計說明依目前程式內容整理。正式規格與指令邊界定義仍以課程發布文件為準。
