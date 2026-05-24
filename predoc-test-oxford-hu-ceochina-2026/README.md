# CEO sentiment and policy exposure of foreign firms in China

Submission for the research assistant screening task at the Said Business School, University of Oxford, Human Algorithm Interaction Lab, March 2026. Maps the strategic stance of senior executives at 28 major foreign firms toward China, and the China related industrial policies that shape risks and opportunities for these firms.

## Context

| Field | Detail |
|-------|--------|
| Institution | Said Business School, University of Oxford |
| Lab | Human Algorithm Interaction Lab |
| PI | Kejia Hu |
| Role | Research Assistant screening task |
| Date completed | March 2026 |
| Tools | Python (pandas, openpyxl, python-docx), Claude (Anthropic) for source discovery and summarisation, web search |

## Task

Paraphrased from the PI brief; the original brief is not redistributed.

Task 1: For 28 firms across four industries (automotive and advanced manufacturing, technology and semiconductors, finance and professional services, healthcare and consumer), identify how the CEO, Chair, or equivalent top executive frames investment in China, risk and uncertainty, supply chains and localisation, and long term positioning versus hedging or retreat. Produce a structured table with one row per executive statement covering firm, executive name and role, source type, date, quote, interpreted stance, and source link.

Task 2: For the same firms, identify policies or regulatory developments that materially affect their China operations across industrial policy, data and cyber regulation, trade and export controls, financial regulation, and localisation requirements. Produce a structured policy mapping table.

Synthesis: a two page memo distilling the headline patterns across firms and policies; and a two page note proposing follow on research questions.

## Approach

* Source priority for Task 1: earnings call transcripts and shareholder letters first, then conference speeches and major interviews; analyst commentary used only for direct quotes from executives.
* Firm tiering by data availability. Tier 1 firms (deepest coverage): Tesla, BMW, Volkswagen, Mercedes Benz, Apple, NVIDIA, Intel, Qualcomm, JPMorgan, HSBC, BlackRock, Nestle. Tier 2: Toyota, Stellantis, Siemens, Microsoft, Goldman Sachs, Citigroup, Pfizer, P&G, SAP, IBM. Tier 3 (limited public CEO commentary): Bosch, PwC, Deloitte, J&J, L'Oreal, Shiseido.
* Stance classification scheme with five labels: optimistic growth, cautious engagement, hedging, de risking, uncertainty management. All labels assigned by manual judgement after reading the underlying source.
* Source priority for Task 2: official government texts first, then law firm briefs, then think tank analyses. Coverage spans Chinese domestic regulation (Data Security Law, PIPL, Anti Espionage Law, NEV policy) and foreign China related policies (CHIPS Act, IRA, US export controls, outbound investment screening).
* AI use: Claude assisted with source discovery, transcript summarisation, and structured extraction into the spreadsheet schema. Stance labelling, policy interpretation, and the synthesis memo are mine.
* Limitations documented in the README and in the synthesis memo. PwC is represented by Global Chairman Bob Moritz, Deloitte by Patrick Tsang of Deloitte China given thin global commentary on China. Some sources sit behind paywalls (Bloomberg, SCMP); URLs are retained for verification.

## Files

| File | Purpose |
|------|---------|
| CEO_Sentiment_Table.xlsx | Task 1 deliverable, 38 executive statements across 28 firms |
| Policy_Mapping_Table.xlsx | Task 2 deliverable, 14 policies affecting the assigned firms |
| Synthesis_Memo.docx | Two page synthesis memo, editable copy |
| Synthesis_Memo.pdf | Two page synthesis memo, compiled |
| Research_Questions.docx | Follow on research questions note, editable copy |
| Research_Questions.pdf | Follow on research questions note, compiled |
| source_documents/ceo_quotes/ | 38 .txt files with the original source text for each statement |
| source_documents/policy_docs/ | 14 .txt files with the original source text for each policy |

## Data and PI materials

The following are not redistributed on GitHub. Available on request from the author:

| File | Description |
|------|-------------|
| `Research Assistant Task - Overseas.pdf` | The PI task brief |

All source materials in `source_documents/` come from public English language texts (earnings calls, shareholder letters, official government policy releases, law firm and think tank analyses). Paywalled sources (e.g., Bloomberg, SCMP) are referenced by URL only; full text from those was not redistributed.

Contact: siddhantpagare2014@gmail.com

## How to reproduce

This is a qualitative research task. There is no analytical pipeline to rerun. To inspect the work:

1. Open `CEO_Sentiment_Table.xlsx` and `Policy_Mapping_Table.xlsx` in Excel or Google Sheets.
2. Read `Synthesis_Memo.pdf` for the headline patterns.
3. Read `Research_Questions.pdf` for proposed follow on questions.
4. Cross check any specific row against the matching file in `source_documents/`.

## Outputs

* CEO sentiment table covering 28 firms and 38 executive statements between 2022 and 2025.
* Policy mapping table covering 14 China related policies between 2015 and 2025.
* Synthesis memo and follow on research questions note.

## Software

Python 3.9 with `pandas`, `openpyxl`, `python-docx`. No analytical code; processing scripts were used to assemble the spreadsheets and Word documents from the extracted source text.

## Author

Siddhant Manav Pagare, siddhantpagare2014@gmail.com
