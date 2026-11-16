# Logic Design Final Project 2026

> **狀態：課程提供的起始專案，尚未完成 RTL 設計。** `alu.v` 和 `top.v` 目前保留原始介面與 `TODO` 標記；此 repository 不代表已通過公開或隱藏測資。

本專案是邏輯設計課程 2026 年期末專案的程式與模擬資料。題目分成兩部分：先設計一個 8-bit ALU，再用 ALU 處理輸入序列，輸出所有運算結果中的第 K 大值。

## 專案內容

| 路徑 | 說明 |
| --- | --- |
| `hdl/part1/alu.v` | Part 1 的 ALU 模組起始模板。 |
| `hdl/part2/top.v` | Part 2 的序列處理與第 K 大值模組起始模板。 |
| `sim/part1/tb1.v` | Part 1 公開測試平台，逐筆檢查 ALU 輸出。 |
| `sim/part1/part1_pattern.dat` | Part 1 公開測資（1,000 筆）。 |
| `sim/part1/part1_sim.f`, `part1_sim.sh` | Part 1 模擬檔案清單與 VCS 執行腳本。 |
| `sim/part2/tb2.v` | Part 2 公開測試平台，測試 `K=1` 到 `K=5`。 |
| `sim/part2/part2_pattern.dat` | Part 2 公開序列與預期答案。 |
| `sim/part2/part2_sim.f`, `part2_sim.sh` | Part 2 模擬檔案清單與 VCS 執行腳本。 |
| `sim/Makefile` | 執行模擬與清理輸出檔的便利目標。 |

## 設計規格摘要

### Part 1：8-bit ALU

模組名稱為 `ALU`，介面如下：

- `A`, `B`：兩個 8-bit 輸入值。
- `instruction`：4-bit 運算選擇碼。
- `F`：8-bit 運算結果。

指令碼對應的運算定義應以課程正式題目為準；本 repository 的起始資料未包含該指令表。請保留模組名稱和 I/O 介面，並完成 `TODO` 區段。

### Part 2：序列運算與第 K 大值

模組名稱為參數化的 `top`，預設 `K=3`。每筆有效輸入包含 `data_A`、`data_B` 和 `instruction`，由 Part 1 的 ALU 計算一個 8-bit 結果。收到 `count` 筆資料後，模組須輸出這些結果中的第 K 大值（unsigned），並以 `finish` 表示結果完成。

主要控制訊號：

- `clk`：時脈。
- `rst_n`：低有效重設。
- `start`：單週期開始訊號；同時提供本次序列的資料筆數 `count`。
- `valid`：本週期輸入資料有效。輸入可以在 `start` 之後的任一週期開始，每次有效一組資料。
- `kth_largest`：第 K 大運算結果。
- `finish`：運算完成旗標。公開 testbench 會檢查其在正緣拉高且只維持一個週期。

一個 test pattern 完成前不可開始下一個；新的 test pattern 只能在初始重設階段或前一個 pattern 完成後開始。請依照正式規格處理重複值、`K` 與 `count` 的邊界情形。

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

Part 1 公開 testbench 使用 1,000 筆 pattern；Part 2 使用 50 組 pattern，並各自建立 `K=1`、`K=2`、`K=3`、`K=4`、`K=5` 的 DUT。成功或錯誤訊息會輸出在模擬 log。Part 2 testbench 也會檢查 `finish` 的時序與單週期行為。

`make clean` 可在 `sim/` 清除常見的 VCS 執行輸出：

```sh
make clean
```

模擬輸出（例如 `.vcd`、`.fsdb`、log、`simv` 與工具產生的目錄）不納入版本控制。

## 實作與提交注意事項

- 保留 `ALU`、`top` 的模組名稱與既有 I/O ports。
- 若開發時新增 submodule，提交前需將設計整合回課程要求的 `alu.v` 和 `top.v`。
- 課程簡報要求 synthesizable RTL 不使用 `initial` block 或延遲敘述（例如 `#5`）；testbench 中的延遲僅供模擬使用。
- 公開測資通過不保證隱藏測資或課程 demo 通過。
- 請遵守課程的學術誠信與提交規範。此 repository 不包含課程簡報/PDF、工作站文件、安裝程式或隱藏測資。

## 來源

起始 RTL、testbench、pattern、檔案清單與腳本取自本機參考資料夾中的 `Logic_Design.zip` 解壓內容；規格摘要依同資料夾提供的期末專案說明簡報整理。正式規格與指令碼定義仍以課程發布的文件為準。
