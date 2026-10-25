# Credit Risk & Loss Forecasting Engine

> **Thesis:** A model is only as good as its ability to survive uncertainty. A prediction without a confidence interval is a guess. This project builds a production-grade credit risk system that predicts default probability, forecasts expected financial loss, and translates those predictions into a capital allocation strategy.

## The Business Question
> *"How much money will we lose next quarter, and what is our risk tolerance?"*

Most credit models stop at predicting binary default. This system goes further: it calculates the **Expected Loss (PD × LGD × EAD)** over a 6-month horizon and provides a **90% confidence interval**. This allows a risk committee to make capital allocation decisions based on worst-case scenarios, not just point estimates.

## The Architecture

This system is built in four distinct layers, each solving a specific failure mode of traditional analytics:

1. **Advanced SQL Feature Pipeline (`/sql`)**
   - **Why:** Traditional models use static features. This pipeline uses recursive CTEs and window functions to calculate rolling 6-month payment behavior and risk deciles.
   - **Failure mode solved:** Prevents data leakage by strictly aligning features to the application date.

2. **Credit Risk Model (`/models`)**
   - **Why:** XGBoost probabilities are often overconfident and uncalibrated. This layer applies **isotonic calibration** to ensure the probabilities are mathematically defensible.
   - **Failure mode solved:** Prevents the business from making decisions based on false confidence.

3. **Forecasting Engine (`/forecasting`)**
   - **Why:** Point estimates are dangerous. This layer uses Holt-Winters exponential smoothing to forecast expected loss, complete with **90% prediction intervals**.
   - **Failure mode solved:** Forces the business to plan for uncertainty, not just the median outcome.

4. **Rust Inference Engine (`/rust-engine`)**
   - **Why:** Python is too slow for real-time decisioning. The core scoring logic is rewritten in Rust to ensure sub-10ms latency.
   - **Failure mode solved:** Prevents the model from becoming a bottleneck in a high-volume lending environment.

## Cost-Sensitive Decisioning
The final threshold is not 0.5. It is derived from a **cost matrix**:
- Cost of a False Negative (Approving a defaulter): $10,000
- Cost of a False Positive (Rejecting a good customer): $1,000

The system calculates the **optimal probability threshold** (currently 45%) that minimizes total expected financial loss. It outputs a recommendation (APPROVE / REJECT), not just a probability.

## How to Run

1. Clone the repository:
```bash
git clone https://github.com/Daniel38215571/credit-risk-forecasting-engine.git
cd credit-risk-forecasting-engine

2. pip install -r requirements.txt

3. python models/credit_risk_model.py

4. python forecasting/expected_loss_forecast.py

5. cd rust-engine
   cargo run
