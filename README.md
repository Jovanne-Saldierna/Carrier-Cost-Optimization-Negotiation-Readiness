# Shipping Cost Intelligence System

A consulting-style analytics case study modeling how a growth-stage retailer with **$1.6M in annual shipping spend** could consolidate fragmented carrier data into a single decision-support system — unlocking **$293,482 in identified savings opportunities (18.6% cost reduction)**.

---

## Live Tableau Dashboard

**[View Interactive Dashboard on Tableau Public →](https://public.tableau.com/app/profile/jovanne.saldierna/viz/ShippingCostIntelligenceSystem/ShippingCostIntelligence)**

Three fully interactive dashboards with live scenario modeling, fuel sensitivity analysis, and carrier optimization engine.

---

## Key Findings

- **UPS and FedEx control 68.4% of total spend** ($1.08M combined) but cost 30% more per lb than USPS — the highest-leverage renegotiation targets in the network
- **99.8% of all shipments are subject to dimensional weight penalties** — carriers bill an average of 2.5x actual package weight, creating a $922,860 annual excess billing impact across parcel shipments
- **Zone 6 costs 65% more per lb than Zone 2** ($6.94 vs $4.21) — geographic lane concentration is the single largest structural cost driver
- **$293,482 in validated savings** identified under proposed carrier rates across 4,995 matched shipments — savings rates are consistent at 18–20% across all top lanes, signaling a systemic rate gap rather than isolated inefficiencies
- **Ground service accounts for 46.8% of total spend** ($740K) — the highest-leverage service level for negotiation

---

## Dashboard Architecture

### Dashboard 1 — Shipping Cost Intelligence
*Operational monitoring & carrier benchmarking*

- KPI cards: Annual Spend, Cost Per Shipment, Cost Per Billed Lb, Dim Weight Penalty Rate
- Monthly spend trend with MoM % change (red/green bar overlay)
- Carrier spend distribution bar chart
- Carrier efficiency scatter: Cost Per Lb vs. Shipment Volume (bubble size = total spend)
- Interactive filters: Carrier, Zone, Weight Class
- Action filter: click any carrier to cross-filter all charts

### Dashboard 2 — Shipping Cost Drivers
*Root cause analysis across cost components, zones, and weight*

- Full cost composition stacked bar: Base Cost + Fuel Surcharge + all surcharge types by carrier
- Dimensional weight penalty chart: Billed vs. Actual package weight — 2.5x overbilling gap visualized
- Zone cost heatmap: Carrier × Zone colored by Cost Per Lb
- Fuel surcharge sensitivity model: parameter-driven dual-line chart modeling cost impact of fuel increases up to 50%
- Interactive fuel slider: drag to see projected cost impact in real time

### Dashboard 3 — Carrier Optimization Engine
*Decision support & scenario modeling*

- Dynamic scenario toggle: switch between Current Rates ($1.58M), Proposed Rates ($1.28M), and Savings ($293K)
- Top 10 highest-value optimization lanes ranked by savings opportunity
- Best Carrier Per Lane matrix: green = cheapest carrier per lane — a direct procurement decision guide
- Carrier optimization detail table: lane-level breakdown of current cost, projected cost, savings %, and shipment count — sorted by highest opportunity, color-coded by savings intensity

---

## Dataset

| File | Description | Rows |
|---|---|---|
| `shipments_enriched.csv` | Primary analytical dataset — 5,000 shipments with pre-computed proposed rate lookups, dimensional weight calculations, and row-level savings | 5,000 |
| `carriers.csv` | Carrier master data | 4 |
| `rate_cards.csv` | Current contracted rate bands by carrier, service level, zone, and weight band | 448 |
| `proposed_rates.csv` | Proposed negotiated rate bands for scenario modeling | 448 |

The `shipments_enriched.csv` file includes all original shipment fields plus pre-computed analytical columns: `dimensional_weight_lb`, `billed_above_actual_flag`, `cost_per_billed_lb`, `weight_delta_lb`, `base_rate_per_lb`, `proposed_rate_per_lb`, `proposed_cost`, `row_potential_savings`, `savings_pct`, and `lane`.

---

## SQL Models

Seven-layer SQL modeling pipeline built for a reporting-ready analytics layer:

| Model | Purpose |
|---|---|
| `01_stg_shipments.sql` | Staging layer — type casting, dimensional weight calculation, billed-above-actual flag, cost-per-lb derivation |
| `02_shipping_cost_metrics.sql` | Monthly aggregations — spend, shipment count, cost per shipment, cost per lb, MoM change via LAG window function |
| `03_surcharge_analysis.sql` | Surcharge burden by carrier/service/zone — surcharge % of total cost, RANK() by surcharge burden |
| `04_carrier_performance.sql` | Carrier benchmarking — cost efficiency, transit time, dimensional weight rate, DENSE_RANK() by cost efficiency |
| `05_lane_cost_analysis.sql` | Origin-destination lane analysis — cost per lb by lane, RANK() within lane partitions to identify cheapest carrier per route |
| `06_rate_change_scenario_model.sql` | Proposed rate scenario modeling — row-level join of shipments to rate bands with weight-band range matching, projected savings calculation |
| `07_executive_summary.sql` | Executive rollup — monthly KPIs, MoM % change, surcharge % of cost, supplemental CTEs for top carriers and highest-burden lanes |

---

## Technical Approach

**Rate Band Join Logic**

The rate scenario model required a non-equi join to match each shipment to exactly one rate band:

```sql
INNER JOIN rate_cards AS rc
    ON s.carrier_id = rc.carrier_id
    AND s.service_level = rc.service_level
    AND s.destination_zone = rc.zone
    AND s.billed_weight_lb >= rc.min_weight_lb
    AND s.billed_weight_lb < rc.max_weight_lb
```

Join integrity was validated in Python prior to Tableau connection — confirming 4,995 of 5,000 shipments matched exactly one rate band (99.9% match rate), with 5 shipments excluded due to missing rate coverage.

**Dimensional Weight Calculation**

```sql
ROUND(
    package_length_in * package_width_in * package_height_in / 139.0,
    2
) AS dimensional_weight_lb
```

The 139.0 divisor is the standard domestic dimensional weight factor used by UPS, FedEx, and USPS for ground shipments.

**Savings Validation**

Total proposed savings of $293,482 represents 18.6% of $1,579,836 total spend — validated at the row level before aggregation to prevent join multiplication errors.

---

## Skills Demonstrated

`Window Functions` · `CTEs` · `Non-Equi Joins` · `LOD Expressions` · `Table Calculations` · `Parameter Actions` · `Scenario Modeling` · `Carrier Rate Analysis` · `Dimensional Weight Analysis` · `Executive Dashboard Design` · `Action Filters` · `Data Validation`

---

## Interview Summary

> *"I built a three-dashboard decision support system for a $1.6M shipping network across four carriers. The operational dashboard identified that UPS and FedEx control 68% of spend but cost 30% more per pound than USPS. The cost drivers dashboard uncovered that 99.8% of shipments are subject to dimensional weight penalties — with carriers billing 2.5x actual package weight, creating a $922K annual excess billing impact. The optimization engine modeled proposed carrier rates across 5,000 shipments and identified $293,000 in achievable savings — an 18.6% reduction — with consistent 18–20% savings rates across all top lanes signaling a systemic rate gap. Every number in the dashboard is validated against the raw data."*

---

*Built with SQL · Tableau · Python*
